-- Inventory sessions and snapshots for storing validated physical counts (real stock)
-- Enables returning both real and estimated stock for variance calculation

CREATE TABLE stock_inventory_sessions (
    id BIGSERIAL PRIMARY KEY,
    store_id BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP NULL,
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stock_inventory_sessions_store_id ON stock_inventory_sessions(store_id);
CREATE INDEX idx_stock_inventory_sessions_finished_at ON stock_inventory_sessions(finished_at);

CREATE TABLE stock_inventory_snapshots (
    id BIGSERIAL PRIMARY KEY,
    session_id BIGINT NOT NULL REFERENCES stock_inventory_sessions(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES stock_products(id) ON DELETE CASCADE,
    counting_quantity DECIMAL(12, 4) NOT NULL,
    base_quantity DECIMAL(12, 4) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(session_id, product_id)
);

CREATE INDEX idx_stock_inventory_snapshots_session ON stock_inventory_snapshots(session_id);
CREATE INDEX idx_stock_inventory_snapshots_product ON stock_inventory_snapshots(product_id);
CREATE INDEX idx_stock_inventory_snapshots_product_created ON stock_inventory_snapshots(product_id, created_at DESC);

COMMENT ON TABLE stock_inventory_sessions IS 'Physical count sessions; finished_at set when owner validates';
COMMENT ON TABLE stock_inventory_snapshots IS 'Per-product validated counts; base_quantity used for real stock calculation';
