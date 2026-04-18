import unittest
import tasks


class TestTasks(unittest.TestCase):
    def setUp(self):
        tasks._tasks.clear()
        tasks._next_id = 1

    def test_add_element(self):
        item = tasks.add_element("task 1")
        self.assertEqual(item["id"], 1)
        self.assertEqual(item["task"], "task 1")
        self.assertEqual(len(tasks.list_elements()), 1)

    def test_remove_element(self):
        item1 = tasks.add_element("task 1")
        item2 = tasks.add_element("task 2")
        self.assertTrue(tasks.remove_element(item1["id"]))
        ids = [t["id"] for t in tasks.list_elements()]
        self.assertNotIn(item1["id"], ids)
        self.assertIn(item2["id"], ids)

    def test_add_empty_raises(self):
        with self.assertRaises(ValueError):
            tasks.add_element("")
        with self.assertRaises(ValueError):
            tasks.add_element(None)

    def test_duplicate_elements(self):
        t1 = tasks.add_element("same")
        t2 = tasks.add_element("same")
        self.assertNotEqual(t1["id"], t2["id"])
        self.assertEqual(len(tasks.list_elements()), 2)


if __name__ == "__main__":
    unittest.main()
