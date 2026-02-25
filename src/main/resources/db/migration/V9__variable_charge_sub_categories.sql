-- Variable charge sub-categories (e.g. under Stock: Raw materials, Hygiene, Packaging, Cash register;
-- under Raw materials: Bar, Cuisine, Congelateur, Soda)
CREATE TABLE variable_charge_sub_categories (
    id BIGSERIAL PRIMARY KEY,
    main_category_id BIGINT NOT NULL REFERENCES variable_charge_main_categories(id) ON DELETE CASCADE,
    parent_sub_category_id BIGINT NULL REFERENCES variable_charge_sub_categories(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_variable_charge_sub_categories_main_category_id ON variable_charge_sub_categories(main_category_id);
CREATE INDEX idx_variable_charge_sub_categories_parent_id ON variable_charge_sub_categories(parent_sub_category_id);

-- Seed direct sub-categories for Stock main category (parent_sub_category_id NULL)
INSERT INTO variable_charge_sub_categories (main_category_id, parent_sub_category_id, name, code, sort_order, created_at, updated_at)
SELECT mc.id, NULL, 'Raw materials', 'raw_materials', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM variable_charge_main_categories mc WHERE mc.code = 'stock';

INSERT INTO variable_charge_sub_categories (main_category_id, parent_sub_category_id, name, code, sort_order, created_at, updated_at)
SELECT mc.id, NULL, 'Hygiene products', 'hygiene', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM variable_charge_main_categories mc WHERE mc.code = 'stock';

INSERT INTO variable_charge_sub_categories (main_category_id, parent_sub_category_id, name, code, sort_order, created_at, updated_at)
SELECT mc.id, NULL, 'Packaging', 'packaging', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM variable_charge_main_categories mc WHERE mc.code = 'stock';

INSERT INTO variable_charge_sub_categories (main_category_id, parent_sub_category_id, name, code, sort_order, created_at, updated_at)
SELECT mc.id, NULL, 'Cash register', 'cash_register', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM variable_charge_main_categories mc WHERE mc.code = 'stock';

-- Seed child sub-categories under Raw materials only (Bar, Kitchen, Freezer, Soda)
INSERT INTO variable_charge_sub_categories (main_category_id, parent_sub_category_id, name, code, sort_order, created_at, updated_at)
SELECT sc.main_category_id, sc.id, 'Bar', 'bar', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM variable_charge_sub_categories sc WHERE sc.code = 'raw_materials' AND sc.parent_sub_category_id IS NULL;

INSERT INTO variable_charge_sub_categories (main_category_id, parent_sub_category_id, name, code, sort_order, created_at, updated_at)
SELECT sc.main_category_id, sc.id, 'Kitchen', 'kitchen', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM variable_charge_sub_categories sc WHERE sc.code = 'raw_materials' AND sc.parent_sub_category_id IS NULL;

INSERT INTO variable_charge_sub_categories (main_category_id, parent_sub_category_id, name, code, sort_order, created_at, updated_at)
SELECT sc.main_category_id, sc.id, 'Freezer', 'freezer', 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM variable_charge_sub_categories sc WHERE sc.code = 'raw_materials' AND sc.parent_sub_category_id IS NULL;

INSERT INTO variable_charge_sub_categories (main_category_id, parent_sub_category_id, name, code, sort_order, created_at, updated_at)
SELECT sc.main_category_id, sc.id, 'Soda', 'soda', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM variable_charge_sub_categories sc WHERE sc.code = 'raw_materials' AND sc.parent_sub_category_id IS NULL;
