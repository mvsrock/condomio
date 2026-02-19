package it.atlantica.components;

import it.atlantica.repository.CachePreload;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;


@Component
public class CachePreloadRegistry implements BeanPostProcessor {
    public static record Entry(Object bean, Method method, CachePreload meta) {}
    private final Map<String, Entry> byCache = new ConcurrentHashMap<>();

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) {
        for (Method m : bean.getClass().getMethods()) {
            CachePreload ann = AnnotationUtils.findAnnotation(m, CachePreload.class);
            if (ann != null) byCache.put(ann.cacheName(), new Entry(bean, m, ann));
        }
        return bean;
    }

    public Optional<Entry> find(String cacheName) {
        return Optional.ofNullable(byCache.get(cacheName));
    }
}