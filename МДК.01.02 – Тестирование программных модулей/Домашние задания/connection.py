from sqlalchemy import create_engine

def get_connection():
    engine = create_engine(
        'postgresql+psycopg2://calculator@localhost:5432/task_manager_db'
    )
    return engine
