import importlib
import os
import tempfile
import unittest
from unittest.mock import patch


class InrApiTests(unittest.TestCase):
    def test_authenticated_recalculation_and_history_without_model(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.dict(os.environ, {'LENDIQ_DB_PATH': os.path.join(directory, 'test.db'),
                                        'AFFORDABILITY_DTI_LIMIT_PERCENT': '40'}):
                module = importlib.import_module('app')
                client = module.app.test_client()
                registration = client.post('/register', json=dict(name='Test User', email='test@example.com', password='test-password'))
                self.assertEqual(registration.status_code, 201)
                token = client.post('/login', json=dict(email='test@example.com', password='test-password')).json['token']
                headers = {'Authorization': f'Bearer {token}'}
                data = dict(currency='INR', annual_income=9400, debt_to_income_ratio=10.8,
                            loan_amount=25000, interest_rate=6.5, loan_term_months=36)
                self.assertEqual(client.post('/predict', json=data).status_code, 401)
                with patch.object(module, 'processor', None):
                    low = client.post('/predict', json=data, headers=headers)
                    high = client.post('/predict', json=dict(data, annual_income=94000), headers=headers)
                self.assertEqual(low.status_code, 200)
                self.assertEqual(high.status_code, 200)
                self.assertFalse(low.json['affordability']['within_demo_limit'])
                self.assertTrue(high.json['affordability']['within_demo_limit'])
                self.assertIsNone(low.json['probability'])
                invalid = client.post('/predict', json=dict(data, loan_term_months=0), headers=headers)
                self.assertEqual(invalid.status_code, 400)
                history = client.get('/history', headers=headers).json['affordability_history']
                self.assertEqual(len(history), 2)
                self.assertTrue(history[0]['affordability']['within_demo_limit'])
                # Fictional lender flow: ownership, eligibility, persistence,
                # consent and duplicate email prevention.
                self.assertEqual(client.get('/demo-lenders').status_code, 401)
                self.assertEqual(len(client.get('/demo-lenders', headers=headers).json['lenders']), 3)
                application = dict(assessment_id=high.json['assessment_id'], lender_id='demo-one', consent=True)
                with patch('demo_lenders.deliver', return_value='preview_only') as send:
                    self.assertEqual(client.post('/demo-applications', json=dict(application, consent=False), headers=headers).status_code, 400)
                    self.assertEqual(client.post('/demo-applications', json=dict(application, assessment_id=low.json['assessment_id']), headers=headers).status_code, 400)
                    self.assertEqual(client.post('/demo-applications', json=dict(application, lender_id='real-bank'), headers=headers).status_code, 400)
                    created = client.post('/demo-applications', json=application, headers=headers)
                    self.assertEqual(created.status_code, 201)
                    self.assertEqual(created.json['application']['email_status'], 'preview_only')
                    self.assertIn('[DEMO]', created.json['application']['email_subject'])
                    repeated = client.post('/demo-applications', json=application, headers=headers)
                    self.assertEqual(repeated.json['application']['reference'], created.json['application']['reference'])
                    self.assertEqual(send.call_count, 1)
                self.assertEqual(len(client.get('/demo-applications', headers=headers).json['applications']), 1)
                client.post('/register', json=dict(name='Second User', email='second@example.com', password='test-password'))
                other_token = client.post('/login', json=dict(email='second@example.com', password='test-password')).json['token']
                other_headers = {'Authorization': f'Bearer {other_token}'}
                self.assertEqual(client.post('/demo-applications', json=application, headers=other_headers).status_code, 404)
                self.assertEqual(client.get('/demo-applications', headers=other_headers).json['applications'], [])


if __name__ == '__main__':
    unittest.main()
