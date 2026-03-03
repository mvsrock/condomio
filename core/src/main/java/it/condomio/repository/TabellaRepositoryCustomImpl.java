package it.condomio.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Component;

@Component
public class TabellaRepositoryCustomImpl implements TabellaRepositoryCustom {

    @SuppressWarnings("unused")
	@Autowired
    private MongoTemplate mongoTemplate;

    // qui puoi implementare i tuoi metodi custom
}

