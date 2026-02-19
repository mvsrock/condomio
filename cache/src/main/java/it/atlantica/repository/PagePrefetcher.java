package it.atlantica.repository;

import org.springframework.data.domain.Pageable;

@FunctionalInterface
public interface PagePrefetcher<F> {
    void fetch(F filters, Pageable pageable);

}
