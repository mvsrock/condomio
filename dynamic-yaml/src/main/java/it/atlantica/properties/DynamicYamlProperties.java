package it.atlantica.properties;


import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "app")
public class DynamicYamlProperties {

    private Cache cache = new Cache();
    private Properties properties = new Properties();

    @Getter
    @Setter
    public static class Cache {
        private boolean enabled=false;
        private int prefetchPages;
    }

    @Getter
    @Setter
    public static class Properties {
        private boolean enabled;
    }
}