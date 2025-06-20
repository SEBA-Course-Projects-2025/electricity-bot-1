from datetime import datetime
from typing import Optional
import uuid
from pydantic import BaseModel, EmailStr


class Device(BaseModel):
    device_id: uuid.UUID
    last_seen: Optional[datetime] = None
