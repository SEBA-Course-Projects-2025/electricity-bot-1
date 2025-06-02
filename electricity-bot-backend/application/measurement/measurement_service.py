from application.database import session
from application.models import MeasurementModel, DeviceModel
from application.measurement.model.mapper.measurement_mapper import dto_to_entity
from application.measurement.model.dto.measurement import Measurement
from datetime import datetime, timezone, timedelta
import uuid

class MeasurementService:
    def __enter__(self):
        self.db = session()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.db.close()

    def save_measurement(self, measurement_dto: Measurement):
        device_id_str = str(measurement_dto.device_id)

        last = self.db.query(MeasurementModel)\
            .filter_by(device_id=device_id_str)\
            .order_by(MeasurementModel.timestamp.desc())\
            .first()

        if last and last.outgate_status == measurement_dto.outgate_status:
            return  

        entity = dto_to_entity(measurement_dto)
        self.db.add(entity)

        if measurement_dto.outgate_status:
            device = self.db.query(DeviceModel).filter_by(device_id=device_id_str).first()
            if device:
                device.last_seen = datetime.now(timezone.utc)

        self.db.commit()

    def check_for_disconnected_devices(self):
        now = datetime.now(timezone.utc)
        threshold = now - timedelta(minutes=2)
        devices = self.db.query(DeviceModel).all()

        for device in devices:
            last_seen = device.last_seen

            if last_seen is not None and last_seen.tzinfo is None:
                last_seen = last_seen.replace(tzinfo=timezone.utc)

            if last_seen is None or last_seen < threshold:
                last = self.db.query(MeasurementModel)\
                    .filter_by(device_id=device.device_id)\
                    .order_by(MeasurementModel.timestamp.desc())\
                    .first()

                if last and last.outgate_status is False:
                    continue  

                measurement = Measurement(
                    measurement_id=uuid.uuid4(),
                    device_id=uuid.UUID(device.device_id),
                    timestamp=now,
                    outgate_status=False
                )
                self.db.add(dto_to_entity(measurement))

        self.db.commit()

    def get_power_events(self, device_id: str, days: int):
        now = datetime.now(timezone.utc)
        since = now - timedelta(days=days)

        events = self.db.query(MeasurementModel)\
            .filter(MeasurementModel.device_id == device_id)\
            .filter(MeasurementModel.timestamp >= since)\
            .order_by(MeasurementModel.timestamp.asc())\
            .all()

        return [
            {
                "timestamp": measurement.timestamp.isoformat(),
                "outgate_status": measurement.outgate_status
            }
            for measurement in events
        ]