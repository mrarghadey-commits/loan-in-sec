import unittest
from pathlib import Path

import pandas as pd

from processor import ModelProcessor


class PredictionRegressionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.processor = ModelProcessor(
            Path(__file__).parent / 'model' / 'logistic_model.pkl'
        )

    def setUp(self):
        self.data = dict(
            annual_income=100000, debt_to_income_ratio=10,
            credit_score=750, loan_amount=25000, interest_rate=6.5,
            gender='Male', marital_status='Single', education_level="Bachelor's",
            employment_status='Employed', loan_purpose='Debt consolidation',
            grade_subgrade='A1',
        )

    def test_percent_input_matches_training_units(self):
        expected_input = dict(self.data, debt_to_income_ratio=0.10)
        expected = self.processor.pipeline.predict_proba(
            pd.DataFrame([expected_input])
        )[0, 1]
        result = self.processor.predict(self.data)
        self.assertAlmostEqual(result['probability'], expected)
        self.assertTrue(result['is_approved'])
        self.assertEqual(result['insights'][0]['value'], '10.0%')

    def test_repeated_predictions_use_changed_values(self):
        first = self.processor.predict(self.data)
        changed = self.processor.predict(dict(self.data, debt_to_income_ratio=40))
        restored = self.processor.predict(self.data)
        self.assertLess(changed['probability'], first['probability'])
        self.assertFalse(changed['is_approved'])
        self.assertEqual(changed['insights'][0]['value'], '40.0%')
        self.assertEqual(first, restored)
        self.assertEqual(self.data['debt_to_income_ratio'], 10)


if __name__ == '__main__':
    unittest.main()
