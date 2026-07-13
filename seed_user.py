# backend/seed_user.py
from database import conectar_banco
import bcrypt
import uuid

def criar_admin():
    email = "admin@norn.com"
    senha = "senha123" # Você pode trocar esta senha
    
    # Transforma a senha em uma "assinatura" (hash) segura
    salt = bcrypt.gensalt()
    senha_hash = bcrypt.hashpw(senha.encode('utf-8'), salt).decode('utf-8')
    
    conn = conectar_banco()
    cur = conn.cursor()
    
    # Insere o usuário na tabela 'users' com cargo de administrador
    query = """
    INSERT INTO users (id, name, email, auth_provider, password_hash, role)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    cur.execute(query, (str(uuid.uuid4()), "Admin Norn", email, 'LOCAL', senha_hash, 'ADMINISTRATOR'))
    
    conn.commit()
    cur.close()
    conn.close()
    print("Usuário admin@norn.com criado com sucesso!")

if __name__ == "__main__":
    criar_admin()