from flask import Blueprint, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from application.user.user_service import UserService

user_bp = Blueprint("user_bp", __name__)


@user_bp.route("/user", methods=["GET"])
@jwt_required()
def get_current_user():
    user_id = get_jwt_identity()
    with UserService() as user_service:
        user = user_service.get_user_by_id(user_id)

        if not user:
            return (
                jsonify(
                    {
                        "error": "User not found",
                        "message": "The user ID extracted from the token does not correspond to any user in the database.",
                        "hint": "Make sure your access token is valid and the user still exists.",
                    }
                ),
                404,
            )

        return (
            jsonify({"user_id": user.user_id, "email": user.email, "name": user.name}),
            200,
        )


@user_bp.route("/user/devices", methods=["GET"])
@jwt_required()
def get_user_devices():
    user_id = get_jwt_identity()
    with UserService() as user_service:
        devices = user_service.get_devices_for_user(user_id)

    return jsonify({"devices": devices}), 200


@user_bp.route("/user", methods=["DELETE"])
@jwt_required()
def delete_current_user():
    user_id = get_jwt_identity()
    with UserService() as user_service:
        success = user_service.delete_user_and_reassign_devices(user_id)

    if not success:
        return (
            jsonify(
                {
                    "error": "User not found",
                    "message": "Cannot delete user because they do not exist in the database.",
                    "hint": "The user might have already been deleted or the access token is invalid.",
                }
            ),
            404,
        )

    return jsonify({"message": "User deleted and devices unassigned"}), 200
