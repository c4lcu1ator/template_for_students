from db.db_interface import DatabaseInterface
from typing import Dict, List
import uuid

class ShoppingBackend:
    def __init__(self, db: DatabaseInterface):
        self.db = db
        self.current_user_id = None
    
    # Состояние системы
    def login(self, username: str) -> bool:
        users = self.db.get_all_users()
        for user in users:
            if user["username"] == username:
                self.current_user_id = str(user["user_id"])
                self.db.log_action(self.current_user_id, "login", {"username": username})
                return True
        return False
    
    def logout(self):
        if self.current_user_id:
            self.db.log_action(self.current_user_id, "logout", {})
        self.current_user_id = None
    
    def get_current_user(self) -> Dict:
        if not self.current_user_id:
            return None
        users = self.db.get_all_users()
        for u in users:
            if str(u["user_id"]) == self.current_user_id:
                return u
        return None
    
    # Обработка действий пользователя
    def buy_product(self, product_id: int, quantity: int = 1) -> bool:
        if not self.current_user_id:
            return False
        
        products = self.db.get_all_products()
        product = next((p for p in products if p["product_id"] == product_id), None)
        if not product or product["stock"] < quantity:
            return False
        
        user = self.get_current_user()
        total = product["price"] * quantity
        if user["balance"] < total:
            return False
        
        self.db.create_purchase(self.current_user_id, [(product_id, quantity)], "card")
        self.db.log_action(self.current_user_id, "purchase", {
            "product_id": product_id,
            "quantity": quantity,
            "total": total
        })
        return True
    
    def add_to_favorites(self, product_id: int):
        if self.current_user_id:
            self.db.add_favorite(self.current_user_id, product_id)
            self.db.log_action(self.current_user_id, "add_favorite", {"product_id": product_id})
    
    def get_recommendations(self) -> List[Dict]:
        # Простая рекомендация: популярные товары из покупок
        query = """
            SELECT p.product_id, p.name, COUNT(pi.product_id) as times_bought
            FROM purchase_items pi
            JOIN products p ON pi.product_id = p.product_id
            GROUP BY p.product_id
            ORDER BY times_bought DESC
            LIMIT 5
        """
        return self.db.execute_query(query, fetch=True)
    
    # Изменение данных в зависимости от логики
    def apply_discount(self, product_id: int, percent: int):
        if percent < 0 or percent > 100:
            raise ValueError("Percent must be between 0 and 100")
        
        products = self.db.get_all_products()
        product = next((p for p in products if p["product_id"] == product_id), None)
        if product:
            new_price = product["price"] * (100 - percent) / 100
            self.db.execute_query("UPDATE products SET price = %s WHERE product_id = %s", (new_price, product_id))
            self.db.log_action(self.current_user_id or "system", "apply_discount", {
                "product_id": product_id,
                "percent": percent,
                "new_price": new_price
            })
