package io.storeyes.storeyes_coffee.stock.services;

import io.storeyes.storeyes_coffee.charges.entities.VariableChargeSubCategory;
import io.storeyes.storeyes_coffee.charges.repositories.VariableChargeSubCategoryRepository;
import io.storeyes.storeyes_coffee.security.KeycloakTokenUtils;
import io.storeyes.storeyes_coffee.stock.dto.CreateStockProductRequest;
import io.storeyes.storeyes_coffee.stock.dto.StockProductResponse;
import io.storeyes.storeyes_coffee.stock.dto.UpdateStockProductRequest;
import io.storeyes.storeyes_coffee.stock.entities.StockProduct;
import io.storeyes.storeyes_coffee.stock.repositories.StockProductRepository;
import io.storeyes.storeyes_coffee.store.entities.Store;
import io.storeyes.storeyes_coffee.store.repositories.StoreRepository;
import io.storeyes.storeyes_coffee.store.services.StoreService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StockProductService {

    private final StockProductRepository stockProductRepository;
    private final VariableChargeSubCategoryRepository variableChargeSubCategoryRepository;
    private final StoreRepository storeRepository;
    private final StoreService storeService;

    private Long getStoreId() {
        String userId = KeycloakTokenUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User is not authenticated");
        }
        return storeService.getStoreByOwnerId(userId).getId();
    }

    /**
     * List products for the store (mobile and backoffice). Optional filter by subCategoryId and search.
     * GET /api/stock/products?subCategoryId=&search=
     */
    public List<StockProductResponse> getProducts(Long subCategoryId, String search) {
        Long storeId = getStoreId();
        List<StockProduct> products;

        // When a subCategoryId is provided, include products linked directly to that sub-category
        // AND to any of its children (sub-sub categories). This lets "Raw materials" return
        // its own products plus products of its children like Bar / Cuisine / Congelateur / Soda.
        if (subCategoryId != null && search != null && !search.isBlank()) {
            List<Long> relevantSubCategoryIds = getSubCategoryIdsWithChildren(subCategoryId);
            products = stockProductRepository.findByStoreIdAndSubCategoryIdInAndNameContainingIgnoreCaseOrderByNameAsc(
                    storeId, relevantSubCategoryIds, search.trim());
        } else if (subCategoryId != null) {
            List<Long> relevantSubCategoryIds = getSubCategoryIdsWithChildren(subCategoryId);
            products = stockProductRepository.findByStoreIdAndSubCategoryIdInOrderByNameAsc(storeId, relevantSubCategoryIds);
        } else if (search != null && !search.isBlank()) {
            products = stockProductRepository.findByStoreIdAndNameContainingIgnoreCaseOrderByNameAsc(storeId, search.trim());
        } else {
            products = stockProductRepository.findByStoreIdOrderByNameAsc(storeId);
        }
        return products.stream().map(this::toResponse).collect(Collectors.toList());
    }

    private List<Long> getSubCategoryIdsWithChildren(Long subCategoryId) {
        List<Long> ids = variableChargeSubCategoryRepository.findByParentSubCategoryIdOrderBySortOrderAsc(subCategoryId)
                .stream()
                .map(sc -> sc.getId())
                .collect(Collectors.toList());
        ids.add(subCategoryId);
        return ids;
    }

    /**
     * Get one product by ID. Store-scoped.
     */
    public StockProductResponse getProductById(Long id) {
        Long storeId = getStoreId();
        StockProduct product = stockProductRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Stock product not found with id: " + id));
        if (!product.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Stock product not found with id: " + id);
        }
        return toResponse(product);
    }

    /**
     * Create a new stock product. Validates subCategoryId belongs to store.
     */
    @Transactional
    public StockProductResponse createProduct(CreateStockProductRequest request) {
        Long storeId = getStoreId();
        Store store = storeRepository.findById(storeId)
                .orElseThrow(() -> new RuntimeException("Store not found with id: " + storeId));

        VariableChargeSubCategory subCategory = variableChargeSubCategoryRepository.findById(request.getSubCategoryId())
                .orElseThrow(() -> new RuntimeException("Sub-category not found with id: " + request.getSubCategoryId()));
        if (!subCategory.getMainCategory().getStore().getId().equals(storeId)) {
            throw new RuntimeException("Sub-category does not belong to your store");
        }

        BigDecimal threshold = request.getMinimalThreshold() != null ? request.getMinimalThreshold() : BigDecimal.ZERO;
        BigDecimal unitPrice = request.getUnitPrice() != null ? request.getUnitPrice() : BigDecimal.ZERO;

        StockProduct product = StockProduct.builder()
                .store(store)
                .subCategory(subCategory)
                .name(request.getName().trim())
                .unit(request.getUnit().trim())
                .unitPrice(unitPrice)
                .minimalThreshold(threshold)
                .countingUnit(request.getCountingUnit() != null ? request.getCountingUnit().trim() : null)
                .basePerCountingUnit(request.getBasePerCountingUnit())
                .build();

        StockProduct saved = stockProductRepository.save(product);
        return toResponse(saved);
    }

    /**
     * Update a stock product. Store-scoped. Validates subCategoryId if provided.
     */
    @Transactional
    public StockProductResponse updateProduct(Long id, UpdateStockProductRequest request) {
        Long storeId = getStoreId();
        StockProduct product = stockProductRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Stock product not found with id: " + id));
        if (!product.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Stock product not found with id: " + id);
        }

        if (request.getName() != null) {
            product.setName(request.getName().trim());
        }
        if (request.getSubCategoryId() != null) {
            VariableChargeSubCategory subCategory = variableChargeSubCategoryRepository.findById(request.getSubCategoryId())
                    .orElseThrow(() -> new RuntimeException("Sub-category not found with id: " + request.getSubCategoryId()));
            if (!subCategory.getMainCategory().getStore().getId().equals(storeId)) {
                throw new RuntimeException("Sub-category does not belong to your store");
            }
            product.setSubCategory(subCategory);
        }
        if (request.getUnit() != null) {
            product.setUnit(request.getUnit().trim());
        }
        if (request.getUnitPrice() != null) {
            product.setUnitPrice(request.getUnitPrice());
        }
        if (request.getMinimalThreshold() != null) {
            product.setMinimalThreshold(request.getMinimalThreshold());
        }
        if (request.getCountingUnit() != null) {
            product.setCountingUnit(request.getCountingUnit().trim().isEmpty() ? null : request.getCountingUnit().trim());
        }
        if (request.getBasePerCountingUnit() != null) {
            product.setBasePerCountingUnit(request.getBasePerCountingUnit());
        }

        StockProduct updated = stockProductRepository.save(product);
        return toResponse(updated);
    }

    /**
     * Delete a stock product. Store-scoped.
     */
    @Transactional
    public void deleteProduct(Long id) {
        Long storeId = getStoreId();
        StockProduct product = stockProductRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Stock product not found with id: " + id));
        if (!product.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Stock product not found with id: " + id);
        }
        stockProductRepository.deleteById(id);
    }

    private StockProductResponse toResponse(StockProduct product) {
        return StockProductResponse.builder()
                .id(product.getId())
                .name(product.getName())
                .unit(product.getUnit())
                .unitPrice(product.getUnitPrice())
                .minimalThreshold(product.getMinimalThreshold())
                .subCategoryId(product.getSubCategory().getId())
                .subCategoryName(product.getSubCategory().getName())
                .countingUnit(product.getCountingUnit())
                .basePerCountingUnit(product.getBasePerCountingUnit())
                .createdAt(product.getCreatedAt())
                .updatedAt(product.getUpdatedAt())
                .build();
    }
}
