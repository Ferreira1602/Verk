# backend/app/auth.py
import bcrypt
from database import SessionLocal
from models import User

def verificar_senha(senha_digitada: str, hash_armazenado: str) -> bool:
    # Converte para bytes conforme exigido pelo bcrypt
    senha_bytes = senha_digitada.encode('utf-8')
    hash_bytes = hash_armazenado.encode('utf-8')
    # Compara a senha digitada com o hash salvo no banco
    return bcrypt.checkpw(senha_bytes, hash_bytes)

def verificar_login(email, senha):
    db = SessionLocal() # Cria a sessão
    try:
        # Busca o usuário no banco usando o modelo da Semana 2
        user = db.query(User).filter(User.email == email).first()
        
        # Verifica se o usuário existe e se a senha confere
        if user and verificar_senha(senha, user.password_hash):
            return True
        return False
    finally:
        db.close() # Sempre fecha a sessão no final