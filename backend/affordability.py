"""INR payment estimates and a configurable demo affordability policy."""
import math
import os
from inr_demo_model import predict_demo


def assess_affordability(data):
    def number(key, minimum, maximum):
        try:
            value = float(data[key])
        except (KeyError, ValueError, TypeError):
            raise ValueError(f'{key} must be a number.') from None
        if isinstance(data[key], bool) or not math.isfinite(value) or not minimum <= value <= maximum:
            raise ValueError(f'{key} must be between {minimum} and {maximum}.')
        return value

    income = number('annual_income', 1, 1e12)
    principal = number('loan_amount', 1, 1e12)
    rate = number('interest_rate', 0, 100)
    dti = number('debt_to_income_ratio', 0, 100)
    term = number('loan_term_months', 1, 600)
    if not term.is_integer():
        raise ValueError('loan_term_months must be a whole number.')
    limit = float(os.environ.get('AFFORDABILITY_DTI_LIMIT_PERCENT', '40'))
    if not math.isfinite(limit) or not 0 < limit <= 100:
        raise ValueError('Affordability policy limit must be between 0 and 100.')
    monthly_rate = rate / 1200
    factor = (-math.expm1(-term * math.log1p(monthly_rate)) / monthly_rate
              if monthly_rate else term)
    emi = principal / factor
    monthly_income = income / 12
    existing_debt = monthly_income * dti / 100
    total_dti = (existing_debt + emi) / monthly_income * 100
    within_limit = total_dti <= limit
    return {
        'currency': 'INR',
        'within_demo_limit': within_limit,
        'monthly_income': round(monthly_income, 2),
        'existing_monthly_debt': round(existing_debt, 2),
        'monthly_emi': round(emi, 2),
        'total_monthly_debt': round(existing_debt + emi, 2),
        'remaining_monthly_income': round(monthly_income - existing_debt - emi, 2),
        'total_dti_percent': round(total_dti, 2),
        'limit_percent': limit,
        'loan_term_months': int(term),
        'total_repayment': round(emi * term, 2),
        'total_interest': round(emi * term - principal, 2),
        'estimated_max_principal': round(max(0, monthly_income * limit / 100 - existing_debt) * factor, 2),
        'policy_note': 'Demo project rule, not a lender approval. Existing DTI excludes the new loan. Living expenses and fees are not included.',
    }


def assess_inr_application(data):
    return {
        'currency': 'INR',
        'affordability': assess_affordability(data),
        'model_available': False,
        'probability': None,
        'prediction_code': None,
        'is_approved': None,
        **predict_demo(data),
    }
