import uuid
from pydantic import BaseModel, EmailStr


class Device(BaseModel):
    device_id: uuid.UUID
    owner_id: uuid.UUID
    owner_email: EmailStr
