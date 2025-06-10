from sqlalchemy import Column, String, Boolean, DateTime
from application.database import base
import uuid
from datetime import datetime, timezone

# ORM models


class DeviceModel(base):
    __tablename__ = "devices"

    device_id = Column(
        String(255), primary_key=True, default=lambda: str(uuid.uuid4()), nullable=False
    )
    owner_id = Column(String(255), default=lambda: str(uuid.uuid4()), nullable=False)
    owner_email = Column(String(255), nullable=False, unique=True)
    last_seen = Column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )


class MeasurementModel(base):
    __tablename__ = "measurements"

    measurement_id = Column(
        String(255), primary_key=True, default=lambda: str(uuid.uuid4()), nullable=False
    )
    device_id = Column(String(255), default=lambda: str(uuid.uuid4()), nullable=False)
    timestamp = Column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )
    outgate_status = Column(Boolean, nullable=False)


class UserModel(base):
    __tablename__ = "users"

    user_id = Column(
        String(255), primary_key=True, default=lambda: str(uuid.uuid4()), nullable=False
    )
    email = Column(String(255), nullable=False, unique=True)
    first_name = Column(String(255), nullable=False)
    last_name = Column(String(255), nullable=False)
