CREATE DATABASE n8n_memory;
CREATE USER n8n_chat_user WITH PASSWORD 'ChatUserTemp123';
GRANT ALL PRIVILEGES ON DATABASE n8n_memory TO n8n_chat_user;
ALTER DATABASE n8n_memory OWNER TO n8n_chat_user;
