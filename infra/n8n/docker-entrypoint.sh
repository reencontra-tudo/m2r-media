#!/bin/sh
set -e

# O volume do Railway monta como root; o n8n roda como `node`. Sem este chown o
# container morre com EACCES na primeira escrita em /home/node/.n8n.
mkdir -p /home/node/.n8n
chown -R node:node /home/node/.n8n

# 700 (e não 755): o n8n emite warning de permissão se o config file estiver
# legível por outros usuários — ele guarda a chave de criptografia das credenciais ali.
chmod -R 700 /home/node/.n8n

# su-exec (Alpine) ou gosu (Debian) — ver comentário no Dockerfile sobre a imagem
# base do n8n trocar de distro de tempos em tempos.
if command -v su-exec >/dev/null 2>&1; then
    exec su-exec node n8n start
elif command -v gosu >/dev/null 2>&1; then
    exec gosu node n8n start
else
    echo "ERRO: nem su-exec nem gosu disponíveis para dropar privilégio" >&2
    exit 1
fi
