package io.storeyes.storeyes_coffee.charges.entities;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(
    name = "charge_employees",
    indexes = {
        @Index(name = "idx_charge_employees_fixed_charge", columnList = "fixed_charge_id"),
        @Index(name = "idx_charge_employees_employee", columnList = "employee_id"),
        @Index(name = "idx_charge_employees_charge_employee", columnList = "fixed_charge_id,employee_id")
    },
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_charge_employee", columnNames = {"fixed_charge_id", "employee_id"})
    }
)
public class ChargeEmployee {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "charge_employee_id_seq")
    @SequenceGenerator(name = "charge_employee_id_seq", sequenceName = "charge_employee_id_seq", allocationSize = 1)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "fixed_charge_id", nullable = false)
    private FixedCharge fixedCharge;

    @ManyToOne
    @JoinColumn(name = "employee_id", nullable = false)
    private Employee employee;

    @Column(name = "salary", precision = 10, scale = 2)
    private BigDecimal salary;

    @Column(name = "hours")
    private Integer hours;

    @Column(name = "salary_by_period", length = 10)
    @Enumerated(EnumType.STRING)
    private SalaryByPeriod salaryByPeriod;

    @Column(name = "week_salary", precision = 10, scale = 2)
    private BigDecimal weekSalary; // Deprecated, kept for backward compatibility

    @Column(name = "month_salary", precision = 10, scale = 2)
    private BigDecimal monthSalary;

    @Column(name = "days_left_salary", precision = 10, scale = 2)
    private BigDecimal daysLeftSalary;

    @Column(name = "week_salaries", columnDefinition = "TEXT")
    private String weekSalariesJson; // Stored as JSON string

    // Transient field for easier access (converted from JSON)
    @Transient
    @Builder.Default
    private Map<String, BigDecimal> weekSalaries = new HashMap<>();

    /**
     * Convert weekSalaries map to JSON string before persisting
     */
    @PrePersist
    @PreUpdate
    public void convertWeekSalariesToJson() {
        try {
            if (weekSalaries != null) {
                this.weekSalariesJson = objectMapper.writeValueAsString(weekSalaries);
            } else if (weekSalariesJson == null) {
                this.weekSalariesJson = "{}";
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to convert weekSalaries to JSON", e);
        }
    }

    /**
     * Convert JSON string to weekSalaries map after loading
     */
    @PostLoad
    public void convertJsonToWeekSalaries() {
        try {
            if (weekSalariesJson != null && !weekSalariesJson.isEmpty()) {
                TypeReference<Map<String, BigDecimal>> typeRef = new TypeReference<Map<String, BigDecimal>>() {};
                this.weekSalaries = objectMapper.readValue(weekSalariesJson, typeRef);
            } else {
                this.weekSalaries = new HashMap<>();
            }
        } catch (Exception e) {
            this.weekSalaries = new HashMap<>();
        }
    }
}
