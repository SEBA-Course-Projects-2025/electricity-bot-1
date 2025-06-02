# from application.measurement.model.dto.measurement import Measurement

# class MeasurementMapper:
#     def map_request(self, request_data): #json to object
#         measurement = Measurement(**request_data)
#         return measurement
    
#     def map_entity_to_dto(self, entity): # ORM object to DTO
#         measurement = Measurement(
#             measurement_id=entity.measurement_id,
#             device_id=entity.device_id,
#             timestamp=entity.timestamp,
#             outgate_status=entity.outgate_status
#         )
#         return measurement

from application.measurement.model.dto.measurement import Measurement
from application.models import MeasurementModel
import uuid

def dto_to_entity(dto: Measurement) -> MeasurementModel:
    return MeasurementModel(
        measurement_id=str(dto.measurement_id),
        device_id=str(dto.device_id),
        timestamp=dto.timestamp,
        outgate_status=dto.outgate_status
    )

def entity_to_dto(entity: MeasurementModel) -> Measurement:
    return Measurement(
        measurement_id=uuid.UUID(entity.measurement_id),
        device_id=uuid.UUID(entity.device_id),
        timestamp=entity.timestamp,
        outgate_status=entity.outgate_status
    )
