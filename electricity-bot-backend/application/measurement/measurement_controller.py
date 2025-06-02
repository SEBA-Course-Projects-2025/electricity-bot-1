from datetime import datetime, timedelta, timezone
from application import app
from flask import request, jsonify
from application.measurement.model.dto.measurement import Measurement
from application.measurement.measurement_service import MeasurementService
from application.models import DeviceModel
from application.database import session
import uuid

@app.route("/api/measurement", methods=["POST"])
def receive_measurement():
    try:
        data = request.get_json()

        device_id = uuid.UUID(data["device_id"])

        with session() as db:
            device_exists = db.query(DeviceModel).filter_by(device_id=str(device_id)).first()
            if device_exists is None:
                return jsonify({"error": "Device not registered"}), 404

        measurement = Measurement(
            measurement_id=uuid.uuid4(),
            device_id=device_id,
            outgate_status=data["outgate_status"]
        )

        with MeasurementService() as service:
            service.save_measurement(measurement)

        return jsonify({"message": "Measurement saved"}), 201

    except KeyError as key_error:
        return jsonify({"error": f"Missing field: {str(key_error)}"}), 400

    except ValueError as value_error:
        return jsonify({"error": f"Invalid UUID or data format: {str(value_error)}"}), 422

    except Exception as exception:
        return jsonify({"error": "Unexpected server error", "details": str(exception)}), 500

@app.route("/api/statistics/day/<device_id>", methods=["GET"])
def get_statistics_day(device_id):
    try:
        uuid_obj = uuid.UUID(device_id)

        with session() as db:
            device_exists = db.query(DeviceModel).filter_by(device_id=str(uuid_obj)).first()
            if device_exists is None:
                return jsonify({"error": "Device not registered"}), 404

        with MeasurementService() as service:
            data = service.get_power_events(str(uuid_obj), days=1)

        return jsonify({
            "device_id": device_id,
            "from": (datetime.now(timezone.utc) - timedelta(days=1)).isoformat(),
            "to": datetime.now(timezone.utc).isoformat(),
            "events": data
        }), 200

    except ValueError as value_error:
        return jsonify({"error": "Invalid device ID format. Must be UUID."}), 422

    except Exception as exception:
        return jsonify({"error": "Could not retrieve statistics", "details": str(exception)}), 500

@app.route("/api/statistics/week/<device_id>", methods=["GET"])
def get_statistics_week(device_id):
    try:
        uuid_obj = uuid.UUID(device_id)

        with session() as db:
            device_exists = db.query(DeviceModel).filter_by(device_id=str(uuid_obj)).first()
            if device_exists is None:
                return jsonify({"error": "Device not registered"}), 404

        with MeasurementService() as service:
            data = service.get_power_events(str(uuid_obj), days=7)

        return jsonify({
            "device_id": device_id,
            "from": (datetime.now(timezone.utc) - timedelta(days=7)).isoformat(),
            "to": datetime.now(timezone.utc).isoformat(),
            "events": data
        }), 200

    except ValueError as value_error:
        return jsonify({"error": "Invalid device ID format. Must be UUID."}), 422

    except Exception as exception:
        return jsonify({"error": "Could not retrieve statistics", "details": str(exception)}), 500