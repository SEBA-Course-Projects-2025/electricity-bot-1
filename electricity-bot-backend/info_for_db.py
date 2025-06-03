from application.database import session
from application.models import UserModel, DeviceModel, MeasurementModel
from datetime import datetime, timedelta, timezone
import uuid
import random

db = session()

try:
    # table users
    users = []
    for i in range(8):
        user = UserModel(
            user_id=str(uuid.uuid4()),
            email=f"user{i}@example.com",
            first_name=f"FirstName{i}",
            last_name=f"LastName{i}",
        )
        db.add(user)
        users.append(user)

    db.commit()

    # table devices
    devices = []
    for i in range(8):
        device = DeviceModel(
            device_id=str(uuid.uuid4()),
            owner_id=users[i % len(users)].user_id,
            owner_email=users[i % len(users)].email,
            last_seen=datetime.now(timezone.utc) - timedelta(minutes=i * 3),
        )
        db.add(device)
        devices.append(device)

    db.commit()

    # table measurements
    for i in range(8):
        measurement = MeasurementModel(
            measurement_id=str(uuid.uuid4()),
            device_id=devices[i % len(devices)].device_id,
            timestamp=datetime.now(timezone.utc) - timedelta(hours=i),
            outgate_status=random.choice([True, False]),
        )
        db.add(measurement)

    db.commit()
    print("8 users, 8 devices, 8 measurements were added to the database")

except:
    db.rollback()
    print("Error during seeding")
finally:
    db.close()
