package it.condomio.config.properties;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Proprieta' bridge interno verso core.
 *
 * `sharedKey` deve combaciare con la stessa proprieta' configurata in core.
 */
@Component
@ConfigurationProperties(prefix = "app.core.internal")
public class CoreInternalBridgeProperties {

    private String sharedKey = "change-me-ops-key";

    public String getSharedKey() {
        return sharedKey;
    }

    public void setSharedKey(String sharedKey) {
        this.sharedKey = sharedKey;
    }
}
