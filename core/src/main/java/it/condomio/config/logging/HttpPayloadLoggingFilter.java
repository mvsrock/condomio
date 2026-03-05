package it.condomio.config.logging;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Log HTTP request/response con payload (testuale/json), abilitabile da property.
 */
@Component
@ConditionalOnProperty(prefix = "app.http-logging", name = "enabled", havingValue = "true")
public class HttpPayloadLoggingFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(HttpPayloadLoggingFilter.class);

    @Value("${app.http-logging.max-payload-length:12000}")
    private int maxPayloadLength;

    @Value("${app.http-logging.exclude-path-prefixes:/actuator,/v3/api-docs,/swagger-ui,/favicon.ico}")
    private String excludePathPrefixes;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        final String path = request.getRequestURI();
        final List<String> prefixes = Arrays.stream(excludePathPrefixes.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
        for (String prefix : prefixes) {
            if (path.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        final ContentCachingRequestWrapper req = (request instanceof ContentCachingRequestWrapper)
                ? (ContentCachingRequestWrapper) request
                : new ContentCachingRequestWrapper(request, maxPayloadLength);
        final ContentCachingResponseWrapper res = (response instanceof ContentCachingResponseWrapper)
                ? (ContentCachingResponseWrapper) response
                : new ContentCachingResponseWrapper(response);

        final long start = System.currentTimeMillis();
        try {
            filterChain.doFilter(req, res);
        } finally {
            final long elapsed = System.currentTimeMillis() - start;
            final String method = req.getMethod();
            final String uri = req.getRequestURI()
                    + (req.getQueryString() == null ? "" : "?" + req.getQueryString());
            final int status = res.getStatus();

            final String reqBody = extractBody(req.getContentAsByteArray(), req.getContentType());
            final String resBody = extractBody(res.getContentAsByteArray(), res.getContentType());

            log.info("[HTTP] {} {} -> status={} in {}ms", method, uri, status, elapsed);
            if (!reqBody.isEmpty()) {
                log.info("[HTTP][REQ] {}", reqBody);
            }
            if (!resBody.isEmpty()) {
                log.info("[HTTP][RES] {}", resBody);
            }
            res.copyBodyToResponse();
        }
    }

    private String extractBody(byte[] bytes, String contentType) {
        if (bytes == null || bytes.length == 0) {
            return "";
        }
        final String ct = contentType == null ? "" : contentType.toLowerCase();
        final boolean textLike = ct.contains("json")
                || ct.contains("text")
                || ct.contains("xml")
                || ct.contains("x-www-form-urlencoded");
        if (!textLike) {
            return "<binary:" + bytes.length + " bytes>";
        }

        String body = new String(bytes, StandardCharsets.UTF_8).replace("\n", " ").replace("\r", " ");
        if (body.length() > maxPayloadLength) {
            body = body.substring(0, maxPayloadLength) + "...(truncated)";
        }
        return body;
    }
}
