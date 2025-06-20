from datetime import datetime, timezone
from application.database import session
from application.models import (
    DeviceModel,
    MeasurementModel,
    UnassignedDeviceModel,
    UserModel,
    user_device_association,
)
from application.device.model.mapper.device_mapper import dto_to_entity
from application.device.model.dto.device import Device as DeviceDTO
from uuid import UUID


class DeviceService:
    def __enter__(self):
        self.db = session()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.db.close()

    @staticmethod
    def is_valid_uuid(value: str) -> bool:
        try:
            UUID(value)
            return True
        except ValueError:
            return False

    def create_device(self, dto: DeviceDTO, user_id: str) -> DeviceModel:
        try:

            if dto.last_seen is None:
                dto.last_seen = datetime.now(timezone.utc)

            existing_device = (
                self.db.query(DeviceModel).filter_by(device_id=dto.device_id).first()
            )
            if existing_device:
                raise ValueError("Device with this ID already exists")

            device = DeviceModel(device_id=dto.device_id, last_seen=dto.last_seen)
            self.db.add(device)

            self.db.flush()

            self.db.execute(
                user_device_association.insert().values(
                    user_id=user_id, device_id=dto.device_id
                )
            )

            self.db.commit()

            return {"device_id": str(dto.device_id)}

        except Exception as exception:
            import traceback

            traceback.print_exc()
            raise exception

    def get_device_by_id(self, device_id: str):
        return self.db.query(DeviceModel).filter_by(device_id=device_id).first()

    def get_device_owners(self, device_id: str) -> list[UserModel]:
        device = self.db.query(DeviceModel).filter_by(device_id=device_id).first()
        if not device:
            return []
        return device.users

    def get_devices_by_user(self, user_id: str):
        return (
            self.db.query(DeviceModel)
            .join(DeviceModel.users)
            .filter(UserModel.user_id == user_id)
            .order_by(DeviceModel.device_id)
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

    def get_all_devices(self):
        return self.db.query(DeviceModel).all()
