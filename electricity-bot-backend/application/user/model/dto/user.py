import uuid
from pydantic import BaseModel, EmailStr


# DTO classes
class User(BaseModel):  # for get
    user_id: uuid.UUID
    email: EmailStr
    first_name: str
    last_name: str


class CreateUserRequest(BaseModel):  # for post
    email: EmailStr
    device_id: uuid.UUID
    first_name: str
    last_name: str


class UpdateUserRequest(BaseModel):  # for patch
    email: EmailStr
    first_name: str
    last_name: str
