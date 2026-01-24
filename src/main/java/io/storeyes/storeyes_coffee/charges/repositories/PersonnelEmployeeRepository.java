package io.storeyes.storeyes_coffee.charges.repositories;

import io.storeyes.storeyes_coffee.charges.entities.EmployeeType;
import io.storeyes.storeyes_coffee.charges.entities.PersonnelEmployee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PersonnelEmployeeRepository extends JpaRepository<PersonnelEmployee, Long> {
    
    /**
     * Find employees by fixed charge
     */
    List<PersonnelEmployee> findByFixedChargeId(Long fixedChargeId);
    
    /**
     * Find distinct employees for reuse (employee lookup)
     * Returns employees filtered by store and type
     * Note: Service layer groups by name, type, position, and startDate to remove duplicates
     */
    @Query("SELECT pe FROM PersonnelEmployee pe WHERE pe.fixedCharge.store.id = :storeId AND " +
           "(:type IS NULL OR pe.type = :type) " +
           "ORDER BY pe.name ASC, pe.id ASC")
    List<PersonnelEmployee> findDistinctEmployeesForReuse(@Param("storeId") Long storeId, @Param("type") EmployeeType type);
}
