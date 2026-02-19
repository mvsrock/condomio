package it.atlantica.view;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Immutable
@Table(name = "keycloak_group_role_summary_view")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class KeycloakGroupRoleSummaryView {

	@Id
	private String id;

	@Column(name = "group_id")
	private String groupID;

	@Column(name = "group_name")
	private String groupName;

	@Column(name = "sub_group_name")
	private String currentGroupName;

	@Column(name = "realm_id")
	private String realmId;

    @Column(name = "roles")
    private String roles;

	@Column(name = "distribution_company_id")
	private String distributionCompanyID;

	@Column(name = "distribution_company_name")
	private String distributionCompanyName;

    @Column(name = "attributes_current", columnDefinition = "jsonb")
    @JdbcTypeCode(SqlTypes.JSON)
    private JsonNode attributesCurrent;

    @Column(name = "group_path")
    private String groupPath;
}
