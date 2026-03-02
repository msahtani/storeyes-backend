-- =============================================================================
-- PHASES 1, 2, 3, 4 + SODA UNIT UPDATE - Run in pgAdmin
-- store_id = 2 | Execute in order
-- =============================================================================

-- -----------------------------------------------------------------------------
-- PHASE 1: Fix stock_products units (align with recipe usage)
-- -----------------------------------------------------------------------------
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
-- SODA: Update all soda sub_category products to unit (sold by bottle)
-- -----------------------------------------------------------------------------
UPDATE stock_products sp SET unit = 'unit'
FROM variable_charge_sub_categories sc
JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id
WHERE sp.sub_category_id = sc.id AND mc.store_id = 2 AND mc.code = 'stock' AND sc.code = 'soda';

-- -----------------------------------------------------------------------------
-- PHASE 2: Add missing stock products (Citron, Gingembre, Avocat, thon, tomate, matcha)
-- -----------------------------------------------------------------------------
INSERT INTO stock_products (store_id, sub_category_id, name, unit, unit_price, minimal_threshold, created_at, updated_at)
SELECT 2, (SELECT sc.id FROM variable_charge_sub_categories sc JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id WHERE mc.store_id = 2 AND mc.code = 'stock' AND sc.code = 'bar'), 'Citron', 'cl', 0, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM stock_products WHERE store_id = 2 AND LOWER(name) = 'Citron');

INSERT INTO stock_products (store_id, sub_category_id, name, unit, unit_price, minimal_threshold, created_at, updated_at)
SELECT 2, (SELECT sc.id FROM variable_charge_sub_categories sc JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id WHERE mc.store_id = 2 AND mc.code = 'stock' AND sc.code = 'bar'), 'gingembre', 'g', 0, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM stock_products WHERE store_id = 2 AND LOWER(name) = 'gingembre');

INSERT INTO stock_products (store_id, sub_category_id, name, unit, unit_price, minimal_threshold, created_at, updated_at)
SELECT 2, (SELECT sc.id FROM variable_charge_sub_categories sc JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id WHERE mc.store_id = 2 AND mc.code = 'stock' AND sc.code = 'kitchen'), 'avocat', 'g', 0, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM stock_products WHERE store_id = 2 AND LOWER(name) = 'avocat');

INSERT INTO stock_products (store_id, sub_category_id, name, unit, unit_price, minimal_threshold, created_at, updated_at)
SELECT 2, (SELECT sc.id FROM variable_charge_sub_categories sc JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id WHERE mc.store_id = 2 AND mc.code = 'stock' AND sc.code = 'kitchen'), 'thon', 'g', 0, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM stock_products WHERE store_id = 2 AND LOWER(name) = 'thon');

INSERT INTO stock_products (store_id, sub_category_id, name, unit, unit_price, minimal_threshold, created_at, updated_at)
SELECT 2, (SELECT sc.id FROM variable_charge_sub_categories sc JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id WHERE mc.store_id = 2 AND mc.code = 'stock' AND sc.code = 'kitchen'), 'tomate', 'g', 0, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM stock_products WHERE store_id = 2 AND LOWER(name) = 'tomate');

INSERT INTO stock_products (store_id, sub_category_id, name, unit, unit_price, minimal_threshold, created_at, updated_at)
SELECT 2, (SELECT sc.id FROM variable_charge_sub_categories sc JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id WHERE mc.store_id = 2 AND mc.code = 'stock' AND sc.code = 'bar'), 'matcha', 'g', 0, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM stock_products WHERE store_id = 2 AND LOWER(name) = 'matcha');

-- -----------------------------------------------------------------------------
-- PHASE 3: Create articles and recipe_ingredients tables
-- -----------------------------------------------------------------------------
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
-- PHASE 4: Insert articles
-- -----------------------------------------------------------------------------
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Orange Juice (Freshly Squeezed)', 26.0, 'Jus' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Orange Juice (Freshly Squeezed)' AND category = 'Jus');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'American Lemonade (Citronnade maison)', 32.0, 'Jus' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'American Lemonade (Citronnade maison)' AND category = 'Jus');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Fraise – Lait', 34.0, 'Jus' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Fraise – Lait' AND category = 'Jus');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Fraise', 36.0, 'Jus' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Fraise' AND category = 'Jus');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Avocat', 32.0, 'Jus' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Avocat' AND category = 'Jus');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Royal Avocat Fruits Secs', 36.0, 'Jus' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Royal Avocat Fruits Secs' AND category = 'Jus');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Mangue', 38.0, 'Jus' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Mangue' AND category = 'Jus');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Ananas', 38.0, 'Jus' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Ananas' AND category = 'Jus');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Detox (Orange, Gingembre & Citron)', 42.0, 'Jus' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Detox (Orange, Gingembre & Citron)' AND category = 'Jus');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Espresso Standard', 14.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Espresso Standard' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Espresso Vanille', 18.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Espresso Vanille' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Espresso Chocolat', 22.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Espresso Chocolat' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Espresso Chocolat Bi', 22.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Espresso Chocolat Bi' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Espresso Pistachio', 22.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Espresso Pistachio' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Espresso Pistachio C', 26.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Espresso Pistachio C' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'MOITIE MOITIE MAROCA', 18.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'MOITIE MOITIE MAROCA' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'nespresso', 22.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'nespresso' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Americano Standard', 18.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Americano Standard' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Americano Vanille', 22.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Americano Vanille' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Americano Chocolat', 26.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Americano Chocolat' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Americano Chocolat B', 26.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Americano Chocolat B' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Americano Pistachio', 26.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Americano Pistachio' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'CAPPUCCINO', 26.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'CAPPUCCINO' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'THE A LA MENTHE', 14.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'THE A LA MENTHE' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'THE CHAMALI', 16.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'THE CHAMALI' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'VERVEINE', 18.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'VERVEINE' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'VERVEINE U LAIT', 22.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'VERVEINE U LAIT' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Double Espresso Standard', 26.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Double Espresso Standard' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Double Espresso Vanille', 0.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Double Espresso Vanille' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Double Espresso Chocolat', 0.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Double Espresso Chocolat' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Double Espresso Chocolat Bi', 0.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Double Espresso Chocolat Bi' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Double Espresso Pistachio', 0.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Double Espresso Pistachio' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Double Espresso Pistachio C', 0.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Double Espresso Pistachio C' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'chocolat chaud', 29.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'chocolat chaud' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Cioco Delice', 28.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Cioco Delice' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Ciocco Delice Con Panna', 34.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Ciocco Delice Con Panna' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Café Mocha', 38.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Café Mocha' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Tokyo Latte Caramel', 32.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Tokyo Latte Caramel' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Américain Latte Vanille', 32.0, 'Boisson chaude' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Américain Latte Vanille' AND category = 'Boisson chaude');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Pdj', 0, 'PDJ' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Pdj' AND category = 'PDJ');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'à la carte', 0, 'PDJ' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'à la carte' AND category = 'PDJ');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Crêpe Nutella', 38.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Crêpe Nutella' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Crêpe 100% Pistache', 44.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Crêpe 100% Pistache' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Crêpe Choco Pistachio', 42.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Crêpe Choco Pistachio' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Crêpe Biscoff Lotus', 44.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Crêpe Biscoff Lotus' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Crêpe Chocolat Glacé', 44.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Crêpe Chocolat Glacé' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'CHOCOLATE MUFFIN', 28.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'CHOCOLATE MUFFIN' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'FONDANT CHOCOLAT', 49.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'FONDANT CHOCOLAT' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'FONDANT LE COMPTOIR', 59.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'FONDANT LE COMPTOIR' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'AMERICAN LAYER CAKE', 49.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'AMERICAN LAYER CAKE' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'CHOCO BROWNIE', 38.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'CHOCO BROWNIE' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'TARTE DU JOUR', 32.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'TARTE DU JOUR' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'chocolat glacé', 38.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'chocolat glacé' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'trio de glace', 32.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'trio de glace' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Croiffle Nutella (39)', 39.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Croiffle Nutella (39)' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Croiffle Pistachio Lovers (44)', 44.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Croiffle Pistachio Lovers (44)' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Croiffle Choco/Pistache (42)', 42.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Croiffle Choco/Pistache (42)' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Croiffle Bicof Lotus (44)', 44.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Croiffle Bicof Lotus (44)' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Croiffle Le Comptoir (49)', 49.0, 'Crepes' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Croiffle Le Comptoir (49)' AND category = 'Crepes');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'SANDWICH THON MAYO', 34.0, 'sandwich' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'SANDWICH THON MAYO' AND category = 'sandwich');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'SANDWICH DINDE FUMEE', 32.0, 'sandwich' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'SANDWICH DINDE FUMEE' AND category = 'sandwich');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'SANDWICH LE TANGEROI', 36.0, 'sandwich' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'SANDWICH LE TANGEROI' AND category = 'sandwich');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'SANDWICH LE CASABLAN', 32.0, 'sandwich' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'SANDWICH LE CASABLAN' AND category = 'sandwich');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'CROISSANDWICH THON M', 34.0, 'sandwich' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'CROISSANDWICH THON M' AND category = 'sandwich');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'CROISSANDWICH DINDE', 36.0, 'sandwich' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'CROISSANDWICH DINDE' AND category = 'sandwich');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'CROISSANT GLACE BISC/nut', 44.0, 'sandwich' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE BISC/nut' AND category = 'sandwich');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'CROISSANT GLACE PIST / nute', 46.0, 'sandwich' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE PIST / nute' AND category = 'sandwich');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'CROISSANT GLACE NUTE', 46.0, 'sandwich' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE NUTE' AND category = 'sandwich');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Ice Tea Pêche', 29.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Ice Tea Pêche' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Ice Tea Fraise', 32.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Ice Tea Fraise' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Ice Tea Passion', 32.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Ice Tea Passion' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Ice Tea Myrtille', 32.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Ice Tea Myrtille' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Ice Tea Mangue', 32.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Ice Tea Mangue' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Ice Tea Bubble Gum', 32.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Ice Tea Bubble Gum' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Smoothie Banane', 34.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Smoothie Banane' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Smoothie Fraise', 34.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Smoothie Fraise' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Smoothie Mangue', 34.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Smoothie Mangue' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Smoothie Myrtille', 34.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Smoothie Myrtille' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Smoothie Passion', 34.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Smoothie Passion' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Smoothie Ananas', 34.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Smoothie Ananas' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Frappuccino Vanille', 42.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Frappuccino Vanille' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Frappuccino Chocolat', 42.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Frappuccino Chocolat' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Frappuccino Fraise', 42.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Frappuccino Fraise' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'strawberry matcha latte', 39.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'strawberry matcha latte' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Frappuccino MATCHA', 38.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Frappuccino MATCHA' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Milkshake Vanille', 36.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Milkshake Vanille' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Milkshake Chocolat', 36.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Milkshake Chocolat' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Milkshake Fraise', 36.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Milkshake Fraise' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'soda', 18.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'soda' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'oulmes', 16.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'oulmes' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Gum Gum', 36.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Gum Gum' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Blue Lagoon', 36.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Blue Lagoon' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Pink Paradise', 36.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Pink Paradise' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Mojito', 38.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Mojito' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Green Goblin', 36.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Green Goblin' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Piña Colada', 36.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Piña Colada' AND category = 'Boisson fraiches');
INSERT INTO articles (store_id, name, sale_price, category) SELECT 2, 'Dragon Ice', 36.0, 'Boisson fraiches' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = 2 AND name = 'Dragon Ice' AND category = 'Boisson fraiches');

-- -----------------------------------------------------------------------------
-- PHASE 4: Insert recipe_ingredients (article -> stock_product, quantity)
-- -----------------------------------------------------------------------------
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Orange Juice (Freshly Squeezed)' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'orange / box' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'American Lemonade (Citronnade maison)' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Citron' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Fraise – Lait' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Fraise – Lait' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 70.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Fraise' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Avocat' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'avocat' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Avocat' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Royal Avocat Fruits Secs' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'avocat' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Royal Avocat Fruits Secs' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'raisin' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Royal Avocat Fruits Secs' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 100.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Mangue' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'mangue' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 200.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ananas' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'ananas' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Detox (Orange, Gingembre & Citron)' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'orange / box' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 10.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Detox (Orange, Gingembre & Citron)' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Citron' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 10.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Detox (Orange, Gingembre & Citron)' AND category = 'Jus' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'gingembre' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Espresso Standard' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Espresso Vanille' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Espresso Chocolat' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Espresso Chocolat Bi' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Espresso Chocolat Bi' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Espresso Pistachio' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Espresso Pistachio C' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Espresso Pistachio C' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'MOITIE MOITIE MAROCA' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'MOITIE MOITIE MAROCA' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'nespresso' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'nespresso / piece' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Americano Standard' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Americano Vanille' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 10.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Americano Vanille' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Americano Chocolat' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Americano Chocolat B' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Americano Chocolat B' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Americano Pistachio' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CAPPUCCINO' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CAPPUCCINO' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'THE A LA MENTHE' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'thé bellar' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'THE CHAMALI' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'thé bellar' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'VERVEINE' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'thé bellar' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'VERVEINE U LAIT' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'thé bellar' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'VERVEINE U LAIT' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Double Espresso Standard' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Double Espresso Vanille' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Double Espresso Chocolat' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Double Espresso Chocolat Bi' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Double Espresso Chocolat Bi' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Double Espresso Pistachio' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 14.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Double Espresso Pistachio C' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Double Espresso Pistachio C' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'chocolat chaud' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Cioco Delice' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ciocco Delice Con Panna' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Café Mocha' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 5.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Café Mocha' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Tokyo Latte Caramel' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Tokyo Latte Caramel' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 9.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Américain Latte Vanille' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Américain Latte Vanille' AND category = 'Boisson chaude' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Nutella' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 250.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Nutella' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Nutella' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'ideal sucre vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Nutella' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'beure "ladda"' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Nutella' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Nutella 3kg' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe 100% Pistache' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 250.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe 100% Pistache' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe 100% Pistache' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'ideal sucre vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe 100% Pistache' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'beure "ladda"' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe 100% Pistache' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'sauce pistache' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Choco Pistachio' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 250.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Choco Pistachio' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Choco Pistachio' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'ideal sucre vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Choco Pistachio' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'beure "ladda"' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Choco Pistachio' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Nutella 3kg' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Choco Pistachio' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'sauce pistache' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Biscoff Lotus' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 250.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Biscoff Lotus' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Biscoff Lotus' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'ideal sucre vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Biscoff Lotus' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'beure "ladda"' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Biscoff Lotus' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Biscuit lotus' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Chocolat Glacé' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 250.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Chocolat Glacé' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Chocolat Glacé' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'ideal sucre vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Chocolat Glacé' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'beure "ladda"' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Chocolat Glacé' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Nutella 3kg' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Crêpe Chocolat Glacé' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CHOCOLATE MUFFIN' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'FONDANT CHOCOLAT' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'FONDANT CHOCOLAT' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'FONDANT LE COMPTOIR' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'FONDANT LE COMPTOIR' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'sauce pistache' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'FONDANT LE COMPTOIR' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'AMERICAN LAYER CAKE' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CHOCO BROWNIE' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'TARTE DU JOUR' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'chocolat glacé' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'farine nouara' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'chocolat glacé' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 180.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'trio de glace' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Nutella (39)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Nutella (39)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Nutella 3kg' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Pistachio Lovers (44)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Pistachio Lovers (44)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'sauce pistache' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Choco/Pistache (42)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Choco/Pistache (42)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Nutella 3kg' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Choco/Pistache (42)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'sauce pistache' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Bicof Lotus (44)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Bicof Lotus (44)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Biscuit lotus' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Le Comptoir (49)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Le Comptoir (49)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Nutella 3kg' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Le Comptoir (49)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'sauce pistache' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 120.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Croiffle Le Comptoir (49)' AND category = 'Crepes' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'SANDWICH THON MAYO' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Pain sandwich' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 40.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'SANDWICH THON MAYO' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'thon' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'SANDWICH DINDE FUMEE' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Pain sandwich' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'SANDWICH DINDE FUMEE' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'dinde fumé' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'SANDWICH LE TANGEROI' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Pain sandwich' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'SANDWICH LE TANGEROI' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'SANDWICH LE CASABLAN' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Pain sandwich' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 2.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'SANDWICH LE CASABLAN' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'oeufs / plateau' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 40.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'SANDWICH LE CASABLAN' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'tomate' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANDWICH THON M' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 40.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANDWICH THON M' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'thon' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANDWICH DINDE' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANDWICH DINDE' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'dinde fumé' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE BISC/nut' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE BISC/nut' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Nutella 3kg' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE BISC/nut' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Biscuit lotus' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE BISC/nut' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE PIST / nute' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE PIST / nute' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Nutella 3kg' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE PIST / nute' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'sauce pistache' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE PIST / nute' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE NUTE' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'croissant' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE NUTE' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'sauce pistache' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 50.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE NUTE' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Biscuit lotus' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'CROISSANT GLACE NUTE' AND category = 'sandwich' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Pêche' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Passion' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Passion' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Myrtille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Myrtille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Mangue' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Mangue' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 60.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Ice Tea Bubble Gum' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Banane' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Banane' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Mangue' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Mangue' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Mangue' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Myrtille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Myrtille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Myrtille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Passion' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Passion' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Ananas' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Ananas' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Smoothie Ananas' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Vanille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Vanille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Vanille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Vanille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Chocolat' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Chocolat' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Chocolat' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Chocolat' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Café' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 10.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'strawberry matcha latte' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'matcha' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'strawberry matcha latte' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 10.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino MATCHA' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'matcha' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 15.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino MATCHA' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 3.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Frappuccino MATCHA' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Milkshake Vanille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Milkshake Vanille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 5.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Milkshake Vanille' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Milkshake Chocolat' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Milkshake Chocolat' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 5.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Milkshake Chocolat' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Milkshake Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Milkshake Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'lait' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 5.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Milkshake Fraise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'glace vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'soda' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'schweppes tonic 33cl' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 1.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'oulmes' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'schweppes tonic 33cl' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Gum Gum' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Gum Gum' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'schweppes tonic 33cl' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Blue Lagoon' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Blue Lagoon' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'schweppes tonic 33cl' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Pink Paradise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Pink Paradise' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'schweppes tonic 33cl' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Mojito' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Mojito' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'schweppes tonic 33cl' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 40.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Green Goblin' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Green Goblin' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Green Goblin' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'schweppes tonic 33cl' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 30.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Piña Colada' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Sirop Vanille' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Piña Colada' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'schweppes tonic 33cl' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 20.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Dragon Ice' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'Purée de fraise' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO recipe_ingredients (article_id, product_id, quantity)
SELECT a.id, p.id, 25.0 FROM (SELECT id FROM articles WHERE store_id = 2 AND name = 'Dragon Ice' AND category = 'Boisson fraiches' LIMIT 1) a,
     (SELECT id FROM stock_products WHERE store_id = 2 AND name = 'schweppes tonic 33cl' LIMIT 1) p
WHERE a.id IS NOT NULL AND p.id IS NOT NULL
ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Done.