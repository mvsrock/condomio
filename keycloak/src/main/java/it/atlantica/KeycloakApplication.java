package it.atlantica;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
//@EnableFeignClients
public class KeycloakApplication {

    public  static void main(String[] args) {
		SpringApplication.run(KeycloakApplication.class, args);
	}

}
