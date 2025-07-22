from application.user.model.dto.user import User as UserDTO


class UserMapper:

    def map_request(self, request_data):  # json to object
        # should be immutable

        # user = User(**request_data)

        user = User(
            user_id=request_data.get("user_id"), email=request_data.get("email")
        )

        return user  # fields are validated by Pydantic

    def map_entity_to_dto(self, entity) -> UserDTO:  # ORM object from db to DTO

        return UserDTO(
            user_id=entity.user_id,
            email=entity.email,
            first_name=entity.first_name,
            last_name=entity.last_name,
        )
