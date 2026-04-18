_tasks = []
_next_id = 1


def add_element(task: str):
    global _next_id
    if not task:
        raise ValueError("task is empty")
    item = {"id": _next_id, "task": task}
    _tasks.append(item)
    _next_id += 1
    return item


def remove_element(task_id: int):
    global _tasks
    before = len(_tasks)
    _tasks = [t for t in _tasks if t["id"] != task_id]
    return len(_tasks) < before
  
def list_elements():
    return list(_tasks)
