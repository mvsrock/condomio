package it.atlantica.view;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;

@Entity
@Immutable
@Table(name = "keycloak_role_group_summary_view")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class KeycloakRoleGroupSummaryView {

	@Id
	@Column(name = "roles_id")
	private String rolesId;

	@Column(name = "role_name")
	private String roleName;

	@Column(name = "realm_id")
	private String realmId;

    @Column(name = "group_name")
    private String groupName;
	@Column(name = "description")
	private String description;
}
