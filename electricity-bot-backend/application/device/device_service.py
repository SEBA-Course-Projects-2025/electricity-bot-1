from application.database import session
from application.models import (
    DeviceModel,
    MeasurementModel,
    UnassignedDeviceModel,
    user_device_association,
)
from application.device.model.mapper.device_mapper import dto_to_entity


class DeviceService:
    def __enter__(self):
        self.db = session()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.db.close()

    def create_device(self, dto):
        device = dto_to_entity(dto)
        self.db.add(device)
        self.db.add(UnassignedDeviceModel(device_id=device.device_id))
        self.db.commit()
        return device

    def get_devices(self, page: int = 1, per_page: int = 3):
        return (
            self.db.query(DeviceModel)
            .offset((page - 1) * per_page)
            .limit(per_page)
            .all()
        )

    def get_device_by_id(self, device_id: str):
        return self.db.query(DeviceModel).filter_by(device_id=device_id).first()

    def get_devices_by_owner(self, user_id: str, page: int = 1, per_page: int = 3):
        return (
            self.db.query(DeviceModel)
            .join(
                user_device_association,
                user_device_association.c.device_id == DeviceModel.device_id,
            )
            .filter(user_device_association.c.user_id == user_id)
            .offset((page - 1) * per_page)
            .limit(per_page)
            .all()
        )

    def delete_device(self, device_id: str) -> bool:
        device = self.db.query(DeviceModel).filter_by(device_id=device_id).first()
        if not device:
            return False

        self.db.query(MeasurementModel).filter_by(device_id=device_id).delete()
        self.db.execute(
            user_device_association.delete().where(
                user_device_association.c.device_id == device_id
            )
        )
        self.db.add(UnassignedDeviceModel(device_id=device_id))
        self.db.delete(device)
        self.db.commit()
        return True
