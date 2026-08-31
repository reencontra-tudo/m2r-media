# m2r-media — Central de Mídia M2RPrime

Esquema canônico e (a partir do NEXT) motor de distribuição de mídia compartilhado entre
produtos M2RPrime — generaliza o motor n8n do AutoPost do Backfindr (hoje hardcoded pra
Facebook/Instagram de 6 nichos) pra publicar em múltiplas contas/plataformas de qualquer
produto ou persona.

**Design completo:** `reencontra-tudo/m2rintelligence` → `docs/media_hub_proposal.md`
(branch `claude/media-hub-schema-events-f05yrs`), aprovado por Marcos em 30/08/2026. Leia
aquele documento antes de mexer aqui — este repo é a implementação do que já foi decidido lá.

## Schema (`migrations/`)

- `0001_media_hub_schema.sql` — 4 tabelas: `media_personas` (conta publicável + gate de
  aprovação), `media_assets` (o asset em si), `media_targets` (onde/como cada asset é
  publicado — um asset pode ir pra vários alvos), `media_engagement_snapshots` (métricas
  agregadas por período, nunca tempo real).
- `0002_seed_backfindr_personas.sql` — seed real das 6 personas de nicho do Backfindr (Page
  IDs confirmados ao vivo contra o node do n8n, 31/08/2026) + 3 linhas pendentes do NEXT
  (Jack Chicken, Dona Arlinda, Mestre das Coisas Importantes) sem `account_ref` ainda.
- `0003_add_backfindr_brand_persona.sql` — 7ª persona do Backfindr, nível marca (`backfindr`,
  distinta das 6 de nicho): mesma Página do Facebook já usada por `geral`/`protect`
  (renomeada de "Webjetos Roubados e Perdidos" pra "Backfindr" em 31/08/2026), Instagram
  @backfindroficial confirmado nativamente vinculado a essa Página mas ainda não incluído
  em `default_targets` (decisão em aberto). Completa as 7 personas de referência do
  Backfindr (6 nicho + 1 marca) pra servir de exemplo quando Jack Chicken/Dona
  Arlinda/Mestre tiverem acesso Meta resolvido.

Banco: Postgres (projeto Supabase dedicado, separado do Backfindr — decisão 31/08/2026,
mantém a Central de Mídia desacoplada de um produto só).

## Tipos (`src/types.ts`)

Espelha o schema SQL 1:1. É o contrato de consumo pro workflow n8n generalizado e pra
qualquer produto que vier a integrar diretamente.

## Eventos

Emite no formato de `reencontra-tudo/m2r-events` (`media_generated`, `media_approved`,
`media_rejected`, `media_published`, `media_publish_failed`, `media_engagement_synced`) —
ver `EVENTS.md` daquele repo. `product` no envelope é sempre o dono real da mídia
(`backfindr`, `jack_chicken`, `m2rplace`, ...), nunca um `'media-hub'` fictício.

## Status

- **NOW (30/08/2026):** schema e eventos desenhados e aprovados.
- **NEXT (em andamento, 31/08/2026):** generalizar o workflow n8n do AutoPost pra ler
  `media_personas` em vez de hardcode; adicionar Jack Chicken, Dona Arlinda e Mestre como
  contas publicáveis (pendente de conexão real das páginas); permitir asset de upload
  manual (`media_assets` com `generation_source='manual_upload'`), não só gerado por IA —
  desbloqueia publicar as personas assim que as páginas forem conectadas.
