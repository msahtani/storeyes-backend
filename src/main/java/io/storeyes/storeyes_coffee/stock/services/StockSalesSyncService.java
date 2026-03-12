package io.storeyes.storeyes_coffee.stock.services;

import io.storeyes.storeyes_coffee.product.entities.SalesProduct;
import io.storeyes.storeyes_coffee.product.repositories.SalesProductRepository;
import io.storeyes.storeyes_coffee.security.KeycloakTokenUtils;
import io.storeyes.storeyes_coffee.stock.entities.Article;
import io.storeyes.storeyes_coffee.stock.repositories.ArticleRepository;
import io.storeyes.storeyes_coffee.stock.repositories.StockMovementRepository;
import io.storeyes.storeyes_coffee.store.services.StoreService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Sync daily sales (SalesProduct) into stock consumption movements.
 * For each SalesProduct row, we:
 * - Find the matching Article (by name, case-insensitive, same store)
 * - Create ARTICLE_SALE CONSUMPTION movements using StockConsumptionService and recipe_ingredients
 * - Mark the movement with referenceType=ARTICLE_SALE and referenceId=sales_product.id for idempotency
 *
 * This drives the "estimated" stock in getInventorySummary (PURCHASE + ADJUSTMENT + ARTICLE_SALE).
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class StockSalesSyncService {

    private static final String REFERENCE_TYPE_ARTICLE_SALE = "ARTICLE_SALE";

    private final SalesProductRepository salesProductRepository;
    private final ArticleRepository articleRepository;
    private final StockMovementRepository stockMovementRepository;
    private final StockConsumptionService stockConsumptionService;
    private final StoreService storeService;

    private Long getStoreId() {
        String userId = KeycloakTokenUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User is not authenticated");
        }
        return storeService.getStoreByOwnerId(userId).getId();
    }

    /**
     * Apply sales for a given date: create ARTICLE_SALE movements for each SalesProduct row.
     * Idempotent: if movements already exist for a SalesProduct (referenceId), it is skipped.
     *
     * @param date sale date (matches SalesProduct.date)
     * @return number of SalesProduct rows that were converted into stock consumption (i.e. newly processed)
     */
    @Transactional
    public int applySalesForDate(LocalDate date) {
        Long storeId = getStoreId();
        List<SalesProduct> sales = salesProductRepository.findByStoreIdAndDate(storeId, date);
        if (sales.isEmpty()) {
            log.info("No SalesProduct rows for store {} and date {}", storeId, date);
            return 0;
        }

        int processed = 0;
        for (SalesProduct sp : sales) {
            if (sp == null || sp.getId() == null || sp.getProduct() == null) {
                continue;
            }
            // Skip if we already created ARTICLE_SALE movements for this sales_product
            if (stockMovementRepository.existsByReferenceTypeAndReferenceId(REFERENCE_TYPE_ARTICLE_SALE, sp.getId())) {
                continue;
            }

            String productName = sp.getProduct().getName();
            if (productName == null || productName.isBlank()) {
                continue;
            }

            Optional<Article> articleOpt =
                    articleRepository.findFirstByStoreIdAndNameIgnoreCase(storeId, productName.trim());
            if (articleOpt.isEmpty()) {
                log.warn("No Article found for SalesProduct id={} name='{}' storeId={}", sp.getId(), productName, storeId);
                continue;
            }
            Article article = articleOpt.get();

            Integer qtyInt = sp.getQuantity();
            if (qtyInt == null || qtyInt <= 0) {
                continue;
            }
            BigDecimal quantitySold = BigDecimal.valueOf(qtyInt);

            stockConsumptionService.createConsumptionForArticleSale(
                    storeId,
                    article.getId(),
                    quantitySold,
                    sp.getDate() != null ? sp.getDate() : date,
                    sp.getId()
            );
            processed++;
        }

        log.info("Applied sales for store {} and date {}: {} SalesProduct rows processed", storeId, date, processed);
        return processed;
    }
}

