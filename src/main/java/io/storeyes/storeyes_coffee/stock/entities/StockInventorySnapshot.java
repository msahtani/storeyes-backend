package io.storeyes.storeyes_coffee.stock.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(
    name = "stock_inventory_snapshots",
    uniqueConstraints = @UniqueConstraint(columnNames = { "session_id", "product_id" }),
    indexes = {
        @Index(name = "idx_stock_inventory_snapshots_session", columnList = "session_id"),
        @Index(name = "idx_stock_inventory_snapshots_product", columnList = "product_id"),
        @Index(name = "idx_stock_inventory_snapshots_product_created", columnList = "product_id,created_at")
    }
)
public class StockInventorySnapshot {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "session_id", nullable = false)
    private StockInventorySession session;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private StockProduct product;

    /** Quantity in human/counting unit (e.g. 3 plateau, 2 kg). */
    @Column(name = "counting_quantity", nullable = false, precision = 12, scale = 4)
    private BigDecimal countingQuantity;

    /** Quantity in base unit (for calculations). */
    @Column(name = "base_quantity", nullable = false, precision = 12, scale = 4)
    private BigDecimal baseQuantity;

    @Column(name = "created_at", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @CreationTimestamp
    private LocalDateTime createdAt;
}
