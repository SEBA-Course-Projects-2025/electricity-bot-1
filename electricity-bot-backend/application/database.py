from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# sessionmarker for creating a new session (factory)

# DATABASE_URL = "sqlite:///./electricity.db"
DATABASE_URL = "mysql+pymysql://user:88888888@localhost:3307/electricity_bot_bd"  # connection to mysql database which is in docker container
# typeof database + driver + username:password@host:port/database_name

# engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
# connect_args={"check_same_thread": False} to work with multithreads (flask and background tasks)
engine = create_engine(DATABASE_URL)
session = sessionmaker(bind=engine, autocommit=False, autoflush=False)

base = declarative_base()
