import uuid
from application.database import SessionLocal
from application.models import UserModel


def get_user_by_id(user_id: str) -> UserModel | None:
    with SessionLocal() as db:
        return db.query(UserModel).filter_by(user_id=user_id).first()


def get_or_create_user_by_keycloak_data(userinfo: dict) -> tuple[UserModel, bool]:
    sub = userinfo.get("sub")
    email = userinfo.get("email")
    name = userinfo.get("name", "")

    with SessionLocal() as db:
        user = db.query(UserModel).filter_by(google_sub=sub).first()
        if user:
            return user, False

        user = UserModel(
            user_id=str(uuid.uuid4()),
            google_sub=sub,
            email=email,
            name=name,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user, True
