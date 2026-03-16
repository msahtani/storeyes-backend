package io.storeyes.storeyes_coffee.stock.repositories;

import io.storeyes.storeyes_coffee.stock.entities.StockProduct;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StockProductRepository extends JpaRepository<StockProduct, Long> {

    List<StockProduct> findByStoreIdOrderByNameAsc(Long storeId);

    List<StockProduct> findByStoreIdAndSubCategoryIdOrderByNameAsc(Long storeId, Long subCategoryId);

    List<StockProduct> findByStoreIdAndNameContainingIgnoreCaseOrderByNameAsc(Long storeId, String search);

    List<StockProduct> findByStoreIdAndSubCategoryIdAndNameContainingIgnoreCaseOrderByNameAsc(
            Long storeId, Long subCategoryId, String search);

    List<StockProduct> findByStoreIdAndSubCategoryIdInOrderByNameAsc(Long storeId, List<Long> subCategoryIds);

    List<StockProduct> findByStoreIdAndSubCategoryIdInAndNameContainingIgnoreCaseOrderByNameAsc(
            Long storeId, List<Long> subCategoryIds, String search);
}
