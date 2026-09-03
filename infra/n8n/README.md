# infra/n8n — servidor n8n próprio da Central de Mídia

Deploy do n8n que roda o motor da Central de Mídia, **separado do n8n do Backfindr**.

| | Backfindr | Central de Mídia |
|---|---|---|
| Projeto Railway | `backfindr-n8n` | `m2r-media-n8n` |
| Serviço n8n | `n8n` (n8n-production-b99a) | `n8n` |
| Postgres do n8n | Postgres dedicado | Postgres dedicado |
| Fonte da imagem | `reencontra-tudo/n8n-railway` | este diretório |

## O que é o quê (não confundir)

- **Postgres do Railway (neste projeto)** = banco interno do próprio n8n: workflows,
  execuções, credenciais criptografadas. É infraestrutura do n8n.
- **Supabase `m2r-media`** (ref `giwhpnrxvfzvsohsmbew`) = banco de **aplicação** da Central
  de Mídia: `media_personas`, `media_assets`, `media_targets`,
  `media_engagement_snapshots`. É dado de produto, acessado pelos nodes Postgres do
  workflow. **Coisas diferentes.**

## Chave de criptografia

Não é definida por variável de ambiente. O n8n gera a dele no primeiro boot e persiste em
`/home/node/.n8n/config`, dentro do volume do Railway montado nesse caminho — por isso o
volume é obrigatório. Sem ele, a chave é regerada a cada deploy e **toda credencial salva
no n8n vira lixo indecifrável**.

Se um dia precisar recriar o serviço do zero, faça backup do volume antes.

## Configuração

Tudo por variável de ambiente no Railway (nada hardcoded na imagem, ao contrário do
Dockerfile do Backfindr). As de banco usam variáveis de referência
(`${{Postgres.PGPASSWORD}}` etc.), então a senha nunca é copiada à mão.

## Estado do servidor próprio (03/09/2026)

- **URL:** https://n8n-production-af794.up.railway.app (projeto Railway `m2r-media-n8n`, n8n 2.37.7)
- **Workflow importado:** "Central de Mídia — AutoPost (multi-conta, cópia de teste)", id `QCFwvx4SQVJyzUL6`, **inativo**.

### Credenciais — 9 slots, 7 já ligados

| Credencial | Existe? | Nodes ligados | Falta |
|---|---|---|---|
| `m2r-media Postgres` | sim | 5 (todos os Postgres) | **senha** |
| `m2r-media R2 (S3)` | sim | 2 (Baixar/Subir asset) | **Access Key ID + Secret**, e conferir o Endpoint |
| `m2r-media OpenAI` | **não** | 0 (2 nodes órfãos) | criar inteira — o n8n exige a API Key para salvar, então nem o casco vazio dá para criar |

Os tokens do Meta **não** passam pelo cofre: entram por expressão a partir do Code node
"Montar mapa de tokens conhecidos", que tem 6 placeholders `COLOQUE_O_TOKEN_...`.
Isso é edição de código, não credencial — e é dívida de segurança já registrada
(BACKFINDR.md §17).

### Conexão com o Supabase: use o Session pooler

Conexão direta do Supabase é IPv6-only; o Railway sai por IPv4. Parâmetros do pooler:
`aws-0-us-west-2.pooler.supabase.com` : `5432`, database `postgres`,
user `postgres.giwhpnrxvfzvsohsmbew`, SSL `allow`.

A senha do banco **não é recuperável** ("The database password isn't viewable after
creation"): se ninguém a anotou, o caminho é *Reset database password* em
Database Settings do projeto `m2r-media`.
