package it.atlantica.service;

import it.atlantica.components.CachePreloadRegistry;
import it.atlantica.components.NextPagePrefetcher;
import it.atlantica.dto.CacheRuntimeSettings;
import it.atlantica.repository.CachePreload;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.lang.reflect.Method;

@Service
@RequiredArgsConstructor
public class CachePreloadService {

    private final CachePreloadRegistry registry;
    private final NextPagePrefetcher prefetcher;

    @Autowired
    private CacheRuntimeSettings cacheRuntimeSettings;


    public void preload(String cacheName) {
        if (!cacheRuntimeSettings.isEnabled()) return;

        registry.find(cacheName).ifPresent(entry -> {
            CachePreload m = entry.meta();

            try {
                Object filters = m.filtersClass().getDeclaredConstructor().newInstance();

                Pageable first = buildPageable(0, m.pageSize(), m.sort());
                Object result = entry.method().invoke(entry.bean(), filters, first);

                int totalPages = extractTotalPages(result);
                int pagesToPrefetch = (m.pagesToPrefetch() != -1) ? m.pagesToPrefetch() : cacheRuntimeSettings.getPrefetchPages();

                prefetcher.prefetchNext(
                        filters,
                        first,
                        totalPages,
                        pagesToPrefetch,
                        (f, p) -> {
                            try { entry.method().invoke(entry.bean(), f, p); } catch (Exception ignored) {}
                        }
                );
            } catch (Exception ignored) {}
        });
    }

    private Pageable buildPageable(int page, int size, String sort) {
        if (sort == null || sort.isBlank()) return PageRequest.of(page, size);
        String[] parts = sort.split(",", 2);
        Sort.Direction dir = (parts.length > 1 && "DESC".equalsIgnoreCase(parts[1])) ? Sort.Direction.DESC : Sort.Direction.ASC;
        return PageRequest.of(page, size, Sort.by(dir, parts[0].trim()));
    }

    private int extractTotalPages(Object result) {
        try {
            Method m = result.getClass().getMethod("getTotalPages");
            return (int) m.invoke(result);
        } catch (Exception e) {
            return 1;
        }
    }
}