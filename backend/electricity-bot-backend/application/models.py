from sqlalchemy import Column, String, Boolean, DateTime, Table, ForeignKey
from sqlalchemy.orm import relationship
from application.database import base
import uuid
from datetime import datetime, timezone


user_device_association = Table(
    "user_device_association",  # for many-to-many relationship
    base.metadata,
    Column("user_id", String(255), ForeignKey("users.user_id", ondelete="CASCADE")),
    Column(
        "device_id", String(255), ForeignKey("devices.device_id", ondelete="CASCADE")
    ),
)

# ORM models


class DeviceModel(base):
    __tablename__ = "devices"

    device_id = Column(
        String(255), primary_key=True, default=lambda: str(uuid.uuid4()), nullable=False
    )
    last_seen = Column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )

    users = relationship(
        "UserModel", secondary=user_device_association, back_populates="devices"
    )


class MeasurementModel(base):
    __tablename__ = "measurements"

    measurement_id = Column(
        String(255), primary_key=True, default=lambda: str(uuid.uuid4()), nullable=False
    )
    device_id = Column(String(255), nullable=False)
    timestamp = Column(
        DateTime, default=lambda: datetime.now(timezone.utc), nullable=False
    )
    outgate_status = Column(Boolean, nullable=False)


class UserModel(base):
    __tablename__ = "users"

    user_id = Column(
        String(255), primary_key=True, default=lambda: str(uuid.uuid4()), nullable=False
    )
    google_sub = Column(
        String(255), nullable=False, unique=True
    )  # unique identifier from Google
    email = Column(String(255), nullable=False, unique=True)
    name = Column(String(255), nullable=True)  # here info which is parsed from token
    devices = relationship(
        "DeviceModel", secondary=user_device_association, back_populates="users"
    )


class UnassignedDeviceModel(base):
    __tablename__ = "unassigned_devices"  # table for devices not assigned to any user
    # device_id is moved there when device was delited, or user was deleted and device with them too

    device_id = Column(String(255), primary_key=True, nullable=False)
