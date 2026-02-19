package it.atlantica.event;

import org.springframework.context.ApplicationEvent;

import java.util.Set;

public class DynamicRebindDoneEvent extends ApplicationEvent {
    private final Set<String> changedKeys;

    public DynamicRebindDoneEvent(Object source, Set<String> changedKeys) {
        super(source);
        this.changedKeys = changedKeys;
    }
    public boolean affects(String keyPrefix) {
        if (changedKeys == null) return true;
        return changedKeys.stream().anyMatch(k -> k.equals(keyPrefix) || k.startsWith(keyPrefix + "."));
    }
    public Set<String> getChangedKeys() { return changedKeys; }
}