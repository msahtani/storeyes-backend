package io.storeyes.storeyes_coffee.charges.dto;

import io.storeyes.storeyes_coffee.charges.entities.EmployeeType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PersonnelDataDTO {
    private EmployeeType type;
    private BigDecimal totalAmount;
    private List<PersonnelEmployeeDTO> employees;
}
