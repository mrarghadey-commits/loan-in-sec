from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from processor import ModelProcessor
from affordability import assess_inr_application

import sqlite3
import secrets
import os
import json
from functools import wraps
from contextlib import contextmanager


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.environ.get('LENDIQ_DB_PATH', os.path.join(BASE_DIR, "lendiq.db"))
MODEL_PATH = os.path.join(BASE_DIR, "model", "logistic_model.pkl")


app = Flask(__name__)
CORS(app)


# -------------------------------------------------------
# DATABASE
# -------------------------------------------------------

@contextmanager
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    try:
        with conn:
            yield conn
    finally:
        conn.close()


def init_db():
    with get_db() as db:
        db.executescript("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE COLLATE NOCASE,
            password_hash TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS sessions (
            token TEXT PRIMARY KEY,
            user_id INTEGER NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id)
        );

        CREATE TABLE IF NOT EXISTS affordability_assessments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            input_json TEXT NOT NULL,
            result_json TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id)
        );

        CREATE TABLE IF NOT EXISTS predictions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            input_json TEXT NOT NULL,
            prediction_code INTEGER NOT NULL,
            probability REAL NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(user_id) REFERENCES users(id)
        );
        """)


init_db()


# -------------------------------------------------------
# LOAD ML MODEL
# -------------------------------------------------------

try:
    processor = ModelProcessor(MODEL_PATH)
    print("ML model loaded successfully")
except Exception as e:
    processor = None
    print("Error loading model:", e)


# -------------------------------------------------------
# AUTHENTICATION MIDDLEWARE
# -------------------------------------------------------

def require_auth(function):

    @wraps(function)
    def wrapper(*args, **kwargs):

        auth_header = request.headers.get("Authorization", "")

        if auth_header.startswith("Bearer "):
            token = auth_header[7:].strip()
        else:
            token = ""

        if not token:
            return jsonify({
                "status": "error",
                "message": "Please login first."
            }), 401

        with get_db() as db:

            user = db.execute("""
                SELECT
                    u.id,
                    u.name,
                    u.email
                FROM sessions s
                JOIN users u ON u.id = s.user_id
                WHERE s.token = ?
            """, (token,)).fetchone()

        if not user:
            return jsonify({
                "status": "error",
                "message": "Session expired. Please login again."
            }), 401

        request.current_user = dict(user)
        request.auth_token = token

        return function(*args, **kwargs)

    return wrapper


# -------------------------------------------------------
# HEALTH CHECK
# -------------------------------------------------------

@app.route("/health", methods=["GET"])
def health():

    return jsonify({
        "status": "healthy",
        "model_loaded": processor is not None
    }), 200


# -------------------------------------------------------
# REGISTER
# -------------------------------------------------------

@app.route("/register", methods=["POST"])
def register():

    data = request.get_json(silent=True) or {}

    name = str(data.get("name", "")).strip()
    email = str(data.get("email", "")).strip().lower()
    password = str(data.get("password", ""))

    if len(name) < 2:
        return jsonify({
            "status": "error",
            "message": "Please enter your full name."
        }), 400

    if "@" not in email:
        return jsonify({
            "status": "error",
            "message": "Please enter a valid email."
        }), 400

    if len(password) < 6:
        return jsonify({
            "status": "error",
            "message": "Password must contain at least 6 characters."
        }), 400

    try:

        password_hash = generate_password_hash(password)

        with get_db() as db:

            db.execute("""
                INSERT INTO users (
                    name,
                    email,
                    password_hash
                )
                VALUES (?, ?, ?)
            """, (
                name,
                email,
                password_hash
            ))

        return jsonify({
            "status": "success",
            "message":
                "Registration successful. Please login using the same email and password."
        }), 201

    except sqlite3.IntegrityError:

        return jsonify({
            "status": "error",
            "message": "An account with this email already exists."
        }), 409


# -------------------------------------------------------
# LOGIN
# -------------------------------------------------------

@app.route("/login", methods=["POST"])
def login():

    data = request.get_json(silent=True) or {}

    email = str(data.get("email", "")).strip().lower()
    password = str(data.get("password", ""))

    with get_db() as db:

        user = db.execute("""
            SELECT *
            FROM users
            WHERE email = ?
        """, (email,)).fetchone()

        if not user:

            return jsonify({
                "status": "error",
                "message": "Invalid email or password."
            }), 401

        if not check_password_hash(
            user["password_hash"],
            password
        ):

            return jsonify({
                "status": "error",
                "message": "Invalid email or password."
            }), 401

        # Generate new login token
        token = secrets.token_urlsafe(32)

        # Remove previous session
        db.execute(
            "DELETE FROM sessions WHERE user_id = ?",
            (user["id"],)
        )

        # Save new session
        db.execute("""
            INSERT INTO sessions (
                token,
                user_id
            )
            VALUES (?, ?)
        """, (
            token,
            user["id"]
        ))

    return jsonify({
        "status": "success",

        "token": token,

        "user": {
            "id": user["id"],
            "name": user["name"],
            "email": user["email"]
        }
    }), 200


# -------------------------------------------------------
# LOGOUT
# -------------------------------------------------------

@app.route("/logout", methods=["POST"])
@require_auth
def logout():

    with get_db() as db:

        db.execute(
            "DELETE FROM sessions WHERE token = ?",
            (request.auth_token,)
        )

    return jsonify({
        "status": "success",
        "message": "Logged out successfully."
    }), 200


# -------------------------------------------------------
# LOAN PREDICTION
# -------------------------------------------------------

@app.route("/predict", methods=["POST"])
@require_auth
def predict():

    payload = request.get_json(silent=True)
    if not isinstance(payload, dict):
        return jsonify(status='error', message='Expected a JSON object.'), 400
    if payload.get('currency') == 'INR':
        try:
            result = assess_inr_application(payload)
        except (ValueError, TypeError) as error:
            return jsonify(status='error', message=str(error)), 400
        with get_db() as db:
            cursor = db.execute(
                'INSERT INTO affordability_assessments (user_id, input_json, result_json) VALUES (?, ?, ?)',
                (request.current_user['id'], json.dumps(payload), json.dumps(result)),
            )
            result['assessment_id'] = cursor.lastrowid
        return jsonify(status='success', **result), 200
    if payload.get('currency') is not None:
        return jsonify(status='error', message='Only INR applications are supported.'), 400

    if processor is None:

        return jsonify({
            "status": "error",
            "message":
                "ML model is unavailable. Install the exact backend requirements and restart."
        }), 500

    payload = request.get_json(silent=True) or {}

    required_fields = [
        "annual_income",
        "debt_to_income_ratio",
        "credit_score",
        "loan_amount",
        "interest_rate",
        "gender",
        "marital_status",
        "education_level",
        "employment_status",
        "loan_purpose",
        "grade_subgrade"
    ]

    missing = [
        field
        for field in required_fields
        if field not in payload
    ]

    if missing:

        return jsonify({
            "status": "error",
            "message":
                "Missing required fields: "
                + ", ".join(missing)
        }), 400

    try:

        # Every request uses THIS USER'S values
        result = processor.predict(payload)

        # Store user's prediction history
        with get_db() as db:

            db.execute("""
                INSERT INTO predictions (
                    user_id,
                    input_json,
                    prediction_code,
                    probability
                )
                VALUES (?, ?, ?, ?)
            """, (
                request.current_user["id"],
                json.dumps(payload),
                result["prediction_code"],
                result["probability"]
            ))

        return jsonify({
            "status": "success",
            **result,
            "user": request.current_user
        }), 200

    except Exception as e:

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 400


# -------------------------------------------------------
# USER PREDICTION HISTORY
# -------------------------------------------------------

@app.route("/history", methods=["GET"])
@require_auth
def history():

    with get_db() as db:

        rows = db.execute("""
            SELECT
                id,
                prediction_code,
                probability,
                created_at
            FROM predictions
            WHERE user_id = ?
            ORDER BY id DESC
            LIMIT 20
        """, (
            request.current_user["id"],
        )).fetchall()

    with get_db() as db:
        assessments = db.execute(
            "SELECT id, result_json, created_at FROM affordability_assessments WHERE user_id = ? ORDER BY id DESC LIMIT 20",
            (request.current_user["id"],),
        ).fetchall()

    return jsonify({
        "status": "success",
        "affordability_history": [
            {"id": row["id"], "created_at": row["created_at"], **json.loads(row["result_json"])}
            for row in assessments
        ],
        "history": [
            dict(row)
            for row in rows
        ]
    }), 200


# -------------------------------------------------------
# RUN SERVER
# -------------------------------------------------------

from demo_lenders import register_lender_routes
register_lender_routes(app, get_db, require_auth)

if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )
