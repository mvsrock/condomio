package it.atlantica.view;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.Immutable;


@Getter
@Setter
@ToString
@RequiredArgsConstructor
@Entity
@Immutable
@Table(name  = "distribution_to_keycloak_group_view")
public class DistributionCompanyKeycloakGroupView {
    @Id
    private Long id;
    @Column(name = "id_company")
    private Long idCompany;
    @Column(name="id_role")
    private String idRole;
    @Column(name="role_name")
    private String name;
    @Column(name="realm_id")
    private String realmId;

    @Column(name="distribution_company")
    private String distributionCompany;
    @Column(name="parent_group_id")
    private String parentGroupId;

    @Column(name="parent_group_name")
    private String parentGroupName;


}