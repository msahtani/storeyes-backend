-- ============================================================================
-- SEED SCRIPT: March 2026 Stock Purchases for StoreYes
-- ============================================================================
-- This script:
--   (Hygiene and cash-register products are intentionally excluded from seed purchases
--    and from zero-price fixes; set them in the app if needed.)
--   1. Fixes unit_price for products that have 0 price (realistic MAD prices)
--   2. Fixes unit/counting_unit where configurations are clearly wrong
--   3. Inserts variable_charges (purchase records) across March 2026
--   4. Inserts stock_movements (PURCHASE type) for raw-material sub-categories
--   5. Resets sequences so future inserts don't conflict
--
-- Run against your PostgreSQL database:
--   psql -U <user> -d <database> -f seed_march_2026_stock.sql
-- ============================================================================

BEGIN;

-- ============================================================================
-- PART 1: Fix unit prices for products with unit_price = 0
-- ============================================================================
-- Prices are in MAD per counting_unit (the unit used for purchasing).

-- Store 2 - Bar (sub_category 37)
UPDATE stock_products SET unit_price = 15.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 12;   -- Orange (per box ≈ per kg)
UPDATE stock_products SET unit_price = 65.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 15;   -- lait (per Box of 6L)
UPDATE stock_products SET unit_price = 55.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 16;   -- sucre Bleu (per box of 500 cubes)
UPDATE stock_products SET unit_price = 220.00, updated_at = CURRENT_TIMESTAMP WHERE id = 18;   -- Pistache (per Kg)
UPDATE stock_products SET unit_price = 120.00, updated_at = CURRENT_TIMESTAMP WHERE id = 26;   -- verveine LOUIZA (per kg)
UPDATE stock_products SET unit_price = 45.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 27;   -- origan ZAATAR (per unit)
UPDATE stock_products SET unit_price = 15.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 31;   -- toon joly (per unit)
UPDATE stock_products SET unit_price = 10.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 56;   -- monada (per unit)
UPDATE stock_products SET unit_price = 20.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 112;  -- citron (per Kg)
UPDATE stock_products SET unit_price = 60.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 113;  -- gingembre (per kg)
UPDATE stock_products SET unit_price = 800.00, updated_at = CURRENT_TIMESTAMP WHERE id = 117;  -- matcha (per kg, premium)

-- Store 2 - Kitchen (sub_category 40)
UPDATE stock_products SET unit_price = 85.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 57;   -- beure "ladda" (per Kg)
UPDATE stock_products SET unit_price = 42.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 58;   -- oeufs / plateau (per plateau of 30)
UPDATE stock_products SET unit_price = 12.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 59;   -- farine nouara (per Kg)
UPDATE stock_products SET unit_price = 6.00,   updated_at = CURRENT_TIMESTAMP WHERE id = 60;   -- ideal sucre vanille (per unit)
UPDATE stock_products SET unit_price = 150.00, updated_at = CURRENT_TIMESTAMP WHERE id = 61;   -- miel arabia (per kg)
UPDATE stock_products SET unit_price = 80.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 62;   -- huile d'olive (per unit/bottle)
UPDATE stock_products SET unit_price = 35.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 63;   -- Olive (per unit/jar)
UPDATE stock_products SET unit_price = 15.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 64;   -- Fromage rouge (per unit)
UPDATE stock_products SET unit_price = 2.50,   updated_at = CURRENT_TIMESTAMP WHERE id = 65;   -- Fromage enfant (per portion)
UPDATE stock_products SET unit_price = 18.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 66;   -- sauce tomate napolitaine (per unit)
UPDATE stock_products SET unit_price = 200.00, updated_at = CURRENT_TIMESTAMP WHERE id = 67;   -- khlie (per Kg)
UPDATE stock_products SET unit_price = 45.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 68;   -- dinde fumé (per unit)
UPDATE stock_products SET unit_price = 1.50,   updated_at = CURRENT_TIMESTAMP WHERE id = 69;   -- Confiture arabia peach (per individual portion)
UPDATE stock_products SET unit_price = 12.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 72;   -- vermicelle chocolat (per unit)
UPDATE stock_products SET unit_price = 15.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 73;   -- toast (per unit/pack)
UPDATE stock_products SET unit_price = 8.00,   updated_at = CURRENT_TIMESTAMP WHERE id = 114;  -- avocat (per piece ~200g)
UPDATE stock_products SET unit_price = 90.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 115;  -- thon (per kg)
UPDATE stock_products SET unit_price = 8.00,   updated_at = CURRENT_TIMESTAMP WHERE id = 116;  -- tomate (per kg)
UPDATE stock_products SET unit_price = 5.00,   updated_at = CURRENT_TIMESTAMP WHERE id = 118;  -- salade (per piece)
UPDATE stock_products SET unit_price = 150.00, updated_at = CURRENT_TIMESTAMP WHERE id = 122;  -- Beurre portion (per bucket)

-- Store 2 - Freezer (sub_category 43)
UPDATE stock_products SET unit_price = 35.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 89;   -- fraise (per kg)
UPDATE stock_products SET unit_price = 50.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 90;   -- mangue (per kg)
UPDATE stock_products SET unit_price = 25.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 91;   -- ananas (per piece)
UPDATE stock_products SET unit_price = 15.00,  updated_at = CURRENT_TIMESTAMP WHERE id = 92;   -- bannane (per kg)

-- Store 2 - Soda (sub_category 46)
UPDATE stock_products SET unit_price = 7.50,   updated_at = CURRENT_TIMESTAMP WHERE id = 100;  -- Hawai ananas (per bottle)
UPDATE stock_products SET unit_price = 5.00,   updated_at = CURRENT_TIMESTAMP WHERE id = 104;  -- Poms (per bottle)
UPDATE stock_products SET unit_price = 7.50,   updated_at = CURRENT_TIMESTAMP WHERE id = 106;  -- Sprit a la menth (per bottle)
UPDATE stock_products SET unit_price = 5.00,   updated_at = CURRENT_TIMESTAMP WHERE id = 107;  -- oulmes (per bottle)
UPDATE stock_products SET unit_price = 2.00,   updated_at = CURRENT_TIMESTAMP WHERE id = 108;  -- eau sidi ali 33cl (per bottle)
UPDATE stock_products SET unit_price = 2.50,   updated_at = CURRENT_TIMESTAMP WHERE id = 109;  -- eau sidi ali 0,5l (per bottle)


-- ============================================================================
-- PART 2: Fix units / counting_unit where clearly wrong
-- ============================================================================

-- id 18 Pistache: was unit=kg, counting_unit=g, base=1000 (backwards)
-- Should be: base in grams, buy in Kg → threshold 500 = 500g
UPDATE stock_products
SET unit = 'g', counting_unit = 'Kg', base_per_counting_unit = 1000.0000, updated_at = CURRENT_TIMESTAMP
WHERE id = 18;

-- id 57 beure "ladda": was counting_unit=g, base=1 → threshold 0.25g is nothing
-- Should be: base in grams, buy in Kg → threshold 0.25 Kg = 250g
UPDATE stock_products
SET counting_unit = 'Kg', base_per_counting_unit = 1000.0000, updated_at = CURRENT_TIMESTAMP
WHERE id = 57;

-- id 59 farine nouara: was counting_unit=g, base=1 → threshold 2g is nothing
-- Should be: base in grams, buy in Kg → threshold 2 Kg
UPDATE stock_products
SET counting_unit = 'Kg', base_per_counting_unit = 1000.0000, updated_at = CURRENT_TIMESTAMP
WHERE id = 59;

-- id 67 khlie: was counting_unit=g, base=1 → threshold 3g is nothing
-- Should be: base in grams, buy in Kg → threshold 3 Kg
UPDATE stock_products
SET counting_unit = 'Kg', base_per_counting_unit = 1000.0000, updated_at = CURRENT_TIMESTAMP
WHERE id = 67;

-- id 118 salade: was unit=g with no counting unit → doesn't make sense for salad
-- Should be: sold/tracked by piece
UPDATE stock_products
SET unit = 'piece', counting_unit = 'piece', base_per_counting_unit = 1.0000, updated_at = CURRENT_TIMESTAMP
WHERE id = 118;


-- ============================================================================
-- PART 3: Insert variable_charges (March 2026 purchases)
-- ============================================================================
-- quantity = number of counting_units purchased
-- unit_price = price per counting_unit
-- amount = quantity × unit_price (total cost in MAD)
-- category = main_category name ('Stock')

INSERT INTO variable_charges
    (id, store_id, main_category_id, sub_category_id, product_id, name, amount, date, category, quantity, unit_price, supplier, notes, created_at, updated_at)
VALUES

-- ── March 1 — Weekly restock (bar + freezer essentials) ─────────────────────
(10001, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 7, 'Café', 540.00, '2026-03-01', 'Stock', 4.00, 135.00, NULL, NULL,
 '2026-03-01 09:00:00', '2026-03-01 09:00:00'),

(10002, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 8, 'Sucre carraro / kg', 330.00, '2026-03-01', 'Stock', 3.00, 110.00, NULL, NULL,
 '2026-03-01 09:00:00', '2026-03-01 09:00:00'),

(10003, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 15, 'lait', 325.00, '2026-03-01', 'Stock', 5.00, 65.00, NULL, NULL,
 '2026-03-01 09:05:00', '2026-03-01 09:05:00'),

(10004, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 16, 'sucre Bleu', 55.00, '2026-03-01', 'Stock', 1.00, 55.00, NULL, NULL,
 '2026-03-01 09:05:00', '2026-03-01 09:05:00'),

(10005, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 9, 'chocolat chocao', 172.50, '2026-03-01', 'Stock', 1.00, 172.50, NULL, NULL,
 '2026-03-01 09:10:00', '2026-03-01 09:10:00'),

(10006, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 41, 'Chocolat carraro', 82.50, '2026-03-01', 'Stock', 0.50, 165.00, NULL, NULL,
 '2026-03-01 09:10:00', '2026-03-01 09:10:00'),

(10007, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 82, 'croissant', 1940.40, '2026-03-01', 'Stock', 7.00, 277.20, NULL, NULL,
 '2026-03-01 09:15:00', '2026-03-01 09:15:00'),

(10008, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 83, 'pain au chocolat', 1422.00, '2026-03-01', 'Stock', 5.00, 284.40, NULL, NULL,
 '2026-03-01 09:15:00', '2026-03-01 09:15:00'),

(10009, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 84, 'fondant', 460.80, '2026-03-01', 'Stock', 2.00, 230.40, NULL, NULL,
 '2026-03-01 09:15:00', '2026-03-01 09:15:00'),

(10010, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 86, 'pain', 864.00, '2026-03-01', 'Stock', 8.00, 108.00, NULL, NULL,
 '2026-03-01 09:20:00', '2026-03-01 09:20:00'),

(10011, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 87, 'gateau du jour', 480.00, '2026-03-01', 'Stock', 4.00, 120.00, NULL, NULL,
 '2026-03-01 09:20:00', '2026-03-01 09:20:00'),

(10012, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 88, 'Pain sandwich', 300.00, '2026-03-01', 'Stock', 3.00, 100.00, NULL, NULL,
 '2026-03-01 09:20:00', '2026-03-01 09:20:00'),

-- ── March 3 — Fresh produce ─────────────────────────────────────────────────
(10013, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 12, 'Orange', 75.00, '2026-03-03', 'Stock', 5.00, 15.00, NULL, NULL,
 '2026-03-03 08:30:00', '2026-03-03 08:30:00'),

(10014, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 112, 'citron', 40.00, '2026-03-03', 'Stock', 2.00, 20.00, NULL, NULL,
 '2026-03-03 08:30:00', '2026-03-03 08:30:00'),

(10015, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 89, 'fraise', 70.00, '2026-03-03', 'Stock', 2.00, 35.00, NULL, NULL,
 '2026-03-03 08:35:00', '2026-03-03 08:35:00'),

(10016, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 92, 'bannane', 45.00, '2026-03-03', 'Stock', 3.00, 15.00, NULL, NULL,
 '2026-03-03 08:35:00', '2026-03-03 08:35:00'),

(10017, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 58, 'oeufs / plateau', 84.00, '2026-03-03', 'Stock', 2.00, 42.00, NULL, NULL,
 '2026-03-03 08:40:00', '2026-03-03 08:40:00'),

(10018, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 114, 'avocat', 80.00, '2026-03-03', 'Stock', 10.00, 8.00, NULL, NULL,
 '2026-03-03 08:40:00', '2026-03-03 08:40:00'),

(10019, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 116, 'tomate', 24.00, '2026-03-03', 'Stock', 3.00, 8.00, NULL, NULL,
 '2026-03-03 08:45:00', '2026-03-03 08:45:00'),

(10020, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 118, 'salade', 25.00, '2026-03-03', 'Stock', 5.00, 5.00, NULL, NULL,
 '2026-03-03 08:45:00', '2026-03-03 08:45:00'),

-- ── March 5 — Sodas & drinks ────────────────────────────────────────────────
(10021, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 108, 'eau sidi ali 33cl', 400.00, '2026-03-05', 'Stock', 200.00, 2.00, NULL, NULL,
 '2026-03-05 10:00:00', '2026-03-05 10:00:00'),

(10022, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 109, 'eau sidi ali 0,5l', 75.00, '2026-03-05', 'Stock', 30.00, 2.50, NULL, NULL,
 '2026-03-05 10:00:00', '2026-03-05 10:00:00'),

(10023, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 119, 'SODA', 32.00, '2026-03-05', 'Stock', 4.00, 8.00, NULL, NULL,
 '2026-03-05 10:05:00', '2026-03-05 10:05:00'),

(10024, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 101, 'pepsi 33cl', 96.00, '2026-03-05', 'Stock', 24.00, 4.00, NULL, NULL,
 '2026-03-05 10:05:00', '2026-03-05 10:05:00'),

(10025, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 97, 'schweppes tonic 33cl', 90.00, '2026-03-05', 'Stock', 12.00, 7.50, NULL, NULL,
 '2026-03-05 10:10:00', '2026-03-05 10:10:00'),

(10026, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 98, 'schweppes citron 33cl', 90.00, '2026-03-05', 'Stock', 12.00, 7.50, NULL, NULL,
 '2026-03-05 10:10:00', '2026-03-05 10:10:00'),

(10027, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 105, 'sprite 33cl', 90.00, '2026-03-05', 'Stock', 12.00, 7.50, NULL, NULL,
 '2026-03-05 10:10:00', '2026-03-05 10:10:00'),

(10028, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 99, 'hawai tropical 33cl', 90.00, '2026-03-05', 'Stock', 12.00, 7.50, NULL, NULL,
 '2026-03-05 10:15:00', '2026-03-05 10:15:00'),

(10029, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 100, 'Hawai ananas', 90.00, '2026-03-05', 'Stock', 12.00, 7.50, NULL, NULL,
 '2026-03-05 10:15:00', '2026-03-05 10:15:00'),

(10030, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 102, 'mirinda citron 25cl', 38.40, '2026-03-05', 'Stock', 12.00, 3.20, NULL, NULL,
 '2026-03-05 10:15:00', '2026-03-05 10:15:00'),

-- ── March 7 — Syrups, toppings, ice cream ───────────────────────────────────
(10031, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 32, 'Purée de fraise', 190.00, '2026-03-07', 'Stock', 1.00, 190.00, NULL, NULL,
 '2026-03-07 09:00:00', '2026-03-07 09:00:00'),

(10032, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 33, 'Purée de mangue', 190.00, '2026-03-07', 'Stock', 1.00, 190.00, NULL, NULL,
 '2026-03-07 09:00:00', '2026-03-07 09:00:00'),

(10033, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 34, 'Purée de myrtille (Blueberry)', 190.00, '2026-03-07', 'Stock', 1.00, 190.00, NULL, NULL,
 '2026-03-07 09:00:00', '2026-03-07 09:00:00'),

(10034, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 37, 'Sirop Bubble Gum', 120.00, '2026-03-07', 'Stock', 1.00, 120.00, NULL, NULL,
 '2026-03-07 09:05:00', '2026-03-07 09:05:00'),

(10035, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 38, 'Sirop Mojito', 120.00, '2026-03-07', 'Stock', 1.00, 120.00, NULL, NULL,
 '2026-03-07 09:05:00', '2026-03-07 09:05:00'),

(10036, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 39, 'Sirop Vanille', 120.00, '2026-03-07', 'Stock', 1.00, 120.00, NULL, NULL,
 '2026-03-07 09:05:00', '2026-03-07 09:05:00'),

(10037, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 40, 'Sirop Caramel', 120.00, '2026-03-07', 'Stock', 1.00, 120.00, NULL, NULL,
 '2026-03-07 09:05:00', '2026-03-07 09:05:00'),

(10038, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 22, 'topping chocolat', 68.00, '2026-03-07', 'Stock', 2.00, 34.00, NULL, NULL,
 '2026-03-07 09:10:00', '2026-03-07 09:10:00'),

(10039, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 24, 'topping fraise', 68.00, '2026-03-07', 'Stock', 2.00, 34.00, NULL, NULL,
 '2026-03-07 09:10:00', '2026-03-07 09:10:00'),

(10040, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 25, 'topping caramel', 68.00, '2026-03-07', 'Stock', 2.00, 34.00, NULL, NULL,
 '2026-03-07 09:10:00', '2026-03-07 09:10:00'),

(10041, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 30, 'biscoff lotus', 80.00, '2026-03-07', 'Stock', 2.00, 40.00, NULL, NULL,
 '2026-03-07 09:15:00', '2026-03-07 09:15:00'),

(10042, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 93, 'glace vanille', 120.00, '2026-03-07', 'Stock', 1.00, 120.00, NULL, NULL,
 '2026-03-07 09:15:00', '2026-03-07 09:15:00'),

(10043, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 94, 'glace chocolat', 120.00, '2026-03-07', 'Stock', 1.00, 120.00, NULL, NULL,
 '2026-03-07 09:15:00', '2026-03-07 09:15:00'),

(10044, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 95, 'glace caramel', 120.00, '2026-03-07', 'Stock', 1.00, 120.00, NULL, NULL,
 '2026-03-07 09:15:00', '2026-03-07 09:15:00'),

(10045, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 96, 'glace fraise', 120.00, '2026-03-07', 'Stock', 1.00, 120.00, NULL, NULL,
 '2026-03-07 09:15:00', '2026-03-07 09:15:00'),

(10046, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 42, 'sauce pistache', 320.00, '2026-03-07', 'Stock', 1.00, 320.00, NULL, NULL,
 '2026-03-07 09:20:00', '2026-03-07 09:20:00'),

-- ── March 8 — Weekly restock 2 ──────────────────────────────────────────────
(10047, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 7, 'Café', 540.00, '2026-03-08', 'Stock', 4.00, 135.00, NULL, NULL,
 '2026-03-08 09:00:00', '2026-03-08 09:00:00'),

(10048, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 8, 'Sucre carraro / kg', 220.00, '2026-03-08', 'Stock', 2.00, 110.00, NULL, NULL,
 '2026-03-08 09:00:00', '2026-03-08 09:00:00'),

(10049, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 15, 'lait', 260.00, '2026-03-08', 'Stock', 4.00, 65.00, NULL, NULL,
 '2026-03-08 09:05:00', '2026-03-08 09:05:00'),

(10050, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 10, 'nespresso / piece', 900.00, '2026-03-08', 'Stock', 15.00, 60.00, NULL, NULL,
 '2026-03-08 09:05:00', '2026-03-08 09:05:00'),

(10051, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 11, 'thé bellar', 78.00, '2026-03-08', 'Stock', 6.00, 13.00, NULL, NULL,
 '2026-03-08 09:10:00', '2026-03-08 09:10:00'),

(10052, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 82, 'croissant', 1663.20, '2026-03-08', 'Stock', 6.00, 277.20, NULL, NULL,
 '2026-03-08 09:10:00', '2026-03-08 09:10:00'),

(10053, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 83, 'pain au chocolat', 1137.60, '2026-03-08', 'Stock', 4.00, 284.40, NULL, NULL,
 '2026-03-08 09:10:00', '2026-03-08 09:10:00'),

(10054, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 86, 'pain', 1080.00, '2026-03-08', 'Stock', 10.00, 108.00, NULL, NULL,
 '2026-03-08 09:15:00', '2026-03-08 09:15:00'),

(10055, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 87, 'gateau du jour', 360.00, '2026-03-08', 'Stock', 3.00, 120.00, NULL, NULL,
 '2026-03-08 09:15:00', '2026-03-08 09:15:00'),

-- ── March 10 — Fresh produce 2 ──────────────────────────────────────────────
(10056, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 12, 'Orange', 90.00, '2026-03-10', 'Stock', 6.00, 15.00, NULL, NULL,
 '2026-03-10 08:30:00', '2026-03-10 08:30:00'),

(10057, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 112, 'citron', 60.00, '2026-03-10', 'Stock', 3.00, 20.00, NULL, NULL,
 '2026-03-10 08:30:00', '2026-03-10 08:30:00'),

(10058, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 89, 'fraise', 105.00, '2026-03-10', 'Stock', 3.00, 35.00, NULL, NULL,
 '2026-03-10 08:35:00', '2026-03-10 08:35:00'),

(10059, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 92, 'bannane', 60.00, '2026-03-10', 'Stock', 4.00, 15.00, NULL, NULL,
 '2026-03-10 08:35:00', '2026-03-10 08:35:00'),

(10060, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 90, 'mangue', 100.00, '2026-03-10', 'Stock', 2.00, 50.00, NULL, NULL,
 '2026-03-10 08:35:00', '2026-03-10 08:35:00'),

(10061, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 58, 'oeufs / plateau', 126.00, '2026-03-10', 'Stock', 3.00, 42.00, NULL, NULL,
 '2026-03-10 08:40:00', '2026-03-10 08:40:00'),

(10062, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 114, 'avocat', 96.00, '2026-03-10', 'Stock', 12.00, 8.00, NULL, NULL,
 '2026-03-10 08:40:00', '2026-03-10 08:40:00'),

(10063, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 116, 'tomate', 32.00, '2026-03-10', 'Stock', 4.00, 8.00, NULL, NULL,
 '2026-03-10 08:45:00', '2026-03-10 08:45:00'),

(10064, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 118, 'salade', 30.00, '2026-03-10', 'Stock', 6.00, 5.00, NULL, NULL,
 '2026-03-10 08:45:00', '2026-03-10 08:45:00'),

-- ── March 13 — Kitchen staples & misc ───────────────────────────────────────
(10065, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 71, 'Nutella 3kg', 245.00, '2026-03-13', 'Stock', 1.00, 245.00, NULL, NULL,
 '2026-03-13 09:00:00', '2026-03-13 09:00:00'),

(10066, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 21, 'amande', 18.15, '2026-03-13', 'Stock', 0.50, 36.30, NULL, NULL,
 '2026-03-13 09:00:00', '2026-03-13 09:00:00'),

(10067, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 18, 'Pistache', 220.00, '2026-03-13', 'Stock', 1.00, 220.00, NULL, NULL,
 '2026-03-13 09:05:00', '2026-03-13 09:05:00'),

(10068, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 20, 'Biscuit lotus', 96.00, '2026-03-13', 'Stock', 4.00, 24.00, NULL, NULL,
 '2026-03-13 09:05:00', '2026-03-13 09:05:00'),

(10069, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 19, 'Crème chatillé', 60.00, '2026-03-13', 'Stock', 3.00, 20.00, NULL, NULL,
 '2026-03-13 09:05:00', '2026-03-13 09:05:00'),

(10070, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 57, 'beure "ladda"', 170.00, '2026-03-13', 'Stock', 2.00, 85.00, NULL, NULL,
 '2026-03-13 09:10:00', '2026-03-13 09:10:00'),

(10071, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 59, 'farine nouara', 60.00, '2026-03-13', 'Stock', 5.00, 12.00, NULL, NULL,
 '2026-03-13 09:10:00', '2026-03-13 09:10:00'),

(10072, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 61, 'miel arabia / kg', 150.00, '2026-03-13', 'Stock', 1.00, 150.00, NULL, NULL,
 '2026-03-13 09:15:00', '2026-03-13 09:15:00'),

(10073, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 64, 'Fromage rouge', 60.00, '2026-03-13', 'Stock', 4.00, 15.00, NULL, NULL,
 '2026-03-13 09:15:00', '2026-03-13 09:15:00'),

(10074, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 65, 'Fromage enfant', 75.00, '2026-03-13', 'Stock', 30.00, 2.50, NULL, NULL,
 '2026-03-13 09:15:00', '2026-03-13 09:15:00'),

(10075, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 69, 'Confiture arabia peach', 450.00, '2026-03-13', 'Stock', 300.00, 1.50, NULL, NULL,
 '2026-03-13 09:20:00', '2026-03-13 09:20:00'),

(10076, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 62, 'huile d''olive', 160.00, '2026-03-13', 'Stock', 2.00, 80.00, NULL, NULL,
 '2026-03-13 09:20:00', '2026-03-13 09:20:00'),

(10077, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 63, 'Olive', 70.00, '2026-03-13', 'Stock', 2.00, 35.00, NULL, NULL,
 '2026-03-13 09:20:00', '2026-03-13 09:20:00'),

(10078, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 70, 'Dosette mayonnaise', 100.00, '2026-03-13', 'Stock', 1.00, 100.00, NULL, NULL,
 '2026-03-13 09:25:00', '2026-03-13 09:25:00'),

-- ── March 15 — Weekly restock 3 ─────────────────────────────────────────────
(10079, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 7, 'Café', 675.00, '2026-03-15', 'Stock', 5.00, 135.00, NULL, NULL,
 '2026-03-15 09:00:00', '2026-03-15 09:00:00'),

(10080, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 8, 'Sucre carraro / kg', 330.00, '2026-03-15', 'Stock', 3.00, 110.00, NULL, NULL,
 '2026-03-15 09:00:00', '2026-03-15 09:00:00'),

(10081, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 15, 'lait', 325.00, '2026-03-15', 'Stock', 5.00, 65.00, NULL, NULL,
 '2026-03-15 09:05:00', '2026-03-15 09:05:00'),

(10082, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 16, 'sucre Bleu', 55.00, '2026-03-15', 'Stock', 1.00, 55.00, NULL, NULL,
 '2026-03-15 09:05:00', '2026-03-15 09:05:00'),

(10083, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 9, 'chocolat chocao', 258.75, '2026-03-15', 'Stock', 1.50, 172.50, NULL, NULL,
 '2026-03-15 09:10:00', '2026-03-15 09:10:00'),

(10084, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 82, 'croissant', 2217.60, '2026-03-15', 'Stock', 8.00, 277.20, NULL, NULL,
 '2026-03-15 09:10:00', '2026-03-15 09:10:00'),

(10085, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 83, 'pain au chocolat', 1706.40, '2026-03-15', 'Stock', 6.00, 284.40, NULL, NULL,
 '2026-03-15 09:10:00', '2026-03-15 09:10:00'),

(10086, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 84, 'fondant', 460.80, '2026-03-15', 'Stock', 2.00, 230.40, NULL, NULL,
 '2026-03-15 09:15:00', '2026-03-15 09:15:00'),

(10087, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 85, 'muffin', 288.96, '2026-03-15', 'Stock', 2.00, 144.48, NULL, NULL,
 '2026-03-15 09:15:00', '2026-03-15 09:15:00'),

(10088, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 86, 'pain', 1080.00, '2026-03-15', 'Stock', 10.00, 108.00, NULL, NULL,
 '2026-03-15 09:15:00', '2026-03-15 09:15:00'),

(10089, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 87, 'gateau du jour', 600.00, '2026-03-15', 'Stock', 5.00, 120.00, NULL, NULL,
 '2026-03-15 09:20:00', '2026-03-15 09:20:00'),

(10090, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 88, 'Pain sandwich', 400.00, '2026-03-15', 'Stock', 4.00, 100.00, NULL, NULL,
 '2026-03-15 09:20:00', '2026-03-15 09:20:00'),

-- ── March 17 — Fresh produce 3 ──────────────────────────────────────────────
(10091, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 12, 'Orange', 105.00, '2026-03-17', 'Stock', 7.00, 15.00, NULL, NULL,
 '2026-03-17 08:30:00', '2026-03-17 08:30:00'),

(10092, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 112, 'citron', 40.00, '2026-03-17', 'Stock', 2.00, 20.00, NULL, NULL,
 '2026-03-17 08:30:00', '2026-03-17 08:30:00'),

(10093, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 89, 'fraise', 70.00, '2026-03-17', 'Stock', 2.00, 35.00, NULL, NULL,
 '2026-03-17 08:35:00', '2026-03-17 08:35:00'),

(10094, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 92, 'bannane', 45.00, '2026-03-17', 'Stock', 3.00, 15.00, NULL, NULL,
 '2026-03-17 08:35:00', '2026-03-17 08:35:00'),

(10095, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 91, 'ananas', 100.00, '2026-03-17', 'Stock', 4.00, 25.00, NULL, NULL,
 '2026-03-17 08:35:00', '2026-03-17 08:35:00'),

(10096, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 58, 'oeufs / plateau', 84.00, '2026-03-17', 'Stock', 2.00, 42.00, NULL, NULL,
 '2026-03-17 08:40:00', '2026-03-17 08:40:00'),

(10097, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 114, 'avocat', 64.00, '2026-03-17', 'Stock', 8.00, 8.00, NULL, NULL,
 '2026-03-17 08:40:00', '2026-03-17 08:40:00'),

(10098, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 116, 'tomate', 24.00, '2026-03-17', 'Stock', 3.00, 8.00, NULL, NULL,
 '2026-03-17 08:45:00', '2026-03-17 08:45:00'),

-- ── March 19 — Soda restock 2 ───────────────────────────────────────────────
(10099, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 108, 'eau sidi ali 33cl', 400.00, '2026-03-19', 'Stock', 200.00, 2.00, NULL, NULL,
 '2026-03-19 10:00:00', '2026-03-19 10:00:00'),

(10100, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 109, 'eau sidi ali 0,5l', 75.00, '2026-03-19', 'Stock', 30.00, 2.50, NULL, NULL,
 '2026-03-19 10:00:00', '2026-03-19 10:00:00'),

(10101, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 119, 'SODA', 24.00, '2026-03-19', 'Stock', 3.00, 8.00, NULL, NULL,
 '2026-03-19 10:05:00', '2026-03-19 10:05:00'),

(10102, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 101, 'pepsi 33cl', 96.00, '2026-03-19', 'Stock', 24.00, 4.00, NULL, NULL,
 '2026-03-19 10:05:00', '2026-03-19 10:05:00'),

(10103, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 46, 103, 'pepsi zéro 33cl', 48.00, '2026-03-19', 'Stock', 12.00, 4.00, NULL, NULL,
 '2026-03-19 10:10:00', '2026-03-19 10:10:00'),

(10104, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 120, 'product S', 104.00, '2026-03-19', 'Stock', 2.00, 52.00, NULL, NULL,
 '2026-03-19 10:10:00', '2026-03-19 10:10:00'),

-- ── March 22 — Weekly restock 4 ─────────────────────────────────────────────
(10105, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 7, 'Café', 540.00, '2026-03-22', 'Stock', 4.00, 135.00, NULL, NULL,
 '2026-03-22 09:00:00', '2026-03-22 09:00:00'),

(10106, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 8, 'Sucre carraro / kg', 220.00, '2026-03-22', 'Stock', 2.00, 110.00, NULL, NULL,
 '2026-03-22 09:00:00', '2026-03-22 09:00:00'),

(10107, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 15, 'lait', 260.00, '2026-03-22', 'Stock', 4.00, 65.00, NULL, NULL,
 '2026-03-22 09:05:00', '2026-03-22 09:05:00'),

(10108, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 10, 'nespresso / piece', 1200.00, '2026-03-22', 'Stock', 20.00, 60.00, NULL, NULL,
 '2026-03-22 09:05:00', '2026-03-22 09:05:00'),

(10109, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 11, 'thé bellar', 104.00, '2026-03-22', 'Stock', 8.00, 13.00, NULL, NULL,
 '2026-03-22 09:10:00', '2026-03-22 09:10:00'),

(10110, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 41, 'Chocolat carraro', 165.00, '2026-03-22', 'Stock', 1.00, 165.00, NULL, NULL,
 '2026-03-22 09:10:00', '2026-03-22 09:10:00'),

(10111, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 82, 'croissant', 1940.40, '2026-03-22', 'Stock', 7.00, 277.20, NULL, NULL,
 '2026-03-22 09:15:00', '2026-03-22 09:15:00'),

(10112, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 83, 'pain au chocolat', 1422.00, '2026-03-22', 'Stock', 5.00, 284.40, NULL, NULL,
 '2026-03-22 09:15:00', '2026-03-22 09:15:00'),

(10113, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 86, 'pain', 972.00, '2026-03-22', 'Stock', 9.00, 108.00, NULL, NULL,
 '2026-03-22 09:15:00', '2026-03-22 09:15:00'),

(10114, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 87, 'gateau du jour', 480.00, '2026-03-22', 'Stock', 4.00, 120.00, NULL, NULL,
 '2026-03-22 09:20:00', '2026-03-22 09:20:00'),

(10115, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 88, 'Pain sandwich', 400.00, '2026-03-22', 'Stock', 4.00, 100.00, NULL, NULL,
 '2026-03-22 09:20:00', '2026-03-22 09:20:00'),

-- ── March 24 — Fresh produce 4 ──────────────────────────────────────────────
(10116, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 12, 'Orange', 90.00, '2026-03-24', 'Stock', 6.00, 15.00, NULL, NULL,
 '2026-03-24 08:30:00', '2026-03-24 08:30:00'),

(10117, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 112, 'citron', 60.00, '2026-03-24', 'Stock', 3.00, 20.00, NULL, NULL,
 '2026-03-24 08:30:00', '2026-03-24 08:30:00'),

(10118, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 89, 'fraise', 105.00, '2026-03-24', 'Stock', 3.00, 35.00, NULL, NULL,
 '2026-03-24 08:35:00', '2026-03-24 08:35:00'),

(10119, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 92, 'bannane', 60.00, '2026-03-24', 'Stock', 4.00, 15.00, NULL, NULL,
 '2026-03-24 08:35:00', '2026-03-24 08:35:00'),

(10120, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 90, 'mangue', 150.00, '2026-03-24', 'Stock', 3.00, 50.00, NULL, NULL,
 '2026-03-24 08:35:00', '2026-03-24 08:35:00'),

(10121, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 91, 'ananas', 75.00, '2026-03-24', 'Stock', 3.00, 25.00, NULL, NULL,
 '2026-03-24 08:35:00', '2026-03-24 08:35:00'),

(10122, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 58, 'oeufs / plateau', 126.00, '2026-03-24', 'Stock', 3.00, 42.00, NULL, NULL,
 '2026-03-24 08:40:00', '2026-03-24 08:40:00'),

(10123, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 114, 'avocat', 80.00, '2026-03-24', 'Stock', 10.00, 8.00, NULL, NULL,
 '2026-03-24 08:40:00', '2026-03-24 08:40:00'),

(10124, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 116, 'tomate', 40.00, '2026-03-24', 'Stock', 5.00, 8.00, NULL, NULL,
 '2026-03-24 08:45:00', '2026-03-24 08:45:00'),

(10125, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 118, 'salade', 40.00, '2026-03-24', 'Stock', 8.00, 5.00, NULL, NULL,
 '2026-03-24 08:45:00', '2026-03-24 08:45:00'),

-- ── March 26 — Kitchen items + Hygiene/Cleaning ─────────────────────────────
(10126, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 66, 'sauce tomate napolitaine', 72.00, '2026-03-26', 'Stock', 4.00, 18.00, NULL, NULL,
 '2026-03-26 09:00:00', '2026-03-26 09:00:00'),

(10127, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 67, 'khlie', 400.00, '2026-03-26', 'Stock', 2.00, 200.00, NULL, NULL,
 '2026-03-26 09:00:00', '2026-03-26 09:00:00'),

(10128, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 68, 'dinde fumé', 180.00, '2026-03-26', 'Stock', 4.00, 45.00, NULL, NULL,
 '2026-03-26 09:05:00', '2026-03-26 09:05:00'),

(10129, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 73, 'toast', 75.00, '2026-03-26', 'Stock', 5.00, 15.00, NULL, NULL,
 '2026-03-26 09:05:00', '2026-03-26 09:05:00'),

(10130, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 72, 'vermicelle chocolat', 36.00, '2026-03-26', 'Stock', 3.00, 12.00, NULL, NULL,
 '2026-03-26 09:05:00', '2026-03-26 09:05:00'),

(10131, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 60, 'ideal sucre vanille', 36.00, '2026-03-26', 'Stock', 6.00, 6.00, NULL, NULL,
 '2026-03-26 09:10:00', '2026-03-26 09:10:00'),

(10132, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 122, 'Beurre portion', 150.00, '2026-03-26', 'Stock', 1.00, 150.00, NULL, NULL,
 '2026-03-26 09:10:00', '2026-03-26 09:10:00'),

(10133, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 80, 'Aluminium', 180.00, '2026-03-26', 'Stock', 2.00, 90.00, NULL, NULL,
 '2026-03-26 09:10:00', '2026-03-26 09:10:00'),

(10134, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 115, 'thon', 180.00, '2026-03-26', 'Stock', 2.00, 90.00, NULL, NULL,
 '2026-03-26 09:15:00', '2026-03-26 09:15:00'),

-- ── March 28 — Bar packaging / cups / straws ────────────────────────────────
(10142, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 48, 'Gobelt 16Oz "JUS"', 70.00, '2026-03-28', 'Stock', 100.00, 0.70, NULL, NULL,
 '2026-03-28 09:00:00', '2026-03-28 09:00:00'),

(10143, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 49, 'Goblet 8Oz "café creme"', 82.50, '2026-03-28', 'Stock', 150.00, 0.55, NULL, NULL,
 '2026-03-28 09:00:00', '2026-03-28 09:00:00'),

(10144, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 50, 'Goblet 4OZ "café noir"', 60.00, '2026-03-28', 'Stock', 150.00, 0.40, NULL, NULL,
 '2026-03-28 09:00:00', '2026-03-28 09:00:00'),

(10145, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 51, 'Sac kraft', 24.00, '2026-03-28', 'Stock', 20.00, 1.20, NULL, NULL,
 '2026-03-28 09:05:00', '2026-03-28 09:05:00'),

(10146, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 52, 'Barquette 2comp', 30.00, '2026-03-28', 'Stock', 20.00, 1.50, NULL, NULL,
 '2026-03-28 09:05:00', '2026-03-28 09:05:00'),

(10147, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 53, 'Cuillère café jetable', 100.00, '2026-03-28', 'Stock', 2.00, 50.00, NULL, NULL,
 '2026-03-28 09:05:00', '2026-03-28 09:05:00'),

(10148, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 55, 'Les pailles 500', 24.00, '2026-03-28', 'Stock', 1.00, 24.00, NULL, NULL,
 '2026-03-28 09:10:00', '2026-03-28 09:10:00'),

-- ── March 29 — Weekly restock 5 ─────────────────────────────────────────────
(10149, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 7, 'Café', 675.00, '2026-03-29', 'Stock', 5.00, 135.00, NULL, NULL,
 '2026-03-29 09:00:00', '2026-03-29 09:00:00'),

(10150, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 8, 'Sucre carraro / kg', 330.00, '2026-03-29', 'Stock', 3.00, 110.00, NULL, NULL,
 '2026-03-29 09:00:00', '2026-03-29 09:00:00'),

(10151, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 15, 'lait', 325.00, '2026-03-29', 'Stock', 5.00, 65.00, NULL, NULL,
 '2026-03-29 09:05:00', '2026-03-29 09:05:00'),

(10152, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 9, 'chocolat chocao', 172.50, '2026-03-29', 'Stock', 1.00, 172.50, NULL, NULL,
 '2026-03-29 09:05:00', '2026-03-29 09:05:00'),

(10153, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 82, 'croissant', 2217.60, '2026-03-29', 'Stock', 8.00, 277.20, NULL, NULL,
 '2026-03-29 09:10:00', '2026-03-29 09:10:00'),

(10154, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 83, 'pain au chocolat', 1706.40, '2026-03-29', 'Stock', 6.00, 284.40, NULL, NULL,
 '2026-03-29 09:10:00', '2026-03-29 09:10:00'),

(10155, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 86, 'pain', 1080.00, '2026-03-29', 'Stock', 10.00, 108.00, NULL, NULL,
 '2026-03-29 09:15:00', '2026-03-29 09:15:00'),

(10156, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 87, 'gateau du jour', 600.00, '2026-03-29', 'Stock', 5.00, 120.00, NULL, NULL,
 '2026-03-29 09:15:00', '2026-03-29 09:15:00'),

(10157, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 88, 'Pain sandwich', 400.00, '2026-03-29', 'Stock', 4.00, 100.00, NULL, NULL,
 '2026-03-29 09:15:00', '2026-03-29 09:15:00'),

(10158, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 85, 'muffin', 433.44, '2026-03-29', 'Stock', 3.00, 144.48, NULL, NULL,
 '2026-03-29 09:20:00', '2026-03-29 09:20:00'),

-- ── March 31 — Fresh produce 5 + month-end misc ─────────────────────────────
(10159, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 12, 'Orange', 120.00, '2026-03-31', 'Stock', 8.00, 15.00, NULL, NULL,
 '2026-03-31 08:30:00', '2026-03-31 08:30:00'),

(10160, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 112, 'citron', 60.00, '2026-03-31', 'Stock', 3.00, 20.00, NULL, NULL,
 '2026-03-31 08:30:00', '2026-03-31 08:30:00'),

(10161, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 43, 92, 'bannane', 75.00, '2026-03-31', 'Stock', 5.00, 15.00, NULL, NULL,
 '2026-03-31 08:35:00', '2026-03-31 08:35:00'),

(10162, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 58, 'oeufs / plateau', 126.00, '2026-03-31', 'Stock', 3.00, 42.00, NULL, NULL,
 '2026-03-31 08:40:00', '2026-03-31 08:40:00'),

(10163, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 114, 'avocat', 96.00, '2026-03-31', 'Stock', 12.00, 8.00, NULL, NULL,
 '2026-03-31 08:40:00', '2026-03-31 08:40:00'),

(10164, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 116, 'tomate', 32.00, '2026-03-31', 'Stock', 4.00, 8.00, NULL, NULL,
 '2026-03-31 08:45:00', '2026-03-31 08:45:00'),

(10165, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 40, 118, 'salade', 30.00, '2026-03-31', 'Stock', 6.00, 5.00, NULL, NULL,
 '2026-03-31 08:45:00', '2026-03-31 08:45:00'),

(10166, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 113, 'gingembre', 30.00, '2026-03-31', 'Stock', 0.50, 60.00, NULL, NULL,
 '2026-03-31 08:50:00', '2026-03-31 08:50:00'),

(10167, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 117, 'matcha', 400.00, '2026-03-31', 'Stock', 0.50, 800.00, NULL, NULL,
 '2026-03-31 08:50:00', '2026-03-31 08:50:00'),

(10168, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 26, 'verveine LOUIZA / kg', 120.00, '2026-03-31', 'Stock', 1.00, 120.00, NULL, NULL,
 '2026-03-31 08:55:00', '2026-03-31 08:55:00'),

(10169, 2, (SELECT id FROM variable_charge_main_categories WHERE store_id = 2 AND code = 'stock' LIMIT 1),
 37, 27, 'origan ZAATAR', 90.00, '2026-03-31', 'Stock', 2.00, 45.00, NULL, NULL,
 '2026-03-31 08:55:00', '2026-03-31 08:55:00'),

-- ── Store 1 — March purchases ───────────────────────────────────────────────
(10172, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 38, 1, 'Coca-Cola 33cl', 240.00, '2026-03-05', 'Stock', 48.00, 5.00, NULL, NULL,
 '2026-03-05 10:00:00', '2026-03-05 10:00:00'),

(10173, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 38, 2, 'Orange juice 1L', 185.00, '2026-03-05', 'Stock', 10.00, 18.50, NULL, NULL,
 '2026-03-05 10:00:00', '2026-03-05 10:00:00'),

(10174, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 41, 3, 'Tomatoes', 240.00, '2026-03-05', 'Stock', 20.00, 12.00, NULL, NULL,
 '2026-03-05 10:05:00', '2026-03-05 10:05:00'),

(10176, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 32, 5, 'Takeaway boxes 100p', 280.00, '2026-03-05', 'Stock', 10.00, 28.00, NULL, NULL,
 '2026-03-05 10:05:00', '2026-03-05 10:05:00'),

(10177, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 38, 1, 'Coca-Cola 33cl', 240.00, '2026-03-15', 'Stock', 48.00, 5.00, NULL, NULL,
 '2026-03-15 10:00:00', '2026-03-15 10:00:00'),

(10178, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 38, 2, 'Orange juice 1L', 148.00, '2026-03-15', 'Stock', 8.00, 18.50, NULL, NULL,
 '2026-03-15 10:00:00', '2026-03-15 10:00:00'),

(10179, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 41, 3, 'Tomatoes', 180.00, '2026-03-15', 'Stock', 15.00, 12.00, NULL, NULL,
 '2026-03-15 10:05:00', '2026-03-15 10:05:00'),

(10180, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 38, 1, 'Coca-Cola 33cl', 240.00, '2026-03-25', 'Stock', 48.00, 5.00, NULL, NULL,
 '2026-03-25 10:00:00', '2026-03-25 10:00:00'),

(10181, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 41, 3, 'Tomatoes', 240.00, '2026-03-25', 'Stock', 20.00, 12.00, NULL, NULL,
 '2026-03-25 10:05:00', '2026-03-25 10:05:00'),

(10182, 1, (SELECT id FROM variable_charge_main_categories WHERE store_id = 1 AND code = 'stock' LIMIT 1),
 32, 5, 'Takeaway boxes 100p', 280.00, '2026-03-25', 'Stock', 10.00, 28.00, NULL, NULL,
 '2026-03-25 10:05:00', '2026-03-25 10:05:00');


-- ============================================================================
-- PART 4: Auto-generate stock movements from variable charges
-- ============================================================================
-- Only for raw-material sub-categories (bar, kitchen, freezer, soda).
-- Packaging and other non-raw categories do not produce stock movements from this SELECT.
-- quantity in stock_movements = charge.quantity × product.base_per_counting_unit (base unit)
-- amount in stock_movements = charge.amount (total MAD cost)
--
-- IMPORTANT (real vs estimated stock):
-- Real stock = last inventory snapshot + movements with created_at > snapshot.created_at
-- (see StockMovementRepository.sumQuantityAfterCreatedAtForReal).
-- movement_date stays the business date (March) for reporting; created_at MUST be "when the
-- movement was recorded" so backfilled purchases still count toward real stock after any
-- existing snapshot. Using vc.created_at (March) makes real drift ignore these rows while
-- estimated stock still includes them — use CURRENT_TIMESTAMP here.

INSERT INTO stock_movements (store_id, product_id, type, quantity, amount, movement_date, reference_type, reference_id, notes, created_at)
SELECT
    vc.store_id,
    vc.product_id,
    'PURCHASE',
    vc.quantity * COALESCE(p.base_per_counting_unit, 1),
    vc.amount,
    vc.date,
    'VARIABLE_CHARGE',
    vc.id,
    NULL,
    CURRENT_TIMESTAMP
FROM variable_charges vc
JOIN stock_products p ON p.id = vc.product_id
JOIN variable_charge_sub_categories sc ON sc.id = p.sub_category_id
WHERE vc.id >= 10001 AND vc.id <= 10182
  AND sc.code IN ('bar', 'kitchen', 'freezer', 'soda');


-- ============================================================================
-- PART 5: Reset sequences so future inserts don't conflict
-- ============================================================================
-- pg_get_serial_sequence() returns a *name* (text), not a table — use pg_sequences or a literal seq name for last_value.
SELECT setval(
    'variable_charge_id_seq',
    GREATEST(
        COALESCE((SELECT MAX(id) FROM variable_charges), 0),
        (SELECT last_value FROM variable_charge_id_seq)
    )
);

SELECT setval(
    pg_get_serial_sequence('stock_movements', 'id'),
    GREATEST(
        COALESCE((SELECT MAX(id) FROM stock_movements), 0),
        COALESCE(
            (
                SELECT s.last_value
                FROM pg_sequences s
                WHERE s.schemaname = split_part(pg_get_serial_sequence('stock_movements', 'id'), '.', 1)
                  AND s.sequencename = split_part(pg_get_serial_sequence('stock_movements', 'id'), '.', 2)
            ),
            0
        )
    )
);


COMMIT;

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Unit price fixes:  41 products updated (from 0 to realistic MAD prices; hygiene/cash register excluded)
-- Unit fixes:        5 products corrected (Pistache, beure, farine, khlie, salade)
-- Variable charges:  172 purchase records across March 2026
--   - Store 2: 162 entries (bar, kitchen, freezer, soda only)
--   - Store 1: 10 entries (raw + packaging; hygiene excluded)
-- Stock movements:   Auto-generated for bar/kitchen/freezer/soda sub-categories only
--
-- If you already ran an older version that set stock_movements.created_at from March dates,
-- real stock will stay wrong until you bump created_at (strictly after latest snapshot), e.g.:
--   UPDATE stock_movements SET created_at = CURRENT_TIMESTAMP
--   WHERE reference_type = 'VARIABLE_CHARGE' AND type = 'PURCHASE'
--     AND reference_id BETWEEN 10001 AND 10182;
-- ============================================================================
