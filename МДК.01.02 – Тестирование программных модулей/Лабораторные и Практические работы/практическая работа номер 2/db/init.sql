-- База данных: shopping_system
-- Расширения
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ENUM типы
CREATE TYPE user_role AS ENUM ('admin', 'user', 'guest');
CREATE TYPE purchase_status AS ENUM ('pending', 'completed', 'cancelled');
CREATE TYPE payment_method AS ENUM ('cash', 'card', 'online');
CREATE TYPE category_type AS ENUM ('food', 'clothing', 'electronics', 'home', 'other');

-- 1. Таблица пользователей (UNIQUE, CHECK)
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    role user_role DEFAULT 'user',
    balance DECIMAL(10,2) DEFAULT 0.00 CHECK (balance >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    preferences JSONB DEFAULT '{"theme": "light", "notifications": true}'::jsonb
);

-- 2. Категории товаров
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    type category_type NOT NULL,
    description TEXT
);

-- 3. Товары (CHECK, индексы)
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock INTEGER NOT NULL CHECK (stock >= 0),
    category_id INTEGER NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    metadata JSONB DEFAULT '{"brand": "unknown", "rating": 0}'::jsonb,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_stock ON products(stock);

-- 4. Покупки (связь с пользователем)
CREATE TABLE purchases (
    purchase_id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status purchase_status DEFAULT 'pending',
    payment payment_method DEFAULT 'cash',
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0)
);

CREATE INDEX idx_purchases_user_date ON purchases(user_id, purchase_date);

-- 5. Связь многие ко многим: товары в покупке
CREATE TABLE purchase_items (
    purchase_id INTEGER NOT NULL REFERENCES purchases(purchase_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price_at_purchase DECIMAL(10,2) NOT NULL CHECK (price_at_purchase > 0),
    PRIMARY KEY (purchase_id, product_id)
);

-- 6. Журнал действий пользователя (JSONB)
CREATE TABLE user_actions (
    action_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(user_id) ON DELETE SET NULL,
    action_type VARCHAR(50) NOT NULL,
    action_details JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_actions_time ON user_actions(created_at);

-- 7. Избранное (связь N:M пользователь-товар)
CREATE TABLE favorites (
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, product_id)
);

-- 8. Отзывы (CHECK, UNIQUE)
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

-- Начальные данные
INSERT INTO users (username, email, role, balance, preferences) VALUES
('alice', 'alice@example.com', 'admin', 500.00, '{"theme": "dark", "notifications": true}'),
('bob', 'bob@example.com', 'user', 250.00, '{"theme": "light", "notifications": false}'),
('charlie', 'charlie@example.com', 'guest', 0.00, '{"theme": "light", "notifications": true}');

INSERT INTO categories (name, type, description) VALUES
('Фрукты', 'food', 'Свежие фрукты'),
('Смартфоны', 'electronics', 'Мобильные устройства'),
('Джинсы', 'clothing', 'Повседневная одежда');

INSERT INTO products (name, price, stock, category_id, metadata) VALUES
('Яблоки', 120.50, 100, 1, '{"brand": "Фермерские", "rating": 4.5}'),
('iPhone 15', 79999.00, 15, 2, '{"brand": "Apple", "rating": 4.8}'),
('Levis 501', 5999.00, 30, 3, '{"brand": "Levis", "rating": 4.3}');

INSERT INTO purchases (user_id, status, payment, total_amount) VALUES
((SELECT user_id FROM users WHERE username='alice'), 'completed', 'card', 120.50),
((SELECT user_id FROM users WHERE username='bob'), 'pending', 'cash', 79999.00);

INSERT INTO purchase_items (purchase_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 120.50),
(2, 2, 1, 79999.00);

INSERT INTO favorites (user_id, product_id) VALUES
((SELECT user_id FROM users WHERE username='alice'), 2),
((SELECT user_id FROM users WHERE username='bob'), 1);

INSERT INTO reviews (user_id, product_id, rating, comment) VALUES
((SELECT user_id FROM users WHERE username='alice'), 1, 5, 'Очень вкусные!');
