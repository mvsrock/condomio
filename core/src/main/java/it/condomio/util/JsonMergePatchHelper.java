package it.condomio.util;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.node.NullNode;
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
        // RFC7396: se patch non e' object, sostituisce interamente il target.
        if (patch == null || patch.isNull()) {
            return NullNode.instance;
        }
        if (!patch.isObject()) {
            return patch.deepCopy();
        }

        final ObjectNode result = (target != null && target.isObject())
                ? ((ObjectNode) target).deepCopy()
                : objectMapper.createObjectNode();

        patch.properties().forEach(entry -> {
            final String fieldName = entry.getKey();
            final JsonNode patchValue = entry.getValue();
            if (patchValue == null || patchValue.isNull()) {
                result.remove(fieldName);
                return;
            }
            final JsonNode targetValue = result.get(fieldName);
            result.set(fieldName, mergePatch(targetValue, patchValue));
        });

        return result;
    }

}
