from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# sessionmarker for creating a new session (factory)

DATABASE_URL = "sqlite:///./electricity.db"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
# connect_args={"check_same_thread": False} to work with multithreads (flask and background tasks) 
session = sessionmaker(bind=engine, autocommit=False, autoflush=False) 

base = declarative_base()