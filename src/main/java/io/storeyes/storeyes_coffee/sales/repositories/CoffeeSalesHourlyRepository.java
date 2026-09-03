package io.storeyes.storeyes_coffee.sales.repositories;

import io.storeyes.storeyes_coffee.sales.entities.CoffeeSalesHourly;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface CoffeeSalesHourlyRepository extends JpaRepository<CoffeeSalesHourly, Long> {

    /**
     * The most recent {@code limit} orders for a store (matched on {@code coffee_shop_name} = store
     * code) on {@code saleDate} strictly before {@code beforeTime}, newest first. Scoped to a single
     * calendar day — an opening-hour alert (e.g. 06:00) with no earlier sales that day should come
     * back empty, not spill into the previous day's closing-time sales. Compares the cast
     * {@code sale_time::time} rather than the {@code hour} bucket column, since {@code hour} alone
     * can't tell a 10:55 sale from a 10:00 one. This mirrors {@code RawSalesRepository} in
     * st-admin-back (its {@code findTop5BeforeAlert}), which reads this same table. Ordering mirrors
     * the raw-JDBC read in {@code SalesProcessor}: newest {@code sale_time} first, with {@code id DESC}
     * as a stable tie-breaker for equal times.
     *
     * @param storeCode  store code stored in {@code coffee_shop_name}
     * @param saleDate   the alert's calendar day — only this day's rows are considered
     * @param beforeTime the alert's exact time-of-day — rows at or after this are excluded
     * @param limit      max rows to return
     */
    @Query(value = """
            SELECT c.* FROM coffee_sales_hourly c
            WHERE c.coffee_shop_name = :storeCode
              AND c.sale_date = :saleDate
              AND c.sale_time::time < :beforeTime
            ORDER BY c.sale_time::time DESC, c.id DESC
            LIMIT :limit
            """, nativeQuery = true)
    List<CoffeeSalesHourly> findRecentOrdersForStore(
            @Param("storeCode") String storeCode,
            @Param("saleDate") LocalDate saleDate,
            @Param("beforeTime") LocalTime beforeTime,
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
