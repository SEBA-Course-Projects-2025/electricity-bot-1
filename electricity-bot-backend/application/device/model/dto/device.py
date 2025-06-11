from datetime import datetime
import uuid
from pydantic import BaseModel, EmailStr


class Device(BaseModel):
    device_id: uuid.UUID
    last_seen: datetime
