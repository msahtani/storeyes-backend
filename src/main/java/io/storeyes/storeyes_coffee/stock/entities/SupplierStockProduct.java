package io.storeyes.storeyes_coffee.stock.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(
    name = "supplier_stock_products",
    uniqueConstraints = @UniqueConstraint(
        name = "uq_supplier_stock_product",
        columnNames = {"supplier_id", "stock_product_id"}
    ),
    indexes = {
        @Index(name = "idx_supplier_stock_supplier_id", columnList = "supplier_id"),
        @Index(name = "idx_supplier_stock_product_id", columnList = "stock_product_id")
    }
)
public class SupplierStockProduct {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id", nullable = false)
    private Supplier supplier;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "stock_product_id", nullable = false)
    private StockProduct stockProduct;

    @Column(name = "supplier_sku", length = 120)
    private String supplierSku;

    @Column(name = "is_preferred", nullable = false)
    @Builder.Default
    private Boolean isPreferred = false;

    @Column(name = "created_at", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
