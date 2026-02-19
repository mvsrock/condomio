package it.atlantica.service.keycloak;

import org.keycloak.admin.client.Keycloak;
import org.keycloak.representations.idm.RealmRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RealmService {

    @Autowired
    private Keycloak keycloak;


    public RealmRepresentation createRealm(String name) {
        RealmRepresentation realm = new RealmRepresentation();
        realm.setRealm(name);
        realm.setEnabled(true);
        keycloak.realms().create(realm);
        return keycloak.realm(name).toRepresentation();
    }

    public List<RealmRepresentation> getAllRealms() {
        return keycloak.realms().findAll();
    }

    public void deleteRealm(String name) {
        keycloak.realm(name).remove();
    }
    
    public RealmRepresentation getRealm(String realmName) {
    	  return keycloak.realm(realmName).toRepresentation();
    }
    
    public String getIdRealm(String realmName) {
        return keycloak.realm(realmName).toRepresentation().getId();
    }


}
