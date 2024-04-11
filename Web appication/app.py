from flask import Flask, render_template, request, redirect, url_for, flash, jsonify
from pymongo import MongoClient
from flask_login import LoginManager, login_user, UserMixin
from flask_bcrypt import generate_password_hash, check_password_hash
import jwt
from datetime import datetime, timedelta
import random

app = Flask(__name__)

DEBUG = True
MONGO_HOST = 'localhost'
MONGO_PORT = 27017
MONGO_DBNAME = 'saferhood'
SECRET_KEY = "Gupt4Ch4bi@2023"
TOKEN_EXPIRATION = 3600

client = MongoClient(MONGO_HOST, MONGO_PORT)
db = client[MONGO_DBNAME]

@app.route('/register', methods=['POST'])
def register():
    # Parse incoming JSON data
    data = request.json
    name = data.get('name')
    age = data.get('age')
    role = data.get('role')
    phone = data.get('phone')
    blood_group = data.get('bloodGroup')
    password = data.get('password')
    email = data.get('email').lower()

    if not (name and age and phone and blood_group and email and password):
        return jsonify({'error': 'Missing required fields'}), 400

    try:
        # Check if user with given email already exists
        existing_user = db.credentials.find_one({'email': email})
        if existing_user:
            return jsonify({'error': 'User with this email already exists'}), 400

        # Encrypt the password
        hashed_password = generate_password_hash(password).decode('utf-8')

        # Create user object
        user = {
            'name': name,
            'age': age,
            'role': role,
            'phone': phone,
            'blood_group': blood_group,
            'password': hashed_password,
            'email': email,
            'id': random.randint(9999,9999999)
        }

        # Insert user into database
        db.credentials.insert_one(user)
        
        return jsonify({'message': 'User registered successfully'}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('username').lower()
    password = data.get('password')
    user = db.credentials.find_one({'email': email})
    if not user or not check_password_hash(user['password'], password):
        return jsonify({'error': 'Invalid email or password'}), 401
    token = jwt.encode({'email': email, 'exp': datetime.now() + timedelta(seconds=TOKEN_EXPIRATION)}, SECRET_KEY, algorithm='HS256')
    user_data = {
        'name': user['name'],
        'age': user['age'],
        'role': user['role'],
        'phone': user['phone'],
        'bloodGroup': user['blood_group'],
        'token': token,
        'id': user['id'],
    }
    return jsonify(user_data), 200

def is_token_valid(token):
    try:
        decoded_token = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return True, decoded_token
    except jwt.ExpiredSignatureError:
        return False, "Token has expired"
    except jwt.InvalidTokenError:
        return False, "Invalid token"

@app.route('/validate_token', methods=['POST'])
def validate_token():
    token = request.json
    token = token.get('token')
    is_valid, decoded_token = is_token_valid(token)
    if not is_valid:
        return jsonify({'error': decoded_token}), 401
    user_email = decoded_token.get('email')
    user = db.credentials.find_one({'email': user_email})
    if not user:
        return jsonify({'error': 'User not found'}), 404
    user_data = {
        'name': user['name'],
        'age': user['age'],
        'role': user['role'],
        'phone': user['phone'],
        'bloodGroup': user['blood_group'],
        'token': token,
        'id': user['id'],
    }
    return jsonify({'userData': user_data}), 200



@app.route('/')
def hello_world():
    return render_template('./index.html')

@app.route('/victim_prediction')
def victims():
    return render_template('./victims.html')

@app.route('/hotspot_mapping')
def victims_post():
    return render_template('./hotspot.html')

@app.route('/suspected_perpetrators')
def victims_post_post():
    return render_template('./suspects.html')

@app.route('/repeat_offenders')
def victims_post_post_post():
    return render_template('./repeat_offenders.html')

@app.route('/<longitude>/<latitude>/<id>', methods=['GET'])
def get_coordinates(longitude, latitude, id):
    return jsonify({
        'longitude': float(longitude),
        'latitude': float(latitude),
        'id': int(id),
        'status': 'success'
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5050, debug=True)