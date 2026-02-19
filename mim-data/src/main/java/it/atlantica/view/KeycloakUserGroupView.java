package it.atlantica.view;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;

@Entity
@Data
@AllArgsConstructor
@NoArgsConstructor
@Immutable
@Table(name = "keycloak_user_group_view")
public class KeycloakUserGroupView {

	@Id
	@Column(name = "id")
	private String id;

	@Column(name = "user_id")
	private String userId;
	@Column(name = "email")
	private String email;

	@Column(name = "username")
	private String username;

	@Column(name = "first_name")
	private String firstName;

	@Column(name = "last_name")
	private String lastName;

	@Column(name = "password")
	private String password;

	@Column(name = "enabled")
	private boolean enabled;

	@Column(name = "realm_id")
	@JsonIgnore
	private String realmId;

	@Column(name = "group_id")
	private String groupId;

	@Column(name = "group_name")
	private String groupName;

	@Column(name = "distribution_company")
	private String distributionCompany;

	@Column(name = "distribution_company_id")
	private String distributionCompanyId;

    @Column(name = "identity_provider")
    private String identityProvider;

}
