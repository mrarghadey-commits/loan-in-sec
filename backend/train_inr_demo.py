"""Reproducible simulation; no real Indian borrower records are used."""
import json
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, brier_score_loss, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

from inr_demo_model import MODEL_PATH, features


def main():
    rng = np.random.default_rng(42)
    count = 20000
    frame = pd.DataFrame({
        'annual_income': np.exp(rng.uniform(np.log(6000), np.log(12000000), count)),
        'loan_amount': np.exp(rng.uniform(np.log(1000), np.log(10000000), count)),
        'interest_rate': rng.uniform(0, 36, count),
        'loan_term_months': rng.choice([6, 12, 24, 36, 60, 120, 240, 360], count),
        'debt_to_income_ratio': rng.uniform(0, 100, count),
        'credit_score': rng.integers(300, 851, count),
    })
    inputs = pd.DataFrame([features(row) for row in frame.to_dict('records')])
    # Explicitly invented educational policy. No claim of Indian bank criteria.
    logit = (1.5 + 1.2 * inputs.credit_scaled + 0.35 * inputs.log_income
             - 8 * (inputs.total_dti - 0.4))
    generated_score = 1 / (1 + np.exp(-np.clip(logit, -50, 50)))
    labels = rng.binomial(1, generated_score)
    train, test = train_test_split(np.arange(count), test_size=0.25,
                                  random_state=42, stratify=labels)
    # Large DTI outliers inflate its standard deviation. Default L2 strength
    # then excessively shrinks the DTI coefficient in the original units.
    # The generator is logistic with only three features and 15k training rows;
    # a weak penalty lets this baseline recover the documented label process.
    model = make_pipeline(StandardScaler(), LogisticRegression(C=1e6, max_iter=5000, tol=1e-8, random_state=42))
    model.fit(inputs.iloc[train], labels[train])
    predicted = model.predict_proba(inputs.iloc[test])[:, 1]
    report = {
        'source': 'Synthetic INR demo; not real Indian bank data',
        'seed': 42, 'train_rows': len(train), 'test_rows': len(test),
        'target': 'synthetic_demo_approval',
        'label_rule': 'Bernoulli(sigmoid(1.5 + 1.2*credit_scaled + 0.35*log_income - 8*(total_dti-0.4)))',
        'accuracy_on_synthetic_holdout': accuracy_score(labels[test], predicted >= 0.5),
        'auc_on_synthetic_holdout': roc_auc_score(labels[test], predicted),
        'brier_on_synthetic_holdout': brier_score_loss(labels[test], predicted),
        'mean_absolute_error_against_generator': float(np.mean(np.abs(predicted - generated_score.iloc[test]))),
        'limitations': 'Only measures reproduction of invented labels. No real-world validation or fairness claim. Gender, marital status, education and employment are not model features.',
    }
    MODEL_PATH.parent.mkdir(exist_ok=True)
    joblib.dump(model, MODEL_PATH)
    output = Path(__file__).parent / 'training'
    output.mkdir(exist_ok=True)
    frame['synthetic_demo_approval'] = labels
    frame['split'] = 'train'
    frame.loc[test, 'split'] = 'test'
    frame.to_csv(output / 'synthetic_inr.csv', index=False)
    (output / 'inr_demo_report.json').write_text(json.dumps(report, indent=2))
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
