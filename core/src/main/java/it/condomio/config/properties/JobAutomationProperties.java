package it.condomio.config.properties;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * Configurazione runtime automazioni morosita' usate dal dominio core.
 *
 * Nota architetturale:
 * - da quando i job asincroni sono stati estratti in operations-service,
 *   nel core restano solo le proprieta' realmente usate dalla business logic
 *   di solleciti/reminder (niente executor/list job).
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

    private final Solleciti solleciti = new Solleciti();
    private final Reminder reminder = new Reminder();

    public Solleciti getSolleciti() {
        return solleciti;
    }

    public Reminder getReminder() {
        return reminder;
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
