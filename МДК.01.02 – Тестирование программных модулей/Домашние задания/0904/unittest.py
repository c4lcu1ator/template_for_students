import unittest
from unittest.mock import Mock
from service import UserService


class TestUserService(unittest.TestCase):
    def setUp(self):
        self.repo = Mock()
        self.service = UserService(self.repo)

    def test_get_user_calls_repo_with_correct_argument(self):
        expected_user = {"name": "Alice"}
        self.repo.find_by_id.return_value = expected_user

        result = self.service.get_user(42)

        self.assertEqual(result, expected_user)
        self.repo.find_by_id.assert_called_once_with(42)

    def test_register_calls_save_with_correct_user(self):
        result_user = self.service.register("Bob")

        self.repo.save.assert_called_once_with({"name": "Bob"})
        self.assertEqual(result_user["name"], "Bob")

    def test_register_empty_name_does_not_call_repo(self):
        with self.assertRaises(ValueError):
            self.service.register(" ")
        self.assertEqual(self.repo.save.call_count, 0)


if __name__ == "__main__":
    unittest.main()
