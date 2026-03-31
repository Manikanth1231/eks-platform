import os
import requests
from flask import Flask, jsonify

app = Flask(__name__)

# Service URLs - will be set via environment variables in Kubernetes
USER_SERVICE_URL  = os.getenv("USER_SERVICE_URL",  "http://user-service:5001")
ORDER_SERVICE_URL = os.getenv("ORDER_SERVICE_URL", "http://order-service:5002")

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "service": "api-gateway"}), 200

@app.route("/api/users")
def get_users():
    response = requests.get(f"{USER_SERVICE_URL}/users")
    return jsonify(response.json()), response.status_code

@app.route("/api/users/<int:user_id>")
def get_user(user_id):
    response = requests.get(f"{USER_SERVICE_URL}/users/{user_id}")
    return jsonify(response.json()), response.status_code

@app.route("/api/orders")
def get_orders():
    response = requests.get(f"{ORDER_SERVICE_URL}/orders")
    return jsonify(response.json()), response.status_code

@app.route("/api/orders/user/<int:user_id>")
def get_orders_by_user(user_id):
    response = requests.get(f"{ORDER_SERVICE_URL}/orders/user/{user_id}")
    return jsonify(response.json()), response.status_code

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

