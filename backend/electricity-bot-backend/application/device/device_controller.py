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
        with DeviceService() as service:
            devices = service.get_all_devices()

        if not devices:
            return (
                jsonify({"message": "No devices found in the database"}),
                200,
            )

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
    if not DeviceService.is_valid_uuid(device_id):
        return jsonify({"error": "Invalid device ID format"}), 400

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


@app.route("/api/devices/<device_id>/owners", methods=["GET"])
def get_device_owners(device_id):
    if not DeviceService.is_valid_uuid(device_id):
        return jsonify({"error": "Invalid device ID format"}), 400

    try:
        with DeviceService() as service:
            owners = service.get_device_owners(device_id)

        if not owners:
            return jsonify({"message": "No owners found or device does not exist"}), 404

        return (
            jsonify(
                [{"user_id": user.user_id, "email": user.email} for user in owners]
            ),
            200,
        )

    except Exception as exception:
        return (
            jsonify({"error": "Failed to fetch owners", "details": str(exception)}),
            500,
        )


@app.route("/api/devices/<device_id>", methods=["DELETE"])
def delete_device_api(device_id):
    if not DeviceService.is_valid_uuid(device_id):
        return jsonify({"error": "Invalid device ID format"}), 400

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

        if not DeviceService.is_valid_uuid(user_id):
            return jsonify({"error": "Invalid user_id format"}), 400

        device_id = data.get("device_id")
        if not device_id:
            return jsonify({"error": "Missing device_id"}), 400

        if not DeviceService.is_valid_uuid(device_id):
            return jsonify({"error": "Invalid device_id format"}), 400

        dto = DeviceDTO(**data)

        with DeviceService() as service:
            device_data = service.create_device(dto, user_id)

        return (
            jsonify(
                {
                    "device_id": device_data["device_id"],
                    "user_id": user_id,
                    "message": f"Device {device_data['device_id']} successfully created and assigned to user {user_id}",
                }
            ),
            201,
        )

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
        if not DeviceService.is_valid_uuid(user_id):
            return jsonify({"error": "Invalid user_id format"}), 400

        with DeviceService() as service:
            devices = service.get_devices_by_user(user_id)

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
        return jsonify({"error": str(exception)}), 500
