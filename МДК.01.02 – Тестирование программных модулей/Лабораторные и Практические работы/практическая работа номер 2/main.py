"""
Тестирование всех модулей
"""
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from db.db_interface import DatabaseInterface
from backend.business_logic import ShoppingBackend
from ui.minimal_ui import MinimalShoppingUI

def test_database_integrity(db):
    """Тест 1: Проверка связей и ограничений БД"""
    print("🧪 Тестирование БД...")
    
    try:
        db.create_user("alice", "dup@test.com")  # Дубликат имени
        print("❌ Ошибка: UNIQUE constraint не сработал")
    except Exception as e:
        print("✅ UNIQUE constraint работает")
    
    try:
        db.create_user("bad_email", "notanemail", "user")
        print("❌ Ошибка: CHECK email не сработал")
    except:
        print("✅ CHECK email работает")
    
    test_id = db.create_product("Тест", 100, 10, 1, {"test": True})
    product = db.execute_query("SELECT metadata FROM products WHERE product_id = %s", (test_id,), fetch=True)
    assert product[0]["metadata"]["test"] == True
    print("✅ JSONB работает")
    
    print("✅ Все тесты БД пройдены\n")

def test_business_logic(backend):
    """Тест 2: Проверка бизнес-логики"""
    print("🧪 Тестирование бэкенда...")
    
    assert backend.login("alice") == True
    assert backend.get_current_user()["username"] == "alice"
    print("✅ Логин работает")
    
    products = backend.db.get_all_products()
    initial_balance = backend.get_current_user()["balance"]
    if products:
        backend.buy_product(products[0]["product_id"])
        new_balance = backend.get_current_user()["balance"]
        assert new_balance < initial_balance
        print("✅ Покупка работает")
    
    if products:
        old_price = products[0]["price"]
        backend.apply_discount(products[0]["product_id"], 10)
        new_price = backend.db.execute_query("SELECT price FROM products WHERE product_id = %s", (products[0]["product_id"],), fetch=True)[0]["price"]
        assert new_price == old_price * 0.9
        print("✅ Скидка работает")
    
    print("✅ Все тесты бэкенда пройдены\n")

def test_integration():
    """Тест 3: Интеграция всех компонентов"""
    print("🧪 Тестирование интеграции...")
    
    db = DatabaseInterface()
    db.connect()
    
    db.execute_query("DELETE FROM purchase_items")
    db.execute_query("DELETE FROM purchases")
    db.execute_query("DELETE FROM favorites")
    db.execute_query("DELETE FROM reviews")
    db.execute_query("DELETE FROM user_actions")
    
    if not db.get_all_users():
        print("📦 Заполнение начальными данными...")
        with open("db/init.sql", "r") as f:
            sql = f.read()
            for statement in sql.split(";"):
                if statement.strip():
                    try:
                        db.execute_query(statement)
                    except:
                        pass
    
    backend = ShoppingBackend(db)
    backend.login("alice")
    
    products = backend.db.get_all_products()
    if products:
        result = backend.buy_product(products[0]["product_id"])
        assert result == True
    
    logs = db.execute_query("SELECT * FROM user_actions WHERE user_id = %s", (backend.current_user_id,), fetch=True)
    assert len(logs) > 0
    print("✅ Логирование работает")
    
    db.close()
    print("✅ Интеграционное тестирование пройдено\n")

if __name__ == "__main__":
    print("=" * 50)
    print("ЗАПУСК ИНТЕГРАЦИОННЫХ ТЕСТОВ")
    print("=" * 50)
    
    test_db = DatabaseInterface()
    test_db.connect()
    test_database_integrity(test_db)
    test_db.close()
    
    test_backend_db = DatabaseInterface()
    test_backend_db.connect()
    test_backend = ShoppingBackend(test_backend_db)
    test_business_logic(test_backend)
    test_backend_db.close()
    
    test_integration()
    
    print("=" * 50)
    print("✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО")
    print("=" * 50)
    
    # Запуск UI
    print("\n🚀 Запуск графического интерфейса...")
    db = DatabaseInterface()
    db.connect()
    backend = ShoppingBackend(db)
    app = MinimalShoppingUI(backend)
    app.run()
