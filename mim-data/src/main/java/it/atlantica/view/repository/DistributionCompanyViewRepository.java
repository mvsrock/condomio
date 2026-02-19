package it.atlantica.view.repository;

import it.atlantica.view.DistributionCompanyView;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DistributionCompanyViewRepository extends JpaRepository<DistributionCompanyView, String> {
}