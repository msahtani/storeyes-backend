package io.storeyes.storeyes_coffee.kpi.entities;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import io.storeyes.storeyes_coffee.store.entities.Store;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "fact_kpi_hourly")
public class FactKpiHourly {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "fact_kpi_hourly_id_seq")
    @SequenceGenerator(name = "fact_kpi_hourly_id_seq", sequenceName = "fact_kpi_hourly_id_seq", allocationSize = 1)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "store_id", nullable = false)
    private Store store;

    @ManyToOne
    @JoinColumn(name = "date_id", nullable = false)
    private DateDimension date;

    @Column(name = "hour", nullable = false)
    private Integer hour;

    @Column(name = "transactions", nullable = false)
    private Integer transactions;

    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @Column(name = "revenue", nullable = false)
    private Double revenue;

    
}
