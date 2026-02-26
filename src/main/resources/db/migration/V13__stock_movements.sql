-- Stock movements: every in/out of stock (purchases from variable charges, consumption, adjustments).
-- Quantity is signed: positive = IN, negative = OUT.
-- Amount = total price (MAD) for this movement; used for inventory value (product unit price can change).
CREATE TABLE stock_movements (
    id BIGSERIAL PRIMARY KEY,
    store_id BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES stock_products(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    quantity DECIMAL(12, 2) NOT NULL,
    amount DECIMAL(12, 2) NULL,
    movement_date DATE NOT NULL,
    reference_type VARCHAR(50) NULL,
    reference_id BIGINT NULL,
    notes VARCHAR(500) NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_stock_movements_store_id ON stock_movements(store_id);
CREATE INDEX idx_stock_movements_product_id ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_store_product ON stock_movements(store_id, product_id);
CREATE INDEX idx_stock_movements_movement_date ON stock_movements(movement_date);
CREATE INDEX idx_stock_movements_reference ON stock_movements(reference_type, reference_id);

COMMENT ON COLUMN stock_movements.quantity IS 'Signed: positive = stock IN, negative = stock OUT';
COMMENT ON COLUMN stock_movements.amount IS 'Total price (MAD) for this movement; for PURCHASE = what was paid (from variable_charge.amount)';
