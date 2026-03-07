-- =============================================================================
-- Seed ADJUSTMENT movements for products that have counting_unit (store_id = 2).
-- Quantities are in HUMAN/COUNTING units; converted to base unit via base_per_counting_unit.
-- Amount (MAD) is taken only from amount_mad below – fill it for each product (no unit_price).
--
-- Edit the "seed" CTE: set amount_mad (MAD) for every row so no movement has 0 unless
-- you really don't know the cost. Safe to run multiple times (skips if adjustment exists).
--
-- If you already ran an OLD version: run reset_manual_adjustments_store2.sql first.
-- =============================================================================

WITH seed (product_id, counting_quantity, amount_mad) AS (
  VALUES
    (7::bigint,  2.00, 270.00),   -- Café: 2 kg
    (8::bigint,  1.00, 110.00),   -- Sucre carraro: 1 kg
    (12::bigint, 1.00, 45.00),   -- Orange (jus pressé): 1 box – fill your cost
    (15::bigint, 10.00, 85.00),  -- lait: 10 bottles – fill your cost
    (16::bigint, 1.00, 12.00),   -- sucre Bleu: 1 box – fill your cost
    (28::bigint, 1.00, 18.00),   -- sucre sacarine: 1 box
    (32::bigint, 1.00, 190.00),  -- Purée de fraise: 1 bottle
    (37::bigint, 1.00, 120.00),  -- Sirop Bubble Gum: 1 bottle
    (48::bigint, 2.00, 1.40),    -- Gobelt 16Oz JUS: 2 packs
    (55::bigint, 1.00, 24.00),   -- Les pailles 500: 1 pack
    (58::bigint, 2.00, 35.00),   -- oeufs: 2 plateaux – fill your cost
    (61::bigint, 2.00, 80.00),   -- miel arabia: 2 kg – fill your cost
    (82::bigint, 30.00, 450.00), -- croissant: 30 unit – fill your cost
    (112::bigint, 5.00, 15.00),  -- Jus de citron: 5 piece – fill your cost
    (113::bigint, 0.50, 25.00),  -- gingembre: 0.5 kg – fill your cost
    (117::bigint, 0.20, 40.00)  -- matcha: 0.2 kg – fill your cost
)
INSERT INTO stock_movements (store_id, product_id, type, quantity, amount, movement_date, reference_type, reference_id, notes, created_at)
SELECT
  2,
  sp.id,
  'ADJUSTMENT',
  (s.counting_quantity * sp.base_per_counting_unit),
  s.amount_mad,
  CURRENT_DATE,
  'MANUAL_ADJUSTMENT',
  NULL,
  'Manual stock: ' || s.counting_quantity || ' ' || COALESCE(sp.counting_unit, sp.unit) || ' ' || sp.name,
  CURRENT_TIMESTAMP
FROM seed s
JOIN stock_products sp ON sp.id = s.product_id AND sp.store_id = 2
WHERE sp.base_per_counting_unit IS NOT NULL
  AND sp.base_per_counting_unit > 0
  AND NOT EXISTS (
    SELECT 1 FROM stock_movements m
    WHERE m.store_id = 2 AND m.product_id = sp.id AND m.reference_type = 'MANUAL_ADJUSTMENT'
  );
