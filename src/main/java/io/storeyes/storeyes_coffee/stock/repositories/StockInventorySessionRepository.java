package io.storeyes.storeyes_coffee.stock.repositories;

import io.storeyes.storeyes_coffee.stock.entities.StockInventorySession;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StockInventorySessionRepository extends JpaRepository<StockInventorySession, Long> {

    List<StockInventorySession> findByStoreIdOrderByStartedAtDesc(Long storeId, Pageable pageable);
}
