# from flask import Blueprint, request, jsonify
# from application.auth.auth_server import exchange_code_for_token, get_userinfo_from_token
# from application.user.user_service import get_or_create_user_by_keycloak_data
# from application.email_utils.email_sender import send_welcome_email

# user_bp = Blueprint("user_bp", __name__)


# @user_bp.route("/user/signup", methods=["POST"])
# def sign_up():
#     data = request.get_json()
#     code = data.get("code")
#     is_web = data.get("is_web", True)

#     if not code:
#         return jsonify({"error": "Authorization code is required"}), 400

#     try:
#         tokens = exchange_code_for_token(code, is_web=is_web)

#         if "access_token" not in tokens:
#             raise Exception("Access token missing in response")

#         userinfo = get_userinfo_from_token(tokens["access_token"])

#         user, created = get_or_create_user_by_keycloak_data(userinfo)

#         if created:
#             send_welcome_email(user.email, user.name or "friend")

#         return jsonify({"access_token": tokens["access_token"]}), 201
#     except Exception as exception:
#         return jsonify({"error": str(exception)}), 400
