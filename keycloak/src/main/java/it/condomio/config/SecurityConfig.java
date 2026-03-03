package it.condomio.config;


import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
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
                .authorizeHttpRequests(auth -> auth
                		 .requestMatchers(
                                 "/swagger-ui/**",
                                 "/v3/api-docs/**",
                                 "/swagger-resources/**",
                                 "/webjars/**",
                                 "/public/**",
                                 "/actuator/**"
                         ).permitAll()
                	      .requestMatchers("/roles/**", "/groups/**", "/users/**").hasRole("amministratore")
                	      .requestMatchers("/menu-items/by-role-names").authenticated()
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
