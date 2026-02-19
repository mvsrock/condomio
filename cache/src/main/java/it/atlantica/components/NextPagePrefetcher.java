package it.atlantica.components;

import it.atlantica.dto.CacheRuntimeSettings;
import it.atlantica.repository.PagePrefetcher;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Executor;


@Component
@RequiredArgsConstructor
@Slf4j
public class NextPagePrefetcher {
    @Autowired
    private CacheRuntimeSettings cacheRuntimeSettings;

    @Qualifier("cachePrefetchExecutor")
    private final  Executor cachePrefetchExecutor;

    @Async("cachePrefetchExecutor")
    public <F> void prefetchNext(F filters,   Pageable current,int totalPages, Integer pagesToPrefetch,  PagePrefetcher<F> fetcher) {

        if (!cacheRuntimeSettings.isEnabled()) return;

        int pages = (pagesToPrefetch != null && pagesToPrefetch > 0)
                ? pagesToPrefetch
                : cacheRuntimeSettings.getPrefetchPages();

        int currentPage = current.getPageNumber();

        for (int i = 0; i < pages; i++) {
            int nextPage = currentPage + i;
            if (nextPage >= totalPages) break;

            Pageable next = PageRequest.of(nextPage, current.getPageSize(), current.getSort());

            CompletableFuture
                    .runAsync(() -> fetcher.fetch(filters, next), cachePrefetchExecutor)
                    .exceptionally(ex -> {
                        log.error("prefetch: {}", ex.getMessage(), ex);
                        return null;
                    });
        }
    }


    public <F> void prefetchNext(F filters,
                                 Pageable current,
                                 int totalPages,
                                 PagePrefetcher<F> fetcher) {
        prefetchNext(filters, current, totalPages, null, fetcher);
    }
}