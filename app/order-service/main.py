from flask import Flask, jsonify

app = Flask(__name__)

ORDERS = [
    {"id": 1, "user_id": 1, "product": "Laptop",  "status": "delivered"},
    {"id": 2, "user_id": 2, "product": "Phone",   "status": "pending"},
    {"id": 3, "user_id": 1, "product": "Monitor", "status": "shipped"},
]

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "service": "order-service"}), 200

@app.route("/orders")
def get_orders():
    return jsonify({"orders": ORDERS}), 200

@app.route("/orders/<int:order_id>")
def get_order(order_id):
    order = next((o for o in ORDERS if o["id"] == order_id), None)
    if not order:
        return jsonify({"error": "Order not found"}), 404
    return jsonify(order), 200

@app.route("/orders/user/<int:user_id>")
def get_orders_by_user(user_id):
    user_orders = [o for o in ORDERS if o["user_id"] == user_id]
    return jsonify({"orders": user_orders}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)

