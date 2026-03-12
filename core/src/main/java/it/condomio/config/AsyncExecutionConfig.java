package it.condomio.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import it.condomio.config.properties.JobAutomationProperties;

/**
 * Configurazione executor per job asincroni applicativi.
 */
@Configuration
@EnableAsync
public class AsyncExecutionConfig {

    private final JobAutomationProperties jobAutomationProperties;

    public AsyncExecutionConfig(JobAutomationProperties jobAutomationProperties) {
        this.jobAutomationProperties = jobAutomationProperties;
    }

    @Bean(name = "jobExecutor")
    ThreadPoolTaskExecutor jobExecutor() {
        final JobAutomationProperties.Executor cfg = jobAutomationProperties.getExecutor();
        final int corePool = Math.max(1, cfg.getCorePoolSize());
        final int maxPool = Math.max(corePool, cfg.getMaxPoolSize());
        final int queueCapacity = Math.max(1, cfg.getQueueCapacity());
        final int awaitTerminationSeconds = Math.max(1, cfg.getAwaitTerminationSeconds());

        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setThreadNamePrefix("condomio-job-");
        executor.setCorePoolSize(corePool);
        executor.setMaxPoolSize(maxPool);
        executor.setQueueCapacity(queueCapacity);
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.setAwaitTerminationSeconds(awaitTerminationSeconds);
        executor.initialize();
        return executor;
    }
}
