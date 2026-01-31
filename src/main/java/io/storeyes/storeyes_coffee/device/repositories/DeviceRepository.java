package io.storeyes.storeyes_coffee.device.repositories;

import io.storeyes.storeyes_coffee.device.entities.Device;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DeviceRepository extends JpaRepository<Device, Long> {
    
    /**
     * Find device by board ID
     */
    Optional<Device> findByBoardId(String boardId);
    
    /**
     * Get store ID by board ID
     */
    @Query("SELECT d.store.id FROM Device d WHERE d.boardId = :boardId")
    Optional<Long> findStoreIdByBoardId(@Param("boardId") String boardId);
}

