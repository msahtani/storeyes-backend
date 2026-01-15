package io.storeyes.storeyes_coffee.kpi.repositories;

import io.storeyes.storeyes_coffee.kpi.entities.DateDimension;
import io.storeyes.storeyes_coffee.kpi.entities.FactKpiProductDaily;
import io.storeyes.storeyes_coffee.store.entities.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FactKpiProductDailyRepository extends JpaRepository<FactKpiProductDaily, Long> {
    
    /**
     * Find all product KPIs for a store and date, ordered by quantity descending
     */
    List<FactKpiProductDaily> findByStoreAndDateOrderByQuantityDesc(Store store, DateDimension date);
    
    /**
     * Find all product KPIs for a store ID and date, ordered by revenue descending
     */
    List<FactKpiProductDaily> findByStoreIdAndDateOrderByRevenueDesc(Long storeId, DateDimension date);
    
    /**
     * Find all product KPIs for a store ID and date
     */
    List<FactKpiProductDaily> findByStoreIdAndDate(Long storeId, DateDimension date);
}

