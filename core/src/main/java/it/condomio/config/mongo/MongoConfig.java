package it.condomio.config.mongo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.data.mongodb.core.SimpleMongoClientDatabaseFactory;

@Configuration
@PropertySource("classpath:mongo-config.properties")
public class MongoConfig {

	@Bean
    MongoDatabaseFactory mongoDatabaseFactory(Environment env) {
        final String uri = env.getRequiredProperty("spring.data.mongodb.uri");
        return new SimpleMongoClientDatabaseFactory(uri);
    }

	@Bean
    MongoTransactionManager transactionManager(MongoDatabaseFactory dbFactory) {
        return new MongoTransactionManager(dbFactory);
    }
}
