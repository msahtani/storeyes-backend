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
@Table(name = "top_product_kpi_facts")
public class FactKpiProductDaily {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "fact_kpi_product_daily_id_seq")
    @SequenceGenerator(name = "fact_kpi_product_daily_id_seq", sequenceName = "fact_kpi_product_daily_id_seq", allocationSize = 1)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "date_id", nullable = false)
    private DateDimension date;

    @ManyToOne
    @JoinColumn(name = "store_id", nullable = false)
    private Store store;

    @Column(name = "product_name", nullable = false)
    private String productName;

    @Column(name = "unit_price", nullable = false)
    private Double unitPrice;

    @Column(name = "quantity", nullable = false)
    private Integer quantity;

    @Column(name = "revenue", nullable = false)
    private Double revenue;

   
}
