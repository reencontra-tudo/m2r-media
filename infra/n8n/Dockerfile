# n8n da Central de Mídia (m2r-media) — servidor próprio, isolado do n8n do Backfindr.
#
# Por que existe: até 31/08/2026 o motor da Central de Mídia rodava no mesmo n8n do
# Backfindr (n8n-production-b99a) por atalho prático, não por design. São produtos
# independentes — se o n8n do Backfindr cair, o robô dos outros produtos não deve cair
# junto. Mesmo princípio já aplicado ao código (repo próprio) e ao banco (Supabase próprio).
#
# Por que não reaproveitar reencontra-tudo/n8n-railway (o Dockerfile do n8n do Backfindr):
# aquele Dockerfile tem as URLs do Backfindr hardcoded (N8N_HOST, WEBHOOK_URL,
# N8N_EDITOR_BASE_URL) e usar ele aqui recriaria exatamente o acoplamento que esta
# separação existe pra remover. Aqui toda configuração vem de variável de ambiente
# do Railway — nada de URL fixa na imagem.
#
# O truque do gosu abaixo é a mesma solução que o n8n-railway descobriu na marra: o
# volume do Railway monta como root, e o n8n roda como usuário `node`, então sem o
# chown o container morre com EACCES ao tentar escrever em /home/node/.n8n.

FROM n8nio/n8n:latest

USER root

# gosu: ajusta permissão do volume como root e depois dropa pro usuário node,
# preservando PID 1 (shutdown gracioso do n8n continua funcionando).
RUN apt-get update \
 && apt-get install -y --no-install-recommends gosu \
 && rm -rf /var/lib/apt/lists/*

COPY infra/n8n/docker-entrypoint.sh /m2r-entrypoint.sh
RUN chmod +x /m2r-entrypoint.sh

ENTRYPOINT ["/m2r-entrypoint.sh"]
