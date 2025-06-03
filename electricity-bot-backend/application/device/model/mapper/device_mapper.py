from application.device.model.dto.device import Device

# should be immutable - device should be not modified after creation


class DeviceMapper:
    def map_request(self, request_data):  # json to object
        # request_data - data from json from API request (usually a dict)
        # device = Device(
        #     device_id=request_data.get('device_id') or uuid.uuid4(),
        #     owner_id=request_data.get('owner_id'),
        #     owner_email=request_data.get('owner_email')
        # )

        device = Device(**request_data)

        return device

    def map_entity_to_dto(self, entity):  # object (ORM) to DTO
        # entity - object that is gotten from database (usually from ORM model)
        device = Device(
            device_id=entity.device_id,
            owner_id=entity.owner_id,
            owner_email=entity.owner_email,
        )

        # device = Device(**{
        #     'device_id': device.device_id,
        #     'owner_id': device.owner_id,
        #     'owner_email': device.owner_email
        # })

        return device
