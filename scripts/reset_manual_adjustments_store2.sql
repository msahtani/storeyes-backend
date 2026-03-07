-- =============================================================================
-- One-time: remove existing MANUAL_ADJUSTMENT movements for store_id = 2.
-- Run this ONCE if you already ran the old seed and want to re-seed with the
-- new script (human quantities + amount filled).
--
-- After this, run: seed_adjustment_movements_counting_units.sql
-- =============================================================================

DELETE FROM stock_movements
WHERE store_id = 2
  AND reference_type = 'MANUAL_ADJUSTMENT';
