from application.device.model.dto.device import Device as DeviceDTO
from application.models import DeviceModel


def dto_to_entity(dto: DeviceDTO) -> DeviceModel:  # json to object
    return DeviceModel(device_id=str(dto.device_id), last_seen=dto.last_seen)


def entity_to_dto(entity: DeviceModel) -> DeviceDTO:  # object to json
    return DeviceDTO(device_id=entity.device_id, last_seen=entity.last_seen)
