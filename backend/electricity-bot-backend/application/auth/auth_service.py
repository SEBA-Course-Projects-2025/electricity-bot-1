import os
import requests
from google.oauth2 import id_token
from google.auth.transport import requests as google_requests
from application.database import session
from application.models import UserModel
import uuid

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")


def handle_google_login(id_token_str: str):
    try:
        id_info = id_token.verify_oauth2_token(
            id_token_str, google_requests.Request(), GOOGLE_CLIENT_ID
        )

        email = id_info["email"]

        db = session()

        user = db.query(UserModel).filter_by(email=email).first()

        if not user:
            new_user = UserModel(user_id=str(uuid.uuid4()), email=email)
            db.add(new_user)
            db.commit()
            user = new_user

        return {
            "user_id": user.user_id,
            "email": user.email,
            "message": "Login successful",
        }

    except ValueError:
        raise Exception("Invalid Google ID token")
    except Exception as exception:
        raise exception
