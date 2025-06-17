from flask import Flask

# from flasgger import Swagger

app = Flask(__name__)
# swagger = Swagger(app) # for API documentation which will be generated automatically

import application.device.device_controller
import application.measurement.measurement_controller
import application.user.user_controller
