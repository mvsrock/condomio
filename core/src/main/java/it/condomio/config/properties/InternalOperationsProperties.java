package it.condomio.config.properties;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Configurazione bridge interno core <-> operations-service.
 */
@Component
@ConfigurationProperties(prefix = "app.internal.operations")
public class InternalOperationsProperties {

    private String sharedKey = "change-me-ops-key";

    public String getSharedKey() {
        return sharedKey;
    }

    public void setSharedKey(String sharedKey) {
        this.sharedKey = sharedKey;
    }
}
