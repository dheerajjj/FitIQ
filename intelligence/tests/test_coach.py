import unittest
from intelligence.coach import Session, next_session

class CoachTests(unittest.TestCase):
    def test_progress(self):
        self.assertEqual(next_session(Session(12, 12, 6, 2, 20))["action"], "progress")
    def test_recovery(self):
        self.assertEqual(next_session(Session(12, 12, 6, 8, 20))["action"], "recover")
    def test_reduce(self):
        self.assertEqual(next_session(Session(8, 12, 9, 2, 20))["action"], "reduce")
    def test_invalid(self):
        with self.assertRaises(ValueError):
            next_session(Session(-1, 12, 6, 2, 20))

if __name__ == "__main__":
    unittest.main()
