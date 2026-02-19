package it.atlantica.multitransaction.config;


import jakarta.persistence.EntityManagerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.mongodb.MongoDatabaseFactory;
import org.springframework.data.mongodb.MongoTransactionManager;
import org.springframework.lang.Nullable;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;


@Configuration
@EnableTransactionManagement
@ConditionalOnProperty(name = "mim.transaction.manager.enabled", havingValue = "true", matchIfMissing = false)
public class TransactionManagerConfig {


    @Bean
    @ConditionalOnProperty(name = "mim.transaction.manager.jpa.enabled", havingValue = "true", matchIfMissing = false)
    public JpaTransactionManager jpaTransactionManager(EntityManagerFactory entityManagerFactory) {
        return new JpaTransactionManager(entityManagerFactory);
    }

    @Bean
    @ConditionalOnProperty(name = "mim.transaction.manager.mongo.enabled", havingValue = "true", matchIfMissing = false)
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