-- =============================================================================
-- STOCK + ARTICLES + RECIPES - COMPLETE SETUP FOR PGADMIN
-- =============================================================================
-- Execute in order. Run each section (separated by -- ----) one by one in pgAdmin.
-- Assumes: store_id = 2, stock_products already populated, stores table exists.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- STEP 0: FIX stock_products UNITS (already run? Skip if done)
-- -----------------------------------------------------------------------------
-- Aligns unit column with recipe usage (cl, g, ml). Sodas stay 'unit' (sold by bottle).

UPDATE stock_products SET unit = 'cl' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'lait';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'café';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'chocolat carraro';
UPDATE stock_products SET unit = 'ml' WHERE store_id = 2 AND LOWER(TRIM(name)) LIKE 'sirop%';
UPDATE stock_products SET unit = 'ml' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'sauce pistache';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND name = 'fraise';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND name = 'mangue';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND name = 'ananas';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND name = 'bannane';
UPDATE stock_products SET unit = 'L' WHERE store_id = 2 AND LOWER(name) LIKE 'eau sidi ali 0%';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'farine nouara';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND (LOWER(name) LIKE 'beure%' OR LOWER(name) LIKE 'beurre%');
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND LOWER(TRIM(name)) LIKE 'nutella%';


-- -----------------------------------------------------------------------------
-- STEP 1: CREATE articles TABLE
-- -----------------------------------------------------------------------------
-- Products sold to clients (Jus, Boisson chaude, Crepes, sandwich, etc.)

CREATE TABLE IF NOT EXISTS articles (
    id BIGSERIAL PRIMARY KEY,
    store_id BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    sale_price DECIMAL(12, 2) NOT NULL,
    category VARCHAR(100) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_articles_store_id ON articles(store_id);
CREATE INDEX IF NOT EXISTS idx_articles_store_name ON articles(store_id, name);


-- -----------------------------------------------------------------------------
-- STEP 2: CREATE recipe_ingredients TABLE
-- -----------------------------------------------------------------------------
-- Links articles to stock_products: which ingredients and how much per serving.
-- Used for automatic stock consumption when an article is sold.

CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id BIGSERIAL PRIMARY KEY,
    article_id BIGINT NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES stock_products(id) ON DELETE RESTRICT,
    quantity DECIMAL(12, 4) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(article_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_article ON recipe_ingredients(article_id);
CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_product ON recipe_ingredients(product_id);


-- -----------------------------------------------------------------------------
-- NEXT: DATA IMPORT (articles + recipe_ingredients)
-- -----------------------------------------------------------------------------
-- Use scripts/ingredient_to_stock_product_mapping.json and articles_parsed.json
-- to generate INSERT statements. A Python script can be created to output SQL
-- from Fich pour storeyes.xlsx.
-- See docs/STOCK_ARTICLES_RECIPES_IMPLEMENTATION.md for full guide.
