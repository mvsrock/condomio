package it.condomio.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfigurationSource;

import it.condomio.security.entry_point.CustomAuthenticationEntryPoint;
import it.condomio.security.jwt.CustomJwtAuthenticationConverter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    private final CorsConfigurationSource corsConfigurationSource;

    public SecurityConfig(CorsConfigurationSource corsConfigurationSource) {
        this.corsConfigurationSource = corsConfigurationSource;
    }

    @Bean
    public CustomAuthenticationEntryPoint customAuthenticationEntryPoint() {
        return new CustomAuthenticationEntryPoint();
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfigurationSource))
                .csrf(AbstractHttpConfigurer::disable)
                .authorizeHttpRequests(authorize -> authorize
                        .requestMatchers(
                                "/swagger-ui/**",
                                "/v3/api-docs/**",
                                "/swagger-resources/**",
                                "/webjars/**",
                                "/public/**",
                                "/actuator/**"
                        ).permitAll()
                        .requestMatchers(HttpMethod.GET, "/condomini/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.POST, "/condomini/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.POST, "/esercizi/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PUT, "/esercizi/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PATCH, "/esercizi/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.DELETE, "/esercizi/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.POST, "/movimenti/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PUT, "/movimenti/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PATCH, "/movimenti/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.DELETE, "/movimenti/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.POST, "/tabelle/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PUT, "/tabelle/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PATCH, "/tabelle/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.DELETE, "/tabelle/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.POST, "/condomino/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PUT, "/condomino/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PATCH, "/condomino/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.DELETE, "/condomino/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.POST, "/unita-immobiliari/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PUT, "/unita-immobiliari/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PATCH, "/unita-immobiliari/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.DELETE, "/unita-immobiliari/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PUT, "/preventivi/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.POST, "/morosita/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PATCH, "/morosita/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.POST, "/documenti/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PUT, "/documenti/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.PATCH, "/documenti/**").hasRole("amministratore")
                        .requestMatchers(HttpMethod.DELETE, "/documenti/**").hasRole("amministratore")
                        .requestMatchers("/keycloak-admin/**").hasRole("amministratore")
                        .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 ->
                        oauth2
                                .authenticationEntryPoint(customAuthenticationEntryPoint())
                                .jwt(jwt -> jwt
                                        .jwtAuthenticationConverter(new CustomJwtAuthenticationConverter()))
                );

        return http.build();
    }
}
