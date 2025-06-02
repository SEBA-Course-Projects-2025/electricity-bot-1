import uuid
from pydantic import BaseModel, Field
# Field is a way to set additional parameters for the model fields
from datetime import datetime, timezone

class Measurement(BaseModel):
    measurement_id: uuid.UUID = Field(default_factory = uuid.uuid4) # similar to autoincrement; is needed for the object to have the unique id during the creation
    device_id: uuid.UUID
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    #default_factory - function which will be called during
    # the exemplar creation so as to generate a value
    outgate_status: bool
