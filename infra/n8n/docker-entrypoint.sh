#!/bin/sh
set -e

# O volume do Railway monta como root; o n8n roda como `node`. Sem este chown o
# container morre com EACCES na primeira escrita em /home/node/.n8n.
mkdir -p /home/node/.n8n
chown -R node:node /home/node/.n8n

# 700 (e não 755): o n8n emite warning de permissão se o config file estiver
# legível por outros usuários — ele guarda a chave de criptografia das credenciais ali.
chmod -R 700 /home/node/.n8n

# gosu vem do estágio de build (binário estático) — ver comentário no Dockerfile.
exec gosu node n8n start
