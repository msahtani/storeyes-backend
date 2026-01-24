package io.storeyes.storeyes_coffee.charges.entities;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(
    name = "personnel_week_salaries",
    indexes = {
        @Index(name = "idx_week_salaries_employee_week", columnList = "personnel_employee_id,week_key"),
        @Index(name = "idx_week_salaries_week", columnList = "week_key"),
        @Index(name = "idx_week_salaries_month", columnList = "month_key"),
        @Index(name = "idx_week_salaries_employee", columnList = "personnel_employee_id")
    },
    uniqueConstraints = {
        @UniqueConstraint(name = "uk_personnel_week_salary", columnNames = {"personnel_employee_id", "week_key"})
    }
)
public class PersonnelWeekSalary {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "personnel_week_salary_id_seq")
    @SequenceGenerator(name = "personnel_week_salary_id_seq", sequenceName = "personnel_week_salary_id_seq", allocationSize = 1)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "personnel_employee_id", nullable = false)
    private PersonnelEmployee personnelEmployee;

    @Column(name = "week_key", nullable = false, length = 10)
    private String weekKey; // Format: "YYYY-MM-DD" (Monday date)

    @Column(name = "amount", nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    @Column(name = "days_in_month", nullable = false)
    @Builder.Default
    private Integer daysInMonth = 7; // Always 7 for weeks that belong to the month (full week)

    @Column(name = "month_key", nullable = false, length = 7)
    private String monthKey; // The month this week belongs to (where Monday falls) Format: "YYYY-MM"

    @Column(name = "created_at", nullable = false, updatable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}
