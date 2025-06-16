#!/bin/bash
set -e

# Inicia o postgres em background
docker-entrypoint.sh postgres &

# Aguarda o PostgreSQL subir
echo "⏳ Aguardando PostgreSQL iniciar..."
until pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  sleep 2
done

# Verifica se o banco evolution_db já existe
echo "🔍 Verificando se o banco evolution_db já existe..."
EXISTS=$(psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='evolution_db'")

echo "Senha detectada: ${EVOLUTION_PASSWORD}"

if [ "$EXISTS" != "1" ]; then
  echo "⚙️ Criando banco evolution_db..."
  psql -U "$POSTGRES_USER" -d postgres <<EOF
CREATE USER evolution_db WITH PASSWORD evolutionUser6543665876;
CREATE DATABASE evolution_db;
GRANT ALL PRIVILEGES ON DATABASE evolution_db TO evolution_db;
ALTER DATABASE evolution_db OWNER TO evolution_db;
EOF
else
  echo "ℹ️ Banco evolution_db já existe. Nada será feito."
fi

# Verifica se o banco chatwoot já existe
echo "🔍 Verificando se o banco chatwoot já existe..."
EXISTS_CHATWOOT=$(psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='chatwoot'")

if [ "$EXISTS_CHATWOOT" != "1" ]; then
  echo "⚙️ Criando banco chatwoot..."
  psql -U "$POSTGRES_USER" -d postgres <<EOF
CREATE USER chatwoot WITH PASSWORD CHATWOOTUser6543665876;
CREATE DATABASE chatwoot;
GRANT ALL PRIVILEGES ON DATABASE chatwoot TO chatwoot;
ALTER DATABASE chatwoot OWNER TO chatwoot;
EOF
else
  echo "ℹ️ Banco chatwoot já existe. Nada será feito."
fi


# Espera o processo do postgres
wait -n
