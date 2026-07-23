# backend/app/auth.py
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
import os

# Importações do seu projeto
from database import get_db
from models import User

# Configurações de Segurança
# Em produção, garanta que SECRET_KEY esteja definida no seu arquivo .env
SECRET_KEY = os.getenv("SECRET_KEY", "super-secret-key-mude-isto-em-producao")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_HOURS = 24

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

def create_access_token(user_id: str):
    """Cria um token JWT contendo o ID do usuário."""
    expire = datetime.utcnow() + timedelta(hours=ACCESS_TOKEN_EXPIRE_HOURS)
    to_encode = {"sub": str(user_id), "exp": expire}
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """
    Dependência para injetar o usuário logado em qualquer rota protegida.
    Valida o token e busca o usuário correspondente no banco de dados.
    """
    credentials_exception = HTTPException(
        status_code=401,
        detail="Credenciais inválidas ou token expirado",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # Decodifica o token
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        
        if user_id is None:
            raise credentials_exception
            
    except JWTError:
        raise credentials_exception
    
    # Busca o usuário no banco de dados para garantir que ele ainda existe e está ativo
    user = db.query(User).filter(User.id == user_id).first()
    
    if user is None:
        raise credentials_exception
        
    return user

def require_admin(current_user: User = Depends(get_current_user)):
    role_str = current_user.role.value if hasattr(current_user.role, 'value') else str(current_user.role)
    if role_str.upper() not in ["ADMINISTRATOR", "HEAD", "ADMIN"]:
        raise HTTPException(status_code=403, detail="Acesso restrito a administradores")
    return current_user

def require_manager(current_user: User = Depends(get_current_user)):
    role_str = current_user.role.value if hasattr(current_user.role, 'value') else str(current_user.role)
    if role_str.upper() not in ["PROJECT_MANAGER", "MANAGER", "ADMINISTRATOR", "HEAD", "ADMIN"]:
        raise HTTPException(status_code=403, detail="Acesso restrito a gerentes ou administradores")
    return current_user