import psycopg2

DB_CONFIG = {
    'dbname': 'music_app_db',
    'user': 'music_user',
    'password': 'strong_password_123',
    'host': 'localhost',
    'port': '5432'
}

conn = psycopg2.connect(**DB_CONFIG)
cur = conn.cursor()

print("=== Все записи ===")
cur.execute("SELECT * FROM categories")
for row in cur.fetchall():
    print(row)

print("\n=== Добавление ===")
cur.execute("INSERT INTO categories (name) VALUES (%s)", ('Новый жанр',))
conn.commit()
print("Добавлено")

print("\n=== Обновление (id=1) ===")
cur.execute("UPDATE categories SET name = %s WHERE id = %s", ('Обновленный жанр', 1))
conn.commit()
print("Обновлено")

print("\n=== Удаление (id=2) ===")
cur.execute("DELETE FROM categories WHERE id = %s", (2,))
conn.commit()
print("Удалено")

print("\n=== Финальный список ===")
cur.execute("SELECT * FROM categories")
for row in cur.fetchall():
    print(row)

cur.close()
conn.close()
