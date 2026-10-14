import joblib
import numpy as np
import pandas as pd

class ModelProcessor:
    def __init__(self, model_path):
        # Load preprocessor + model pipeline
        self.pipeline = joblib.load(model_path)
        self.classifier = self.pipeline.named_steps.get('classifier', self.pipeline)

    def predict(self, data):
        # Build DataFrame directly matching your feature pipeline schema
        df = pd.DataFrame([{
            'annual_income': float(data.get('annual_income', 0)),
            # The API/form uses percent (10 = 10%); training used a
            # fractional ratio (0.10). Convert only at the model boundary.
            'debt_to_income_ratio': float(data.get('debt_to_income_ratio', 0)) / 100.0,
            'credit_score': float(data.get('credit_score', 600)),
            'loan_amount': float(data.get('loan_amount', 10000)),
            'interest_rate': float(data.get('interest_rate', 10.0)),
            'gender': str(data.get('gender', 'Male')),
            'marital_status': str(data.get('marital_status', 'Single')),
            'education_level': str(data.get('education_level', "Bachelor's")),
            'employment_status': str(data.get('employment_status', 'Employed')),
            'loan_purpose': str(data.get('loan_purpose', 'Debt consolidation')),
            'grade_subgrade': str(data.get('grade_subgrade', 'B1')),
        }])

        # Core pipeline inference
        prediction_code = int(self.pipeline.predict(df)[0])
        probabilities = self.pipeline.predict_proba(df)[0]
        # Training target is loan_paid_back: class 1 means repayment,
        # not a lender's approval decision.
        probability = float(probabilities[1])

        # Dynamic Credit Integrity metric (derived from credit score and model confidence)
        credit_val = float(df['credit_score'].iloc[0])
        credit_integrity = int(np.clip(((credit_val - 300) / 550) * 100 * (0.8 + 0.2 * probability), 10, 99))

        # Dynamic Industry/Employment Risk Metric
        emp_status = str(df['employment_status'].iloc[0]).lower()
        industry_risk_map = {
            'employed': 88,
            'self-employed': 74,
            'unemployed': 28,
        }
        industry_risk = industry_risk_map.get(emp_status, 65)

        # Dynamic Explainable Drivers derived from input values
        dti_val = float(data.get('debt_to_income_ratio', 0))
        income_val = float(df['annual_income'].iloc[0])
        loan_val = float(df['loan_amount'].iloc[0])

        insights = []

        # 1. DTI Driver
        if dti_val <= 20:
            insights.append({
                "name": "Debt-to-Income (DTI)",
                "value": f"{dti_val:.1f}%",
                "subtitle": "Top low-risk bracket nationwide",
                "pts": f"+{int(35 + (20 - dti_val))} pts",
                "positive": True
            })
        elif dti_val <= 40:
            insights.append({
                "name": "Debt-to-Income (DTI)",
                "value": f"{dti_val:.1f}%",
                "subtitle": "Moderate risk balance",
                "pts": f"+{int(max(5, (40 - dti_val)))} pts",
                "positive": True
            })
        else:
            insights.append({
                "name": "High Debt Burden",
                "value": f"{dti_val:.1f}%",
                "subtitle": "Exceeds standard 40% threshold",
                "pts": f"-{int((dti_val - 40) * 1.2)} pts",
                "positive": False
            })

        # 2. Credit Score Driver
        if credit_val >= 720:
            insights.append({
                "name": "Credit Score",
                "value": f"{int(credit_val)} FICO",
                "subtitle": "Clean repayment track record",
                "pts": f"+{int(25 + (credit_val - 720) * 0.15)} pts",
                "positive": True
            })
        elif credit_val >= 620:
            insights.append({
                "name": "Credit Score",
                "value": f"{int(credit_val)} FICO",
                "subtitle": "Standard repayment profile",
                "pts": "+10 pts",
                "positive": True
            })
        else:
            insights.append({
                "name": "Credit Delinquency Risk",
                "value": f"{int(credit_val)} FICO",
                "subtitle": "Elevated subprime risk tier",
                "pts": f"-{int((620 - credit_val) * 0.2)} pts",
                "positive": False
            })

        # 3. Income to Loan Leverage
        ratio = round(income_val / (loan_val if loan_val > 0 else 1), 2)
        if ratio >= 2.5:
            insights.append({
                "name": "Income Leverage",
                "value": f"{ratio}x",
                "subtitle": "Income comfortably covers principal",
                "pts": "+20 pts",
                "positive": True
            })
        else:
            insights.append({
                "name": "Capital Exposure",
                "value": f"{ratio}x",
                "subtitle": "Requested sum exceeds safe coverage ratio",
                "pts": "-25 pts",
                "positive": False
            })

        return {
    "prediction_target": "loan_paid_back",
    "is_approved": prediction_code == 1,
    "prediction_code": prediction_code,
    "probability": probability,
    "credit_integrity": credit_integrity,
    "industry_risk": industry_risk,
    "insights": insights,
    "requested_amount": loan_val,
    "interest_rate": float(df["interest_rate"].iloc[0])
}
