from flask import Blueprint, request, jsonify
from application.auth.auth_service import handle_google_login
from pydantic import ValidationError
import os
from urllib.parse import urlencode

auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")

REALM_NAME = os.getenv("KEYCLOAK_REALM", "electricity-bot")
KEYCLOAK_BASE_URL = os.getenv(
    "KEYCLOAK_BASE_URL", "http://localhost:8080"
)  # lokacal Keycloak server URL
REDIRECT_AFTER_LOGOUT = os.getenv(
    "LOGOUT_REDIRECT_URI", "http://localhost:3000"
)  # URL to redirect after logout (it may be the port where frontend is running)


@auth_bp.route("/login", methods=["POST"])
def login_with_google():  # id_token from frontend after communication with Google is wanted
    try:
        data = request.get_json()
        if "id_token" not in data:
            return jsonify({"error": "Missing id_token"}), 400

        id_token = data["id_token"]
        result = handle_google_login(id_token)
        # handle_google_login - add/update user in db; create session or return token

        return jsonify(result), 200

    except ValidationError as exception:
        return jsonify({"error": "Invalid input", "details": exception.errors()}), 422
    except Exception as exception:
        return jsonify({"error": "Login failed", "details": str(exception)}), 500


@auth_bp.route("/logout", methods=["GET"])  # real logout from Keycloak
def logout():
    try:
        params = {"redirect_uri": REDIRECT_AFTER_LOGOUT}

        logout_url = (
            f"{KEYCLOAK_BASE_URL}/realms/{REALM_NAME}/protocol/openid-connect/logout?"
            + urlencode(params)
        )

        return jsonify({"logout_url": logout_url}), 200

    except Exception as exception:
        return jsonify({"error": "Logout failed", "details": str(exception)}), 500
