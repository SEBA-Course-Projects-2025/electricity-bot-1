import os
import uuid
from datetime import datetime, timedelta, timezone

os.environ["DATABASE_URL"] = (
    "mysql+pymysql://user:88888888@127.0.0.1:3307/electricity_bot_bd"
)

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from application.models import MeasurementModel
from application.database import Base

DATABASE_URL = os.environ["DATABASE_URL"]
engine = create_engine(DATABASE_URL, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

device_id = "b0c87254-0c85-47be-8b35-e8d49c6d2a92"
now = datetime.now(timezone.utc)

measurements = [
    MeasurementModel(
        measurement_id=str(uuid.uuid4()),
        device_id=device_id,
        timestamp=now - timedelta(hours=23),
        outgate_status=True,
    ),
    MeasurementModel(
        measurement_id=str(uuid.uuid4()),
        device_id=device_id,
        timestamp=now - timedelta(hours=18),
        outgate_status=False,
    ),
    MeasurementModel(
        measurement_id=str(uuid.uuid4()),
        device_id=device_id,
        timestamp=now - timedelta(hours=8),
        outgate_status=True,
    ),
    MeasurementModel(
        measurement_id=str(uuid.uuid4()),
        device_id=device_id,
        timestamp=now - timedelta(hours=3),
        outgate_status=False,
    ),
]

try:
    with SessionLocal() as db:
        db.add_all(measurements)
        db.commit()
    print("✅ Measurements successfully inserted for device:", device_id)
except Exception as e:
    print("❌ Error inserting measurements:", str(e))
