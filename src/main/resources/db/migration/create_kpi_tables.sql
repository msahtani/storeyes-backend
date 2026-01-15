-- =====================================================
-- KPI Module Database Schema
-- =====================================================
-- This script creates all tables for the KPI module entities
-- Note: Some entities have incorrect @Table annotations that need to be fixed
-- =====================================================

-- =====================================================
-- 1. Date Dimension Table
-- =====================================================
CREATE SEQUENCE IF NOT EXISTS date_dimension_id_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS date_dimensions (
    id BIGINT PRIMARY KEY DEFAULT nextval('date_dimension_id_seq'),
    date DATE NOT NULL UNIQUE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    CONSTRAINT date_dimensions_date_unique UNIQUE (date)
);

CREATE INDEX IF NOT EXISTS idx_date_dimensions_date ON date_dimensions(date);
CREATE INDEX IF NOT EXISTS idx_date_dimensions_year_month ON date_dimensions(year, month);

-- Link sequence to column (deep binding)
ALTER SEQUENCE date_dimension_id_seq OWNED BY date_dimensions.id;

COMMENT ON TABLE date_dimensions IS 'Date dimension table for time-based KPI analysis';
COMMENT ON COLUMN date_dimensions.month IS '1=January, 2=February, ..., 12=December';
COMMENT ON COLUMN date_dimensions.day_of_week IS '0=Sunday, 1=Monday, ..., 6=Saturday';

-- =====================================================
-- 2. Fact KPI Daily Table
-- =====================================================
-- NOTE: Entity FactKpiDaily has @Table(name = "fact_kpi_hourly") which is INCORRECT
-- Should be: fact_kpi_daily
-- Creating table as fact_kpi_daily (correct name)
-- You may need to fix the entity annotation
CREATE SEQUENCE IF NOT EXISTS fact_kpi_daily_id_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS fact_kpi_daily (
    id BIGINT PRIMARY KEY DEFAULT nextval('fact_kpi_daily_id_seq'),
    store_id BIGINT NOT NULL,
    date_id BIGINT NOT NULL,
    total_revenue_ht DOUBLE PRECISION NOT NULL,
    total_revenue_ttc DOUBLE PRECISION NOT NULL,
    total_tax DOUBLE PRECISION NOT NULL,
    transactions INTEGER NOT NULL,
    total_revenue DOUBLE PRECISION NOT NULL,
    total_items_sold INTEGER NOT NULL,
    avg_transaction_value DOUBLE PRECISION NOT NULL,
    CONSTRAINT fk_fact_kpi_daily_store FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    CONSTRAINT fk_fact_kpi_daily_date FOREIGN KEY (date_id) REFERENCES date_dimensions(id) ON DELETE CASCADE,
    CONSTRAINT uk_fact_kpi_daily_store_date UNIQUE (store_id, date_id)
);

CREATE INDEX IF NOT EXISTS idx_fact_kpi_daily_store ON fact_kpi_daily(store_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_daily_date ON fact_kpi_daily(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_daily_store_date ON fact_kpi_daily(store_id, date_id);

-- Link sequence to column (deep binding)
ALTER SEQUENCE fact_kpi_daily_id_seq OWNED BY fact_kpi_daily.id;

COMMENT ON TABLE fact_kpi_daily IS 'Daily aggregated KPI facts per store';

-- =====================================================
-- 3. Fact KPI Hourly Table
-- =====================================================
CREATE SEQUENCE IF NOT EXISTS fact_kpi_hourly_id_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS fact_kpi_hourly (
    id BIGINT PRIMARY KEY DEFAULT nextval('fact_kpi_hourly_id_seq'),
    store_id BIGINT NOT NULL,
    date_id BIGINT NOT NULL,
    hour INTEGER NOT NULL CHECK (hour >= 0 AND hour <= 23),
    transactions INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    revenue DOUBLE PRECISION NOT NULL,
    CONSTRAINT fk_fact_kpi_hourly_store FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    CONSTRAINT fk_fact_kpi_hourly_date FOREIGN KEY (date_id) REFERENCES date_dimensions(id) ON DELETE CASCADE,
    CONSTRAINT uk_fact_kpi_hourly_store_date_hour UNIQUE (store_id, date_id, hour)
);

CREATE INDEX IF NOT EXISTS idx_fact_kpi_hourly_store ON fact_kpi_hourly(store_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_hourly_date ON fact_kpi_hourly(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_hourly_store_date ON fact_kpi_hourly(store_id, date_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_hourly_hour ON fact_kpi_hourly(hour);

COMMENT ON TABLE fact_kpi_hourly IS 'Hourly aggregated KPI facts per store';
COMMENT ON COLUMN fact_kpi_hourly.hour IS 'Hour of day (0-23)';

-- =====================================================
-- 4. Fact KPI Product Daily Table
-- =====================================================
CREATE SEQUENCE IF NOT EXISTS fact_kpi_product_daily_id_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS top_product_kpi_facts (
    id BIGINT PRIMARY KEY DEFAULT nextval('fact_kpi_product_daily_id_seq'),
    date_id BIGINT NOT NULL,
    store_id BIGINT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    unit_price DOUBLE PRECISION NOT NULL,
    quantity INTEGER NOT NULL,
    revenue DOUBLE PRECISION NOT NULL,
    CONSTRAINT fk_fact_kpi_product_daily_date FOREIGN KEY (date_id) REFERENCES date_dimensions(id) ON DELETE CASCADE,
    CONSTRAINT fk_fact_kpi_product_daily_store FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_fact_kpi_product_daily_store ON top_product_kpi_facts(store_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_product_daily_date ON top_product_kpi_facts(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_product_daily_store_date ON top_product_kpi_facts(store_id, date_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_product_daily_product ON top_product_kpi_facts(product_name);

COMMENT ON TABLE top_product_kpi_facts IS 'Daily product performance KPI facts per store';

-- =====================================================
-- 5. Fact KPI Category Daily Table
-- =====================================================
-- NOTE: Entity FactKpiCategoryDaily has @Table(name = "fact_kpi_hourly") which is INCORRECT
-- Should be: fact_kpi_category_daily
-- Creating table as fact_kpi_category_daily (correct name)
-- You may need to fix the entity annotation
CREATE SEQUENCE IF NOT EXISTS fact_kpi_category_daily_id_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS fact_kpi_category_daily (
    id BIGINT PRIMARY KEY DEFAULT nextval('fact_kpi_category_daily_id_seq'),
    store_id BIGINT NOT NULL,
    date_id BIGINT NOT NULL,
    category VARCHAR(255) NOT NULL,
    transactions INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    revenue DOUBLE PRECISION NOT NULL,
    CONSTRAINT fk_fact_kpi_category_daily_store FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    CONSTRAINT fk_fact_kpi_category_daily_date FOREIGN KEY (date_id) REFERENCES date_dimensions(id) ON DELETE CASCADE,
    CONSTRAINT uk_fact_kpi_category_daily_store_date_category UNIQUE (store_id, date_id, category)
);

CREATE INDEX IF NOT EXISTS idx_fact_kpi_category_daily_store ON fact_kpi_category_daily(store_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_category_daily_date ON fact_kpi_category_daily(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_category_daily_store_date ON fact_kpi_category_daily(store_id, date_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_category_daily_category ON fact_kpi_category_daily(category);

COMMENT ON TABLE fact_kpi_category_daily IS 'Daily category performance KPI facts per store';

-- =====================================================
-- 6. Fact KPI Server Daily Table
-- =====================================================
-- NOTE: Entity FactKpiServerDaily has @Table(name = "fact_kpi_hourly") which is INCORRECT
-- Should be: fact_kpi_server_daily
-- Creating table as fact_kpi_server_daily (correct name)
-- You may need to fix the entity annotation
CREATE SEQUENCE IF NOT EXISTS fact_kpi_server_daily_id_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS fact_kpi_server_daily (
    id BIGINT PRIMARY KEY DEFAULT nextval('fact_kpi_server_daily_id_seq'),
    store_id BIGINT NOT NULL,
    date_id BIGINT NOT NULL,
    server VARCHAR(255) NOT NULL,
    transactions INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    revenue DOUBLE PRECISION NOT NULL,
    CONSTRAINT fk_fact_kpi_server_daily_store FOREIGN KEY (store_id) REFERENCES stores(id) ON DELETE CASCADE,
    CONSTRAINT fk_fact_kpi_server_daily_date FOREIGN KEY (date_id) REFERENCES date_dimensions(id) ON DELETE CASCADE,
    CONSTRAINT uk_fact_kpi_server_daily_store_date_server UNIQUE (store_id, date_id, server)
);

CREATE INDEX IF NOT EXISTS idx_fact_kpi_server_daily_store ON fact_kpi_server_daily(store_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_server_daily_date ON fact_kpi_server_daily(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_server_daily_store_date ON fact_kpi_server_daily(store_id, date_id);
CREATE INDEX IF NOT EXISTS idx_fact_kpi_server_daily_server ON fact_kpi_server_daily(server);

COMMENT ON TABLE fact_kpi_server_daily IS 'Daily server/staff performance KPI facts per store';

-- =====================================================
-- IMPORTANT NOTES:
-- =====================================================
-- 1. Some entities have incorrect @Table annotations:
--    - FactKpiDaily: has @Table(name = "fact_kpi_hourly") but should be "fact_kpi_daily"
--    - FactKpiCategoryDaily: has @Table(name = "fact_kpi_hourly") but should be "fact_kpi_category_daily"
--    - FactKpiServerDaily: has @Table(name = "fact_kpi_hourly") but should be "fact_kpi_server_daily"
--
-- 2. You need to fix these entity annotations to match the table names created above,
--    OR update the table names in this SQL to match the annotations.
--
-- 3. This script assumes the 'stores' table already exists.
--    If it doesn't, you'll need to create it first.
--
-- 4. All foreign keys use ON DELETE CASCADE, meaning deleting a store or date
--    will automatically delete related KPI records.
-- =====================================================

