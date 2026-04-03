-- Suppliers (per store) and links to stock products (purchasing sources)
CREATE TABLE suppliers (
    id BIGSERIAL PRIMARY KEY,
    store_id BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(100),
    notes VARCHAR(2000),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_suppliers_store_id ON suppliers(store_id);
CREATE INDEX idx_suppliers_store_active_name ON suppliers(store_id, is_active, name);

CREATE TABLE supplier_stock_products (
    id BIGSERIAL PRIMARY KEY,
    supplier_id BIGINT NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    stock_product_id BIGINT NOT NULL REFERENCES stock_products(id) ON DELETE CASCADE,
    supplier_sku VARCHAR(120),
    is_preferred BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_supplier_stock_product UNIQUE (supplier_id, stock_product_id)
);

CREATE INDEX idx_supplier_stock_supplier_id ON supplier_stock_products(supplier_id);
CREATE INDEX idx_supplier_stock_product_id ON supplier_stock_products(stock_product_id);
