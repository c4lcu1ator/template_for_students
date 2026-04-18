import unittest
import calculator


class TestCalculator(unittest.TestCase):
    def test_add_basic(self):
        self.assertEqual(calculator.add(2, 3), 5)
        self.assertEqual(calculator.add(-1, 1), 0)

    def test_sub_basic(self):
        self.assertEqual(calculator.sub(5, 3), 2)
        self.assertEqual(calculator.sub(-1, -1), 0)

    def test_mul_basic(self):
        self.assertEqual(calculator.mul(4, 5), 20)
        self.assertEqual(calculator.mul(-2, 3), -6)

    def test_div_basic(self):
        self.assertEqual(calculator.div(10, 2), 5)
        self.assertAlmostEqual(calculator.div(1, 3), 0.3333333, places=6)

    def test_div_by_zero(self):
        with self.assertRaises(ZeroDivisionError):
            calculator.div(10, 0)

    def test_long_numbers(self):
        a = 10**12
        b = 10**12
        self.assertEqual(calculator.add(a, b), 2 * 10**12)
        self.assertEqual(calculator.mul(a, 2), 2 * 10**12)

    def test_negative_numbers(self):
        self.assertEqual(calculator.add(-5, -7), -12)
        self.assertEqual(calculator.sub(-5, -7), 2)
        self.assertEqual(calculator.mul(-3, -4), 12)
        self.assertEqual(calculator.div(-10, 2), -5)


if __name__ == "__main__":
    unittest.main()
