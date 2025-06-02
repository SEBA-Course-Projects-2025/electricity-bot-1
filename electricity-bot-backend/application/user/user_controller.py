import uuid
from application import app
from flask import request, jsonify
from application.user.user_service import UserService
from application.user.model.dto.user import CreateUserRequest, UpdateUserRequest
from pydantic import ValidationError

@app.route("/api/user", methods=["POST"])
def create_user():
    try:
        data = request.get_json()
        dto = CreateUserRequest(**data)

        with UserService() as user_service:
            result = user_service.create_user_with_device(dto)

        return jsonify(result), 201

    except ValidationError as validation_error:
        return jsonify({"error": "Invalid input", "details": validation_error.errors()}), 422
    except KeyError as key_error:
        return jsonify({"error": f"Missing required field: {str(key_error)}"}), 400
    except Exception as exception:
        return jsonify({"error": "Unexpected server error", "details": str(exception)}), 500


@app.route("/api/users", methods=["GET"])
def list_users():
    try:
        page = int(request.args.get("page", 1))  
        per_page = int(request.args.get("per_page", 20))  
        first_name = request.args.get("first_name")
        last_name = request.args.get("last_name")

        if page < 1 or per_page < 1:
            raise ValueError("page and per_page must be >= 1")

        with UserService() as user_service:
            users = user_service.get_all_users(page, per_page, first_name, last_name)

        return jsonify({
            "page": page,
            "per_page": per_page,
            "users": [
                {
                    "user_id": user.user_id,
                    "email": user.email,
                    "first_name": user.first_name,
                    "last_name": user.last_name
                } for user in users
            ]
        }), 200

    except ValueError:
        return jsonify({"error": "Invalid pagination parameters"}), 400
    except Exception as exception:
        return jsonify({"error": "Failed to fetch users", "details": str(exception)}), 500


@app.route("/api/user/<user_id>", methods=["PATCH"])
def update_user(user_id):
    try:
        user_id = str(uuid.UUID(user_id))
        data = request.get_json()
        dto = UpdateUserRequest(**data)

        with UserService() as user_service:
            user = user_service.update_user(user_id, dto)

        if not user:
            return jsonify({"error": "User not found"}), 404

        return jsonify({"message": "User updated"}), 200

    except ValueError:
        return jsonify({"error": "Invalid UUID format"}), 400
    except ValidationError as validation_error:
        return jsonify({"error": "Invalid input", "details": validation_error.errors()}), 422
    except Exception as exception:
        return jsonify({"error": "Update failed", "details": str(exception)}), 400


@app.route("/api/user/<user_id>", methods=["DELETE"])
def delete_user_route(user_id):
    try:
        user_id = str(uuid.UUID(user_id))

        with UserService() as user_service:
            success = user_service.delete_user(user_id)

        if success:
            return jsonify({"message": "User deleted"}), 200
        else:
            return jsonify({"error": "User not found"}), 404

    except ValueError:
        return jsonify({"error": "Invalid UUID format"}), 400
    except Exception as exception:
        return jsonify({"error": "Delete failed", "details": str(exception)}), 400


@app.route("/api/user/<user_id>", methods=["GET"])
def get_user(user_id):
    try:
        user_id = str(uuid.UUID(user_id))

        with UserService() as user_service:
            user = user_service.get_user_by_id(user_id)

        if user:
            return jsonify({
                "user_id": user.user_id,
                "email": user.email,
                "first_name": user.first_name,
                "last_name": user.last_name
            }), 200
        else:
            return jsonify({"error": "User not found"}), 404

    except ValueError:
        return jsonify({"error": "Invalid UUID format"}), 400
    except Exception as exception:
        return jsonify({"error": "Failed to fetch user", "details": str(exception)}), 500