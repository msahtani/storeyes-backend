package io.storeyes.storeyes_coffee.sales.repositories;

import io.storeyes.storeyes_coffee.sales.entities.CoffeeSalesHourly;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface CoffeeSalesHourlyRepository extends JpaRepository<CoffeeSalesHourly, Long> {

    /**
     * The most recent {@code limit} orders for a store (matched on {@code coffee_shop_name} = store
     * code) up to and including a given day/hour, newest first. Ordering mirrors the raw-JDBC read
     * in {@code SalesProcessor}: {@code sale_date DESC, hour DESC}, with {@code id DESC} as a stable
     * tie-breaker within the same hour.
     *
     * @param storeCode  store code stored in {@code coffee_shop_name}
     * @param beforeDate the alert's calendar day — rows after this day are excluded
     * @param beforeHour the alert's hour-of-day — on {@code beforeDate}, rows in a later hour are excluded
     * @param limit      max rows to return
     */
    @Query(value = """
            SELECT c.* FROM coffee_sales_hourly c
            WHERE c.coffee_shop_name = :storeCode
              AND (c.sale_date < :beforeDate
                   OR (c.sale_date = :beforeDate AND c.hour <= :beforeHour))
            ORDER BY c.sale_date DESC, c.hour DESC, c.id DESC
            LIMIT :limit
            """, nativeQuery = true)
    List<CoffeeSalesHourly> findRecentOrdersForStore(
            @Param("storeCode") String storeCode,
            @Param("beforeDate") LocalDate beforeDate,
            @Param("beforeHour") int beforeHour,
            @Param("limit") int limit);

    /**
     * Aggregate product revenue and quantity over a date range for a given store code.
     * Only products with non-zero total revenue are returned.
     * <p>
     * Returns {@code Object[]} rows where:
     * <ul>
     *   <li>[0] {@code String} — coffeeName</li>
     *   <li>[1] {@code BigDecimal} — SUM(quantity)</li>
     *   <li>[2] {@code BigDecimal} — SUM(totalPrice)</li>
     * </ul>
     */
    @Query("""
            SELECT c.coffeeName, SUM(c.quantity), SUM(c.totalPrice)
            FROM CoffeeSalesHourly c
            WHERE c.coffeeShopName = :storeCode
              AND c.saleDate >= :startDate
              AND c.saleDate <= :endDate
            GROUP BY c.coffeeName
            HAVING SUM(c.totalPrice) > 0
            """)
    List<Object[]> aggregateByStoreCodeAndDateRange(
            @Param("storeCode") String storeCode,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
