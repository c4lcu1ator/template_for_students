-- =========================
-- 1. СОЗДАНИЕ СХЕМЫ
-- =========================

DROP SCHEMA IF EXISTS shop CASCADE;
CREATE SCHEMA shop;
SET search_path TO shop;

-- =========================
-- 2. ТАБЛИЦЫ
-- =========================

-- 1) Пользователи
CREATE TABLE users (
    user_id        BIGSERIAL PRIMARY KEY,
    email          VARCHAR(255) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    first_name     VARCHAR(100) NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2) Роли пользователей
CREATE TABLE roles (
    role_id   SMALLSERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- 3) Связь пользователей и ролей (многие-ко-многим)
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id SMALLINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
);

-- 4) Категории товаров
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

-- 5) Производители
CREATE TABLE manufacturers (
    manufacturer_id SERIAL PRIMARY KEY,
    manufacturer_name VARCHAR(150) NOT NULL UNIQUE
);

-- 6) Товары
CREATE TABLE products (
    product_id      BIGSERIAL PRIMARY KEY,
    product_name    VARCHAR(255) NOT NULL,
    category_id     INT NOT NULL,
    manufacturer_id INT NOT NULL,
    price           DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(manufacturer_id)
);

-- 7) Склады / магазины
CREATE TABLE stores (
    store_id   SERIAL PRIMARY KEY,
    store_name VARCHAR(150) NOT NULL,
    city       VARCHAR(100) NOT NULL
);

-- 8) Заказы (покупки)
CREATE TABLE orders (
    order_id    BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL,
    store_id    INT NOT NULL,
    order_date  TIMESTAMP NOT NULL DEFAULT NOW(),
    status      VARCHAR(20) NOT NULL DEFAULT 'new', -- new, paid, cancelled
    total_sum   DECIMAL(12,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- 9) Позиции заказа
CREATE TABLE order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id      BIGINT NOT NULL,
    product_id    BIGINT NOT NULL,
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    is_deleted    BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 10) Оплаты
CREATE TABLE payments (
    payment_id   BIGSERIAL PRIMARY KEY,
    order_id     BIGINT NOT NULL,
    amount       DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    paid_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    method       VARCHAR(30) NOT NULL, -- card, cash, sbp и т.п.
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- =========================
-- 3. ИНДЕКСЫ
-- =========================

-- Простой индекс 1: по email пользователей
CREATE INDEX idx_users_email ON users(email);

-- Простой индекс 2: по дате заказа
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- Составной индекс 1: по (user_id, order_date) для выборок заказов пользователя
CREATE INDEX idx_orders_user_date ON orders(user_id, order_date);

-- Составной индекс 2: по (category_id, price) для фильтраций по категории и цене
CREATE INDEX idx_products_category_price ON products(category_id, price);

-- Уникальный индекс: уникальное имя производителя
CREATE UNIQUE INDEX idx_manufacturers_name_unique ON manufacturers(manufacturer_name);

-- =========================
-- 4. ТЕСТОВЫЕ ДАННЫЕ
-- =========================

INSERT INTO roles (role_name) VALUES
    ('customer'),
    ('manager'),
    ('admin');

INSERT INTO users (email, password_hash, first_name, last_name)
VALUES
    ('ivan@example.com', 'hash1', 'Иван', 'Петров'),
    ('maria@example.com', 'hash2', 'Мария', 'Сидорова'),
    ('admin@example.com', 'hash3', 'Админ', 'Админов');

INSERT INTO user_roles (user_id, role_id) VALUES
    (1, 1), -- Иван - customer
    (2, 1), -- Мария - customer
    (3, 3); -- Админ - admin

INSERT INTO categories (category_name) VALUES
    ('Электроника'),
    ('Одежда'),
    ('Книги');

INSERT INTO manufacturers (manufacturer_name) VALUES
    ('Samsung'),
    ('Nike'),
    ('Penguin Books');

INSERT INTO products (product_name, category_id, manufacturer_id, price)
VALUES
    ('Телефон Galaxy', 1, 1, 29999.99),
    ('Кроссовки Air', 2, 2, 8999.00),
    ('Книга по SQL', 3, 3, 1500.50);

INSERT INTO stores (store_name, city) VALUES
    ('Магазин Иркутск', 'Иркутск'),
    ('Магазин Москва', 'Москва');

-- Один стартовый заказ
INSERT INTO orders (user_id, store_id, status, total_sum)
VALUES (1, 1, 'new', 29999.99);

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 1, 29999.99);

-- =========================
-- 5. ТРАНЗАКЦИИ
-- =========================

-- 5.1. Успешная транзакция с COMMIT
BEGIN;

INSERT INTO orders (user_id, store_id, status, total_sum)
VALUES (2, 2, 'new', 2 * 8999.00) RETURNING order_id;

-- предположим, мы вручную подставляем вернувшийся order_id, например 2
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (2, 2, 2, 8999.00);

INSERT INTO payments (order_id, amount, method)
VALUES (2, 2 * 8999.00, 'card');

COMMIT;

-- 5.2. Транзакция с ошибкой и ROLLBACK
BEGIN;

INSERT INTO orders (user_id, store_id, status, total_sum)
VALUES (9999, 1, 'new', 1000.00); -- user_id не существует -> ошибка FK

-- если ошибка не поймана приложением -> произойдет автоматический ROLLBACK
ROLLBACK;

-- 5.3. Транзакция с проверкой условий (псевдо-ручная проверка)
DO $$
DECLARE
    v_user_exists INT;
    v_new_order_id BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_user_exists FROM users WHERE user_id = 1;

    IF v_user_exists > 0 THEN
        BEGIN
            INSERT INTO orders (user_id, store_id, status, total_sum)
            VALUES (1, 1, 'new', 1500.50)
            RETURNING order_id INTO v_new_order_id;

            INSERT INTO order_items (order_id, product_id, quantity, unit_price)
            VALUES (v_new_order_id, 3, 1, 1500.50);

            COMMIT;
        EXCEPTION WHEN OTHERS THEN
            ROLLBACK;
        END;
    ELSE
        RAISE NOTICE 'Пользователь не существует, транзакция не выполняется';
    END IF;
END $$;

-- =========================
-- 6. UNION / INTERSECT / EXCEPT
-- =========================

-- Клиенты, оформившие заказы в Иркутске
WITH irkutsk_customers AS (
    SELECT DISTINCT u.user_id, u.first_name, u.last_name
    FROM users u
    JOIN orders o ON o.user_id = u.user_id
    JOIN stores s ON s.store_id = o.store_id
    WHERE s.city = 'Иркутск'
),

-- Клиенты, оформившие заказы в Москве
moscow_customers AS (
    SELECT DISTINCT u.user_id, u.first_name, u.last_name
    FROM users u
    JOIN orders o ON o.user_id = u.user_id
    JOIN stores s ON s.store_id = o.store_id
    WHERE s.city = 'Москва'
)

-- UNION: все клиенты, покупавшие либо в Иркутске, либо в Москве
SELECT * FROM irkutsk_customers
UNION
SELECT * FROM moscow_customers;

-- INTERSECT: клиенты, покупавшие и в Иркутске, и в Москве
SELECT * FROM irkutsk_customers
INTERSECT
SELECT * FROM moscow_customers;

-- EXCEPT: клиенты, покупавшие только в Иркутске, но не в Москве
SELECT * FROM irkutsk_customers
EXCEPT
SELECT * FROM moscow_customers;

-- =========================
-- 7. ПРАКТИЧЕСКИЕ ЗАПРОСЫ (10+)
-- =========================

-- 1) Фильтрация: активные товары дороже 5000
SELECT product_id, product_name, price
FROM products
WHERE is_active = TRUE AND price > 5000
ORDER BY price DESC;

-- 2) Сортировка и LIMIT
SELECT product_id, product_name, price
FROM products
ORDER BY price DESC
LIMIT 5;

-- 3) Группировка и HAVING: сумма заказов по пользователям > 20000
SELECT u.user_id, u.first_name, u.last_name, SUM(o.total_sum) AS total_spent
FROM users u
JOIN orders o ON o.user_id = u.user_id
GROUP BY u.user_id, u.first_name, u.last_name
HAVING SUM(o.total_sum) > 20000
ORDER BY total_spent DESC;

-- 4) INNER JOIN: товары и их категории
SELECT p.product_id, p.product_name, c.category_name, p.price
FROM products p
JOIN categories c ON c.category_id = p.category_id;

-- 5) LEFT JOIN: все пользователи и их последние заказы
SELECT u.user_id, u.first_name, u.last_name, o.order_id, o.order_date, o.status
FROM users u
LEFT JOIN orders o ON o.user_id = u.user_id
ORDER BY u.user_id, o.order_date DESC;

-- 6) RIGHT JOIN: все магазины и заказы (PostgreSQL поддерживает)
SELECT s.store_id, s.store_name, o.order_id, o.order_date
FROM orders o
RIGHT JOIN stores s ON s.store_id = o.store_id
ORDER BY s.store_id;

-- 7) Подзапрос: товары дороже средней цены
SELECT product_id, product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- 8) Подзапрос с EXISTS: пользователи, у которых есть хотя бы один заказ
SELECT u.user_id, u.first_name, u.last_name
FROM users u
WHERE EXISTS (
    SELECT 1 FROM orders o WHERE o.user_id = u.user_id
);

-- 9) Запрос, использующий составной индекс (user_id, order_date)
SELECT o.order_id, o.order_date, o.total_sum
FROM orders o
WHERE o.user_id = 1
ORDER BY o.order_date DESC;

-- 10) Запрос, использующий индекс по (category_id, price)
SELECT p.product_id, p.product_name, p.price
FROM products p
WHERE p.category_id = 1 AND p.price BETWEEN 10000 AND 40000
ORDER BY p.price;

-- 11) Агрегация по магазину: общая выручка
SELECT s.store_id, s.store_name, SUM(o.total_sum) AS store_revenue
FROM stores s
LEFT JOIN orders o ON o.store_id = s.store_id
GROUP BY s.store_id, s.store_name
ORDER BY store_revenue DESC NULLS LAST;

-- =========================
-- 8. ТЕСТЫ НА ДОБАВЛЕНИЕ / ИЗМЕНЕНИЕ / УДАЛЕНИЕ
-- =========================

-- Тест 1: добавление (INSERT) нового заказа и позиции
BEGIN;
INSERT INTO orders (user_id, store_id, status, total_sum)
VALUES (1, 1, 'new', 2 * 1500.50) RETURNING order_id;
-- подставь вернувшийся order_id (например, 3)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (3, 3, 2, 1500.50);
COMMIT;
-- Проверка: SELECT * FROM orders WHERE order_id = 3;

-- Тест 2: изменение (UPDATE) цены товара
UPDATE products
SET price = price * 1.10
WHERE product_id = 1;
-- Проверка: SELECT product_id, price FROM products WHERE product_id = 1;

-- Тест 3: мягкое удаление позиции заказа (UPDATE флага)
UPDATE order_items
SET is_deleted = TRUE
WHERE order_item_id = 1;
-- Проверка: SELECT * FROM order_items WHERE order_item_id = 1;

-- Тест 4: жесткое удаление (DELETE) позиции заказа
DELETE FROM order_items
WHERE order_item_id = 1;
-- Проверка: SELECT COUNT(*) FROM order_items WHERE order_item_id = 1;

-- Тест 5: негативный тест на FK (ожидаем ошибку)
BEGIN;
INSERT INTO orders (user_id, store_id, status, total_sum)
VALUES (9999, 1, 'new', 1000.00); -- нет такого user_id
ROLLBACK;
-- Проверка: SELECT COUNT(*) FROM orders WHERE user_id = 9999; -- 0
