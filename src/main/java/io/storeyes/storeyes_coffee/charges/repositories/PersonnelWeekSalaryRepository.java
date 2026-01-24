package io.storeyes.storeyes_coffee.charges.repositories;

import io.storeyes.storeyes_coffee.charges.entities.PersonnelWeekSalary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PersonnelWeekSalaryRepository extends JpaRepository<PersonnelWeekSalary, Long> {
    
    /**
     * Find all week salaries for a personnel employee
     */
    List<PersonnelWeekSalary> findByPersonnelEmployeeId(Long personnelEmployeeId);
    
    /**
     * Find week salary by personnel employee and week key
     */
    Optional<PersonnelWeekSalary> findByPersonnelEmployeeIdAndWeekKey(Long personnelEmployeeId, String weekKey);
    
    /**
     * Find all week salaries for a specific week key
     */
    List<PersonnelWeekSalary> findByWeekKey(String weekKey);
    
    /**
     * Find all week salaries for a specific month key
     */
    List<PersonnelWeekSalary> findByMonthKey(String monthKey);
    
    /**
     * Delete all week salaries for a personnel employee
     */
    @Modifying
    @Query("DELETE FROM PersonnelWeekSalary pws WHERE pws.personnelEmployee.id = :personnelEmployeeId")
    void deleteByPersonnelEmployeeId(@Param("personnelEmployeeId") Long personnelEmployeeId);
    
    /**
     * Find week salaries by personnel employee and month key
     */
    @Query("SELECT pws FROM PersonnelWeekSalary pws WHERE pws.personnelEmployee.id = :personnelEmployeeId AND pws.monthKey = :monthKey")
    List<PersonnelWeekSalary> findByPersonnelEmployeeIdAndMonthKey(@Param("personnelEmployeeId") Long personnelEmployeeId, @Param("monthKey") String monthKey);
}
