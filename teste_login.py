# backend/app/teste_login.py
from auth import verificar_login

# Vamos testar com os dados que criamos no script de seed
email = "admin@norn.com"
senha = "senha123"

print(f"Tentando login para: {email}...")

if verificar_login(email, senha):
    print("✅ Sucesso! O porteiro liberou a entrada.")
else:
    print("❌ Acesso negado. Verifique o e-mail ou a senha.")