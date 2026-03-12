package io.storeyes.storeyes_coffee.stock.repositories;

import io.storeyes.storeyes_coffee.stock.entities.StockMovement;
import io.storeyes.storeyes_coffee.stock.entities.StockMovementType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface StockMovementRepository extends JpaRepository<StockMovement, Long> {

    List<StockMovement> findByStoreIdAndProductIdOrderByMovementDateDescIdDesc(Long storeId, Long productId);

    boolean existsByReferenceTypeAndReferenceId(String referenceType, Long referenceId);

    Optional<StockMovement> findByReferenceTypeAndReferenceId(String referenceType, Long referenceId);

    void deleteByReferenceTypeAndReferenceId(String referenceType, Long referenceId);

    /**
     * Average purchase cost per base unit for a stock product (from PURCHASE movements).
     */
    @Query(value = """
        SELECT CASE WHEN COALESCE(SUM(sm.quantity), 0) > 0
                    THEN COALESCE(SUM(sm.amount), 0) / SUM(sm.quantity)
                    ELSE 0 END
        FROM stock_movements sm
        WHERE sm.store_id = :storeId AND sm.product_id = :productId
          AND sm.type = 'PURCHASE' AND sm.amount IS NOT NULL AND sm.quantity > 0
        """, nativeQuery = true)
    BigDecimal getAveragePurchaseCostPerUnit(@Param("storeId") Long storeId,
                                             @Param("productId") Long productId);

    /**
     * Estimated summary: quantity and value from PURCHASE, ADJUSTMENT, and ARTICLE_SALE consumption only.
     * Real stock uses MANUAL_CONSUMPTION; estimated uses ARTICLE_SALE (sales-driven consumption).
     * ARTICLE_SALE movements now carry amount = consumedQty * avgPurchaseCost so value decreases with sales.
     */
    @Query(value = """
        SELECT sm.product_id AS product_id,
               COALESCE(SUM(sm.quantity), 0) AS estimated_quantity,
               COALESCE(SUM(
                 CASE WHEN sm.type = 'PURCHASE' OR sm.type = 'ADJUSTMENT' THEN COALESCE(sm.amount, 0)
                      WHEN sm.type = 'CONSUMPTION' AND sm.reference_type = 'ARTICLE_SALE' THEN -COALESCE(sm.amount, 0)
                      ELSE 0 END
               ), 0) AS estimated_value
        FROM stock_movements sm
        WHERE sm.store_id = :storeId
          AND (sm.type IN ('PURCHASE', 'ADJUSTMENT')
               OR (sm.type = 'CONSUMPTION' AND sm.reference_type = 'ARTICLE_SALE'))
        GROUP BY sm.product_id
        """, nativeQuery = true)
    List<Object[]> getEstimatedSummaryByStore(@Param("storeId") Long storeId);

    /**
     * Sum of movement quantities for real stock after a given date.
     * Real = snapshot + (PURCHASE + ADJUSTMENT + MANUAL_CONSUMPTION only).
     * Excludes ARTICLE_SALE consumptions (those are for estimated only).
     */
    @Query("""
        SELECT COALESCE(SUM(m.quantity), 0) FROM StockMovement m
        WHERE m.store.id = :storeId AND m.product.id = :productId AND m.movementDate > :afterDate
        AND (m.type IN ('PURCHASE', 'ADJUSTMENT')
             OR (m.type = 'CONSUMPTION' AND m.referenceType = 'MANUAL_CONSUMPTION'))
        """)
    BigDecimal sumQuantityAfterDateForReal(
            @Param("storeId") Long storeId,
            @Param("productId") Long productId,
            @Param("afterDate") java.time.LocalDate afterDate);

    /**
     * Sum of movement amounts for real stock after a given date.
     * PURCHASE and ADJUSTMENT add amount; MANUAL_CONSUMPTION subtracts.
     * Used with snapshot.amount to get real value directly.
     */
    @Query(value = """
        SELECT COALESCE(SUM(
          CASE WHEN sm.type = 'PURCHASE' OR sm.type = 'ADJUSTMENT' THEN COALESCE(sm.amount, 0)
               WHEN sm.type = 'CONSUMPTION' AND sm.reference_type = 'MANUAL_CONSUMPTION' THEN -COALESCE(sm.amount, 0)
               ELSE 0 END
        ), 0) FROM stock_movements sm
        WHERE sm.store_id = :storeId AND sm.product_id = :productId AND sm.movement_date > :afterDate
        AND (sm.type IN ('PURCHASE', 'ADJUSTMENT')
             OR (sm.type = 'CONSUMPTION' AND sm.reference_type = 'MANUAL_CONSUMPTION'))
        """, nativeQuery = true)
    BigDecimal sumAmountAfterDateForReal(
            @Param("storeId") Long storeId,
            @Param("productId") Long productId,
            @Param("afterDate") java.time.LocalDate afterDate);
}
