package it.condomio.multitransaction.config;


import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import jakarta.annotation.Nullable;
import jakarta.persistence.EntityManagerFactory;


@Configuration
@EnableTransactionManagement
@ConditionalOnProperty(name = "condomio.transaction.manager.enabled", havingValue = "true", matchIfMissing = false)
public class TransactionManagerConfig {


    @Bean
    @ConditionalOnProperty(name = "condomio.transaction.manager.jpa.enabled", havingValue = "true", matchIfMissing = false)
    public JpaTransactionManager jpaTransactionManager(EntityManagerFactory entityManagerFactory) {
        return new JpaTransactionManager(entityManagerFactory);
    }

    @Bean
    @ConditionalOnProperty(name = "condomio.transaction.manager.mongo.enabled", havingValue = "true", matchIfMissing = false)
    public MongoTransactionManager mongoTransactionManager(MongoDatabaseFactory dbFactory) {
        return new MongoTransactionManager(dbFactory);
    }

    @Bean
    @Primary
    public PlatformTransactionManager transactionManager(
            @Nullable @Qualifier("jpaTransactionManager") JpaTransactionManager jpaTransactionManager
            , @Nullable @Qualifier("mongoTransactionManager") MongoTransactionManager mongoTransactionManager
    ) {

        if (jpaTransactionManager != null) {
            return jpaTransactionManager;
        }
        else if (mongoTransactionManager != null) {
            return mongoTransactionManager;
        }
        else {
            return null;
        }
    }
}