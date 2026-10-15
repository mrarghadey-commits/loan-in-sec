# Training audit

Source notebook: https://www.kaggle.com/code/arghadey18/loan-pred
Dataset: https://www.kaggle.com/datasets/deeplumiere/load-pred-dataset

Downloaded and inspected on 2026-10-03. The notebook is preserved in
`loan-pred.ipynb`; `dataset.zip` contains train.csv, test.csv and
original_dataset.csv.

## Findings

- train.csv's target is `loan_paid_back`, not an approval decision.
  The app must describe the model output as a repayment prediction.
- DTI is a fraction in training (for example 0.084). The API accepts
  percentage points and processor.py converts them before inference.
- The notebook guesses the target from the last column and maps the first
  observed label to 1. This is fragile, but train.csv starts with label 1,
  so this dataset does not reverse the numeric labels.
- There are two training blocks. Only the first exports logistic_model.pkl.
  The second trains another pipeline using the first CSV it discovers,
  which can have a different schema, and does not export it.
- The notebook provides no approval-policy labels or affordability policy.
  Replacing repayment labels with invented approval rules would change the
  task rather than correct the existing trained model.
- With the current local model and default categorical inputs, income 9400,
  DTI 10.8%, credit score 710, loan 25000 and interest 6.5 produce a repayment
  score of 0.8887617398. Income 94000 produces 0.8957850745. These are actual
  model outputs, not cached responses. Income has little influence here.

The existing `is_approved` API field remains for compatibility with the
current navigation; it represents predicted class 1, not verified approval.
`prediction_target` explicitly identifies the trained outcome. Do not use
this compatibility flag as a lending eligibility check.

To build an approval decision, supply a documented eligibility policy
(including repayment term if assessing installment affordability), or
training data with actual approval labels. The saved model was not replaced.
