package io.storeyes.storeyes_coffee.charges.repositories;

import io.storeyes.storeyes_coffee.charges.entities.VariableCharge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface VariableChargeRepository extends JpaRepository<VariableCharge, Long> {
    
    /**
     * Find variable charges by store and date range
     */
    @Query("SELECT vc FROM VariableCharge vc WHERE vc.store.id = :storeId AND " +
           "(:startDate IS NULL OR vc.date >= :startDate) AND " +
           "(:endDate IS NULL OR vc.date <= :endDate) AND " +
           "(:category IS NULL OR vc.category = :category) " +
           "ORDER BY vc.date DESC")
    List<VariableCharge> findByStoreIdAndDateRangeAndCategory(
            @Param("storeId") Long storeId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            @Param("category") String category
    );
    
    /**
     * Find variable charges by store and category
     */
    List<VariableCharge> findByStoreIdAndCategory(Long storeId, String category);
    
    /**
     * Find variable charges by store and date
     */
    List<VariableCharge> findByStoreIdAndDate(Long storeId, LocalDate date);
}
