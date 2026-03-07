package io.storeyes.storeyes_coffee.stock.controllers;

import io.storeyes.storeyes_coffee.stock.dto.ArticleResponse;
import io.storeyes.storeyes_coffee.stock.dto.CreateArticleRequest;
import io.storeyes.storeyes_coffee.stock.dto.UpdateArticleRequest;
import io.storeyes.storeyes_coffee.stock.services.ArticleService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/stock/articles")
@RequiredArgsConstructor
public class ArticleController {

    private final ArticleService articleService;

    /**
     * List sales products (articles) for the store. Optional filters: category, search.
     * GET /api/stock/articles?category=&search=
     */
    @GetMapping
    public ResponseEntity<Map<String, Object>> getArticles(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String search) {
        List<ArticleResponse> articles = articleService.getArticles(category, search);
        Map<String, Object> response = new HashMap<>();
        response.put("data", articles);
        response.put("message", "Articles retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Get article by ID.
     * GET /api/stock/articles/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getArticleById(@PathVariable Long id) {
        ArticleResponse article = articleService.getArticleById(id);
        Map<String, Object> response = new HashMap<>();
        response.put("data", article);
        response.put("message", "Article retrieved successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Create article.
     * POST /api/stock/articles
     */
    @PostMapping
    public ResponseEntity<Map<String, Object>> createArticle(
            @Valid @RequestBody CreateArticleRequest request) {
        ArticleResponse article = articleService.createArticle(request);
        Map<String, Object> response = new HashMap<>();
        response.put("data", article);
        response.put("message", "Article created successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Update article.
     * PUT /api/stock/articles/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateArticle(
            @PathVariable Long id,
            @Valid @RequestBody UpdateArticleRequest request) {
        ArticleResponse article = articleService.updateArticle(id, request);
        Map<String, Object> response = new HashMap<>();
        response.put("data", article);
        response.put("message", "Article updated successfully");
        response.put("timestamp", java.time.OffsetDateTime.now());
        return ResponseEntity.ok(response);
    }

    /**
     * Delete article.
     * DELETE /api/stock/articles/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteArticle(@PathVariable Long id) {
        articleService.deleteArticle(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }
}
