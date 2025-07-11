from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from application.auth.auth_server import KeycloakAuthClient
from application.user.user_service import UserService
from application.email_utils.email_sender import send_welcome_email

auth_bp = Blueprint("auth_bp", __name__)


@auth_bp.route("/auth/callback", methods=["POST"])
def keycloak_callback():
    data = request.get_json()
    code = data.get("code")
    is_web = data.get("is_web", True)
    is_custom_mobile = data.get(
        "is_custom_mobile", False
    )  # updated to handle custom mobile

    if not code:
        return (
            jsonify(
                {
                    "error": "Authorization code is required. Please ensure 'code' is included in the request body."
                }
            ),
            400,
        )

    try:
        kc = KeycloakAuthClient()
        tokens = kc.exchange_code_for_token(
            code, is_web=is_web, is_custom_mobile=is_custom_mobile
        )

        access_token = tokens.get("access_token")
        if not access_token:
            raise Exception(
                "Access token missing in response. Keycloak did not return a valid token."
            )

        userinfo = kc.get_userinfo_from_token(access_token)

        with UserService() as user_service:
            user, created = user_service.get_or_create_user_by_keycloak_data(userinfo)

        jwt_token = create_access_token(identity=user.user_id)

        if created:
            send_welcome_email(user.email, user.name or "friend")

        return jsonify(
            {
                "message": (
                    "User created successfully"
                    if created
                    else "User already exists, logged in"
                ),
                "access_token": jwt_token,
                "user_id": user.user_id,
                "email_sent": created,
                "refresh_token": tokens.get("refresh_token"),
            }
        ), (201 if created else 200)

    except Exception as exception:
        return (
            jsonify(
                {
                    "error": f"Login failed: {str(exception)}",
                    "hint": "Check that the authorization code is valid and not expired. Also verify Keycloak configuration.",
                }
            ),
            400,
        )


@auth_bp.route("/auth/logout", methods=["POST"])
@jwt_required()
def logout_user():
    user_id = get_jwt_identity()
    data = request.get_json()

    refresh_token = data.get("refresh_token")
    is_web = data.get("is_web", True)
    is_custom_mobile = data.get("is_custom_mobile", False)

    if not refresh_token:
        return (
            jsonify(
                {"error": "Refresh token required. Provide it in the request body."}
            ),
            400,
        )

    try:
        kc = KeycloakAuthClient()
        kc.logout(refresh_token, is_web=is_web)
    except Exception as exception:
        return (
            jsonify(
                {
                    "error": f"Logout failed: {str(exception)}",
                    "hint": "Ensure the refresh token is still valid and has not already been used or revoked.",
                }
            ),
            400,
        )

    with UserService() as user_service:
        user_service.delete_user_and_reassign_devices(user_id)

    return (
        jsonify({"message": "User logged out, session revoked, devices unassigned"}),
        200,
    )


@auth_bp.route("/auth/refresh", methods=["POST"])
def refresh_tokens():
    data = request.get_json()
    refresh_token = data.get("refresh_token")
    is_web = data.get("is_web", True)
    is_custom_mobile = data.get("is_custom_mobile", False)

    if not refresh_token:
        return (
            jsonify(
                {
                    "error": "Refresh token is required. Include 'refresh_token' in request body."
                }
            ),
            400,
        )

    kc = KeycloakAuthClient()
    try:
        tokens = kc.refresh_token(refresh_token, is_web=is_web)
    except Exception as exception:
        return (
            jsonify(
                {
                    "error": f"Refresh failed: {str(exception)}",
                    "hint": "Refresh token may be expired, used already, or associated session is not active.",
                }
            ),
            400,
        )

    return jsonify(tokens), 200
