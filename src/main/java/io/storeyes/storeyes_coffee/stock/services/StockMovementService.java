package io.storeyes.storeyes_coffee.stock.services;

import io.storeyes.storeyes_coffee.charges.entities.VariableCharge;
import io.storeyes.storeyes_coffee.security.KeycloakTokenUtils;
import io.storeyes.storeyes_coffee.stock.dto.StockInventoryItemResponse;
import io.storeyes.storeyes_coffee.stock.entities.StockMovement;
import io.storeyes.storeyes_coffee.stock.entities.StockMovementType;
import io.storeyes.storeyes_coffee.stock.entities.StockProduct;
import io.storeyes.storeyes_coffee.stock.repositories.StockMovementRepository;
import io.storeyes.storeyes_coffee.stock.repositories.StockProductRepository;
import io.storeyes.storeyes_coffee.store.services.StoreService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StockMovementService {

    private static final String REFERENCE_TYPE_VARIABLE_CHARGE = "VARIABLE_CHARGE";

    private final StockMovementRepository stockMovementRepository;
    private final StockProductRepository stockProductRepository;
    private final StoreService storeService;

    private Long getStoreId() {
        String userId = KeycloakTokenUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User is not authenticated");
        }
        return storeService.getStoreByOwnerId(userId).getId();
    }

    /**
     * Record a PURCHASE movement when a variable charge with a product is saved.
     * Uses quantity and amount (total price) from the charge.
     */
    @Transactional
    public void recordPurchase(VariableCharge charge) {
        if (charge.getProduct() == null || charge.getQuantity() == null || charge.getQuantity().compareTo(BigDecimal.ZERO) <= 0) {
            return;
        }
        if (stockMovementRepository.existsByReferenceTypeAndReferenceId(REFERENCE_TYPE_VARIABLE_CHARGE, charge.getId())) {
            return;
        }
        StockMovement movement = StockMovement.builder()
                .store(charge.getStore())
                .product(charge.getProduct())
                .type(StockMovementType.PURCHASE)
                .quantity(charge.getQuantity())
                .amount(charge.getAmount() != null ? charge.getAmount() : null)
                .movementDate(charge.getDate() != null ? charge.getDate() : LocalDate.now())
                .referenceType(REFERENCE_TYPE_VARIABLE_CHARGE)
                .referenceId(charge.getId())
                .notes(null)
                .build();
        stockMovementRepository.save(movement);
    }

    /**
     * Inventory summary: all products that have movements, with current quantity and total value.
     * Total value is based on purchase amounts (average cost), not product.unitPrice.
     */
    public List<StockInventoryItemResponse> getInventorySummary() {
        Long storeId = getStoreId();
        List<Object[]> rows = stockMovementRepository.getInventorySummaryByStore(storeId);
        if (rows.isEmpty()) {
            return List.of();
        }
        List<Long> productIds = rows.stream()
                .map(r -> ((Number) r[0]).longValue())
                .distinct()
                .toList();
        Map<Long, StockProduct> productsById = stockProductRepository.findAllById(productIds).stream()
                .collect(Collectors.toMap(StockProduct::getId, p -> p));

        return rows.stream()
                .map(r -> {
                    Long productId = ((Number) r[0]).longValue();
                    BigDecimal currentQuantity = r[1] != null ? new BigDecimal(r[1].toString()) : BigDecimal.ZERO;
                    BigDecimal totalPurchaseAmount = r[2] != null ? new BigDecimal(r[2].toString()) : BigDecimal.ZERO;
                    BigDecimal totalPurchaseQuantity = r[3] != null ? new BigDecimal(r[3].toString()) : BigDecimal.ZERO;

                    BigDecimal averageUnitCost = BigDecimal.ZERO;
                    if (totalPurchaseQuantity.compareTo(BigDecimal.ZERO) > 0 && totalPurchaseAmount.compareTo(BigDecimal.ZERO) > 0) {
                        averageUnitCost = totalPurchaseAmount.divide(totalPurchaseQuantity, 4, RoundingMode.HALF_UP);
                    }
                    BigDecimal totalValue = currentQuantity.multiply(averageUnitCost).setScale(2, RoundingMode.HALF_UP);

                    StockProduct product = productsById.get(productId);
                    return StockInventoryItemResponse.builder()
                            .productId(productId)
                            .productName(product != null ? product.getName() : null)
                            .unit(product != null ? product.getUnit() : null)
                            .subCategoryId(product != null && product.getSubCategory() != null ? product.getSubCategory().getId() : null)
                            .subCategoryName(product != null && product.getSubCategory() != null ? product.getSubCategory().getName() : null)
                            .currentQuantity(currentQuantity)
                            .totalPurchaseAmount(totalPurchaseAmount)
                            .averageUnitCost(averageUnitCost)
                            .totalValue(totalValue)
                            .build();
                })
                .toList();
    }
}
