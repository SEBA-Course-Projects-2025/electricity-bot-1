from database import base, engine
import models

base.metadata.create_all(bind=engine)  # to create real tables from orm models
