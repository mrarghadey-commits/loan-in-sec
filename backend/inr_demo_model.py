"""Synthetic INR demo only: scores generated labels, not bank approvals."""
from functools import lru_cache
from pathlib import Path
import math

import joblib
import pandas as pd

MODEL_PATH = Path(__file__).parent / 'model' / 'inr_demo_model.pkl'
RANGES = {'annual_income': (6000, 12000000), 'loan_amount': (1000, 10000000),
          'interest_rate': (0, 36), 'loan_term_months': (6, 360),
          'debt_to_income_ratio': (0, 100), 'credit_score': (300, 850)}


def features(data):
    values = {}
    for key, (low, high) in RANGES.items():
        value = float(data[key])
        if not math.isfinite(value) or not low <= value <= high:
            raise ValueError(f'{key} is outside the synthetic model range {low}–{high}.')
        values[key] = value
    income = values['annual_income'] / 12
    rate = values['interest_rate'] / 1200
    term = values['loan_term_months']
    factor = -math.expm1(-term * math.log1p(rate)) / rate if rate else term
    emi = values['loan_amount'] / factor
    return {
        'total_dti': values['debt_to_income_ratio'] / 100 + emi / income,
        'credit_scaled': (values['credit_score'] - 650) / 100,
        'log_income': math.log(values['annual_income'] / 300000),
    }


@lru_cache(maxsize=1)
def load_model():
    return joblib.load(MODEL_PATH)


def predict_demo(data):
    try:
        row = features(data)
    except (KeyError, TypeError, ValueError) as error:
        return {'model_available': False, 'probability': None,
                'model_note': f'Synthetic demo score unavailable: check the six financial inputs and credit score. {error}'}
    if not MODEL_PATH.exists():
        return {'model_available': False, 'probability': None,
                'model_note': 'Synthetic demo model is not installed. Run train_inr_demo.py and restart the backend.'}
    model = load_model()
    score = float(model.predict_proba(pd.DataFrame([row]))[0, list(model.classes_).index(1)])
    return {'model_available': True, 'probability': score,
            'model_target': 'synthetic_demo_approval',
            'demo_prediction': 'Pass' if score >= 0.5 else 'Fail',
            'model_note': 'Trained on simulated INR applications and invented demo labels. This score is not a bank approval or a real repayment probability.'}
