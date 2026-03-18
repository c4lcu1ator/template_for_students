from db.task_repository import TaskRepository

repo = TaskRepository()
tasks_df = repo.get_all()  # начальное состояние

def refresh_tasks():
    global tasks_df
    tasks_df = repo.get_all()

def print_tasks(df):
    if df.empty:
        print("Нет задач.")
        return
    print(df.to_string(index=False))

def main():
    global tasks_df

    while True:
        print("\nМеню:")
        print("1 — Показать все задачи")
        print("2 — Добавить задачу")
        print("3 — Обновить статус")
        print("4 — Удалить задачу")
        print("5 — Фильтр по статусу")
        print("0 — Выход")

        choice = input("Выберите: ").strip()

        try:
            if choice == '1':
                print_tasks(tasks_df)

            elif choice == '2':
                title = input("Title: ").strip()
                if not title:
                    print("Ошибка: title обязателен!")
                    continue
                desc = input("Description: ").strip()
                status = input("Status (todo/in_progress/done): ").strip()
                priority = int(input("Priority (1-3): "))
                repo.add(title, desc, status, priority)
                refresh_tasks()
                print("Задача добавлена!")

            elif choice == '3':
                print_tasks(tasks_df[['id', 'title', 'status']])
                tid = int(input("Task ID: "))
                new_status = input("New status: ").strip()
                repo.update_status(tid, new_status)
                refresh_tasks()
                print("Статус обновлен!")

            elif choice == '4':
                print_tasks(tasks_df[['id', 'title']])
                tid = int(input("Task ID: "))
                repo.delete(tid)
                refresh_tasks()
                print("Задача удалена!")

            elif choice == '5':
                status = input("Status: ").strip()
                filtered = repo.get_by_status(status)
                print_tasks(filtered)

            elif choice == '0':
                break

            else:
                print("Неверный выбор!")

        except ValueError as e:
            print(f"Ошибка ввода: {e}")
        except Exception as e:
            print(f"Ошибка: {e}. Попробуйте снова.")

if __name__ == "__main__":
    main()
