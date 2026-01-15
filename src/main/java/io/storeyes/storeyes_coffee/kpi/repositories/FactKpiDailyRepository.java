package io.storeyes.storeyes_coffee.kpi.repositories;

import io.storeyes.storeyes_coffee.kpi.entities.DateDimension;
import io.storeyes.storeyes_coffee.kpi.entities.FactKpiDaily;
import io.storeyes.storeyes_coffee.store.entities.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface FactKpiDailyRepository extends JpaRepository<FactKpiDaily, Long> {
    
    /**
     * Find daily KPI by store and date
     */
    Optional<FactKpiDaily> findByStoreAndDate(Store store, DateDimension date);
    
    /**
     * Find daily KPI by store ID and date
     */
    Optional<FactKpiDaily> findByStoreIdAndDate(Long storeId, DateDimension date);
}

