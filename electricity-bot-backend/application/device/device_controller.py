from application import app
from flask import request, jsonify
from application.device.device_service import DeviceService

@app.route("/api/devices", methods=["GET"])
def list_devices():
    try:
        owner_id = request.args.get("owner_id")
        owner_email = request.args.get("owner_email")  
        page = int(request.args.get("page", 1))
        per_page = int(request.args.get("per_page", 3))

        if page < 1 or per_page < 1:
            return jsonify({"error": "Invalid pagination parameters"}), 400

        with DeviceService() as service:
            devices = service.get_devices(owner_id, owner_email, page, per_page)

        return jsonify([
            {
                "device_id": d.device_id,
                "owner_id": d.owner_id,
                "owner_email": d.owner_email,
                "last_seen": d.last_seen.isoformat() if d.last_seen else None
            }
            for d in devices
        ]), 200

    except Exception as exception:
        return jsonify({"error": "Device fetch failed", "details": str(exception)}), 500

@app.route("/api/device/<device_id>", methods=["GET"])
def get_device(device_id):
    try:
        with DeviceService() as service:
            device = service.get_device_by_id(device_id)
            if device is None:
                return jsonify({"error": "Device not found"}), 404

            return jsonify({
                "device_id": device.device_id,
                "owner_id": device.owner_id,
                "owner_email": device.owner_email,
                "last_seen": device.last_seen.isoformat() if device.last_seen else None
            }), 200

    except Exception as exception:
        return jsonify({"error": "Failed to fetch device", "details": str(exception)}), 500

@app.route("/api/device/<device_id>", methods=["DELETE"])
def delete_device_api(device_id):
    try:
        with DeviceService() as service:
            success = service.delete_device(device_id)

        if success:
            return jsonify({"message": "Device deleted"}), 200
        else:
            return jsonify({"error": "Device not found"}), 404

    except Exception as exception:
        return jsonify({"error": "Failed to delete device", "details": str(exception)}), 500