-- Fix stock_products.unit based on verification of current data
-- Run in pgAdmin. Adjust store_id if needed.

-- 1) Syrups: recipe uses Sirop (ml) → unit must be ml (not g)
UPDATE stock_products SET unit = 'ml'
WHERE store_id = 2 AND LOWER(TRIM(name)) LIKE 'sirop%';

-- 2) Sauce pistache: recipe uses ml → unit must be ml (not g)
UPDATE stock_products SET unit = 'ml'
WHERE store_id = 2 AND LOWER(TRIM(name)) = 'sauce pistache';

-- 3) Eggs: recipe uses Œufs / oeuf (u) in pieces → base unit = piece for movements; counting stays plateau
UPDATE stock_products SET unit = 'piece'
WHERE store_id = 2 AND LOWER(TRIM(name)) = 'oeufs / plateau';

-- Optional: set counting_unit and base_per_counting_unit for oeufs / plateau (if columns exist)
-- UPDATE stock_products SET counting_unit = 'plateau', base_per_counting_unit = 30
-- WHERE store_id = 2 AND LOWER(TRIM(name)) = 'oeufs / plateau';
