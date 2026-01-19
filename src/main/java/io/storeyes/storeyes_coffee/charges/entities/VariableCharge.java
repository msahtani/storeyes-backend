package io.storeyes.storeyes_coffee.charges.entities;

import io.storeyes.storeyes_coffee.store.entities.Store;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(
    name = "variable_charges",
    indexes = {
        @Index(name = "idx_variable_charges_store", columnList = "store_id"),
        @Index(name = "idx_variable_charges_date", columnList = "date"),
        @Index(name = "idx_variable_charges_category", columnList = "category"),
        @Index(name = "idx_variable_charges_store_date", columnList = "store_id,date")
    }
)
public class VariableCharge {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "variable_charge_id_seq")
    @SequenceGenerator(name = "variable_charge_id_seq", sequenceName = "variable_charge_id_seq", allocationSize = 1)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "store_id", nullable = false)
    private Store store;

    @Column(name = "name", nullable = false, length = 200)
    private String name;

    @Column(name = "amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @Column(name = "date", nullable = false)
    @Temporal(TemporalType.DATE)
    private LocalDate date;

    @Column(name = "category", nullable = false, length = 50)
    private String category;

    @Column(name = "supplier", length = 200)
    private String supplier;

    @Column(name = "notes", length = 1000)
    private String notes;

    @Column(name = "purchase_order_url", length = 500)
    private String purchaseOrderUrl;

    @Column(name = "created_at", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
