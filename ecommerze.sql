CREATE DATABASE IF NOT EXISTS luxurylo_naeembiswassniloy_ecommerce_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE luxurylo_naeembiswassniloy_ecommerce_db;

-- 1. PRODUCTS
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_products_name (name)
);

-- 2. PRODUCT VARIANTS
CREATE TABLE product_variants (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,
    size VARCHAR(50),
    color VARCHAR(50),
    model VARCHAR(100),
    weight DECIMAL(10,2),
    price DECIMAL(12,2) NOT NULL,
    image_url VARCHAR(500),
    stock_quantity INT UNSIGNED NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_variant_product
        FOREIGN KEY (product_id)
        REFERENCES products(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    INDEX idx_variant_product (product_id),
    INDEX idx_variant_size (size),
    INDEX idx_variant_color (color)
);

-- 3. ORDERS
CREATE TABLE orders (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    status ENUM(
        'pending',
        'confirmed',
        'processing',
        'shipped',
        'delivered',
        'cancelled'
    ) NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_orders_status (status),
    INDEX idx_orders_created_at (created_at)
);


-- 4. ORDER ITEMS
CREATE TABLE order_items (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT UNSIGNED NOT NULL,
    product_variant_id BIGINT UNSIGNED NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_order_item_variant
        FOREIGN KEY (product_variant_id)
        REFERENCES product_variants(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    INDEX idx_order_item_order (order_id),
    INDEX idx_order_item_variant (product_variant_id)
);


-- Sample Data Insertion

-- Products
INSERT INTO products
(name, description)
VALUES
(
    'Nike T-Shirt',
    'Premium cotton sports t-shirt'
),
(
    'Samsung Galaxy S25',
    'Android flagship smartphone'
),
(
    'Running Shoes',
    'Lightweight running shoes'
);

-- Product Variants
INSERT INTO product_variants
(
    product_id,
    sku,
    size,
    color,
    model,
    weight,
    price,
    image_url,
    stock_quantity
)
VALUES
(
    1,
    'NIKE-TS-M-BLK',
    'M',
    'Black',
    NULL,
    0.50,
    1200.00,
    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
    20
),
(
    1,
    'NIKE-TS-L-BLK',
    'L',
    'Black',
    NULL,
    0.55,
    1250.00,
    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
    15
),
(
    1,
    'NIKE-TS-M-WHT',
    'M',
    'White',
    NULL,
    0.50,
    1200.00,
    'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
    25
),
(
    2,
    'S25-256-BLK',
    NULL,
    'Black',
    'S25-256GB',
    0.16,
    85000.00,
    'https://images.unsplash.com/photo-1598327105666-5b89351aff97',
    10
),
(
    2,
    'S25-512-BLU',
    NULL,
    'Blue',
    'S25-512GB',
    0.17,
    98000.00,
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9',
    8
),
(
    3,
    'SHOE-42-BLK',
    '42',
    'Black',
    NULL,
    0.80,
    3500.00,
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
    12
),
(
    3,
    'SHOE-43-BLK',
    '43',
    'Black',
    NULL,
    0.85,
    3500.00,
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
    10
);

-- SAMPLE ORDERS
INSERT INTO orders
(status, total_amount)
VALUES('confirmed', 2450.00),
      ('processing',85000.00);

-- ORDER ITEMS
INSERT INTO order_items
(
    order_id,
    product_variant_id,
    quantity,
    unit_price
)
VALUES(1, 1, 1, 1200.00),
      (1, 2, 1, 1250.00);

INSERT INTO order_items
(
    order_id,
    product_variant_id,
    quantity,
    unit_price
)
VALUES (2, 4, 1, 85000.00);