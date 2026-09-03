package io.storeyes.storeyes_coffee.sales.repositories;

import io.storeyes.storeyes_coffee.sales.entities.CoffeeSalesHourly;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface CoffeeSalesHourlyRepository extends JpaRepository<CoffeeSalesHourly, Long> {

    /**
     * The most recent {@code limit} orders for a store (matched on {@code coffee_shop_name} = store
     * code) strictly before a given timestamp, newest first. Compares the full
     * {@code sale_date + sale_time::time} timestamp rather than the {@code hour} bucket column, since
     * {@code hour} alone can't tell a 10:55 sale from a 10:00 one. This cast-and-add comparison mirrors
     * {@code RawSalesRepository} in st-admin-back (e.g. its {@code findTop5BeforeAlert} and
     * {@code countByCategoryInRangeExcludingCafeLatte}), which reads this same table. Ordering mirrors
     * the raw-JDBC read in {@code SalesProcessor}: {@code sale_date DESC, hour DESC}, with
     * {@code id DESC} as a stable tie-breaker for equal timestamps.
     *
     * @param storeCode      store code stored in {@code coffee_shop_name}
     * @param beforeDateTime rows with a sale timestamp at or after this are excluded
     * @param limit          max rows to return
     */
    @Query(value = """
            SELECT c.* FROM coffee_sales_hourly c
            WHERE c.coffee_shop_name = :storeCode
              AND (c.sale_date + c.sale_time::time) < :beforeDateTime
            ORDER BY (c.sale_date + c.sale_time::time) DESC, c.id DESC
            LIMIT :limit
            """, nativeQuery = true)
    List<CoffeeSalesHourly> findRecentOrdersForStore(
            @Param("storeCode") String storeCode,
            @Param("beforeDateTime") LocalDateTime beforeDateTime,
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
