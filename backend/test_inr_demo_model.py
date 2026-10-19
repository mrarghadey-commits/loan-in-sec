import unittest
import math
from inr_demo_model import predict_demo, features
from affordability import assess_inr_application


class DemoModelTests(unittest.TestCase):
    def setUp(self):
        self.data = dict(annual_income=300000, loan_amount=200000, interest_rate=12,
                         loan_term_months=36, debt_to_income_ratio=10, credit_score=710)

    def test_score_changes_in_expected_directions(self):
        score = predict_demo(self.data)['probability']
        self.assertIsNotNone(score)
        for field, value in [('annual_income', 60000), ('loan_amount', 1000000),
                             ('interest_rate', 30), ('loan_term_months', 12),
                             ('debt_to_income_ratio', 60), ('credit_score', 400)]:
            with self.subTest(field=field):
                self.assertLess(predict_demo(dict(self.data, **{field: value}))['probability'], score)

    def test_demographic_changes_do_not_change_score(self):
        first = predict_demo(dict(self.data, gender='Male', marital_status='Single'))
        second = predict_demo(dict(self.data, gender='Female', marital_status='Married'))
        self.assertEqual(first, second)

    def test_demo_score_is_separate_from_approval(self):
        result = assess_inr_application(self.data)
        self.assertTrue(result['model_available'])
        self.assertIsNone(result['is_approved'])
        self.assertIn('affordability', result)
        self.assertEqual(result['model_target'], 'synthetic_demo_approval')

    def test_out_of_range_input_has_no_score(self):
        result = predict_demo(dict(self.data, annual_income=1))
        self.assertFalse(result['model_available'])
        self.assertIsNone(result['probability'])

    def test_model_recovers_generator_across_financial_profiles(self):
        for income in [9400, 94000, 300000, 1200000]:
            for credit in [400, 650, 750]:
                for amount in [25000, 200000]:
                    data = dict(self.data, annual_income=income, credit_score=credit,
                                loan_amount=amount, interest_rate=6.5, debt_to_income_ratio=10.8)
                    f = features(data)
                    logit = 1.5 + 1.2*f['credit_scaled'] + .35*f['log_income'] - 8*(f['total_dti']-.4)
                    expected = 1/(1+math.exp(-max(-50, min(50, logit))))
                    with self.subTest(income=income, credit=credit, amount=amount):
                        self.assertAlmostEqual(predict_demo(data)['probability'], expected, delta=0.05)


if __name__ == '__main__':
    unittest.main()
