package io.storeyes.storeyes_coffee.stock.entities;

import io.storeyes.storeyes_coffee.store.entities.Store;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(
    name = "stock_movements",
    indexes = {
        @Index(name = "idx_stock_movements_store_id", columnList = "store_id"),
        @Index(name = "idx_stock_movements_product_id", columnList = "product_id"),
        @Index(name = "idx_stock_movements_store_product", columnList = "store_id,product_id"),
        @Index(name = "idx_stock_movements_movement_date", columnList = "movement_date"),
        @Index(name = "idx_stock_movements_reference", columnList = "reference_type,reference_id")
    }
)
public class StockMovement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "store_id", nullable = false)
    private Store store;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id", nullable = false)
    private StockProduct product;

    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 50)
    private StockMovementType type;

    @Column(name = "quantity", nullable = false, precision = 12, scale = 2)
    private BigDecimal quantity;

    /** Total price (MAD) for this movement; for PURCHASE = amount paid (from variable_charge.amount). */
    @Column(name = "amount", precision = 12, scale = 2)
    private BigDecimal amount;

    @Column(name = "movement_date", nullable = false)
    @Temporal(TemporalType.DATE)
    private LocalDate movementDate;

    @Column(name = "reference_type", length = 50)
    private String referenceType;

    @Column(name = "reference_id")
    private Long referenceId;

    @Column(name = "notes", length = 500)
    private String notes;

    @Column(name = "created_at", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @CreationTimestamp
    private LocalDateTime createdAt;
}
