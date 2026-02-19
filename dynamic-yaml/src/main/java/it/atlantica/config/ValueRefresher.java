package it.atlantica.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.beans.factory.support.DefaultListableBeanFactory;
import org.springframework.core.convert.ConversionService;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import org.springframework.util.ReflectionUtils;
import org.springframework.util.StringValueResolver;

import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
@Component
@RequiredArgsConstructor
public class ValueRefresher implements BeanPostProcessor {

    private final Environment env;
    private final BeanFactory beanFactory;

    private static final class InjectionPoint {
        final String beanName;
        final Object bean;
        final Field field;        // o method
        final Method method;
        final String placeholder; // es. "${app.prova:notrovato}"
        final Class<?> targetType;

        InjectionPoint(String beanName, Object bean, Field f, String ph) {
            this.beanName = beanName; this.bean = bean; this.field = f; this.method = null;
            this.placeholder = ph; this.targetType = f.getType();
        }
        InjectionPoint(String beanName, Object bean, Method m, String ph, Class<?> paramType) {
            this.beanName = beanName; this.bean = bean; this.field = null; this.method = m;
            this.placeholder = ph; this.targetType = paramType;
        }
    }

    private final Map<String, List<InjectionPoint>> points = new ConcurrentHashMap<>();

    private static boolean placeholderMentionsKey(String placeholder, String key) {
        return placeholder.contains("${" + key + "}") ||
                placeholder.contains("${" + key + ":") ||
                placeholder.contains("${" + key + ".");
    }

    private StringValueResolver resolver() {
        if (beanFactory instanceof DefaultListableBeanFactory dlbf) {
            return dlbf::resolveEmbeddedValue; // usa PropertySourcesPlaceholderConfigurer se presente
        }
        return env::resolvePlaceholders;
    }

    private ConversionService conversionService() {
        if (beanFactory instanceof DefaultListableBeanFactory dlbf) {
            return dlbf.getConversionService();
        }
        return null;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        List<InjectionPoint> list = new ArrayList<>();

        // Campi con @Value
        ReflectionUtils.doWithFields(bean.getClass(), f -> {
            Value ann = f.getAnnotation(Value.class);
            if (ann != null && ann.value() != null && ann.value().contains("${")) {
                f.setAccessible(true);
                list.add(new InjectionPoint(beanName, bean, f, ann.value()));
            }
        });

        // Metodi con @Value (sul metodo o sul parametro)
        ReflectionUtils.doWithMethods(bean.getClass(), m -> {
            Value ann = m.getAnnotation(Value.class);
            if (ann != null && ann.value() != null && ann.value().contains("${")) {
                Class<?>[] params = m.getParameterTypes();
                if (params.length == 1) {
                    m.setAccessible(true);
                    list.add(new InjectionPoint(beanName, bean, m, ann.value(), params[0]));
                }
            } else {
                Annotation[][] pa = m.getParameterAnnotations();
                Class<?>[] pt = m.getParameterTypes();
                if (pa.length == 1 && pt.length == 1) {
                    for (Annotation a : pa[0]) {
                        if (a instanceof Value v && v.value() != null && v.value().contains("${")) {
                            m.setAccessible(true);
                            list.add(new InjectionPoint(beanName, bean, m, v.value(), pt[0]));
                            break;
                        }
                    }
                }
            }
        });

        if (!list.isEmpty()) {
            points.compute(beanName, (k, old) -> {
                if (old == null) old = new ArrayList<>();
                old.addAll(list);
                return old;
            });
        }
        return bean;
    }

    /** Invocata dal reloader con le chiavi modificate/forzate. */
    public void refreshValues(Set<String> changedKeys) {
        if (changedKeys == null || changedKeys.isEmpty()) return;

        StringValueResolver resolver = resolver();
        ConversionService cs = conversionService();

        for (Map.Entry<String, List<InjectionPoint>> e : points.entrySet()) {
            for (InjectionPoint ip : e.getValue()) {
                boolean hit = false;
                for (String key : changedKeys) {
                    if (placeholderMentionsKey(ip.placeholder, key)) { hit = true; break; }
                }
                if (!hit) continue;

                try {
                    String resolved = resolver.resolveStringValue(ip.placeholder);
                    Object value = resolved;

                    if (ip.targetType != String.class && cs != null && resolved != null) {
                        if (cs.canConvert(String.class, ip.targetType)) {
                            value = cs.convert(resolved, ip.targetType);
                        }
                    }

                    if (ip.field != null) {
                        ReflectionUtils.setField(ip.field, ip.bean, value);
                        log.debug("[dynamic] @Value refreshed (field) {}.{} = {}",
                                ip.bean.getClass().getSimpleName(), ip.field.getName(), value);
                    } else if (ip.method != null) {
                        ip.method.invoke(ip.bean, value);
                        log.debug("[dynamic] @Value refreshed (method) {}.{}(..) = {}",
                                ip.bean.getClass().getSimpleName(), ip.method.getName(), value);
                    }
                } catch (Exception ex) {
                    log.warn("[dynamic] @Value refresh failed for bean={} placeholder='{}' : {}",
                            ip.beanName, ip.placeholder, ex.toString());
                }
            }
        }
    }
}
