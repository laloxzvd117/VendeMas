-- ============================================================================
-- VendeMas - PostgreSQL Schema (Servidor Central)
-- Migración: 001_initial_schema.sql
-- Cada tabla incluye business_id para aislamiento de datos (RF-24)
-- Motor: PostgreSQL 15+
-- ============================================================================

BEGIN;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────────────────────────────────────────
-- 1. NEGOCIO
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE businesses (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(100)    NOT NULL,
    phone_number    VARCHAR(20)     UNIQUE NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 2. PRODUCTOS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE products (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id     UUID            NOT NULL REFERENCES businesses(id),
    name            VARCHAR(100)    NOT NULL,
    price           NUMERIC(10,2)   NOT NULL,
    cost            NUMERIC(10,2)   NOT NULL DEFAULT 0,
    track_stock     BOOLEAN         NOT NULL DEFAULT FALSE,
    stock           INTEGER         NOT NULL DEFAULT 0,
    min_stock       INTEGER         NOT NULL DEFAULT 3,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 3. VENTAS
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE sales (
    id              UUID PRIMARY KEY,   -- generado en el cliente (offline-first)
    business_id     UUID            NOT NULL REFERENCES businesses(id),
    total           NUMERIC(10,2)   NOT NULL,
    profit          NUMERIC(10,2)   NOT NULL,
    received        NUMERIC(10,2)   NOT NULL,
    change          NUMERIC(10,2)   NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ     NOT NULL,
    synced_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 4. DETALLE DE VENTA
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE sale_items (
    id              UUID PRIMARY KEY,   -- generado en el cliente
    sale_id         UUID            NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    product_id      UUID            NOT NULL REFERENCES products(id),
    product_name    VARCHAR(100)    NOT NULL,
    quantity        INTEGER         NOT NULL,
    unit_price      NUMERIC(10,2)   NOT NULL,
    unit_cost       NUMERIC(10,2)   NOT NULL
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 5. MOVIMIENTOS DE INVENTARIO
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE stock_movements (
    id              UUID PRIMARY KEY,   -- generado en el cliente
    product_id      UUID            NOT NULL REFERENCES products(id),
    business_id     UUID            NOT NULL REFERENCES businesses(id),
    type            VARCHAR(20)     NOT NULL CHECK (type IN ('sale','entry','count','deactivate')),
    quantity        INTEGER         NOT NULL,
    resulting_stock INTEGER         NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL,
    synced_at       TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- 6. RESÚMENES SEMANALES
-- daily_data JSONB guarda el arreglo de días para evitar una tabla extra:
-- [{"date":"2024-10-28","sales":1450,"profit":820,"tickets":32}, ...]
-- ─────────────────────────────────────────────────────────────────────────────
CREATE TABLE weekly_summaries (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id     UUID            NOT NULL REFERENCES businesses(id),
    week_start      DATE            NOT NULL,
    week_end        DATE            NOT NULL,
    total_sales     NUMERIC(12,2)   NOT NULL,
    total_profit    NUMERIC(12,2)   NOT NULL,
    total_tickets   INTEGER         NOT NULL,
    daily_data      JSONB           NOT NULL DEFAULT '[]',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    UNIQUE (business_id, week_start)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- ÍNDICES
-- ─────────────────────────────────────────────────────────────────────────────
CREATE INDEX idx_products_business         ON products(business_id);
CREATE INDEX idx_sales_business            ON sales(business_id);
CREATE INDEX idx_sales_created             ON sales(business_id, created_at);
CREATE INDEX idx_sale_items_sale           ON sale_items(sale_id);
CREATE INDEX idx_stock_movements_product   ON stock_movements(product_id);
CREATE INDEX idx_weekly_summaries_business ON weekly_summaries(business_id, week_start);

-- ─────────────────────────────────────────────────────────────────────────────
-- TRIGGER: actualizar updated_at automáticamente
-- ─────────────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION trigger_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_businesses_updated_at
    BEFORE UPDATE ON businesses
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION trigger_set_updated_at();

COMMIT;
