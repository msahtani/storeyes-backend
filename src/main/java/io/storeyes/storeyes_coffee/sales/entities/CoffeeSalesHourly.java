package io.storeyes.storeyes_coffee.sales.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Maps the {@code coffee_sales_hourly} table (Postgres, storeyes-blue).
 * <p>
 * Column types mirror the live schema exactly:
 * <ul>
 *   <li>{@code id} — sequence {@code coffee_sales_hourly_id_seq}</li>
 *   <li>{@code sale_time} — varchar(10); the raw string ("HH:mm" or "HH:mm:ss") is kept as-is here,
 *       callers that need a {@link java.time.LocalTime} parse it themselves</li>
 *   <li>{@code quantity} — numeric(10,4); {@code price} / {@code total_price} — numeric(10,2)</li>
 * </ul>
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "coffee_sales_hourly")
public class CoffeeSalesHourly {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "sale_date", nullable = false)
    private LocalDate saleDate;

    @Column(name = "hour", nullable = false)
    private Integer hour;

    @Column(name = "sale_time", length = 10)
    private String saleTime;

    @Column(name = "coffee_name", nullable = false, length = 255)
    private String coffeeName;

    @Column(name = "quantity", nullable = false, precision = 10, scale = 4)
    private BigDecimal quantity;

    @Column(name = "price", nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(name = "total_price", nullable = false, precision = 10, scale = 2)
    private BigDecimal totalPrice;

    @Column(name = "category", length = 100)
    private String category;

    @Column(name = "created_at")
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "coffee_shop_name", length = 256)
    private String coffeeShopName;
}
