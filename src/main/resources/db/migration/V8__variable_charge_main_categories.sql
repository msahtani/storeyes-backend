-- Variable charge main categories (e.g. Stock, Achat exceptionnel) – store-scoped
CREATE TABLE variable_charge_main_categories (
    id BIGSERIAL PRIMARY KEY,
    store_id BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_variable_charge_main_categories_store_id ON variable_charge_main_categories(store_id);

-- Seed default main categories for all existing stores: Stock and Achat exceptionnel
INSERT INTO variable_charge_main_categories (store_id, name, code, sort_order, created_at, updated_at)
SELECT id, 'Stock', 'stock', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM stores;

INSERT INTO variable_charge_main_categories (store_id, name, code, sort_order, created_at, updated_at)
SELECT id, 'Achat exceptionnel', 'achat_exceptionnel', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM stores;
