import uuid
from flask import request, jsonify
from application import app
from application.database import session
from application.models import DeviceModel, UnassignedDeviceModel
from application.measurement.model.dto.measurement import Measurement as MeasurementDTO
from application.measurement.measurement_service import MeasurementService
from pydantic import ValidationError
from datetime import datetime, timezone


@app.route("/api/measurements", methods=["POST"])
def receive_measurement():
    try:
        data = request.get_json() or {}

        if (
            "device_id" not in data
            or "outgate_status" not in data
            or "timestamp" not in data
        ):
            return (
                jsonify(
                    {
                        "error": "Missing required field: device_id, outgate_status and timestamp are required"
                    }
                ),
                400,
            )

        try:
            timestamp = datetime.fromisoformat(data["timestamp"])
            if timestamp.tzinfo is None:
                timestamp = timestamp.replace(tzinfo=timezone.utc)
        except Exception:
            return (
                jsonify({"error": "Invalid timestamp format, must be ISO-8601 UTC"}),
                400,
            )

        dto = MeasurementDTO(
            device_id=uuid.UUID(data["device_id"]),
            outgate_status=data["outgate_status"],
            timestamp=timestamp,
        )

        with session() as db:
            dev = db.query(DeviceModel).filter_by(device_id=str(dto.device_id)).first()
            if not dev:
                orphaned = (
                    db.query(UnassignedDeviceModel)
                    .filter_by(device_id=str(dto.device_id))
                    .first()
                )
                if orphaned:
                    return (
                        jsonify(
                            {"error": "Device removed from system", "action": "reboot"}
                        ),
                        410,
                    )
                return jsonify({"error": "Device not registered"}), 404

        with MeasurementService() as service:
            service.save_measurement(dto)

        return (
            jsonify(
                {"message": "Measurement saved", "timestamp": dto.timestamp.isoformat()}
            ),
            201,
        )

    except ValidationError as validation_error:
        return (
            jsonify({"error": "Invalid input", "details": validation_error.errors()}),
            422,
        )

    except (ValueError,) as validation_error:
        return jsonify({"error": str(validation_error)}), 400

    except Exception as exception:
        return (
            jsonify({"error": "Unexpected server error", "details": str(exception)}),
            500,
        )


@app.route("/api/statistics/day/<device_id>", methods=["GET"])
def get_statistics_day(device_id):
    return _get_statistics(device_id, days=1)


@app.route("/api/statistics/week/<device_id>", methods=["GET"])
def get_statistics_week(device_id):
    return _get_statistics(device_id, days=7)


def _get_statistics(device_id: str, days: int):
    try:
        uuid_obj = uuid.UUID(device_id)

        with session() as db:
            device_exists = (
                db.query(DeviceModel).filter_by(device_id=str(uuid_obj)).first()
            )
            if not device_exists:
                return jsonify({"error": "Device not registered"}), 404

        with MeasurementService() as service:
            data = service.get_power_events(str(uuid_obj), days=days)

        return (
            jsonify(
                {
                    "device_id": device_id,
                    "from": (
                        datetime.now(timezone.utc) - timedelta(days=days)
                    ).isoformat(),
                    "to": datetime.now(timezone.utc).isoformat(),
                    "events": data,
                }
            ),
            200,
        )

    except ValueError:
        return jsonify({"error": "Invalid device ID format. Must be UUID."}), 422
    except Exception as exception:
        return (
            jsonify(
                {"error": "Could not retrieve statistics", "details": str(exception)}
            ),
            500,
        )
