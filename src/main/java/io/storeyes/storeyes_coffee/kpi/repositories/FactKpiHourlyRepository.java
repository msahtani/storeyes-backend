package io.storeyes.storeyes_coffee.kpi.repositories;

import io.storeyes.storeyes_coffee.kpi.entities.DateDimension;
import io.storeyes.storeyes_coffee.kpi.entities.FactKpiHourly;
import io.storeyes.storeyes_coffee.store.entities.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FactKpiHourlyRepository extends JpaRepository<FactKpiHourly, Long> {
    
    /**
     * Find all hourly KPIs for a store and date, ordered by hour
     */
    List<FactKpiHourly> findByStoreAndDateOrderByHourAsc(Store store, DateDimension date);
    
    /**
     * Find all hourly KPIs for a store ID and date, ordered by hour
     */
    List<FactKpiHourly> findByStoreIdAndDateOrderByHourAsc(Long storeId, DateDimension date);
}

