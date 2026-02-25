-- Stock products: single source for backoffice (product management, inventory) and mobile (variable charge picker, stock screens)
CREATE TABLE stock_products (
    id BIGSERIAL PRIMARY KEY,
    store_id BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    sub_category_id BIGINT NOT NULL REFERENCES variable_charge_sub_categories(id) ON DELETE RESTRICT,
    name VARCHAR(255) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    minimal_threshold DECIMAL(12, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stock_products_store_id ON stock_products(store_id);
CREATE INDEX idx_stock_products_sub_category_id ON stock_products(sub_category_id);
CREATE INDEX idx_stock_products_store_name ON stock_products(store_id, name);
