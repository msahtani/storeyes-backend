package io.storeyes.storeyes_coffee.stock.services;

import io.storeyes.storeyes_coffee.stock.entities.RecipeIngredient;
import io.storeyes.storeyes_coffee.stock.entities.StockMovement;
import io.storeyes.storeyes_coffee.stock.entities.StockMovementType;
import io.storeyes.storeyes_coffee.stock.repositories.RecipeIngredientRepository;
import io.storeyes.storeyes_coffee.stock.repositories.StockMovementRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.List;

/**
 * Creates CONSUMPTION movements when articles (sales products) are sold.
 * Each ingredient movement carries an amount = consumedQty * avgPurchaseCost
 * so that estimated stock value correctly decreases with sales.
 */
@Service
@RequiredArgsConstructor
public class StockConsumptionService {

    private static final String REFERENCE_TYPE_ARTICLE_SALE = "ARTICLE_SALE";

    private final RecipeIngredientRepository recipeIngredientRepository;
    private final StockMovementRepository stockMovementRepository;

    @Transactional
    public void createConsumptionForArticleSale(Long storeId, Long articleId, BigDecimal quantitySold, LocalDate saleDate, Long referenceId) {
        if (quantitySold == null || quantitySold.compareTo(BigDecimal.ZERO) <= 0) {
            return;
        }
        List<RecipeIngredient> ingredients = recipeIngredientRepository.findByArticleIdOrderByProductName(articleId);
        for (RecipeIngredient ri : ingredients) {
            if (ri.getProduct() == null || ri.getQuantity() == null) continue;
            if (!ri.getArticle().getStore().getId().equals(storeId)) continue;

            BigDecimal consumedAbs = ri.getQuantity().multiply(quantitySold);
            BigDecimal consumed = consumedAbs.negate();

            BigDecimal avgCost = stockMovementRepository.getAveragePurchaseCostPerUnit(storeId, ri.getProduct().getId());
            BigDecimal movementAmount = null;
            if (avgCost != null && avgCost.compareTo(BigDecimal.ZERO) > 0) {
                movementAmount = consumedAbs.multiply(avgCost).setScale(2, RoundingMode.HALF_UP);
            }

            StockMovement movement = StockMovement.builder()
                    .store(ri.getArticle().getStore())
                    .product(ri.getProduct())
                    .type(StockMovementType.CONSUMPTION)
                    .quantity(consumed)
                    .amount(movementAmount)
                    .movementDate(saleDate)
                    .referenceType(REFERENCE_TYPE_ARTICLE_SALE)
                    .referenceId(referenceId)
                    .notes("Consumption from article sale: " + ri.getArticle().getName() + " x " + quantitySold)
                    .build();
            stockMovementRepository.save(movement);
        }
    }
}
