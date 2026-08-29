from db.connection import get_connection
import pandas as pd

class TaskRepository:
    def __init__(self):
        self.engine = get_connection()

    def get_all(self):
        with self.engine.connect() as conn:
            query = "SELECT * FROM app.tasks ORDER BY id;"
            return pd.read_sql_query(query, conn)

    def get_by_status(self, status):
        with self.engine.connect() as conn:
            query = "SELECT * FROM app.tasks WHERE status = %s ORDER BY id;"
            return pd.read_sql_query(query, conn, params=(status,))

    def add(self, title, description, status, priority):
        conn_raw = self.engine.raw_connection()
        cur = conn_raw.cursor()
        try:
            query = """
                INSERT INTO app.tasks (title, description, status, priority)
                VALUES (%s, %s, %s, %s);
            """
            cur.execute(query, (title, description, status, priority))
            conn_raw.commit()
        except Exception as e:
            conn_raw.rollback()
            raise e
        finally:
            cur.close()
            conn_raw.close()

    def update_status(self, task_id, new_status):
        conn_raw = self.engine.raw_connection()
        cur = conn_raw.cursor()
        try:
            query = "UPDATE app.tasks SET status = %s WHERE id = %s;"
            cur.execute(query, (new_status, task_id))
            conn_raw.commit()
        except Exception as e:
            conn_raw.rollback()
            raise e
        finally:
            cur.close()
            conn_raw.close()

    def delete(self, task_id):
        conn_raw = self.engine.raw_connection()
        cur = conn_raw.cursor()
        try:
            query = "DELETE FROM app.tasks WHERE id = %s;"
            cur.execute(query, (task_id,))
            conn_raw.commit()
        except Exception as e:
            conn_raw.rollback()
            raise e
        finally:
            cur.close()
            conn_raw.close()
