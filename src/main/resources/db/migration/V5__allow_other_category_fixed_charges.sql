-- Allow OTHER category in fixed_charges (violates existing check constraint otherwise)
ALTER TABLE fixed_charges DROP CONSTRAINT IF EXISTS fixed_charges_category_check;
ALTER TABLE fixed_charges ADD CONSTRAINT fixed_charges_category_check
  CHECK (category IN ('PERSONNEL', 'WATER', 'ELECTRICITY', 'WIFI', 'OTHER'));
