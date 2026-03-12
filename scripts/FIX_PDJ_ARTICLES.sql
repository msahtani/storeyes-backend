-- =============================================================================
-- FIX: PDJ Articles - Replace category names with actual menu items
-- store_id = 2 | Run in pgAdmin | Execute in order
-- =============================================================================
-- Problem: The PDJ Excel sheet has a different column layout (sub-category in
-- column A, article name in column B). The parser captured the sub-category
-- names ("Pdj", "à la carte") as article names instead of the actual items.
-- =============================================================================

BEGIN;

-- =============================================================================
-- PART 1: Add missing stock product (salade) for PDJ recipes
-- =============================================================================
INSERT INTO stock_products (store_id, sub_category_id, name, unit, unit_price, minimal_threshold, created_at, updated_at)
SELECT 2,
       (SELECT sc.id FROM variable_charge_sub_categories sc
        JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id
        WHERE mc.store_id = 2 AND mc.code = 'stock' AND sc.code = 'kitchen'),
       'salade', 'g', 0, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM stock_products WHERE store_id = 2 AND LOWER(name) = 'salade');

-- =============================================================================
-- PART 2: Delete wrong PDJ articles and their recipe_ingredients
-- =============================================================================
DELETE FROM recipe_ingredients
WHERE article_id IN (SELECT id FROM articles WHERE store_id = 2 AND name IN ('Pdj', 'à la carte') AND category = 'PDJ');

DELETE FROM articles
WHERE store_id = 2 AND name IN ('Pdj', 'à la carte') AND category = 'PDJ';

-- =============================================================================
-- PART 3: Insert correct PDJ articles (12 items)
-- =============================================================================
-- Sub-category "Pdj" (7 items)
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'L''Express', 24.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'L''Express' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Le Classique', 36.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Le Classique' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Le Fassi', 39.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Le Fassi' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Le Casablanca', 39.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Le Casablanca' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Le Comptoir', 39.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Le Comptoir' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Le Gourmand', 44.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Le Gourmand' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Croffle Brunch', 44.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Croffle Brunch' AND category = 'PDJ');

-- Sub-category "à la carte" (5 items)
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Viennoiserie', 14.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Viennoiserie' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'M9ila Khlii', 28.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'M9ila Khlii' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'M9ila Oeuf Tomate', 28.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'M9ila Oeuf Tomate' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Omlette nature', 24.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Omlette nature' AND category = 'PDJ');

INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Baguette Marocaine', 22.0, 'PDJ'
WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Baguette Marocaine' AND category = 'PDJ');

-- =============================================================================
-- PART 4: Insert recipe_ingredients for PDJ articles
-- =============================================================================
-- Note: "Boisson chaude" is included with PDJ sets (marked ✔ in Excel) but
-- is a customer choice, so it's NOT tracked as a fixed recipe ingredient.
-- The hot drink stock consumption comes from the separate hot drink sale.
-- -----------------------------------------------------------------------------

-- ---- L'Express (24 DH): Croissant + Jus d'orange + Boisson chaude ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'L''Express' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'L''Express' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'orange / box' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- Le Classique (36 DH): Pain + Fromage + Jus d'orange + Boisson chaude ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Classique' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'pain' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Classique' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Fromage enfant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Classique' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'orange / box' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- Le Fassi (39 DH): Pain + Œufs 2 + Khlie 20g + Olives 20 + Jus d'orange + Boisson chaude ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Fassi' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'pain' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Fassi' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Fassi' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'khlie' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Fassi' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Olive' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Fassi' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'orange / box' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- Le Casablanca (39 DH): Pain + Œufs 2 + sc Tomate 60g + Salade 70g + Olives 20 + Jus d'orange + Boisson chaude ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Casablanca' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'pain' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Casablanca' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Casablanca' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'tomate' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 70.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Casablanca' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'salade' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Casablanca' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Olive' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Casablanca' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'orange / box' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- Le Comptoir (39 DH): Pain + Œufs 2 + sc Tomate 60g + Olives 20 + Jus d'orange + Boisson chaude ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Comptoir' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'pain' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Comptoir' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Comptoir' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'tomate' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Comptoir' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Olive' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Comptoir' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'orange / box' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- Le Gourmand (44 DH): Crêpe (batter) + Olives 20 + Jus d'orange + Boisson chaude ----
-- Crêpe batter = Œufs 3 + Farine 250g + Sucre vanille 2 + Beurre 20g (same as crêpe articles 42-46)
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Gourmand' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 250.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Gourmand' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Gourmand' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'ideal sucre vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Gourmand' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND LOWER(name) LIKE 'beure%' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Gourmand' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Olive' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Le Gourmand' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'orange / box' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- Croffle Brunch (44 DH): Croissant + Œufs 1 + sc Tomate 60g + Salade 70g + Jus d'orange + Boisson chaude ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croffle Brunch' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croffle Brunch' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croffle Brunch' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'tomate' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 70.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croffle Brunch' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'salade' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croffle Brunch' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'orange / box' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- Viennoiserie (14 DH): Croissant ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Viennoiserie' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- M9ila Khlii (28 DH): Pain + Œufs 2 + Khlie 20g ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'M9ila Khlii' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'pain' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'M9ila Khlii' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'M9ila Khlii' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'khlie' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- M9ila Oeuf Tomate (28 DH): Pain + Œufs 2 + sc Tomate 60g ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'M9ila Oeuf Tomate' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'pain' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'M9ila Oeuf Tomate' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'M9ila Oeuf Tomate' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'tomate' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- Omlette nature (24 DH): Pain + Œufs 2 ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Omlette nature' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'pain' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Omlette nature' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- ---- Baguette Marocaine (22 DH): Pain + Fromage ----
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Baguette Marocaine' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'pain' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0
FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Baguette Marocaine' AND category = 'PDJ' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Fromage enfant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- =============================================================================
-- PART 5: Fix products table (POS) - Add PDJ items for cashier
-- =============================================================================
-- The products table currently has OEUFS BROUILLEES (22) and OMELETTE (22)
-- but is missing the actual PDJ menu items from the Excel.
-- We keep existing products and add the missing PDJ items.
-- -----------------------------------------------------------------------------

-- -- Update OMELETTE price to match Excel (Omlette nature = 24 DH)
-- UPDATE products SET name = 'OMLETTE NATURE', price = 24.0
-- WHERE store_id = 2 AND LOWER(name) = 'omelette';

-- -- Add missing PDJ products
-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-l-express', 'L''EXPRESS', 24.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-l-express');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-le-classique', 'LE CLASSIQUE', 36.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-le-classique');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-le-fassi', 'LE FASSI', 39.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-le-fassi');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-le-casablanca', 'LE CASABLANCA', 39.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-le-casablanca');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-le-comptoir-pdj', 'LE COMPTOIR PDJ', 39.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-le-comptoir-pdj');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-le-gourmand', 'LE GOURMAND', 44.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-le-gourmand');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-croffle-brunch', 'CROFFLE BRUNCH', 44.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-croffle-brunch');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-viennoiserie', 'VIENNOISERIE', 14.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-viennoiserie');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-m9ila-khlii', 'M9ILA KHLII', 28.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-m9ila-khlii');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-m9ila-oeuf-tomate', 'M9ILA OEUF TOMATE', 28.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-m9ila-oeuf-tomate');

-- INSERT INTO products (store_id, code, name, price)
-- SELECT 2, 'tachfine-baguette-marocaine', 'BAGUETTE MAROCAINE', 22.0
-- WHERE NOT EXISTS (SELECT 1 FROM products WHERE store_id = 2 AND code = 'tachfine-baguette-marocaine');

-- =============================================================================
-- PART 6: Verification queries (run after the above to check results)
-- =============================================================================
-- Check new PDJ articles:
-- SELECT id, name, sale_price, category FROM articles WHERE store_id = 2 AND category = 'PDJ' ORDER BY id;

-- Check recipe_ingredients for PDJ articles:
-- SELECT a.name AS article, sp.name AS stock_product, ri.quantity, sp.unit
-- FROM recipe_ingredients ri
-- JOIN articles a ON ri.article_id = a.id
-- JOIN stock_products sp ON ri.product_id = sp.id
-- WHERE a.store_id = 2 AND a.category = 'PDJ'
-- ORDER BY a.name, sp.name;

COMMIT;
