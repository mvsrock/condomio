package it.condomio.aspects;

import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.stereotype.Component;

import it.condomio.service.CachePreloadService;
import lombok.RequiredArgsConstructor;

@Aspect
@Component
@RequiredArgsConstructor
public class CachePreloadAspect {

    private final CachePreloadService preloadService;

    @AfterReturning("@annotation(cacheEvict)")
    public void afterEvict(CacheEvict cacheEvict) {
        if (!cacheEvict.allEntries()) return;
        for (String cacheName : cacheEvict.cacheNames()) {
            preloadService.preload(cacheName);
        }
    }
}