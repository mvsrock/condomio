package it.atlantica.view;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Immutable;

@Table(name = "distribution_company_view")
@Entity
@Immutable
@Data
@AllArgsConstructor
@NoArgsConstructor
public class DistributionCompanyView {
    @Id
    @Column(name = "group_id")
    private String groupId;
    @Column(name = "group_name")
    private String group_name;
    @Column(name = "piva")
    private String piva;
    @Column(name = "company_db_id")
    private String companyDbId;
    @Column(name = "company_name")
    private String companyName;

}
