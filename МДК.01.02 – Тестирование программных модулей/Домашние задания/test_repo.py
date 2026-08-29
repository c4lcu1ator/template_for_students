from db.task_repository import TaskRepository

repo = TaskRepository()
df = repo.get_all()
print(df)
