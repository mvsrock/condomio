package it.condomio.service;

import org.springframework.context.annotation.Lazy;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

/**
 * Worker asincrono separato per evitare self-invocation su @Async.
 */
@Component
public class AsyncJobWorker {

    private final AsyncJobService asyncJobService;

    public AsyncJobWorker(@Lazy AsyncJobService asyncJobService) {
        this.asyncJobService = asyncJobService;
    }

    @Async("jobExecutor")
    public void process(String jobId) {
        asyncJobService.executeJob(jobId);
    }
}
