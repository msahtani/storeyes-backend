-- Add staff source store to demo store mappings, so a demo store's staff/attendance reads
-- (proxied to the upstream staff service) can be sourced from a different real store, consistent
-- with the other source mappings. Applies to GET requests only — writes still target the caller's
-- actual store.
ALTER TABLE demo_store_mappings
    ADD COLUMN IF NOT EXISTS staff_source_store_id BIGINT REFERENCES stores(id);
