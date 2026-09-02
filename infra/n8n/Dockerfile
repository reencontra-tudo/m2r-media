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
# Sobre o gosu: o volume do Railway monta como root e o n8n roda como usuário `node`;
# sem um chown no boot o container morre com EACCES ao escrever em /home/node/.n8n
# (mesmo problema que o n8n-railway resolveu na marra). Dropar privilégio precisa de um
# helper, e a imagem oficial do n8n não tem gerenciador de pacotes nenhum — já tentamos
# apt-get ("not found", ela é Alpine) e apk (também não existe, é base mínima). Por isso
# o binário estático vem de um estágio separado: não depende da distro nem da libc da
# imagem base, então sobrevive às trocas de base image que o n8n faz de tempos em tempos.

FROM alpine:3 AS gosu
ARG TARGETARCH
RUN apk add --no-cache curl \
 && curl -fsSL -o /gosu "https://github.com/tianon/gosu/releases/download/1.17/gosu-${TARGETARCH}" \
 && chmod +x /gosu

FROM n8nio/n8n:latest

USER root

COPY --from=gosu /gosu /usr/local/bin/gosu
COPY infra/n8n/docker-entrypoint.sh /m2r-entrypoint.sh
RUN chmod +x /m2r-entrypoint.sh

ENTRYPOINT ["/m2r-entrypoint.sh"]
