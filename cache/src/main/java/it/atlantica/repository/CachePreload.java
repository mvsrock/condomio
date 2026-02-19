package it.atlantica.repository;


import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface CachePreload {
    String cacheName();                 // deve combaciare con @Cacheable.cacheNames
    Class<?> filtersClass();            // classe dei filtri
    int pageSize() default 10;          // page size di default deve coincidere con quello del FE
    String sort() default "";           // es. "label,ASC" deve coincidere con quello del FE
    int  pagesToPrefetch() default -1; // -1 = usa valore globale
}