package io.storeyes.storeyes_coffee.stock.entities;

import io.storeyes.storeyes_coffee.store.entities.Store;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(
    name = "stock_inventory_sessions",
    indexes = {
        @Index(name = "idx_stock_inventory_sessions_store_id", columnList = "store_id"),
        @Index(name = "idx_stock_inventory_sessions_finished_at", columnList = "finished_at")
    }
)
public class StockInventorySession {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "store_id", nullable = false)
    private Store store;

    @Column(name = "started_at", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private LocalDateTime startedAt;

    @Column(name = "finished_at")
    @Temporal(TemporalType.TIMESTAMP)
    private LocalDateTime finishedAt;

    @Column(name = "notes", length = 500)
    private String notes;

    @Column(name = "created_at", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @CreationTimestamp
    private LocalDateTime createdAt;
}
