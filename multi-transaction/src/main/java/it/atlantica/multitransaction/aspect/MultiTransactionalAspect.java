package it.atlantica.multitransaction.aspect;


import it.atlantica.multitransaction.annotation.MultiTransactional;
import it.atlantica.multitransaction.annotation.TransactionManagerConfig;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import java.util.ArrayList;
import java.util.List;

@Aspect
@Component
@Slf4j
public class MultiTransactionalAspect {

    @Autowired
    private ApplicationContext applicationContext;

    @Around("@annotation(multiTransactional)")
    public Object manageMultipleTransactions(ProceedingJoinPoint pjp, MultiTransactional multiTransactional) throws Throwable {
        List<TransactionStatus> statuses = new ArrayList<>();
        List<PlatformTransactionManager> managers = new ArrayList<>();
        boolean newSynchronization = false;
        try {
            log.info("manageMultipleTransactions, initSynchronization");
            // Inizio la sincronizzazione se necessario
            if (!TransactionSynchronizationManager.isSynchronizationActive()) {
                TransactionSynchronizationManager.initSynchronization();
                newSynchronization = true;
            }
            // Creo e inizio le transazioni
            for (TransactionManagerConfig config : multiTransactional.value()) {
                PlatformTransactionManager tm = applicationContext.getBean(config.manager(), PlatformTransactionManager.class);
                DefaultTransactionDefinition def = new DefaultTransactionDefinition();
                def.setPropagationBehavior(config.propagation().value());
                def.setIsolationLevel(config.isolation().value());
                def.setReadOnly(config.readOnly());
                def.setTimeout(config.timeout());


                TransactionStatus status = tm.getTransaction(def);
                statuses.add(status);
                managers.add(tm);
            }

            Object result = pjp.proceed();

            // Commit di tutte le transazioni
            for (int i = 0; i < managers.size(); i++) {
                managers.get(i).commit(statuses.get(i));
            }

            return result;
        } catch (Throwable ex) {
            // Rollback di tutte le transazioni in caso di errore, salvo diversa specifica
            for (int i = 0; i < managers.size(); i++) {
                TransactionManagerConfig config = multiTransactional.value()[i];
                boolean shouldRollback = shouldRollbackFor(ex, config.rollbackFor(), config.noRollbackFor());

                if (shouldRollback && !statuses.get(i).isCompleted()) {
                    managers.get(i).rollback(statuses.get(i));
                } else if (!shouldRollback && !statuses.get(i).isCompleted()) {
                    managers.get(i).commit(statuses.get(i));
                }
            }
            throw ex;
        } finally {
            // Pulisco la sincronizzazione solo se è stata iniziata da questo aspect
            if (newSynchronization) {
                TransactionSynchronizationManager.clearSynchronization();
                log.info("manageMultipleTransactions, clearSynchronization");
            }
        }
    }

    private boolean shouldRollbackFor(Throwable ex, Class<? extends Throwable>[] rollbackFor, Class<? extends Throwable>[] noRollbackFor) {
        for (Class<? extends Throwable> rbEx : rollbackFor) {
            if (rbEx.isAssignableFrom(ex.getClass())) {
                return true;
            }
        }
        for (Class<? extends Throwable> noRbEx : noRollbackFor) {
            if (noRbEx.isAssignableFrom(ex.getClass())) {
                return false;
            }
        }
        return false;  // Di default, non eseguo il rollback se non trovo una corrispondenza specifica
    }
}