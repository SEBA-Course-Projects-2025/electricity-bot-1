from flask import Flask
from flask_jwt_extended import JWTManager
import os

app = Flask(__name__)

app.config["JWT_SECRET_KEY"] = os.getenv("JWT_SECRET_KEY", "dev-secret")
jwt = JWTManager(app)

import application.device.device_controller
import application.measurement.measurement_controller
from application.auth.auth_controller import auth_bp

# from application.user.user_controller import user_bp

app.register_blueprint(auth_bp)
# app.register_blueprint(user_bp)
