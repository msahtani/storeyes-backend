-- Add amount (MAD) to snapshots for real stock value without extra calculation
-- Real value = snapshot.amount + sum(amounts from real movements after snapshot)

ALTER TABLE stock_inventory_snapshots
    ADD COLUMN amount DECIMAL(12, 2) NULL DEFAULT 0;

COMMENT ON COLUMN stock_inventory_snapshots.amount IS 'Value (MAD) of validated count at snapshot time; real value = amount + movements after';
