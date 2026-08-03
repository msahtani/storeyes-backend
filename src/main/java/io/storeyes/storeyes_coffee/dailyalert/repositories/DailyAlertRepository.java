package io.storeyes.storeyes_coffee.dailyalert.repositories;

import io.storeyes.storeyes_coffee.dailyalert.entities.DailyAlert;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface DailyAlertRepository extends JpaRepository<DailyAlert, Long> {

    Optional<DailyAlert> findByStoreIdAndDate(Long storeId, LocalDate date);
}
