import uuid
from datetime import datetime, timezone
from application.database import session
from application.models import (
    UserModel,
    DeviceModel,
    UnassignedDeviceModel,
    user_device_association,
)
from application.user.model.dto.user import CreateUserRequest, UpdateUserRequest


class UserService:
    def __enter__(self):
        self.db = session()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.db.close()

    def create_user_with_device(self, dto: CreateUserRequest):
        try:
            user_id = str(uuid.uuid4())
            user = UserModel(
                user_id=user_id,
                email=dto.email,
                first_name=dto.first_name,
                last_name=dto.last_name,
            )
            self.db.add(user)

            device = DeviceModel(
                device_id=str(dto.device_id),
                last_seen=datetime.now(timezone.utc),
            )
            self.db.add(device)

            user.devices.append(device)

            self.db.add(UnassignedDeviceModel(device_id=device.device_id))

            self.db.commit()
            return {"user_id": user.user_id, "device_id": device.device_id}

        except Exception:
            self.db.rollback()
            raise

    def get_all_users(
        self, page: int, per_page: int, first_name: str = None, last_name: str = None
    ):
        query = self.db.query(UserModel)
        if first_name:
            query = query.filter(UserModel.first_name.ilike(f"%{first_name}%"))
        if last_name:
            query = query.filter(UserModel.last_name.ilike(f"%{last_name}%"))
        return query.offset((page - 1) * per_page).limit(per_page).all()

    def get_user_by_id(self, user_id: str):
        return self.db.query(UserModel).filter_by(user_id=user_id).first()

    def update_user(self, user_id: str, dto: UpdateUserRequest):
        user = self.db.query(UserModel).filter_by(user_id=user_id).first()
        if not user:
            return None
        user.email = dto.email
        user.first_name = dto.first_name
        user.last_name = dto.last_name
        self.db.commit()
        return user

    def delete_user(self, user_id: str) -> bool:
        user = self.db.query(UserModel).filter_by(user_id=user_id).first()
        if not user:
            return False

        associated = (
            self.db.query(user_device_association.c.device_id)
            .filter(user_device_association.c.user_id == user_id)
            .all()
        )
        self.db.execute(
            user_device_association.delete().where(
                user_device_association.c.user_id == user_id
            )
        )
        for (device_id,) in associated:
            self.db.add(UnassignedDeviceModel(device_id=device_id))

        self.db.delete(user)
        self.db.commit()
        return True
