-- Add feedback source store to demo store mappings, so a demo store's kiosk feedback
-- (reviews / satisfaction stats) can be sourced from a different real store, consistent
-- with alerts/kpi/stock/charges/access source mappings.
ALTER TABLE demo_store_mappings
    ADD COLUMN IF NOT EXISTS feedback_source_store_id BIGINT REFERENCES stores(id);
