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
