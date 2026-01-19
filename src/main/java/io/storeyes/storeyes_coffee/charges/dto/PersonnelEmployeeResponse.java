package io.storeyes.storeyes_coffee.charges.dto;

import io.storeyes.storeyes_coffee.charges.entities.EmployeeType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Response DTO for employee lookup (without salary information, as salary is charge-specific)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PersonnelEmployeeResponse {
    private Long id;
    private String name;
    private EmployeeType type;
    private String position;
    private LocalDate startDate;
}
