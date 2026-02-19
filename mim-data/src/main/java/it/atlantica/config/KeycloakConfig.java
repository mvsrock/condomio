package it.atlantica.config;

import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.KeycloakBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class KeycloakConfig {
	private final KeycloakProperties keycloakProperties;

	public KeycloakConfig(KeycloakProperties keycloakProperties) {
		this.keycloakProperties = keycloakProperties;
	}
	

	@Bean
	Keycloak keycloak() {
		
		return KeycloakBuilder.builder().serverUrl(keycloakProperties.getAuthServerUrl())
				.realm(keycloakProperties.getRealm()).clientId(keycloakProperties.getResource())
				.username(keycloakProperties.getCredentials().getUsername())
				.password(keycloakProperties.getCredentials().getPassword()).build();
	}
	
}
