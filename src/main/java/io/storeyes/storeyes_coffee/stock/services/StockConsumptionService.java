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
import java.time.LocalDate;
import java.util.List;

/**
 * Creates CONSUMPTION movements when articles (sales products) are sold.
 * Call {@link #createConsumptionForArticleSale} from your order/sales flow when an article is sold.
 */
@Service
@RequiredArgsConstructor
public class StockConsumptionService {

    private static final String REFERENCE_TYPE_ARTICLE_SALE = "ARTICLE_SALE";

    private final RecipeIngredientRepository recipeIngredientRepository;
    private final StockMovementRepository stockMovementRepository;

    /**
     * Create CONSUMPTION movements for each recipe ingredient when an article is sold.
     *
     * @param storeId      store id
     * @param articleId    article (sales product) id
     * @param quantitySold quantity of article sold (e.g. 2 cups)
     * @param saleDate     date of sale
     * @param referenceId  external reference (e.g. order_id, sale_id) for traceability
     */
    @Transactional
    public void createConsumptionForArticleSale(Long storeId, Long articleId, BigDecimal quantitySold, LocalDate saleDate, Long referenceId) {
        if (quantitySold == null || quantitySold.compareTo(BigDecimal.ZERO) <= 0) {
            return;
        }
        List<RecipeIngredient> ingredients = recipeIngredientRepository.findByArticleIdOrderByProductName(articleId);
        for (RecipeIngredient ri : ingredients) {
            if (ri.getProduct() == null || ri.getQuantity() == null) continue;
            if (!ri.getArticle().getStore().getId().equals(storeId)) continue;

            BigDecimal consumed = ri.getQuantity().multiply(quantitySold).negate();
            StockMovement movement = StockMovement.builder()
                    .store(ri.getArticle().getStore())
                    .product(ri.getProduct())
                    .type(StockMovementType.CONSUMPTION)
                    .quantity(consumed)
                    .amount(null)
                    .movementDate(saleDate)
                    .referenceType(REFERENCE_TYPE_ARTICLE_SALE)
                    .referenceId(referenceId)
                    .notes("Consumption from article sale: " + ri.getArticle().getName() + " x " + quantitySold)
                    .build();
            stockMovementRepository.save(movement);
        }
    }
}
