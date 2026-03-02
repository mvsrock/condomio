package it.condomio.view.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import it.condomio.view.DistributionCompanyView;

@Repository
public interface DistributionCompanyViewRepository extends JpaRepository<DistributionCompanyView, String> {
}