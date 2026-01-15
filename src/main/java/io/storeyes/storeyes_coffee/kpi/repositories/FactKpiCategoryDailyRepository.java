package io.storeyes.storeyes_coffee.kpi.repositories;

import io.storeyes.storeyes_coffee.kpi.entities.DateDimension;
import io.storeyes.storeyes_coffee.kpi.entities.FactKpiCategoryDaily;
import io.storeyes.storeyes_coffee.store.entities.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FactKpiCategoryDailyRepository extends JpaRepository<FactKpiCategoryDaily, Long> {
    
    /**
     * Find all category KPIs for a store and date
     */
    List<FactKpiCategoryDaily> findByStoreAndDate(Store store, DateDimension date);
    
    /**
     * Find all category KPIs for a store ID and date
     */
    List<FactKpiCategoryDaily> findByStoreIdAndDate(Long storeId, DateDimension date);
}

