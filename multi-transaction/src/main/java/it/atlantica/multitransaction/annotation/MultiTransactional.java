package it.atlantica.multitransaction.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface MultiTransactional {
    TransactionManagerConfig[] value();
}

/** esempio per usarlo:
 *   @MultiTransactional({
 *         @TransactionManagerConfig(
 *         		                manager = "mongoTransactionManager",
 *         		propagation = Propagation.REQUIRES_NEW,
 *         		isolation = Isolation.DEFAULT,
 *         		readOnly = false,
 *         		noRollbackFor = {AuthorizationException.class}),
 *         @TransactionManagerConfig(
 *                manager = "jpaTransactionManager",
 *         		propagation = Propagation.REQUIRED,
 *         		readOnly = false,
 *         		rollbackFor = {Exception.class})
 *     })
 *
 * */


