# repo.py
class UserRepository:
    def find_by_id(self, user_id: int):
        raise NotImplementedError

    def save(self, user):
        raise NotImplementedError


# service.py
class UserService:
    def __init__(self, repo: UserRepository):
        self.repo = repo

    def get_user(self, user_id: int):
        return self.repo.find_by_id(user_id)

    def register(self, name: str):
        if not name or name.strip() == "":
            raise ValueError("name is empty")
        user = {"name": name}
        self.repo.save(user)
        return user
