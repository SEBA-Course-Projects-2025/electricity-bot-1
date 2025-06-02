from application.database import session
from application.models import DeviceModel, MeasurementModel

class DeviceService:
    def __init__(self):
        self.db = session()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.db.close()
        
    def get_devices(self, owner_id: str = None, owner_email: str = None, page: int = 1, per_page: int = 3):
        query = self.db.query(DeviceModel)

        if owner_id:
            query = query.filter(DeviceModel.owner_id == owner_id)
        if owner_email:
            query = query.filter(DeviceModel.owner_email.ilike(f"%{owner_email}%"))

        return query.offset((page - 1) * per_page).limit(per_page).all()

    def get_devices_by_owner(self, owner_id: str, page: int = 1, per_page: int = 3):
        return self.db.query(DeviceModel)\
            .filter_by(owner_id=owner_id)\
            .offset((page - 1) * per_page)\
            .limit(per_page).all()

    def delete_device(self, device_id: str) -> bool:
        device = self.db.query(DeviceModel).filter_by(device_id=device_id).first()
        if not device:
            return False

        self.db.query(MeasurementModel).filter_by(device_id=device_id).delete()
        self.db.delete(device)
        self.db.commit()
        return True
    
    def get_device_by_id(self, device_id: str):
        return self.db.query(DeviceModel).filter_by(device_id=device_id).first()
    
    def get_devices_by_owner(self, owner_id: str, page: int = 1, per_page: int = 3, owner_email: str = None):
        query = self.db.query(DeviceModel).filter_by(owner_id=owner_id)

        if owner_email:
            query = query.filter(DeviceModel.owner_email.ilike(f"%{owner_email}%"))

        return query.offset((page - 1) * per_page).limit(per_page).all()