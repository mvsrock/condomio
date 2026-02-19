package it.atlantica.config;

import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.support.NoOpCacheManager;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.concurrent.atomic.AtomicReference;

@Component("cacheManager")
public class SwitchableCacheManager implements CacheManager {
    private final AtomicReference<CacheManager> delegate = new AtomicReference<>(new NoOpCacheManager());

    @Override public Cache getCache(String name) { return delegate.get().getCache(name); }
    @Override public Collection<String> getCacheNames() { return delegate.get().getCacheNames(); }

    public void switchTo(CacheManager next) { delegate.set(next); }
}