package it.condomio.util;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.ArrayNode;
import tools.jackson.databind.node.ObjectNode;

public class JsonMergePatchHelper {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    public static <T> T applyMergePatch(JsonNode mergePatch, T targetBean, Class<T> beanClass)
            throws JacksonException, IllegalArgumentException {
        JsonNode targetNode = objectMapper.valueToTree(targetBean);
        JsonNode patchedNode = mergePatch(targetNode, mergePatch);
        return objectMapper.treeToValue(patchedNode, beanClass);
    }

    static private JsonNode mergePatch(JsonNode target, JsonNode patch) {
        if (patch.isObject()) {
            patch.properties().forEach(entry -> {
                String fieldName = entry.getKey();
                JsonNode patchValue = entry.getValue();

                if (patchValue.isNull()) {
                    // Rimuovi il campo se il valore e' null
                    ((ObjectNode) target).remove(fieldName);
                } else {
                    JsonNode targetValue = target.get(fieldName);

                    if (targetValue != null && targetValue.isObject()) {
                        // Unisci oggetti ricorsivamente
                        mergePatch(targetValue, patchValue);
                    } else if (targetValue != null && targetValue.isArray() && patchValue.isArray()) {
                        // Unisci array con chiave identificativa
                        mergeArray((ArrayNode) targetValue, (ArrayNode) patchValue);
                    } else {
                        // Sovrascrivi il valore
                        ((ObjectNode) target).set(fieldName, patchValue);
                    }
                }
            });
        }
        return target;
    }

    static private void mergeArray(ArrayNode targetArray, ArrayNode patchArray) {
        for (int i = 0; i < patchArray.size(); i++) {
            JsonNode patchElement = patchArray.get(i);

            // Gestisci il caso in cui l'elemento nella patch ha "_delete": true
            if (patchElement.isObject() && patchElement.has("_delete") && patchElement.get("_delete").asBoolean()) {
                if (patchElement.has("codice")) {
                    String patchKey = patchElement.get("codice").asString();

                    // Rimuovi l'elemento corrispondente nel target manualmente
                    for (int j = 0; j < targetArray.size(); j++) {
                        JsonNode targetElement = targetArray.get(j);
                        if (targetElement.isObject() && targetElement.has("codice")
                                && targetElement.get("codice").asString().equals(patchKey)) {
                            targetArray.remove(j); // Rimuovi l'elemento
                            break; // Esci una volta trovato
                        }
                    }
                }
            } else if (patchElement.isObject() && patchElement.has("codice")) {
                // Cerca un elemento corrispondente nel target tramite "codice"
                String patchKey = patchElement.get("codice").asString();
                boolean updated = false;

                for (int j = 0; j < targetArray.size(); j++) {
                    JsonNode targetElement = targetArray.get(j);
                    if (targetElement.isObject() && targetElement.has("codice")
                            && targetElement.get("codice").asString().equals(patchKey)) {
                        // Trovato l'elemento con lo stesso codice, aggiorna ricorsivamente
                        mergePatch(targetElement, patchElement);
                        updated = true;
                        break;
                    }
                }

                // Se non e' stato trovato un elemento corrispondente, aggiungilo al target
                if (!updated) {
                    targetArray.add(patchElement);
                }
            }
        }
    }
}
