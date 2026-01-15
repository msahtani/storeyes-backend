package io.storeyes.storeyes_coffee.kpi.repositories;

import io.storeyes.storeyes_coffee.kpi.entities.DateDimension;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface DateDimensionRepository extends JpaRepository<DateDimension, Long> {
    
    /**
     * Find date dimension by date
     */
    Optional<DateDimension> findByDate(LocalDate date);
}

