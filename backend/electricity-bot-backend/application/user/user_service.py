import uuid
from application.database import SessionLocal
from application.models import UserModel, UnassignedDeviceModel, DeviceModel


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

        if not user:
            user = self.db.query(UserModel).filter_by(email=email).first()
            if user:
                user.google_sub = sub

        created = False
        if not user:
            user = UserModel(
                user_id=str(uuid.uuid4()),
                google_sub=sub,
                email=email,
                name=name,
            )
            self.db.add(user)
            created = True

        self.db.commit()
        self.db.refresh(user)

        unassigned_devices = (
            self.db.query(UnassignedDeviceModel)
            .filter_by(previous_owner_id=user.user_id)
            .all()
        )
        for device in unassigned_devices:
            device_obj = (
                self.db.query(DeviceModel).filter_by(device_id=device.device_id).first()
            )
            if device_obj:
                user.devices.append(device_obj)
            self.db.delete(device)

        self.db.commit()
        return user, created

    def unassign_devices_and_logout(self, user_id: str) -> bool:
        user = self.db.query(UserModel).filter_by(user_id=user_id).first()
        if not user:
            return False

        for device in user.devices:
            self.db.add(
                UnassignedDeviceModel(
                    device_id=device.device_id, previous_owner_id=user.user_id
                )
            )

        user.devices.clear()
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

    def unassign_devices(self, user_id: str) -> bool:
        user = self.db.query(UserModel).filter_by(user_id=user_id).first()
        if not user:
            return False

        for device in user.devices:
            self.db.add(UnassignedDeviceModel(device_id=device.device_id))

        user.devices.clear()
        self.db.commit()
        return True
