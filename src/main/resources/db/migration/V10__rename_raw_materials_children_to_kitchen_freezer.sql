-- Align sub-category names under Raw materials with VARIABLE_CHARGE_REDESIGN.md: Kitchen, Freezer (was Cuisine, Congelateur)
UPDATE variable_charge_sub_categories SET name = 'Kitchen', code = 'kitchen' WHERE code = 'cuisine';
UPDATE variable_charge_sub_categories SET name = 'Freezer', code = 'freezer' WHERE code = 'congelateur';
