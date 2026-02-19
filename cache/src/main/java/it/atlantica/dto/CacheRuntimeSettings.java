package it.atlantica.dto;


import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "app.cache")
public class CacheRuntimeSettings  {

    private boolean enabled=false;
    private int prefetchPages;

    private Duration defaultTtl=Duration.ofHours(24);
}