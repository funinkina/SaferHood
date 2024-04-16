from flask import Flask, render_template, request, url_for, jsonify
from pymongo import MongoClient
import flask_login
from flask_bcrypt import generate_password_hash, check_password_hash
import jwt
from datetime import datetime, timedelta
import random

app = Flask(__name__)

DEBUG = True
MONGO_HOST = "localhost"
MONGO_PORT = 27017
MONGO_DBNAME = "saferhood"
SECRET_KEY = "Gupt4Ch4bi@2023"
TOKEN_EXPIRATION = 3600

client = MongoClient(MONGO_HOST, MONGO_PORT)
db = client[MONGO_DBNAME]


@app.route("/register", methods=["POST"])
def register():
    # Parse incoming form data
    name = request.form.get("name")
    police_id = request.form.get("id")
    position = request.form.get("position")
    password = request.form.get("password")
    confirm_password = request.form.get("confirm-password")

    if not (name and police_id and position and password and confirm_password):
        return jsonify({"error": "Missing required fields"}), 400

    if password != confirm_password:
        return jsonify({"error": "Passwords do not match"}), 400

    try:
        # Check if user with given police ID already exists
        existing_user = db.credentials.find_one({"police_id": police_id})
        if existing_user:
            return jsonify({"error": "User with this police ID already exists"}), 400

        # Encrypt the password
        hashed_password = generate_password_hash(password)

        # Create user object
        user = {
            "name": name,
            "police_id": police_id,
            "position": position,
            "password": hashed_password,
        }

        # Insert user into database
        db.credentials.insert_one(user)

        return jsonify({"message": "User registered successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/register", methods=["GET"])
def show_register():
    return render_template("./register.html")


@app.route("/login", methods=["POST"])
def login():
    data = request.json
    email = data.get("email").lower()  # Change to "email" from "username"
    password = data.get("password")
    user = db.credentials.find_one({"email": email})
    if not user or not check_password_hash(user["password"], password):
        return jsonify({"error": "Invalid email or password"}), 401

    # Generate token
    token_payload = {
        "email": email,
        "exp": datetime.now() + timedelta(seconds=TOKEN_EXPIRATION),
    }
    token = jwt.encode(token_payload, SECRET_KEY, algorithm="HS256").decode("utf-8")

    # Construct user data response
    user_data = {
        "name": user["name"],
        "age": user["age"],
        "role": user["role"],
        "phone": user["phone"],
        "bloodGroup": user["blood_group"],
        "token": token,  # Include the token in the response
        "id": user["id"],
    }
    return jsonify(user_data), 200


@app.route("/", methods=["GET"])
def show_login():
    return render_template("./login.html")


def is_token_valid(token):
    try:
        decoded_token = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        return True, decoded_token
    except jwt.ExpiredSignatureError:
        return False, "Token has expired"
    except jwt.InvalidTokenError:
        return False, "Invalid token"


@app.route("/validate_token", methods=["POST"])
def validate_token():
    token = request.json
    token = token.get("token")
    is_valid, decoded_token = is_token_valid(token)
    if not is_valid:
        return jsonify({"error": decoded_token}), 401
    user_email = decoded_token.get("email")
    user = db.credentials.find_one({"email": user_email})
    if not user:
        return jsonify({"error": "User not found"}), 404
    user_data = {
        "name": user["name"],
        "age": user["age"],
        "role": user["role"],
        "phone": user["phone"],
        "bloodGroup": user["blood_group"],
        "token": token,
        "id": user["id"],
    }
    return jsonify({"userData": user_data}), 200

@app.route("/home")
def dashboard():
    json_file = url_for("static", filename="data/victim_info.json")
    offenders_list = url_for("static", filename="data/repeat_offenders.json")
    news_file = url_for("static", filename="data/news_data.json")
    return render_template("./index.html", json_file=json_file,
                           offenders_list=offenders_list, news_file=news_file)


@app.route("/live-alerts")
def live_alerts():
    return render_template("./live_alerts.html")


@app.route("/hotspot_mapping")
def hotspot():
    hospitals_data = url_for("static", filename="data/hospitals_data.json")
    stations_data = url_for("static", filename="data/police_station.json")
    return render_template(
        "./hotspot.html", hospitals_data=hospitals_data,
        stations_data=stations_data)


@app.route("/repeat_offenders")
def repeat_offenders():
    json_file = url_for("static", filename="data/repeat_offenders.json")
    return render_template("./repeat_offenders.html", json_file=json_file)


@app.route("/victim_analysis")
def victims_post_post():
    json_file = url_for("static", filename="data/victim_info.json")
    return render_template("./victims.html", json_file=json_file)


@app.route("/add_alert", methods=["POST"])
def add_alert():
    data = request.form
    alert = {
        "headline": data.get("headline"),
        "description": data.get("description"),
        "address": data.get("address"),
        "street": data.get("street"),
        "colony": data.get("colony"),
        "city": data.get("city"),
        "state": data.get("state"),
        "severity": data.get("severity"),
        "id": random.randint(9999, 9999999),
        "date": datetime.now(),
    }
    db.alerts.insert_one(alert)
    return dict(data)


@app.route("/alerts", methods=["get"])
def get_alerts():
    alerts = []
    alerts_db = db.alerts.find()
    for alert in alerts_db:
        alerts.append(
            {
                "id": int(alert["id"]),
                "headline": alert["headline"],
                "description": alert["description"],
                "address": alert["address"],
                "street": alert["street"],
                "colony": alert["colony"],
                "city": alert["city"],
                "severity": alert["severity"],
                "date": alert["date"].strftime("%Y-%m-%d %H:%M:%S"),
            }
        )
    alerts = sorted(alerts, key=lambda k: k["date"])
    return jsonify(alerts)


@app.route("/live_data")
def live_data():
    news_file = url_for("static", filename="data/news_data.json")
    return render_template("./news_live_data.html", news_file=news_file)


@app.route("/<longitude>/<latitude>/<id>", methods=["GET"])
def get_coordinates(longitude, latitude, id):
    return jsonify(
        {
            "longitude": float(longitude),
            "latitude": float(latitude),
            "id": int(id),
            "status": "success",
        }
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5050, debug=True)
