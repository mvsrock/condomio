package com.example.demo;

import java.time.LocalDateTime;
import java.time.ZoneOffset;

import org.joda.time.Instant;
import org.junit.jupiter.api.Test;

class CoreApplicationTests {

	@Test
	void contextLoads() {
			System.out.println(Instant.now());
			System.out.println(LocalDateTime.now());
			System.out.println(Instant.now().getMillis());
			System.out.println(LocalDateTime.now().toEpochSecond(ZoneOffset.UTC));
	}

}
