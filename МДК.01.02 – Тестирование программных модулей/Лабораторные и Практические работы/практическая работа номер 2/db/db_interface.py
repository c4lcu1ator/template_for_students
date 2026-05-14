import psycopg2
from psycopg2.extras import RealDictCursor
import json
from typing import List, Dict, Any

class DatabaseInterface:
    def __init__(self, dbname="shopping_system", user="postgres", password="1234", host="localhost"):
        self.conn_params = {
            "dbname": dbname,
            "user": user,
            "password": password,
            "host": host
        }
        self.connection = None
    
    def connect(self):
        self.connection = psycopg2.connect(**self.conn_params)
        return self.connection
    
    def execute_query(self, query: str, params: tuple = None, fetch=False):
        with self.connection.cursor(cursor_factory=RealDictCursor) as cursor:
            cursor.execute(query, params)
            if fetch:
                return cursor.fetchall()
            self.connection.commit()
            return None
    
    # CRUD для пользователей
    def create_user(self, username: str, email: str, role: str = "user", balance: float = 0):
        query = """
            INSERT INTO users (username, email, role, balance)
            VALUES (%s, %s, %s, %s) RETURNING user_id
        """
        result = self.execute_query(query, (username, email, role, balance), fetch=True)
        return result[0]["user_id"]
    
    def get_all_users(self) -> List[Dict]:
        return self.execute_query("SELECT * FROM users ORDER BY created_at", fetch=True)
    
    def update_user_balance(self, user_id: str, new_balance: float):
        query = "UPDATE users SET balance = %s WHERE user_id = %s"
        self.execute_query(query, (new_balance, user_id))
    
    def delete_user(self, user_id: str):
        self.execute_query("DELETE FROM users WHERE user_id = %s", (user_id,))
    
    # CRUD для товаров
    def create_product(self, name: str, price: float, stock: int, category_id: int, metadata: dict):
        query = """
            INSERT INTO products (name, price, stock, category_id, metadata)
            VALUES (%s, %s, %s, %s, %s) RETURNING product_id
        """
        result = self.execute_query(query, (name, price, stock, category_id, json.dumps(metadata)), fetch=True)
        return result[0]["product_id"]
    
    def get_all_products(self) -> List[Dict]:
        return self.execute_query("""
            SELECT p.*, c.name as category_name 
            FROM products p 
            JOIN categories c ON p.category_id = c.category_id
        """, fetch=True)
    
    def update_product_stock(self, product_id: int, new_stock: int):
        self.execute_query("UPDATE products SET stock = %s WHERE product_id = %s", (new_stock, product_id))
    
    def delete_product(self, product_id: int):
        self.execute_query("DELETE FROM products WHERE product_id = %s", (product_id,))
    
    # Покупки
    def create_purchase(self, user_id: str, items: List[tuple], payment: str = "cash"):
        # items: [(product_id, quantity), ...]
        total = 0
        for pid, qty in items:
            product = self.execute_query("SELECT price FROM products WHERE product_id = %s", (pid,), fetch=True)
            total += product[0]["price"] * qty
        
        purchase_id = self.execute_query("""
            INSERT INTO purchases (user_id, total_amount, payment, status)
            VALUES (%s, %s, %s, 'pending') RETURNING purchase_id
        """, (user_id, total, payment), fetch=True)[0]["purchase_id"]
        
        for pid, qty in items:
            price = self.execute_query("SELECT price FROM products WHERE product_id = %s", (pid,), fetch=True)[0]["price"]
            self.execute_query("""
                INSERT INTO purchase_items (purchase_id, product_id, quantity, price_at_purchase)
                VALUES (%s, %s, %s, %s)
            """, (purchase_id, pid, qty, price))
            self.update_product_stock(pid, self.execute_query("SELECT stock FROM products WHERE product_id = %s", (pid,), fetch=True)[0]["stock"] - qty)
        
        self.update_user_balance(user_id, self.execute_query("SELECT balance FROM users WHERE user_id = %s", (user_id,), fetch=True)[0]["balance"] - total)
        self.execute_query("UPDATE purchases SET status = 'completed' WHERE purchase_id = %s", (purchase_id,))
        return purchase_id
    
    # Избранное
    def add_favorite(self, user_id: str, product_id: int):
        self.execute_query("INSERT INTO favorites (user_id, product_id) VALUES (%s, %s)", (user_id, product_id))
    
    def get_favorites(self, user_id: str) -> List[Dict]:
        return self.execute_query("""
            SELECT p.* FROM products p
            JOIN favorites f ON p.product_id = f.product_id
            WHERE f.user_id = %s
        """, (user_id,), fetch=True)
    
    # Логирование действий (JSONB)
    def log_action(self, user_id: str, action_type: str, details: dict):
        self.execute_query("""
            INSERT INTO user_actions (user_id, action_type, action_details)
            VALUES (%s, %s, %s)
        """, (user_id, action_type, json.dumps(details)))
    
    def close(self):
        if self.connection:
            self.connection.close()
