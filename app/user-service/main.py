from flask import Flask, jsonify

app = Flask(__name__)

# Simulated database
USERS = [
    {"id": 1, "name": "Alice", "email": "alice@example.com"},
    {"id": 2, "name": "Bob",   "email": "bob@example.com"},
]

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "service": "user-service"}), 200

@app.route("/users")
def get_users():
    return jsonify({"users": USERS}), 200

@app.route("/users/<int:user_id>")
def get_user(user_id):
    user = next((u for u in USERS if u["id"] == user_id), None)
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify(user), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)

