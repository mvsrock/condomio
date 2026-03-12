package it.condomio.config.properties;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Configurazione runtime delle automazioni Fase 8.
 *
 * Tutti i valori hanno fallback di sicurezza per evitare NPE o bootstrap failure
 * in assenza di override su application.yml / variabili ambiente.
 */
@Component
@ConfigurationProperties(prefix = "app.jobs")
public class JobAutomationProperties {

    public static final String DEFAULT_CHANNEL = "email";
    public static final String DEFAULT_SOLLECITO_TITLE = "Sollecito automatico";
    public static final String DEFAULT_SOLLECITO_NOTE = "Generato automaticamente per debito scaduto";
    public static final String DEFAULT_REMINDER_TITLE = "Promemoria scadenza rata";
    public static final String DEFAULT_REMINDER_NOTE_PATTERN =
            "Rate in scadenza entro %d giorni: %d, scoperto totale %.2f";
    public static final String DEFAULT_REMINDER_NEAREST_DUE_DATE_PATTERN = ", prima scadenza %s";

    private final Executor executor = new Executor();
    private final ListConfig list = new ListConfig();
    private final Solleciti solleciti = new Solleciti();
    private final Reminder reminder = new Reminder();

    public Executor getExecutor() {
        return executor;
    }

    public ListConfig getList() {
        return list;
    }

    public Solleciti getSolleciti() {
        return solleciti;
    }

    public Reminder getReminder() {
        return reminder;
    }

    public static class Executor {
        private int corePoolSize = 2;
        private int maxPoolSize = 8;
        private int queueCapacity = 200;
        private int awaitTerminationSeconds = 30;

        public int getCorePoolSize() {
            return corePoolSize;
        }

        public void setCorePoolSize(int corePoolSize) {
            this.corePoolSize = corePoolSize;
        }

        public int getMaxPoolSize() {
            return maxPoolSize;
        }

        public void setMaxPoolSize(int maxPoolSize) {
            this.maxPoolSize = maxPoolSize;
        }

        public int getQueueCapacity() {
            return queueCapacity;
        }

        public void setQueueCapacity(int queueCapacity) {
            this.queueCapacity = queueCapacity;
        }

        public int getAwaitTerminationSeconds() {
            return awaitTerminationSeconds;
        }

        public void setAwaitTerminationSeconds(int awaitTerminationSeconds) {
            this.awaitTerminationSeconds = awaitTerminationSeconds;
        }
    }

    public static class ListConfig {
        private int defaultLimit = 30;
        private int maxLimit = 200;

        public int getDefaultLimit() {
            return defaultLimit;
        }

        public void setDefaultLimit(int defaultLimit) {
            this.defaultLimit = defaultLimit;
        }

        public int getMaxLimit() {
            return maxLimit;
        }

        public void setMaxLimit(int maxLimit) {
            this.maxLimit = maxLimit;
        }
    }

    public static class Solleciti {
        private int defaultMinDaysOverdue = 1;
        private int minDaysOverdueMin = 0;
        private int minDaysOverdueMax = 3650;
        private String channel = DEFAULT_CHANNEL;
        private String title = DEFAULT_SOLLECITO_TITLE;
        private String note = DEFAULT_SOLLECITO_NOTE;
        private boolean promoteInBonisToSollecitato = true;
        private boolean deduplicatePerDay = true;

        public int getDefaultMinDaysOverdue() {
            return defaultMinDaysOverdue;
        }

        public void setDefaultMinDaysOverdue(int defaultMinDaysOverdue) {
            this.defaultMinDaysOverdue = defaultMinDaysOverdue;
        }

        public int getMinDaysOverdueMin() {
            return minDaysOverdueMin;
        }

        public void setMinDaysOverdueMin(int minDaysOverdueMin) {
            this.minDaysOverdueMin = minDaysOverdueMin;
        }

        public int getMinDaysOverdueMax() {
            return minDaysOverdueMax;
        }

        public void setMinDaysOverdueMax(int minDaysOverdueMax) {
            this.minDaysOverdueMax = minDaysOverdueMax;
        }

        public String getChannel() {
            return channel;
        }

        public void setChannel(String channel) {
            this.channel = channel;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getNote() {
            return note;
        }

        public void setNote(String note) {
            this.note = note;
        }

        public boolean isPromoteInBonisToSollecitato() {
            return promoteInBonisToSollecitato;
        }

        public void setPromoteInBonisToSollecitato(boolean promoteInBonisToSollecitato) {
            this.promoteInBonisToSollecitato = promoteInBonisToSollecitato;
        }

        public boolean isDeduplicatePerDay() {
            return deduplicatePerDay;
        }

        public void setDeduplicatePerDay(boolean deduplicatePerDay) {
            this.deduplicatePerDay = deduplicatePerDay;
        }
    }

    public static class Reminder {
        private int defaultMaxDaysAhead = 7;
        private int maxDaysAheadMin = 0;
        private int maxDaysAheadMax = 365;
        private String channel = DEFAULT_CHANNEL;
        private String title = DEFAULT_REMINDER_TITLE;
        private String notePattern = DEFAULT_REMINDER_NOTE_PATTERN;
        private String nearestDueDatePattern = DEFAULT_REMINDER_NEAREST_DUE_DATE_PATTERN;
        private boolean deduplicatePerDay = true;

        public int getDefaultMaxDaysAhead() {
            return defaultMaxDaysAhead;
        }

        public void setDefaultMaxDaysAhead(int defaultMaxDaysAhead) {
            this.defaultMaxDaysAhead = defaultMaxDaysAhead;
        }

        public int getMaxDaysAheadMin() {
            return maxDaysAheadMin;
        }

        public void setMaxDaysAheadMin(int maxDaysAheadMin) {
            this.maxDaysAheadMin = maxDaysAheadMin;
        }

        public int getMaxDaysAheadMax() {
            return maxDaysAheadMax;
        }

        public void setMaxDaysAheadMax(int maxDaysAheadMax) {
            this.maxDaysAheadMax = maxDaysAheadMax;
        }

        public String getChannel() {
            return channel;
        }

        public void setChannel(String channel) {
            this.channel = channel;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getNotePattern() {
            return notePattern;
        }

        public void setNotePattern(String notePattern) {
            this.notePattern = notePattern;
        }

        public String getNearestDueDatePattern() {
            return nearestDueDatePattern;
        }

        public void setNearestDueDatePattern(String nearestDueDatePattern) {
            this.nearestDueDatePattern = nearestDueDatePattern;
        }

        public boolean isDeduplicatePerDay() {
            return deduplicatePerDay;
        }

        public void setDeduplicatePerDay(boolean deduplicatePerDay) {
            this.deduplicatePerDay = deduplicatePerDay;
        }
    }
}
