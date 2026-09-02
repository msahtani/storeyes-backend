package io.storeyes.storeyes_coffee.alerts.repositories;

import io.storeyes.storeyes_coffee.alerts.entities.Alert;
import io.storeyes.storeyes_coffee.alerts.entities.AlertType;
import io.storeyes.storeyes_coffee.alerts.entities.HumanJudgement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AlertRepository extends JpaRepository<Alert, Long> {

    // Find unprocessed alerts by exact date (day) and store ID
    @Query("SELECT a FROM Alert a WHERE DATE(a.alertDate) = DATE(:date) AND a.isProcessed = false AND a.store.id = :storeId ORDER BY a.alertDate DESC")
    List<Alert> findUnprocessedByAlertDateAndStoreId(LocalDateTime date, Long storeId);

    // Default alerts list by exact date (day) and store ID:
    // processed alerts, plus unprocessed alerts already judged TRUE_POSITIVE
    @Query("SELECT a FROM Alert a WHERE DATE(a.alertDate) = DATE(:date) AND a.store.id = :storeId "
            + "AND (a.isProcessed = true OR a.humanJudgement = io.storeyes.storeyes_coffee.alerts.entities.HumanJudgement.TRUE_POSITIVE) "
            + "ORDER BY a.alertDate DESC")
    List<Alert> findDefaultListByAlertDateAndStoreId(LocalDateTime date, Long storeId);

    // Default alerts list within a date range and store ID:
    // processed alerts, plus unprocessed alerts already judged TRUE_POSITIVE
    @Query("SELECT a FROM Alert a WHERE a.alertDate >= :startDate AND a.alertDate <= :endDate AND a.store.id = :storeId "
            + "AND (a.isProcessed = true OR a.humanJudgement = io.storeyes.storeyes_coffee.alerts.entities.HumanJudgement.TRUE_POSITIVE) "
            + "ORDER BY a.alertDate DESC")
    List<Alert> findDefaultListByAlertDateBetweenAndStoreId(
        LocalDateTime startDate,
        LocalDateTime endDate,
        Long storeId
    );
    
    // Find unprocessed alerts within a date range and store ID
    @Query("SELECT a FROM Alert a WHERE a.alertDate >= :startDate AND a.alertDate <= :endDate AND a.isProcessed = false AND a.store.id = :storeId ORDER BY a.alertDate DESC")
    List<Alert> findUnprocessedByAlertDateBetweenAndStoreId(
        LocalDateTime startDate,
        LocalDateTime endDate,
        Long storeId
    );
    
    // Find all alerts by exact date (day) and store ID ordered by alertDate ascending (chronologically)
    @Query("SELECT a FROM Alert a WHERE DATE(a.alertDate) = :date AND a.store.id = :storeId ORDER BY a.alertDate ASC")
    List<Alert> findByAlertDateAndStoreIdOrderByAlertDateAsc(LocalDate date, Long storeId);

    // Update human judgement directly via query
    @Modifying
    @Query("UPDATE Alert a SET a.humanJudgement = :judgement, a.updatedAt = :updatedAt WHERE a.id = :id")
    int updateHumanJudgement(
        Long id,
        HumanJudgement judgement,
        LocalDateTime updatedAt
    );

    // Update (or clear, when alertClassId is null) the alert's classification tag
    @Modifying
    @Query("UPDATE Alert a SET a.alertClassId = :alertClassId, a.updatedAt = :updatedAt WHERE a.id = :id")
    int updateAlertClassId(
        Long id,
        Long alertClassId,
        LocalDateTime updatedAt
    );
    
    /**
     * Count of alerts for a store on a calendar day ({@code DATE(alert_date) = DATE(:dayStart)})
     * shown on the default alerts list: processed alerts, plus unprocessed alerts judged
     * {@code TRUE_POSITIVE}, restricted to the human judgements in {@code :judgements}
     * ({@code NEW}, {@code TRUE_POSITIVE}).
     */
    @Query("SELECT COUNT(a) FROM Alert a WHERE a.store.id = :storeId "
            + "AND (a.isProcessed = true OR a.humanJudgement = io.storeyes.storeyes_coffee.alerts.entities.HumanJudgement.TRUE_POSITIVE) "
            + "AND DATE(a.alertDate) = DATE(:dayStart) "
            + "AND a.humanJudgement IN :judgements")
    long countProcessedHomeAlertsByDay(
            @Param("storeId") Long storeId,
            @Param("dayStart") LocalDateTime dayStart,
            @Param("judgements") List<HumanJudgement> judgements);

    /**
     * Same as {@link #countProcessedHomeAlertsByDay} but restricted to the given alert types
     * (per-store alert-type visibility). Rows with a null alertType count as NOT_TAPPED,
     * included when {@code includeNullType} is true.
     */
    @Query("SELECT COUNT(a) FROM Alert a WHERE a.store.id = :storeId "
            + "AND (a.isProcessed = true OR a.humanJudgement = io.storeyes.storeyes_coffee.alerts.entities.HumanJudgement.TRUE_POSITIVE) "
            + "AND DATE(a.alertDate) = DATE(:dayStart) "
            + "AND a.humanJudgement IN :judgements "
            + "AND (a.alertType IN :alertTypes OR (:includeNullType = true AND a.alertType IS NULL))")
    long countProcessedHomeAlertsByDayAndTypes(
            @Param("storeId") Long storeId,
            @Param("dayStart") LocalDateTime dayStart,
            @Param("judgements") List<HumanJudgement> judgements,
            @Param("alertTypes") List<AlertType> alertTypes,
            @Param("includeNullType") boolean includeNullType);
}

