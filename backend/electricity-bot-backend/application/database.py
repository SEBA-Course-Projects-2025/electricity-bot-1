from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = "mysql+pymysql://user:88888888@mysql:3306/electricity_bot_bd"

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,  
)

session = sessionmaker(bind=engine, autocommit=False, autoflush=False)

base = declarative_base()
