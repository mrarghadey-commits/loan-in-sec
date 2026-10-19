import unittest
from unittest.mock import patch

from affordability import assess_affordability, assess_inr_application


class AffordabilityTests(unittest.TestCase):
    def setUp(self):
        self.environment = patch.dict('os.environ', {'AFFORDABILITY_DTI_LIMIT_PERCENT': '40'})
        self.environment.start()
        self.addCleanup(self.environment.stop)
        self.data = dict(annual_income=9400, loan_amount=25000,
                         interest_rate=6.5, debt_to_income_ratio=10.8,
                         loan_term_months=36, currency='INR')

    def test_low_income_fails_and_higher_income_passes(self):
        low = assess_affordability(self.data)
        high = assess_affordability(dict(self.data, annual_income=94000))
        self.assertFalse(low['within_demo_limit'])
        self.assertTrue(high['within_demo_limit'])
        self.assertAlmostEqual(low['monthly_emi'], 766.23, places=2)
        self.assertEqual(low['monthly_emi'], high['monthly_emi'])

    def test_zero_interest_and_threshold_boundary(self):
        data = dict(self.data, annual_income=120000, debt_to_income_ratio=10,
                    interest_rate=0, loan_amount=36000, loan_term_months=12)
        result = assess_affordability(data)
        self.assertEqual(result['monthly_emi'], 3000)
        self.assertEqual(result['total_interest'], 0)
        self.assertEqual(result['total_dti_percent'], 40)
        self.assertTrue(result['within_demo_limit'])
        self.assertFalse(assess_affordability(dict(data, loan_amount=36001))['within_demo_limit'])

    def test_amount_term_rate_and_existing_debt_change_assessment(self):
        baseline = assess_affordability(self.data)
        for key, value in [('loan_amount', 50000), ('interest_rate', 20),
                           ('loan_term_months', 12), ('debt_to_income_ratio', 30)]:
            with self.subTest(key=key):
                changed = assess_affordability(dict(self.data, **{key: value}))
                self.assertGreater(changed['total_dti_percent'], baseline['total_dti_percent'])

    def test_invalid_values_rejected(self):
        for key, value in [('annual_income', 0), ('loan_amount', -1),
                           ('interest_rate', float('nan')), ('debt_to_income_ratio', 101),
                           ('loan_term_months', 0), ('loan_term_months', 1.5),
                           ('loan_amount', float('inf')), ('loan_term_months', True)]:
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                assess_affordability(dict(self.data, **{key: value}))

    def test_inr_does_not_invent_model_probability(self):
        result = assess_inr_application(self.data)
        self.assertIsNone(result['probability'])
        self.assertIsNone(result['is_approved'])
        self.assertFalse(result['model_available'])


if __name__ == '__main__':
    unittest.main()
