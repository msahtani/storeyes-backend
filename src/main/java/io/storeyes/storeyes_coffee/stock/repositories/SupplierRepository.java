package io.storeyes.storeyes_coffee.stock.repositories;

import io.storeyes.storeyes_coffee.stock.entities.Supplier;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SupplierRepository extends JpaRepository<Supplier, Long> {

    List<Supplier> findByStoreIdAndIsActiveTrueOrderByNameAsc(Long storeId);

    List<Supplier> findByStoreIdAndIsActiveTrueAndNameContainingIgnoreCaseOrderByNameAsc(Long storeId, String search);

    List<Supplier> findByStoreIdOrderByIsActiveDescNameAsc(Long storeId);

    List<Supplier> findByStoreIdAndNameContainingIgnoreCaseOrderByIsActiveDescNameAsc(Long storeId, String name);

    Optional<Supplier> findByIdAndStore_Id(Long id, Long storeId);
}
