# backend/app/database.py
import os
from urllib.parse import quote_plus
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

load_dotenv()

# ... carregue as variáveis ...

# Aqui está o pulo do gato: use quote_plus para a senha
password = quote_plus(os.getenv("DB_PASSWORD"))
user = os.getenv("DB_USER")
host = os.getenv("DB_HOST")
port = os.getenv("DB_PORT")
name = os.getenv("DB_NAME")

# Monta a URL usando a senha "tratada"
SQLALCHEMY_DATABASE_URL = f"postgresql://{user}:{password}@{host}:{port}/{name}"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Adicione esta função aqui:
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Garante a criação das tabelas
#Base.metadata.create_all(bind=engine)