# Loan in Sec

A college project for exploring loan affordability in Indian rupees, estimating monthly payments, and submitting applications to fictional demo lenders.

Built with **Flutter**, **Flask**, **SQLite**, and **scikit-learn**.

> Educational demonstration only. The model uses synthetic data and invented labels, not real Indian bank decisions. The application does not approve loans, verify real documents, or transfer money.

## Repository status

The project is being uploaded in stages. The features and setup below describe the complete local project; some referenced files may not appear on GitHub until their upload stage is complete.

## Features

- Account registration, login, and logout.
- INR amounts with Indian digit grouping.
- EMI estimates using loan amount, annual interest rate, and duration.
- Affordability assessment including existing debt and the new EMI.
- Separate synthetic-model score using financial inputs and credit score.
- Three fictional lenders, application references, and demo application history.
- Acknowledgement email preview, with optional SMTP delivery from the project's email account.
- Responsive interface with a photo watermark and custom app icons.

## Application flow

1. Register and sign in.
2. Enter annual income, existing debt-to-income percentage, loan amount, interest rate, duration, and profile details.
3. Review the payment breakdown and affordability result.
4. Review the separate synthetic demo score.
5. If the affordability check passes, select a fictional lender and submit a demo application.
6. View its reference, acknowledgement, and **Awaiting document verification (demo)** status.

Document verification is a simulated checklist. Do not submit real identity documents or banking credentials.

## How the results work

### Affordability calculation

Monthly income is annual income divided by 12. Existing monthly debt is estimated from the entered DTI percentage; that percentage must exclude the new loan.

The app calculates the new EMI and compares total monthly debt payments against a configurable limit. The default **40%** limit is a project assumption, not an Indian regulatory or lender standard. Living expenses and fees are excluded.

### Synthetic INR model

The training script generates 20,000 simulated applications, using 15,000 for training and 5,000 for evaluation. A logistic regression pipeline learns invented demo approval labels.

Its features include total DTI after the new EMI, credit score, and income. Loan amount, interest rate, and duration affect EMI. Gender, marital status, education, and employment are not inputs to this synthetic model.

The score estimates a simulated label, not real approval or repayment probability. Evaluation on synthetic data does not demonstrate real-world accuracy or fairness. The exact generating formula and evaluation are recorded in `backend/training/inr_demo_report.json`.

The older repayment model is retained for legacy requests; it is not used for INR applications.

## Project structure

```text
Loan_Prediction/
├── backend/
│   ├── app.py                   # API, authentication, and database
│   ├── affordability.py         # EMI and affordability calculations
│   ├── inr_demo_model.py        # Synthetic model inference
│   ├── train_inr_demo.py        # Reproducible generation and training
│   ├── demo_lenders.py          # Fictional applications and email
│   ├── processor.py             # Legacy repayment model
│   ├── model/                   # Model artifacts
│   ├── training/                # Data, reports, and training notes
│   ├── test_*.py                # Backend tests
│   └── requirements.txt
├── flutter_app/
│   ├── lib/                     # Screens, widgets, and API client
│   ├── assets/                  # Bundled imagery
│   ├── test/                    # Flutter tests
│   └── web/                     # Web entry point and icons
└── README.md
```

## Run locally on Windows

Use **Command Prompt (CMD)**. Install Python 3.11, Flutter with a Dart SDK satisfying `^3.13.4`, and Chrome. Run commands from the cloned project folder.

### 1. Start the backend

```cmd
cd backend
py -3.11 -m venv venv
venv\Scripts\python.exe -m pip install -r requirements.txt
venv\Scripts\python.exe train_inr_demo.py
venv\Scripts\python.exe app.py
```

Training creates the synthetic dataset, model artifact, and evaluation report. You do not need to retrain on every startup. Restart the backend after retraining to reload the cached model.

The API runs at `http://127.0.0.1:5000`. SQLite tables are created automatically. Keep this terminal open.

`/health` reports whether the **legacy** model loaded. If its artifact is absent, INR affordability and the separately generated INR demo model can still be used.

### 2. Start Flutter

In a second terminal, from the project root:

```cmd
cd flutter_app
flutter pub get
flutter run -d chrome
```

The API client currently points to `http://127.0.0.1:5000`, intended for Chrome running on the same computer. Other devices require an appropriate backend address.

## Optional configuration

Set environment variables in the backend terminal before starting the server:

| Variable | Purpose |
| --- | --- |
| `AFFORDABILITY_DTI_LIMIT_PERCENT` | Demo affordability threshold; default `40` |
| `LENDIQ_DB_PATH` | Optional SQLite path; legacy configuration name retained |
| `DEMO_SMTP_HOST` | Project SMTP server |
| `DEMO_SMTP_PORT` | STARTTLS port; default `587` |
| `DEMO_EMAIL_FROM` | Sender address you are authorised to use |
| `DEMO_SMTP_USER` | SMTP username |
| `DEMO_SMTP_PASSWORD` | SMTP credential |

Without SMTP configuration, acknowledgements remain previews and no email is sent. Credentials should stay outside source control. Use test email addresses you control; registration does not verify email ownership.

See `backend/AFFORDABILITY.md` and `backend/DEMO_LENDERS.md` for implementation details.

## Validation

From `backend`:

```cmd
venv\Scripts\python.exe -m unittest discover -p "test_*.py" -v
```

Generate the synthetic model first. Legacy processor tests also require the original `backend/model/logistic_model.pkl` artifact; they will fail if it has not been supplied.

From `flutter_app`:

```cmd
flutter analyze
flutter test
```

## Data and privacy

- Synthetic data is simulated in INR; it is not a collection of real Indian borrower records.
- Do not commit user databases, passwords, SMTP credentials, or virtual environments.
- The root `.gitignore` excludes local databases, environments, and generated/downloaded datasets.
- The app is a local educational prototype, not a production lending or document-verification service.
