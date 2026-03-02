-- Fix stock_products.unit for store_id = 2
-- Align units with recipe usage from Fich pour storeyes.xlsx
-- Run in pgAdmin after verifying product names match your DB

-- Liquids -> cl
UPDATE stock_products SET unit = 'cl' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'lait';

-- Coffee & chocolate -> g
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'café';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'chocolat carraro';

-- Syrups & sauces -> ml
UPDATE stock_products SET unit = 'ml' WHERE store_id = 2 AND LOWER(TRIM(name)) LIKE 'sirop%';
UPDATE stock_products SET unit = 'ml' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'sauce pistache';

-- Fruits (freezer) -> g (recipes use g)
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND name = 'fraise';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND name = 'mangue';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND name = 'ananas';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND name = 'bannane';

-- Sodas: sold by bottle to client -> keep unit (1 sale = 1 unit consumed)
-- (No update: Hawai ananas, Sprit a la menth, Poms, oulmes stay unit)

-- Water 0.5L -> L
UPDATE stock_products SET unit = 'L' WHERE store_id = 2 AND LOWER(name) LIKE 'eau sidi ali 0%';

-- Kitchen ingredients -> g
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND LOWER(TRIM(name)) = 'farine nouara';
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND (LOWER(name) LIKE 'beure%' OR LOWER(name) LIKE 'beurre%');
UPDATE stock_products SET unit = 'g' WHERE store_id = 2 AND LOWER(TRIM(name)) LIKE 'nutella%';
