package it.atlantica.config;


import it.atlantica.dto.CacheRuntimeSettings;
import it.atlantica.event.DynamicRebindDoneEvent;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.CachingConfigurer;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.interceptor.KeyGenerator;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.cache.RedisCacheWriter;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.JacksonJsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.json.JsonMapper;
import tools.jackson.datatype.jsr310.JavaTimeModule;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Duration;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Configuration
@EnableCaching
@Slf4j
@RequiredArgsConstructor
public class CacheConfig implements CachingConfigurer {

    private final SwitchableCacheManager switchable;
    private final CacheRuntimeSettings settings;
    private final RedisConnectionFactory connectionFactory;

    // ----------  KEY GENERATOR GLOBALE (immutato) ----------
    @Bean
    @Override
    public KeyGenerator keyGenerator() {
        ObjectMapper mapper = JsonMapper.builder()
                .addModule(new JavaTimeModule())
                .build();

        return (target, method, params) -> {
            List<Object> norm = new ArrayList<>(params.length);
            for (Object p : params) norm.add(normalizeArg(p));

            String json;
            try { json = mapper.writeValueAsString(norm); }
            catch (JacksonException e) {
                json = Arrays.toString(norm.toArray());
            }
            return shortSha256(json);
        };
    }

    private static Object normalizeArg(Object p) {
        if (p == null) return null;
        if (p instanceof Pageable pageable) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("page", pageable.getPageNumber());
            m.put("size", pageable.getPageSize());
            m.put("sort", normalizeSort(pageable.getSort()));
            return m;
        }
        if (p instanceof Sort sort) return normalizeSort(sort);
        return p;
    }

    private static List<Map<String, Object>> normalizeSort(Sort sort) {
        List<Map<String, Object>> orders = new ArrayList<>();
        for (Sort.Order o : sort) {
            Map<String, Object> om = new LinkedHashMap<>();
            om.put("property", o.getProperty());
            om.put("direction", o.getDirection().name());
            om.put("ignoreCase", o.isIgnoreCase());
            om.put("nullHandling", o.getNullHandling().name());
            orders.add(om);
        }
        return orders;
    }

    private static String shortSha256(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] d = md.digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 12; i++) sb.append(String.format("%02x", d[i]));
            return sb.toString();
        } catch (Exception e) {
            return Integer.toHexString(Objects.hashCode(s));
        }
    }

    // ----------  Bootstrap iniziale ----------
    @PostConstruct
    void init() {
        apply("bootstrap");
    }

    // ----------  Builder dei due target ----------
    private CacheManager buildRedis(Duration defaultTtl) {
        var keySer = new StringRedisSerializer();
        var valSer = new JacksonJsonRedisSerializer<>(Object.class);

        RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
                .computePrefixWith(name -> "app:" + sanitize(name) + "::")
                .entryTtl(defaultTtl)
                .disableCachingNullValues()
                .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(keySer))
                .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(valSer));

        return new ConventionTtlRedisCacheManager(
                RedisCacheWriter.nonLockingRedisCacheWriter(connectionFactory),
                defaultConfig
        );
    }

    private static String sanitize(String name) {
        return name.replaceAll("[^a-zA-Z0-9:_-]", "_");
    }

    // ----------  Applica lo switch in base ai settings correnti ----------
    void apply(String reason) {
        if (settings.isEnabled()) {
            CacheManager redis = buildRedis(settings.getDefaultTtl());
            switchable.switchTo(redis);
            log.debug("Redis attivo (switch runtime) — reason={}, ttl={}", reason, settings.getDefaultTtl());
        } else {
            switchable.switchTo(new org.springframework.cache.support.NoOpCacheManager());
            log.debug("Redis disabilitato (switch runtime) — reason={}", reason);
        }
    }

    // ----------  Listener: chiamalo dopo il tuo rebind ----------
    @EventListener(DynamicRebindDoneEvent.class)
    public void onDynamicRebind(DynamicRebindDoneEvent ev) {
        if (ev.affects("app.cache")) {
            apply("rebind");
        }
    }

    // ----- classe interna invariata -----
    static class ConventionTtlRedisCacheManager extends RedisCacheManager {
        private static final Pattern TTL_PATTERN =
                Pattern.compile("^(?<name>[^#]+)(#(?<ttl>\\d+[smhd]))?$", Pattern.CASE_INSENSITIVE);

        private final RedisCacheConfiguration defaults;

        ConventionTtlRedisCacheManager(RedisCacheWriter cacheWriter, RedisCacheConfiguration defaultCacheConfiguration) {
            super(cacheWriter, defaultCacheConfiguration);
            this.defaults = defaultCacheConfiguration;
        }

        @Override
        protected org.springframework.data.redis.cache.RedisCache createRedisCache(
                String name, RedisCacheConfiguration cacheConfig) {

            Matcher m = TTL_PATTERN.matcher(name);
            if (m.matches()) {
                String base = m.group("name");
                String ttlToken = m.group("ttl");
                Duration ttl = ttlToken != null ? parseTtl(ttlToken) : null;

                RedisCacheConfiguration cfg = (cacheConfig != null ? cacheConfig : defaults);
                if (ttl != null) cfg = cfg.entryTtl(ttl);
                return super.createRedisCache(base, cfg);
            }
            return super.createRedisCache(name, cacheConfig);
        }

        private static Duration parseTtl(String token) {
            token = token.toLowerCase(Locale.ROOT);
            long time = Long.parseLong(token.substring(0, token.length() - 1));
            if (token.endsWith("s")) return Duration.ofSeconds(time);
            if (token.endsWith("m")) return Duration.ofMinutes(time);
            if (token.endsWith("h")) return Duration.ofHours(time);
            if (token.endsWith("d")) return Duration.ofDays(time);
            throw new IllegalArgumentException("TTL non valido: " + token + " (usa es: 30s, 10m, 2h, 7d)");
        }
    }
}
