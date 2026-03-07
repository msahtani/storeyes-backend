package io.storeyes.storeyes_coffee.stock.services;

import io.storeyes.storeyes_coffee.security.KeycloakTokenUtils;
import io.storeyes.storeyes_coffee.stock.dto.CreateRecipeIngredientRequest;
import io.storeyes.storeyes_coffee.stock.dto.RecipeIngredientResponse;
import io.storeyes.storeyes_coffee.stock.dto.UpdateRecipeIngredientRequest;
import io.storeyes.storeyes_coffee.stock.entities.Article;
import io.storeyes.storeyes_coffee.stock.entities.RecipeIngredient;
import io.storeyes.storeyes_coffee.stock.entities.StockProduct;
import io.storeyes.storeyes_coffee.stock.repositories.RecipeIngredientRepository;
import io.storeyes.storeyes_coffee.stock.repositories.StockProductRepository;
import io.storeyes.storeyes_coffee.store.services.StoreService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecipeIngredientService {

    private final RecipeIngredientRepository recipeIngredientRepository;
    private final StockProductRepository stockProductRepository;
    private final ArticleService articleService;
    private final StoreService storeService;

    private Long getStoreId() {
        String userId = KeycloakTokenUtils.getUserId();
        if (userId == null) {
            throw new RuntimeException("User is not authenticated");
        }
        return storeService.getStoreByOwnerId(userId).getId();
    }

    public List<RecipeIngredientResponse> getRecipeByArticleId(Long articleId) {
        Long storeId = getStoreId();
        Article article = articleService.getArticleEntity(articleId, storeId);
        List<RecipeIngredient> list = recipeIngredientRepository.findByArticleIdOrderByProductName(article.getId());
        return list.stream().map(this::toResponse).collect(Collectors.toList());
    }

    public RecipeIngredientResponse getRecipeIngredientById(Long articleId, Long id) {
        Long storeId = getStoreId();
        articleService.getArticleEntity(articleId, storeId);
        RecipeIngredient ri = recipeIngredientRepository.findByIdAndArticleId(id, articleId)
                .orElseThrow(() -> new RuntimeException("Recipe ingredient not found with id: " + id));
        return toResponse(ri);
    }

    @Transactional
    public RecipeIngredientResponse createRecipeIngredient(Long articleId, CreateRecipeIngredientRequest request) {
        Long storeId = getStoreId();
        Article article = articleService.getArticleEntity(articleId, storeId);
        StockProduct product = stockProductRepository.findById(request.getProductId())
                .orElseThrow(() -> new RuntimeException("Stock product not found with id: " + request.getProductId()));
        if (!product.getStore().getId().equals(storeId)) {
            throw new RuntimeException("Stock product not found with id: " + request.getProductId());
        }
        if (recipeIngredientRepository.existsByArticleIdAndProductId(articleId, request.getProductId())) {
            throw new RuntimeException("This product is already in the recipe for this article");
        }
        RecipeIngredient ri = RecipeIngredient.builder()
                .article(article)
                .product(product)
                .quantity(request.getQuantity())
                .build();
        RecipeIngredient saved = recipeIngredientRepository.save(ri);
        return toResponse(saved);
    }

    @Transactional
    public RecipeIngredientResponse updateRecipeIngredient(Long articleId, Long id, UpdateRecipeIngredientRequest request) {
        Long storeId = getStoreId();
        articleService.getArticleEntity(articleId, storeId);
        RecipeIngredient ri = recipeIngredientRepository.findByIdAndArticleId(id, articleId)
                .orElseThrow(() -> new RuntimeException("Recipe ingredient not found with id: " + id));
        if (request.getQuantity() != null) {
            ri.setQuantity(request.getQuantity());
        }
        RecipeIngredient updated = recipeIngredientRepository.save(ri);
        return toResponse(updated);
    }

    @Transactional
    public void deleteRecipeIngredient(Long articleId, Long id) {
        Long storeId = getStoreId();
        articleService.getArticleEntity(articleId, storeId);
        if (!recipeIngredientRepository.findByIdAndArticleId(id, articleId).isPresent()) {
            throw new RuntimeException("Recipe ingredient not found with id: " + id);
        }
        recipeIngredientRepository.deleteById(id);
    }

    private RecipeIngredientResponse toResponse(RecipeIngredient ri) {
        return RecipeIngredientResponse.builder()
                .id(ri.getId())
                .articleId(ri.getArticle().getId())
                .productId(ri.getProduct().getId())
                .productName(ri.getProduct().getName())
                .productUnit(ri.getProduct().getUnit())
                .quantity(ri.getQuantity())
                .createdAt(ri.getCreatedAt())
                .build();
    }
}
