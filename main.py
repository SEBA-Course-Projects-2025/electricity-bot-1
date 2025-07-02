from flask import Flask, request, jsonify
from flask_cors import CORS
import random
import uuid

app = Flask(__name__)

CORS(app, resources={r"/*": {"origins": "*"}})

@app.route("/api/auth/login", methods=["POST"])
def mock_login():
    data = request.get_json()
    print("Received ID token:", data)

    if not data or "id_token" not in data:
        return jsonify({"error": "Missing id_token"}), 400

    return jsonify({
        "user_id": "123e4567-e89b-12d3-a456-426614174000",
        "email": "dlitvakk21@gmail.com",
        "full_name": "Dana Litvak",
        "message": "Login successful"
    }), 200

@app.route("/api/auth/logout", methods=["GET"])
def mock_logout():
    return jsonify({
        "logout_url": "https://keycloak.local/logout?redirect_uri=http://localhost:3000"
    }), 200

from datetime import datetime, timedelta


@app.route("/api/statistics/day/<device_id>", methods=["GET"])
def mock_statistics_day(device_id):
    now = datetime.utcnow()
    start_time = now - timedelta(days=1)

    num_events = random.randint(15, 30)

    events = []
    for _ in range(num_events):
        random_offset = random.uniform(0, 24 * 3600)
        event_time = start_time + timedelta(seconds=random_offset)
        outgate_status = random.random() < 0.7

        events.append({
            "timestamp": event_time.isoformat(timespec="milliseconds") + "Z",
            "outgate_status": outgate_status
        })

    return jsonify({
        "device_id": device_id,
        "from": start_time.isoformat(timespec="milliseconds") + "Z",
        "to": now.isoformat(timespec="milliseconds") + "Z",
        "events": events
    }), 200
@app.route("/api/statistics/week/<device_id>", methods=["GET"])
def mock_statistics_week(device_id):
    now = datetime.utcnow()
    events = []

    for day in range(7):
        base_time = now - timedelta(days=day)
        num_events = random.randint(2, 5)
        last_time = base_time.replace(hour=random.randint(0, 3), minute=0, second=0, microsecond=0)

        for i in range(num_events):
            last_time += timedelta(hours=random.randint(2, 6))
            events.append({
                "timestamp": last_time.isoformat(timespec="milliseconds") + "Z",
                "outgate_status": random.choice([True, False])
            })

    sorted_events = sorted(events, key=lambda e: e["timestamp"])

    return jsonify({
        "device_id": device_id,
        "from": (now - timedelta(days=7)).isoformat(timespec="milliseconds") + "Z",
        "to": now.isoformat(timespec="milliseconds") + "Z",
        "events": sorted_events
    }), 200

@app.route("/api/status/<device_id>", methods=["GET"])
def mock_get_status(device_id):
    try:
        uuid_obj = uuid.UUID(device_id)
        now = datetime.utcnow()
        random_seconds = random.uniform(0, 24 * 3600)
        random_time = now - timedelta(seconds=random_seconds)
        timestamp = random_time.isoformat(timespec="milliseconds") + "Z"

        if str(uuid_obj) == "00000000-0000-0000-0000-000000000000":
            return jsonify({"error": "No data for this device"}), 404

        status = {
            "device_id": device_id,
            "outgate_status": random.choice([True, False]),
            "timestamp": timestamp
        }

        return jsonify(status), 200

    except ValueError:
        return jsonify({"error": "Invalid UUID format"}), 422
    except Exception as e:
        return jsonify({
            "error": "Failed to fetch status",
            "details": str(e)
        }), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5050, debug=True)


