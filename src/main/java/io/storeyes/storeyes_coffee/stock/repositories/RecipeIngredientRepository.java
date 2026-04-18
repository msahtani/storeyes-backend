package io.storeyes.storeyes_coffee.stock.repositories;

import io.storeyes.storeyes_coffee.stock.entities.RecipeIngredient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RecipeIngredientRepository extends JpaRepository<RecipeIngredient, Long> {

    @Query("""
            SELECT DISTINCT r FROM RecipeIngredient r
            JOIN FETCH r.article
            JOIN FETCH r.product p
            JOIN FETCH p.store
            WHERE r.article.id = :articleId
            ORDER BY p.name
            """)
    List<RecipeIngredient> findByArticleIdOrderByProductName(@Param("articleId") Long articleId);

    Optional<RecipeIngredient> findByIdAndArticleId(Long id, Long articleId);

    Optional<RecipeIngredient> findByArticleIdAndProductId(Long articleId, Long productId);

    boolean existsByArticleIdAndProductId(Long articleId, Long productId);

    void deleteByArticleIdAndProductId(Long articleId, Long productId);

    void deleteByProduct_Id(Long productId);
}
