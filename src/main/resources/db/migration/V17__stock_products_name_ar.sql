-- Optional Arabic display name for stock products (backoffice / labels)
ALTER TABLE stock_products
    ADD COLUMN IF NOT EXISTS name_ar VARCHAR(255) NULL;

COMMENT ON COLUMN stock_products.name_ar IS 'Optional product name in Arabic for display and search';
