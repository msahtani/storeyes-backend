package io.storeyes.storeyes_coffee.stock.controllers;

import io.storeyes.storeyes_coffee.stock.dto.CreateRecipeIngredientRequest;
import io.storeyes.storeyes_coffee.stock.dto.RecipeIngredientResponse;
import io.storeyes.storeyes_coffee.stock.dto.UpdateRecipeIngredientRequest;
import io.storeyes.storeyes_coffee.stock.services.RecipeIngredientService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/stock/articles/{articleId}/recipes")
@RequiredArgsConstructor
public class RecipeIngredientController {

    private final RecipeIngredientService recipeIngredientService;

    /**
     * List recipe ingredients for an article.
     * GET /api/stock/articles/{articleId}/recipes
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getRecipeByArticleId(@PathVariable Long articleId) {
        List<RecipeIngredientResponse> list = recipeIngredientService.getRecipeByArticleId(articleId);
        Map<String, Object> response = new HashMap<>();
        response.put("data", list);
        response.put("message", "Recipe ingredients retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Get one recipe ingredient by ID (scoped to article).
     * GET /api/stock/articles/{articleId}/recipes/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getRecipeIngredientById(
            @PathVariable Long articleId,
            @PathVariable Long id) {
        RecipeIngredientResponse ri = recipeIngredientService.getRecipeIngredientById(articleId, id);
        Map<String, Object> response = new HashMap<>();
        response.put("data", ri);
        response.put("message", "Recipe ingredient retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Add a recipe line (product + quantity) to an article.
     * POST /api/stock/articles/{articleId}/recipes
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createRecipeIngredient(
            @PathVariable Long articleId,
            @Valid @RequestBody CreateRecipeIngredientRequest request) {
        RecipeIngredientResponse ri = recipeIngredientService.createRecipeIngredient(articleId, request);
        Map<String, Object> response = new HashMap<>();
        response.put("data", ri);
        response.put("message", "Recipe ingredient created successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Update quantity of a recipe ingredient.
     * PUT /api/stock/articles/{articleId}/recipes/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateRecipeIngredient(
            @PathVariable Long articleId,
            @PathVariable Long id,
            @Valid @RequestBody UpdateRecipeIngredientRequest request) {
        RecipeIngredientResponse ri = recipeIngredientService.updateRecipeIngredient(articleId, id, request);
        Map<String, Object> response = new HashMap<>();
        response.put("data", ri);
        response.put("message", "Recipe ingredient updated successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Remove a recipe ingredient from an article.
     * DELETE /api/stock/articles/{articleId}/recipes/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRecipeIngredient(
            @PathVariable Long articleId,
            @PathVariable Long id) {
        recipeIngredientService.deleteRecipeIngredient(articleId, id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
