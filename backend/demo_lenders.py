"""Fictional lenders and a demo acknowledgement, never real loan processing."""
import json
import os
import secrets
import smtplib
import ssl
from email.message import EmailMessage
from flask import jsonify, request
from affordability import assess_affordability

LENDERS = [
    {'id': 'demo-one', 'name': 'Demo Lender One', 'description': 'Standard document review simulation'},
    {'id': 'demo-two', 'name': 'Demo Lender Two', 'description': 'Digital application review simulation'},
    {'id': 'demo-three', 'name': 'Demo Lender Three', 'description': 'Assisted verification simulation'},
]


def deliver(email, subject, body):
    if not os.environ.get('DEMO_SMTP_HOST') or not os.environ.get('DEMO_EMAIL_FROM'):
        return 'preview_only'
    try:
        message = EmailMessage()
        message['From'] = os.environ['DEMO_EMAIL_FROM']
        message['To'] = email
        message['Subject'] = subject
        message.set_content(body)
        with smtplib.SMTP(os.environ['DEMO_SMTP_HOST'], int(os.environ.get('DEMO_SMTP_PORT', '587')), timeout=10) as smtp:
            smtp.starttls(context=ssl.create_default_context())
            if os.environ.get('DEMO_SMTP_USER'):
                smtp.login(os.environ['DEMO_SMTP_USER'], os.environ['DEMO_SMTP_PASSWORD'])
            smtp.send_message(message)
        return 'sent'
    except Exception:
        return 'failed'


def register_lender_routes(app, get_db, require_auth):
    with get_db() as db:
        db.execute('''CREATE TABLE IF NOT EXISTS demo_applications (
            reference TEXT PRIMARY KEY, user_id INTEGER NOT NULL,
            assessment_id INTEGER NOT NULL, lender_id TEXT NOT NULL,
            details_json TEXT NOT NULL, UNIQUE(user_id, assessment_id))''')

    @app.get('/demo-lenders')
    @require_auth
    def lenders():
        return jsonify(lenders=LENDERS)

    @app.get('/demo-applications')
    @require_auth
    def applications():
        with get_db() as db:
            rows = db.execute('SELECT details_json FROM demo_applications WHERE user_id=? ORDER BY rowid DESC',
                              (request.current_user['id'],)).fetchall()
        return jsonify(applications=[json.loads(row['details_json']) for row in rows])

    @app.post('/demo-applications')
    @require_auth
    def apply():
        data = request.get_json(silent=True)
        if not isinstance(data, dict) or data.get('consent') is not True:
            return jsonify(message='Please accept the demo application and email acknowledgement.'), 400
        lender = next((item for item in LENDERS if item['id'] == data.get('lender_id')), None)
        assessment_id = data.get('assessment_id')
        if lender is None or type(assessment_id) is not int:
            return jsonify(message='Select a valid lender and assessment.'), 400
        with get_db() as db:
            db.execute('BEGIN IMMEDIATE')
            assessment = db.execute('SELECT input_json FROM affordability_assessments WHERE id=? AND user_id=?',
                                    (assessment_id, request.current_user['id'])).fetchone()
            if assessment is None:
                return jsonify(message='Assessment not found. Recalculate your application.'), 404
            old = db.execute('SELECT details_json FROM demo_applications WHERE user_id=? AND assessment_id=?',
                             (request.current_user['id'], assessment_id)).fetchone()
            if old:
                return jsonify(application=json.loads(old['details_json'])), 200
            inputs = json.loads(assessment['input_json'])
            checked = assess_affordability(inputs)
            if not checked['within_demo_limit']:
                return jsonify(message='This application is above the demo affordability limit.'), 400
            reference = 'DEMO-' + secrets.token_hex(6).upper()
            subject = f'[DEMO] {lender["name"]} application {reference}'
            body = (f'Hello {request.current_user["name"]},\n\n'
                    f'Your Loan in Sec demo application {reference} with {lender["name"]} is saved.\n'
                    f'Requested amount: INR {float(inputs["loan_amount"]):,.2f}\n'
                    f'Duration: {checked["loan_term_months"]} months\n'
                    'Status: Awaiting document verification (demo).\n\n'
                    'Simulated next steps: prepare SAMPLE identity, income and bank-statement documents; '
                    'a demo reviewer would check them, then review terms and simulate disbursal.\n'
                    'Do not email or upload real Aadhaar, PAN, bank statements, passwords or OTPs.\n'
                    'This fictional lender cannot verify documents, approve a loan or transfer money.\n\n'
                    'Loan in Sec college project — automated demo acknowledgement.')
            details = dict(reference=reference, lender_name=lender['name'],
                           status='Awaiting document verification (demo)',
                           email_to=request.current_user['email'], email_subject=subject,
                           email_body=body, email_status='pending',
                           amount=inputs['loan_amount'], term_months=checked['loan_term_months'])
            db.execute('INSERT INTO demo_applications VALUES (?,?,?,?,?)',
                       (reference, request.current_user['id'], assessment_id, lender['id'], json.dumps(details)))
        details['email_status'] = deliver(details['email_to'], subject, body)
        with get_db() as db:
            db.execute('UPDATE demo_applications SET details_json=? WHERE reference=?', (json.dumps(details), reference))
        return jsonify(application=details), 201
