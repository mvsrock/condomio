package it.atlantica.config;

import it.atlantica.event.DynamicRebindDoneEvent;
import it.atlantica.properties.DynamicYamlProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.YamlPropertiesFactoryBean;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.ConfigurationPropertiesBean;
import org.springframework.boot.context.properties.bind.Bindable;
import org.springframework.boot.context.properties.bind.Binder;
import org.springframework.boot.logging.LogLevel;
import org.springframework.boot.logging.LoggingSystem;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;
import org.springframework.core.env.MutablePropertySources;
import org.springframework.core.env.StandardEnvironment;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;

/**
 * Ordine di precedenza:
 *   dynamicPropsExternal (ESTERNI) > ENV / -D > dynamicPropsInternal (INTERNI)
 */
@Configuration
@Slf4j
@ConditionalOnProperty(name = "app.properties.enabled", havingValue = "true", matchIfMissing = false)
public class DynamicYamlLoading {

    private static final String DYNAMIC_PS_EXTERNAL = "dynamicPropsExternal";
    private static final String DYNAMIC_PS_INTERNAL = "dynamicPropsInternal";

    private final DynamicYamlProperties props;

    public DynamicYamlLoading(DynamicYamlProperties appProps) {
        this.props = appProps;
    }

    @Bean(destroyMethod = "shutdownNow")
    ExecutorService yamlReloaderExecutor() {
        return Executors.newSingleThreadExecutor(r -> {
            Thread t = new Thread(r, "yaml-reloader-diff");
            t.setDaemon(true);
            return t;
        });
    }

    @Autowired
    private ApplicationEventPublisher publisher;
    @Autowired
    private LoggingSystem loggingSystem;

    @Bean
    public ApplicationRunner reloadWholeYaml(ConfigurableEnvironment env,
                                             ApplicationContext ctx,
                                             ExecutorService yamlReloaderExecutor,
                                             ValueRefresher valueRefresher) {
        return args -> {
            MutablePropertySources sources = env.getPropertySources();

            // --- due MapPropertySource separati per controllare la precedenza
            Map<String, Object> backingExternal = new LinkedHashMap<>();
            Map<String, Object> backingInternal = new LinkedHashMap<>();
            MapPropertySource dynExternal = new MapPropertySource(DYNAMIC_PS_EXTERNAL, backingExternal);
            MapPropertySource dynInternal = new MapPropertySource(DYNAMIC_PS_INTERNAL, backingInternal);

            // 1) Esterni PRIMA di tutto (vincono su ENV e -D)
            if (!sources.contains(DYNAMIC_PS_EXTERNAL)) {
                sources.addFirst(dynExternal);
            }

            // 2) Interni DOPO ENV/-D (così ENV vince sugli interni)
            if (!sources.contains(DYNAMIC_PS_INTERNAL)) {
                if (sources.contains(StandardEnvironment.SYSTEM_ENVIRONMENT_PROPERTY_SOURCE_NAME)) {
                    sources.addAfter(StandardEnvironment.SYSTEM_ENVIRONMENT_PROPERTY_SOURCE_NAME, dynInternal);
                } else if (sources.contains(StandardEnvironment.SYSTEM_PROPERTIES_PROPERTY_SOURCE_NAME)) {
                    sources.addAfter(StandardEnvironment.SYSTEM_PROPERTIES_PROPERTY_SOURCE_NAME, dynInternal);
                } else {
                    sources.addLast(dynInternal); // fallback
                }
            }

            // --- Risoluzione iniziale risorse
            ResolvedResources rr = resolveAllResourcesRecursively(env);
            List<Resource> internalRes = rr.internals();
            List<Resource> externalRes = rr.externalsInOrder();

            // --- Watch list iniziale
            Map<Path, String> watchedFiles = new LinkedHashMap<>();
            List<Resource> allForWatch = new ArrayList<>();
            allForWatch.addAll(internalRes);
            allForWatch.addAll(externalRes);
            for (Resource r : allForWatch) {
                if (r instanceof FileSystemResource fsr) {
                    Path p = fsr.getFile().toPath().toAbsolutePath().normalize();
                    watchedFiles.put(p, p.getFileName().toString());
                }
            }

            // --- Caricamento iniziale SEPARATO
            Map<String, Object> internalMap = new LinkedHashMap<>();
            for (Resource r : internalRes) internalMap.putAll(loadOneResourceAsFlatMap(r));
            Map<String, Object> externalMap = new LinkedHashMap<>();
            for (Resource r : externalRes) externalMap.putAll(loadOneResourceAsFlatMap(r));

            log.debug("[dynamic] loaded {} entries from INTERNALs, {} from EXTERNALs",
                    internalMap.size(), externalMap.size());

            Map<String, Object> internalFiltered = filterOutConfigImport(internalMap);
            Map<String, Object> externalFiltered = filterOutConfigImport(externalMap);

            backingInternal.clear();
            backingInternal.putAll(internalFiltered);
            backingExternal.clear();
            backingExternal.putAll(externalFiltered);

            // Applica log level anche al boot (unione: esterni vincono)
            Map<String, Object> unionAtBoot = new LinkedHashMap<>();
            unionAtBoot.putAll(internalFiltered);
            unionAtBoot.putAll(externalFiltered); // esterni vincono
            applyLogLevels(unionAtBoot);

            // *** REBIND INIZIALE ***
            // Rebind completo dei @ConfigurationProperties al boot (così gli esterni sovrascrivono subito)
            Binder binder = Binder.get(env);
            Map<String, Object> cpBeans = ConfigurationPropertiesBean.getAll(ctx).values().stream()
                    .collect(Collectors.toMap(
                            cpb -> cpb.getAnnotation().prefix(),
                            cpb -> ctx.getBean(cpb.getName())
                    ));
            for (Map.Entry<String, Object> e : cpBeans.entrySet()) {
                String beanPrefix = e.getKey();
                try {
                    binder.bind(beanPrefix, Bindable.ofInstance(e.getValue()));
                } catch (Exception ex) {
                    log.warn("[dynamic] initial bind skip @{} prefix={} : {}",
                            e.getValue().getClass().getSimpleName(), beanPrefix, ex.getMessage());
                }
            }

            // Refresh @Value + evento al boot
            Set<String> initialKeys = new LinkedHashSet<>();
            initialKeys.addAll(internalFiltered.keySet());
            initialKeys.addAll(externalFiltered.keySet());
            try { valueRefresher.refreshValues(initialKeys); } catch (Exception ignore) {}
            publisher.publishEvent(new DynamicRebindDoneEvent(this, initialKeys));

            // snapshot separati per il diff nel watcher
            AtomicReference<Map<String, Object>> lastInternalSnapshot =
                    new AtomicReference<>(new LinkedHashMap<>(internalFiltered));
            AtomicReference<Map<String, Object>> lastExternalSnapshot =
                    new AtomicReference<>(new LinkedHashMap<>(externalFiltered));

            AtomicReference<Map<String, Object>> prefixToBean = new AtomicReference<>(cpBeans);

            // --- Watcher
            WatchService ws = FileSystems.getDefault().newWatchService();
            Map<Path, String> watchedFilesSet = new LinkedHashMap<>(watchedFiles);
            Map<Path, WatchKey> keyByDir = new HashMap<>();
            Map<Path, Integer> dirRefCount = new HashMap<>();

            Runnable registerInitialDirs = () -> {
                Set<Path> uniqueDirs = new LinkedHashSet<>();
                watchedFilesSet.keySet().forEach(f -> { if (f.getParent()!=null) uniqueDirs.add(f.getParent()); });
                for (Path dir : uniqueDirs) {
                    try {
                        WatchKey key = keyByDir.get(dir);
                        if (key == null) {
                            key = dir.register(ws,
                                    StandardWatchEventKinds.ENTRY_MODIFY,
                                    StandardWatchEventKinds.ENTRY_CREATE,
                                    StandardWatchEventKinds.ENTRY_DELETE);
                            keyByDir.put(dir, key);
                            log.debug("[dynamic] watching dir: {}", dir);
                        }
                        int cnt = 0;
                        for (Path f : watchedFilesSet.keySet()) if (dir.equals(f.getParent())) cnt++;
                        dirRefCount.put(dir, cnt);
                    } catch (IOException e) {
                        log.warn("[dynamic] cannot watch dir {}: {}", dir, e.toString());
                    }
                }
            };
            registerInitialDirs.run();

            final long DEBOUNCE_MS = 100L;
            final long[] lastReloadMs = {0L};

            yamlReloaderExecutor.submit(() -> {
                try {
                    while (true) {
                        if (!props.getProperties().isEnabled()) return;

                        WatchKey key = ws.take();
                        Path dir = null;
                        for (Map.Entry<Path, WatchKey> e : keyByDir.entrySet()) {
                            if (e.getValue() == key) { dir = e.getKey(); break; }
                        }
                        boolean shouldReload = false;

                        for (WatchEvent<?> ev : key.pollEvents()) {
                            if (dir == null) continue;
                            Object ctxObj = ev.context();
                            if (ctxObj instanceof Path c) {
                                Path changed = dir.resolve(c).toAbsolutePath().normalize();
                                if (watchedFilesSet.containsKey(changed)) {
                                    shouldReload = true;
                                    log.debug("[dynamic] detected {} on {}", ev.kind().name(), changed);
                                }
                            }
                        }

                        if (shouldReload) {
                            long now = System.currentTimeMillis();
                            if (now - lastReloadMs[0] >= DEBOUNCE_MS) {
                                lastReloadMs[0] = now;
                                try {
                                    // Ricalcola risorse
                                    ResolvedResources rr2 = resolveAllResourcesRecursively(env);
                                    List<Resource> internalRes2 = rr2.internals();
                                    List<Resource> externalRes2 = rr2.externalsInOrder();

                                    Map<String, Object> freshInternal = new LinkedHashMap<>();
                                    for (Resource r : internalRes2) freshInternal.putAll(loadOneResourceAsFlatMap(r));
                                    Map<String, Object> freshExternal = new LinkedHashMap<>();
                                    for (Resource r : externalRes2) freshExternal.putAll(loadOneResourceAsFlatMap(r));

                                    log.debug("[dynamic] reloaded {} entries from INTERNALs, {} from EXTERNALs",
                                            freshInternal.size(), freshExternal.size());

                                    Map<String, Object> freshInternalFiltered = filterOutConfigImport(freshInternal);
                                    Map<String, Object> freshExternalFiltered = filterOutConfigImport(freshExternal);

                                    Map<String, Object> prevInt = lastInternalSnapshot.get();
                                    Map<String, Object> prevExt = lastExternalSnapshot.get();

                                    Diff dInt = diff(prevInt, freshInternalFiltered);
                                    Diff dExt = diff(prevExt, freshExternalFiltered);

                                    boolean changedSomething = false;

                                    if (!dInt.isEmpty()) {
                                        @SuppressWarnings("unchecked")
                                        Map<String, Object> mapInt = (Map<String, Object>) Objects.requireNonNull(dynInternal).getSource();
                                        dInt.removed.forEach(mapInt::remove);
                                        mapInt.putAll(dInt.changedOrAdded);
                                        applyLogLevels(dInt.changedOrAdded);
                                        lastInternalSnapshot.set(freshInternalFiltered);
                                        changedSomething = true;
                                    }

                                    if (!dExt.isEmpty()) {
                                        @SuppressWarnings("unchecked")
                                        Map<String, Object> mapExt = (Map<String, Object>) Objects.requireNonNull(dynExternal).getSource();
                                        dExt.removed.forEach(mapExt::remove);
                                        mapExt.putAll(dExt.changedOrAdded);
                                        applyLogLevels(dExt.changedOrAdded);
                                        lastExternalSnapshot.set(freshExternalFiltered);
                                        changedSomething = true;
                                    }

                                    if (changedSomething) {
                                        Set<String> changedKeys = new LinkedHashSet<>();
                                        changedKeys.addAll(dInt.allKeys());
                                        changedKeys.addAll(dExt.allKeys());

                                        // Rebind @ConfigurationProperties solo per i prefix impattati
                                        Binder binder2 = Binder.get(env);
                                        prefixToBean.set(ConfigurationPropertiesBean.getAll(ctx).values().stream()
                                                .collect(Collectors.toMap(
                                                        cpb -> cpb.getAnnotation().prefix(),
                                                        cpb -> ctx.getBean(cpb.getName())
                                                )));
                                        for (Map.Entry<String, Object> e2 : prefixToBean.get().entrySet()) {
                                            String beanPrefix = e2.getKey();
                                            boolean hit = changedKeys.stream().anyMatch(k ->
                                                    k.equals(beanPrefix) || k.startsWith(beanPrefix + "."));
                                            if (hit) {
                                                try {
                                                    binder2.bind(beanPrefix, Bindable.ofInstance(e2.getValue()));
                                                    log.debug("[dynamic] rebound @{} prefix={}",
                                                            e2.getValue().getClass().getSimpleName(), beanPrefix);
                                                } catch (Exception ex) {
                                                    log.warn("[dynamic] skip @{} prefix={} : {}",
                                                            e2.getValue().getClass().getSimpleName(), beanPrefix, ex.getMessage());
                                                }
                                            }
                                        }

                                        try { valueRefresher.refreshValues(changedKeys); } catch (Exception ignore) {}

                                        // evento di notifica
                                        publisher.publishEvent(new DynamicRebindDoneEvent(this, changedKeys));
                                    }

                                    // Aggiorna dinamicamente la watchlist (add/remove)
                                    Map<Path, String> newWatched = new LinkedHashMap<>();
                                    List<Resource> allRes2 = new ArrayList<>();
                                    allRes2.addAll(internalRes2);
                                    allRes2.addAll(externalRes2);
                                    for (Resource r : allRes2) {
                                        if (r instanceof FileSystemResource fsr) {
                                            Path p = fsr.getFile().toPath().toAbsolutePath().normalize();
                                            newWatched.put(p, p.getFileName().toString());
                                        }
                                    }

                                    Set<Path> oldPaths = new LinkedHashSet<>(watchedFilesSet.keySet());
                                    Set<Path> newPaths = new LinkedHashSet<>(newWatched.keySet());
                                    Set<Path> toRemove = new LinkedHashSet<>(oldPaths); toRemove.removeAll(newPaths);
                                    Set<Path> toAdd = new LinkedHashSet<>(newPaths);   toAdd.removeAll(oldPaths);

                                    // unwatch
                                    for (Path p : toRemove) {
                                        watchedFilesSet.remove(p);
                                        Path parentDir = p.getParent();
                                        if (parentDir != null) {
                                            int cnt = dirRefCount.getOrDefault(parentDir, 0) - 1;
                                            if (cnt <= 0) {
                                                WatchKey k2 = keyByDir.remove(parentDir);
                                                if (k2 != null) { k2.cancel(); log.debug("[dynamic] unwatch dir: {} (no files remaining)", parentDir); }
                                                dirRefCount.remove(parentDir);
                                            } else {
                                                dirRefCount.put(parentDir, cnt);
                                            }
                                        }
                                        log.debug("[dynamic] unwatch file: {}", p);
                                    }

                                    // watch
                                    for (Path p : toAdd) {
                                        watchedFilesSet.put(p, p.getFileName().toString());
                                        Path parentDir = p.getParent();
                                        if (parentDir != null) {
                                            if (!keyByDir.containsKey(parentDir)) {
                                                try {
                                                    WatchKey k2 = parentDir.register(ws,
                                                            StandardWatchEventKinds.ENTRY_MODIFY,
                                                            StandardWatchEventKinds.ENTRY_CREATE,
                                                            StandardWatchEventKinds.ENTRY_DELETE);
                                                    keyByDir.put(parentDir, k2);
                                                    dirRefCount.put(parentDir, 1);
                                                    log.debug("[dynamic] watching new dir: {}", parentDir);
                                                } catch (IOException e) {
                                                    log.warn("[dynamic] cannot watch dir {}: {}", parentDir, e.toString());
                                                }
                                            } else {
                                                dirRefCount.put(parentDir, dirRefCount.getOrDefault(parentDir, 0) + 1);
                                            }
                                        }
                                        log.debug("[dynamic] watch new file: {}", p);
                                    }

                                } catch (Exception ex) {
                                    log.error("[dynamic] error during reload", ex);
                                }
                            }
                        }
                        key.reset();
                    }
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                } catch (Throwable t) {
                    log.error("[dynamic] watcher error", t);
                } finally {
                    try { ws.close(); } catch (IOException ignored) {}
                }
            });
        };
    }

    // --- DTO immutabili ---
    private record ResolvedResources(List<Resource> internals, List<Resource> externalsInOrder) { }
    private record ImportTask(String location, Resource parent) { }

    // --- Risoluzione ricorsiva import + discovery dinamica root YAML ---
    private static ResolvedResources resolveAllResourcesRecursively(ConfigurableEnvironment env) {
        // 1) tutti i file *.yml/*.yaml nel root (dev/jar)
        List<Resource> internals = resolveRootYamlResources();

        // 2) importa: SOLO ENV/CLI e import definiti in ciascun interno (parent corretto)
        List<String> envImports = readImportsFromEnv(env);
        log.debug("[dynamic] top-level imports (sys/env only): {}", envImports);

        List<Resource> externalsInOrder = new ArrayList<>();
        Set<String> seenKeys = new LinkedHashSet<>();
        internals.forEach(r -> seenKeys.add(resourceKey(r)));

        // Usare una CODA per preservare l'ordine dichiarato (non uno stack!)
        Deque<ImportTask> queue = new ArrayDeque<>();

        // ENV: parent = null -> in ORDINE di dichiarazione
        for (String loc : envImports) {
            if (loc != null && !loc.isBlank()) queue.addLast(new ImportTask(loc.trim(), null));
        }
        // per ogni interno aggiungi i suoi import con parent = quell'interno (in ORDINE di file)
        for (Resource r : internals) {
            List<String> imps = extractImportsFromResource(r);
            for (String loc : imps) {
                if (loc != null && !loc.isBlank()) queue.addLast(new ImportTask(loc.trim(), r));
            }
        }

        // 3) risoluzione ricorsiva in FIFO (mantiene l'ordine di discovery)
        while (!queue.isEmpty()) {
            ImportTask task = queue.pollFirst();   // <--- FIFO
            Resource parent = task.parent();
            String loc = stripOptional(task.location());

            Optional<Resource> resolved = resolveImportLocation(loc, parent);
            if (resolved.isEmpty()) continue;
            Resource res = resolved.get();

            String key = resourceKey(res);
            if (seenKeys.add(key)) {
                externalsInOrder.add(res);

                // importa eventuali nested import in ORDINE
                List<String> nested = extractImportsFromResource(res);
                for (String n : nested) {
                    if (n != null && !n.isBlank()) queue.addLast(new ImportTask(n.trim(), res));
                }
            }
        }

        if (!externalsInOrder.isEmpty()) {
            log.debug("[dynamic] resolved externals (declaration order, last wins): {}",
                    externalsInOrder.stream().map(DynamicYamlLoading::resourceKey).toList());
        }
        return new ResolvedResources(internals, externalsInOrder);
    }

    private static List<Path> devResourcesDirsFromClasspath() {
        List<Path> out = new ArrayList<>();
        String cp = System.getProperty("java.class.path", "");
        for (String entry : cp.split(java.io.File.pathSeparator)) {
            Path p = Paths.get(entry).toAbsolutePath().normalize();
            String norm = p.toString().replace('\\','/');
            if (Files.isDirectory(p) && norm.endsWith("/target/classes")) {
                Path res = p.getParent().getParent().resolve("src/main/resources")
                        .toAbsolutePath().normalize();
                if (Files.isDirectory(res)) out.add(res);
            }
        }
        return out.stream().distinct().toList();
    }

    private static List<Resource> resolveRootYamlResources() {
        List<Resource> out = new ArrayList<>();

        List<Path> devResDirs = devResourcesDirsFromClasspath();
        if (!devResDirs.isEmpty()) {
            try {
                for (Path dir : devResDirs) {
                    try (java.util.stream.Stream<Path> s = Files.list(dir)) {
                        s.filter(Files::isRegularFile)
                                .filter(p -> {
                                    String n = p.getFileName().toString().toLowerCase(Locale.ROOT);
                                    return n.endsWith(".yml") || n.endsWith(".yaml");
                                })
                                .sorted(Comparator.comparing(p -> p.getFileName().toString().toLowerCase(Locale.ROOT)))
                                .forEach(p -> out.add(new FileSystemResource(p.toFile())));
                    }
                }
            } catch (IOException ignore) {}
            if (!out.isEmpty()) {
                out.forEach(r -> log.info("[dynamic] internal yaml (dev) registered: {}", resourceKey(r)));
                return out;
            }
        }

        org.springframework.core.io.support.PathMatchingResourcePatternResolver resolver =
                new org.springframework.core.io.support.PathMatchingResourcePatternResolver();
        Set<String> seen = new LinkedHashSet<>();
        try {
            for (Resource r : resolver.getResources("classpath*:*.yml")) {
                if (r.exists() && seen.add(resourceKey(r))) out.add(r);
            }
            for (Resource r : resolver.getResources("classpath*:*.yaml")) {
                if (r.exists() && seen.add(resourceKey(r))) out.add(r);
            }
        } catch (IOException ignore) {}

        out.sort(Comparator.comparing(r -> filenameOf(r).toLowerCase(Locale.ROOT)));
        if (out.isEmpty()) {
            Resource fallback = new ClassPathResource("application.yml");
            log.info("[dynamic] internal yaml registered as classpath resource (not watchable in JAR): {}", resourceKey(fallback));
            out.add(fallback);
        } else {
            out.forEach(r -> log.info("[dynamic] internal yaml (classpath) registered: {}", resourceKey(r)));
        }
        return out;
    }

    private static String filenameOf(Resource r) {
        try {
            if (r instanceof FileSystemResource fs) {
                return fs.getFile().getName();
            }
            String desc = r.getFilename();
            if (desc != null) return desc;
            String key = resourceKey(r);
            int slash = key.lastIndexOf('/');
            return (slash >= 0 && slash < key.length()-1) ? key.substring(slash+1) : key;
        } catch (Exception e) {
            return String.valueOf(r);
        }
    }

    private static List<String> readImportsFromEnv(ConfigurableEnvironment env) {
        List<String> list = new ArrayList<>();

        String fromSysProp = System.getProperty("spring.config.import");
        if (fromSysProp != null && !fromSysProp.isBlank()) {
            for (String s : fromSysProp.split(",")) {
                String t = s.trim();
                if (!t.isBlank()) list.add(t);
            }
        }

        String fromEnv = System.getenv("SPRING_CONFIG_IMPORT");
        if (fromEnv != null && !fromEnv.isBlank()) {
            for (String s : fromEnv.split(",")) {
                String t = s.trim();
                if (!t.isBlank()) list.add(t);
            }
        }

        return list;
    }

    private static List<String> extractImportsFromResource(Resource r) {
        Map<String, Object> flat = loadOneResourceAsFlatMap(r);
        List<String> out = new ArrayList<>();

        Object scalar = flat.get("spring.config.import");
        if (scalar instanceof String s && !s.isBlank()) {
            for (String part : s.split(",")) {
                String t = part.trim();
                if (!t.isBlank()) out.add(t);
            }
        }
        for (Map.Entry<String, Object> e : flat.entrySet()) {
            String k = e.getKey();
            if (k.startsWith("spring.config.import[") && e.getValue() instanceof String s && !s.isBlank()) {
                out.add(s.trim());
            }
        }
        if (!out.isEmpty()) {
            log.debug("[dynamic] found {} import(s) in {}", out.size(), resourceKey(r));
        }
        return out;
    }

    private static Optional<Resource> resolveImportLocation(String loc, Resource parent) {
        if (loc.startsWith("classpath:")) {
            String cp = loc.substring("classpath:".length());
            ClassPathResource r = new ClassPathResource(cp.startsWith("/") ? cp.substring(1) : cp);
            if (!r.exists()) {
                log.debug("[dynamic] classpath resource not found (skipped): {}", loc);
                return Optional.empty();
            }
            try {
                if (r.isFile()) {
                    Path cpFile = r.getFile().toPath().toAbsolutePath().normalize();
                    for (Path resDir : devResourcesDirsFromClasspath()) {
                        Path targetClasses = resDir.getParent().resolve("target/classes").toAbsolutePath().normalize();
                        String cpStr = cpFile.toString().replace('\\','/');
                        String base = targetClasses.toString().replace('\\','/');
                        if (cpStr.startsWith(base + "/")) {
                            String rel = cpStr.substring((base + "/").length());
                            Path srcPath = resDir.resolve(rel).normalize();
                            if (Files.exists(srcPath)) {
                                return Optional.of(new FileSystemResource(srcPath.toFile()));
                            }
                        }
                    }
                    return Optional.of(new FileSystemResource(cpFile.toFile()));
                }
            } catch (IOException ignore) {}
            return Optional.of(r);
        }
        if (loc.startsWith("file:")) {
            Optional<Path> p = toPathFromFileLocationRelativeToParent(loc, parent);
            if (p.isPresent()) {
                Path abs = p.get().toAbsolutePath().normalize();
                if (Files.exists(abs)) return Optional.of(new FileSystemResource(abs.toFile()));
                log.debug("[dynamic] file resource not found (skipped): {}", abs);
            }
            return Optional.empty();
        }
        log.warn("[dynamic] unsupported import scheme (only file:, classpath:): {}", loc);
        return Optional.empty();
    }

    private static String stripOptional(String loc) {
        return loc.startsWith("optional:") ? loc.substring("optional:".length()) : loc;
    }

    private static String resourceKey(Resource r) {
        try {
            if (r instanceof FileSystemResource fs) {
                return "file:" + fs.getFile().toPath().toAbsolutePath().normalize();
            }
            if (r instanceof ClassPathResource cp) {
                return "classpath:" + (cp.getPath() == null ? "application.yml" : cp.getPath());
            }
        } catch (Exception ignore) {}
        return r.getDescription();
    }

    private static Optional<Path> toPathFromFileLocationRelativeToParent(String location, Resource parent) {
        Optional<Path> p = toPathFromFileLocation(location);
        if (p.isEmpty()) return Optional.empty();
        Path raw = p.get();
        if (raw.isAbsolute()) return Optional.of(raw);
        try {
            if (parent instanceof FileSystemResource fsr) {
                Path base = fsr.getFile().toPath().toAbsolutePath().normalize().getParent();
                if (base != null) return Optional.of(base.resolve(raw));
            }
        } catch (Exception ignore) {}
        return Optional.of(raw);
    }

    private static Optional<Path> toPathFromFileLocation(String location) {
        String loc = stripOptional(location);
        if (!loc.startsWith("file:")) return Optional.empty();

        try {
            java.net.URI uri = java.net.URI.create(loc);
            if ("file".equalsIgnoreCase(uri.getScheme()) && uri.isAbsolute() && !uri.isOpaque()) {
                return Optional.of(Paths.get(uri));
            }
        } catch (Exception ignore) {}

        String after = loc.substring("file:".length()).replace('\\', '/');

        if (after.startsWith("//") && !after.matches("^/{2,3}[A-Za-z]:/.*")) {
            return Optional.of(Paths.get(after));
        }
        if (after.matches("^/{2,3}[A-Za-z]:/.*")) {
            String win = after.replaceFirst("^/{2,3}", "");
            return Optional.of(Paths.get(win));
        }
        if (after.matches("^[A-Za-z]:/.*")) {
            return Optional.of(Paths.get(after));
        }
        if (after.startsWith("/")) {
            return Optional.of(Paths.get(after));
        }
        return Optional.of(Paths.get(after));
    }

    /**
     * Carica una risorsa .yml/.yaml/.properties in una mappa "piatta".
     * - YAML: usa YamlPropertiesFactoryBean
     * - .properties: usa Properties#load con UTF-8 (cambiare se usate ISO-8859-1)
     */
    private static Map<String, Object> loadOneResourceAsFlatMap(Resource r) {
        String name = filenameOf(r).toLowerCase(Locale.ROOT);
        Properties props = new Properties();

        try {
            if (name.endsWith(".yml") || name.endsWith(".yaml")) {
                YamlPropertiesFactoryBean ypf = new YamlPropertiesFactoryBean();
                ypf.setResources(r);
                Properties p = ypf.getObject();
                if (p != null) props.putAll(p);
            } else if (name.endsWith(".properties")) {
                try (Reader reader = new InputStreamReader(r.getInputStream(), java.nio.charset.StandardCharsets.UTF_8)) {
                    props.load(reader);
                }
            } else {
                log.warn("[dynamic] estensione non riconosciuta per {}: provo YAML come fallback", resourceKey(r));
                YamlPropertiesFactoryBean ypf = new YamlPropertiesFactoryBean();
                ypf.setResources(r);
                Properties p = ypf.getObject();
                if (p != null) props.putAll(p);
            }
        } catch (IOException ex) {
            log.warn("[dynamic] impossibile leggere risorsa {}: {}", resourceKey(r), ex.toString());
        }

        Map<String, Object> map = new LinkedHashMap<>();
        props.forEach((k, v) -> map.put(String.valueOf(k), v));
        return map;
    }

    private static final class Diff {
        final Map<String, Object> changedOrAdded;
        final Set<String> removed;
        Diff(Map<String, Object> c, Set<String> rset) { this.changedOrAdded = c; this.removed = rset; }
        boolean isEmpty() { return changedOrAdded.isEmpty() && removed.isEmpty(); }
        Set<String> allKeys() {
            Set<String> s = new LinkedHashSet<>(changedOrAdded.keySet());
            s.addAll(removed);
            return s;
        }
    }

    private Diff diff(Map<String, Object> oldMap, Map<String, Object> newMap) {
        Map<String, Object> changed = new LinkedHashMap<>();
        Set<String> removed = new LinkedHashSet<>();

        for (Map.Entry<String, Object> e : newMap.entrySet()) {
            String k = e.getKey();
            Object oldVal = oldMap.get(k);
            if (!Objects.equals(oldVal, e.getValue())) {
                changed.put(k, e.getValue());
            }
        }
        for (String k : oldMap.keySet()) {
            if (!newMap.containsKey(k)) {
                removed.add(k);
            }
        }
        return new Diff(changed, removed);
    }

    private static Map<String, Object> filterOutConfigImport(Map<String, Object> in) {
        Map<String, Object> out = new LinkedHashMap<>();
        in.forEach((k,v) -> {
            if (!"spring.config.import".equals(k) && !k.startsWith("spring.config.import[")) {
                out.put(k, v);
            }
        });
        return out;
    }

    private void applyLogLevels(Map<String, Object> changedOrAdded) {
        for (Map.Entry<String, Object> e : changedOrAdded.entrySet()) {
            String key = e.getKey();
            if (key.startsWith("logging.level.")) {
                String logger = key.substring("logging.level.".length());
                if ("root".equalsIgnoreCase(logger)) logger = "ROOT";
                Object val = e.getValue();
                if (val != null) {
                    try {
                        LogLevel level = LogLevel.valueOf(String.valueOf(val).trim().toUpperCase(Locale.ROOT));
                        loggingSystem.setLogLevel(logger, level);
                        log.info("[dynamic] log level aggiornato: {}={}", logger, level);
                    } catch (IllegalArgumentException ex) {
                        log.warn("[dynamic] livello log non valido per {}: {}", logger, val);
                    }
                }
            }
        }
    }
}
