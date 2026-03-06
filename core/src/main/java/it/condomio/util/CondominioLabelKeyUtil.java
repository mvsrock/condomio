package it.condomio.util;

import java.util.Locale;

/**
 * Utility condivisa per derivare una chiave stabile e case-insensitive
 * del nome condominio usata per il root document.
 */
public final class CondominioLabelKeyUtil {
    private CondominioLabelKeyUtil() {
    }

    public static String normalizeLabel(String raw) {
        if (raw == null) {
            return "";
        }
        return raw.trim().replaceAll("\\s+", " ");
    }

    public static String toLabelKey(String raw) {
        return normalizeLabel(raw).toLowerCase(Locale.ROOT);
    }
}
