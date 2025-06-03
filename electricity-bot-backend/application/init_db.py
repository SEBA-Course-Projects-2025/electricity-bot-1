from database import base, engine
from models import MeasurementModel, DeviceModel, UserModel

base.metadata.create_all(bind=engine)  # to create real tables from orm models
