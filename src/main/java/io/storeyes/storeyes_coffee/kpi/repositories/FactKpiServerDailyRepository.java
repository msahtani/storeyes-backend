package io.storeyes.storeyes_coffee.kpi.repositories;

import io.storeyes.storeyes_coffee.kpi.entities.DateDimension;
import io.storeyes.storeyes_coffee.kpi.entities.FactKpiServerDaily;
import io.storeyes.storeyes_coffee.store.entities.Store;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FactKpiServerDailyRepository extends JpaRepository<FactKpiServerDaily, Long> {
    
    /**
     * Find all server KPIs for a store and date, ordered by revenue descending
     */
    List<FactKpiServerDaily> findByStoreAndDateOrderByRevenueDesc(Store store, DateDimension date);
    
    /**
     * Find all server KPIs for a store ID and date, ordered by revenue descending
     */
    List<FactKpiServerDaily> findByStoreIdAndDateOrderByRevenueDesc(Long storeId, DateDimension date);
}

