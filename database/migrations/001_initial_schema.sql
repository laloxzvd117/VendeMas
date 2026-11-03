-- VendeMas: esquema inicial
-- Cada tabla incluye business_id para aislamiento de datos (RF-24)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE businesses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    cost NUMERIC(10,2) NOT NULL DEFAULT 0,
    track_stock BOOLEAN DEFAULT FALSE,
    stock INTEGER DEFAULT 0,
    min_stock INTEGER DEFAULT 3,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE sales (
    id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(id),
    total NUMERIC(10,2) NOT NULL,
    profit NUMERIC(10,2) NOT NULL,
    received NUMERIC(10,2) NOT NULL,
    change NUMERIC(10,2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE sale_items (
    id UUID PRIMARY KEY,
    sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    product_name VARCHAR(100) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    unit_cost NUMERIC(10,2) NOT NULL
);

CREATE TABLE stock_movements (
    id UUID PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id),
    business_id UUID NOT NULL REFERENCES businesses(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('sale', 'entry', 'count', 'deactivate')),
    quantity INTEGER NOT NULL,
    resulting_stock INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    synced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE weekly_summaries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    business_id UUID NOT NULL REFERENCES businesses(id),
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    total_sales NUMERIC(12,2) NOT NULL,
    total_profit NUMERIC(12,2) NOT NULL,
    total_tickets INTEGER NOT NULL,
    daily_data JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(business_id, week_start)
);

CREATE INDEX idx_products_business ON products(business_id);
CREATE INDEX idx_sales_business ON sales(business_id);
CREATE INDEX idx_sales_created ON sales(business_id, created_at);
CREATE INDEX idx_sale_items_sale ON sale_items(sale_id);
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_weekly_summaries_business ON weekly_summaries(business_id, week_start);
