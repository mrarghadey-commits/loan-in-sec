# Demo lenders

After a successful INR affordability assessment, choose a fictional lender,
accept the acknowledgement checkbox, and submit. The server checks ownership
and current affordability and allows one lender per saved assessment. Repeat
submissions return the existing application without sending another email.
Recalculate to create a new assessment. The selection page also lists the
signed-in user's previous demo applications.

Document verification is a simulation checklist, not an upload or review
service. No identity documents should be sent. No real lender is contacted.

Without email configuration, the acknowledgement is saved as a preview only.
To enable delivery, set these environment variables on the backend machine:

- DEMO_SMTP_HOST: your project's SMTP server
- DEMO_SMTP_PORT: STARTTLS port (default 587)
- DEMO_EMAIL_FROM: an address you are authorised to send from
- DEMO_SMTP_USER: SMTP login
- DEMO_SMTP_PASSWORD: SMTP credential, kept outside source control

Restart the backend. New submissions send an explicitly labelled demo email
to the logged-in user's registered address. Failed sending does not lose the
application. No automatic retries are made, avoiding duplicate deliveries.
The UI distinguishes preview-only, pending, failed, and SMTP-accepted states;
SMTP acceptance does not guarantee inbox delivery.

Use test accounts/addresses you control for this local college demo. The
existing registration system does not verify ownership of email addresses.
This is not a production email or lending service.
