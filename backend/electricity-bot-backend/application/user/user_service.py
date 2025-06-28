import uuid
from application.database import SessionLocal
from application.models import UserModel, UnassignedDeviceModel


class UserService:
    def __enter__(self):
        self.db = SessionLocal()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.db.close()

    def get_user_by_id(self, user_id: str) -> UserModel | None:
        return self.db.query(UserModel).filter_by(user_id=user_id).first()

    def get_or_create_user_by_keycloak_data(
        self, userinfo: dict
    ) -> tuple[UserModel, bool]:
        sub = userinfo.get("sub")
        email = userinfo.get("email")
        name = userinfo.get("name", "")

        user = self.db.query(UserModel).filter_by(google_sub=sub).first()
        if user:
            return user, False

        user = UserModel(
            user_id=str(uuid.uuid4()),
            google_sub=sub,
            email=email,
            name=name,
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user, True

    def delete_user_and_reassign_devices(self, user_id: str) -> bool:
        user = self.db.query(UserModel).filter_by(user_id=user_id).first()
        if not user:
            return False

        for device in user.devices:
            self.db.add(UnassignedDeviceModel(device_id=device.device_id))

        self.db.delete(user)
        self.db.commit()
        return True

    def get_devices_for_user(self, user_id: str) -> list[dict]:
        user = self.db.query(UserModel).filter_by(user_id=user_id).first()
        if not user:
            return []

        return [
            {"device_id": device.device_id, "last_seen": device.last_seen.isoformat()}
            for device in user.devices
        ]
