package it.atlantica.security.entry_point;

import it.atlantica.payload.ErrorPayload;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;

@Component
public class CustomAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private static final Logger logger = LoggerFactory.getLogger(CustomAuthenticationEntryPoint.class);
    private final JsonMapper jsonMapper = JsonMapper.builder().build();
    @Override
    public void commence(HttpServletRequest request,
                         HttpServletResponse response,
                         AuthenticationException authException) throws IOException {
        Throwable cause = authException.getCause();
        logger.error("Authentication Exception: ", cause);
        String errorCode = "authentication.unauthorized";
        if (cause instanceof JwtException jwtEx) {
            String msg = jwtEx.getMessage();
            String msgLower = (msg != null) ? msg.toLowerCase() : "";
            if (msgLower.contains("expired")) {
                errorCode = "token.expired";
            } else if (msgLower.contains("signature")) {
                errorCode = "token.invalid_signature";
            } else if (msgLower.contains("malformed")) {
                errorCode = "token.malformed";
            }  else if (msgLower.contains("algorithm") || msgLower.contains("no matching key")) {
                errorCode = "token.invalid_key_or_algorithm";
            } else {
                errorCode = "token.invalid_or_expired";
            }
            logger.warn("JWT error: {}", msg, jwtEx);
        } else {
            logger.warn("Authentication failed: {}", authException.getMessage(), authException);
        }
        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        ErrorPayload payload = new ErrorPayload(errorCode);
        String jsonPayload = jsonMapper.writeValueAsString(payload);
        response.getWriter().write(jsonPayload);
    }
}