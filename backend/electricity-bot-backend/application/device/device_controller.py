import uuid
from datetime import datetime, timezone
from flask import request, jsonify
from application import app
from application.device.model.dto.device import Device as DeviceDTO
from application.device.device_service import DeviceService
from pydantic import ValidationError


@app.route("/api/devices", methods=["GET"])
def list_devices():
    try:
        page = int(request.args.get("page", 1))
        per_page = int(request.args.get("per_page", 3))
        if page < 1 or per_page < 1:
            return jsonify({"error": "Invalid pagination parameters"}), 400

        with DeviceService() as service:
            devices = service.get_devices(page, per_page)

        return (
            jsonify(
                [
                    {
                        "device_id": d.device_id,
                        "last_seen": d.last_seen.isoformat() if d.last_seen else None,
                    }
                    for d in devices
                ]
            ),
            200,
        )

    except Exception as exception:
        return jsonify({"error": "Device fetch failed", "details": str(exception)}), 500


@app.route("/api/devices/<device_id>", methods=["GET"])
def get_device(device_id):
    try:
        with DeviceService() as service:
            device = service.get_device_by_id(device_id)
        if not device:
            return jsonify({"error": "Device not found"}), 404

        return (
            jsonify(
                {
                    "device_id": device.device_id,
                    "last_seen": (
                        device.last_seen.isoformat() if device.last_seen else None
                    ),
                }
            ),
            200,
        )

    except Exception as exception:
        return (
            jsonify({"error": "Failed to fetch device", "details": str(exception)}),
            500,
        )


@app.route("/api/devices/<device_id>", methods=["DELETE"])
def delete_device_api(device_id):
    try:
        with DeviceService() as service:
            success = service.delete_device(device_id)
        if success:
            return jsonify({"message": "Device deleted"}), 200
        return jsonify({"error": "Device not found"}), 404

    except Exception as exception:
        return (
            jsonify({"error": "Failed to delete device", "details": str(exception)}),
            500,
        )


@app.route("/api/devices", methods=["POST"])
def create_device():
    try:
        data = request.get_json() or {}
        user_id = data.get("user_id")
        if not user_id:
            return jsonify({"error": "Missing user_id"}), 400

        dto = DeviceDTO(
            device_id=(
                uuid.UUID(data["device_id"]) if data.get("device_id") else uuid.uuid4()
            ),
            last_seen=(
                datetime.fromisoformat(data["last_seen"])
                if data.get("last_seen")
                else datetime.now(timezone.utc)
            ),
        )
        with DeviceService() as service:
            device = service.create_device(dto, user_id)
        return jsonify({"device_id": str(device.device_id)}), 201

    except ValidationError as validation_error:
        return (
            jsonify({"error": "Invalid input", "details": validation_error.errors()}),
            422,
        )
    except (KeyError, ValueError) as exception:
        return jsonify({"error": str(exception)}), 400
    except Exception as exception:
        return (
            jsonify({"error": "Failed to create device", "details": str(exception)}),
            500,
        )


@app.route("/api/users/<user_id>/devices", methods=["GET"])
def list_user_devices(user_id):
    try:
        user_id = str(uuid.UUID(user_id))
        page = int(request.args.get("page", 1))
        per_page = int(request.args.get("per_page", 20))
        if page < 1 or per_page < 1:
            return jsonify({"error": "Invalid pagination"}), 400

        with DeviceService() as service:
            devices = service.get_devices_by_user(user_id, page, per_page)

        return (
            jsonify(
                [
                    {
                        "device_id": d.device_id,
                        "last_seen": d.last_seen.isoformat() if d.last_seen else None,
                    }
                    for d in devices
                ]
            ),
            200,
        )
    except ValueError:
        return jsonify({"error": "Invalid UUID format"}), 400
    except Exception as exception:
        return jsonify({"error": str(exception)}), 500
