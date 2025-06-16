# N8N Setup :)


# n8n com Ngrok - Configuração Local + Webhook Externo

Este projeto configura o `n8n` em um ambiente Docker com suporte a Webhooks públicos via **ngrok** (usando subdomínio fixo).

---

## ✅ Pré-requisitos

- Docker + Docker Compose instalados
- Conta gratuita no [ngrok.com](https://ngrok.com)
- Token de autenticação do ngrok
- Subdomínio fixo criado no dashboard do ngrok (Ex: `https://meuapp.ngrok-free.app`)

---

## 📁 Estrutura esperada

```plaintext
n8n-setup/
├── docker-compose.yml
├── .env
├── n8n_storage/
└── README.md
```
---
## ⚙️ Adicionando Evolution API

Este setup inclui o Evolution API — uma API de automações personalizáveis que pode ser usada junto com o n8n.

---

## ⚙️ Arquivo `.env` (exemplo)

Crie um arquivo `.env` na raiz do projeto com:

```env
# Configuração básica do n8n
HOST=0.0.0.0
N8N_PORT=5678
N8N_PROTOCOL=http

# URL pública do webhook (use seu subdomínio fixo do ngrok)
WEBHOOK_URL=https://meuapp.ngrok-free.app/

# Chave de criptografia (obrigatória)
N8N_ENCRYPTION_KEY=coloque_uma_chave_forte_aqui

# Fuso horário
GENERIC_TIMEZONE=America/Sao_Paulo

# PostgreSQL
POSTGRES_HOST=postgres
POSTGRES_DB=n8n
POSTGRES_USER=root
POSTGRES_PASSWORD=minhasenha
EVOLUTION_PASSWORD=minhasenha_evolution
DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false
DB_POSTGRESDB_SSL_MODE=disable

# Redis
REDIS_PASSWORD=minhasenha_redis

# Ngrok
NGROK_AUTHTOKEN=seu_token_do_ngrok_aqui

# Evolution API
EVOLUTION_JWT_SECRET=sua_chave_forte_aqui
EVOLUTION_DATABASE_URL=postgres://usuario:senha@postgres:5432/evolution_db
```

## 🐳 Subindo o ambiente

Para iniciar os serviços com Docker Compose, execute:

```bash
docker-compose down -v --remove-orphans
docker-compose up -d --build
```

### Este comando irá:

- Construir e iniciar os containers para:
  - **n8n** (orquestrador de automações)
  - **PostgreSQL** (banco de dados)
  - **Redis** (gerenciador de filas)
  - **Ngrok** (exposição do n8n via HTTPS público)
- Ler as variáveis do arquivo `.env`
- Aplicar as configurações corretas de rede


## 🔐 Corrigir permissões (se necessário)

Se o volume `n8n_storage` apresentar erros de leitura ou avisos de permissões, ajuste com os comandos abaixo:

```bash
# Define o usuário correto (UID 1000 é o usado dentro do container n8n)
sudo chown -R 1000:1000 ./n8n_storage

# Restringe permissões de leitura/gravação apenas para o dono
sudo chmod -R 700 ./n8n_storage
```

Essas permissões evitam erros como:

Permissions XXXX for n8n settings file are too wide.


## 🌍 Como acessar o n8n

| Descrição                             | Endereço                                    |
|---------------------------------------|---------------------------------------------|
| Interface web (via ngrok)             | `https://meuapp.ngrok-free.app`             |
| Interface local (sem ngrok)           | `http://localhost:5678`                     |
| Painel de monitoramento do ngrok      | `http://localhost:4040`                     |
| API Evolution (local)	                | `http://localhost:3010`                     |

## 📡 Testando Webhooks externos

Siga os passos abaixo para testar se seu webhook está funcionando corretamente via ngrok:

1. Acesse a interface do n8n:
   `https://meuapp.ngrok-free.app`

2. Crie um novo fluxo e adicione o nó **Webhook**.

3. Configure o método (GET ou POST) e uma URL personalizada (ex: `/teste-webhook`).

4. Clique em **"Execute Node"** para ativar o modo escuta.

5. A URL gerada deve começar com o domínio do ngrok, como:
   `https://meuapp.ngrok-free.app/webhook/teste-webhook`

6. Use um cliente HTTP (como Postman, Insomnia ou `curl`) para enviar uma requisição para o webhook:

```bash
curl -X POST https://meuapp.ngrok-free.app/webhook/teste-webhook \
  -H "Content-Type: application/json" \
  -d '{"mensagem": "teste com ngrok"}'
```

## ❌ Problemas comuns

### 🔸 Webhook usando `localhost` na URL

**Causa:**
O n8n não reconheceu corretamente a variável `WEBHOOK_URL` no momento da inicialização.

**Solução:**

1. Verifique se o `.env` contém corretamente:

```bash
# 1 – confirme no .env
WEBHOOK_URL=https://meuapp.ngrok-free.app/

# 2 – reinicie o ambiente
docker-compose down -v --remove-orphans
docker-compose up -d --build
```

### 🔸 Erro ERR_NGROK_8012

**Mensagem:**
> Traffic was successfully tunneled to the ngrok agent, but the agent failed to establish a connection…

**Causa:**
o serviço n8n não está escutando na porta `5678` dentro da rede Docker.

**Solução:**
```bash
# verifique se HOST está correto no .env
HOST=0.0.0.0

# teste dentro do container
docker exec -it n8n-setup-n8n-1 netstat -tlnp
# saída esperada
# tcp  0  0 0.0.0.0:5678  0.0.0.0:*  LISTEN
```

## 📚 Referências úteis

- [n8n - Documentação oficial](https://docs.n8n.io)
- [ngrok - Documentação oficial](https://ngrok.com/docs)
- [n8n Webhook Node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)
- [Exemplos de automações com n8n](https://n8n.io/workflows)
- [n8n GitHub oficial](https://github.com/n8n-io/n8n)
- [API Evolution](https://github.com/EvolutionAPI/evolution-api)
