-- 0002_seed_backfindr_personas.sql
-- Seed real das 6 personas do Backfindr (extraído ao vivo do workflow n8n
-- "Backfindr AutoPost — Facebook", id urluPuyxe4ccY9ZE, via MCP, 31/08/2026)
-- + 3 linhas pendentes pro NEXT (Jack Chicken, Dona Arlinda, Mestre das
-- Coisas Importantes) — sem page_id/account_id ainda, ficam null/pendente
-- até as contas serem conectadas. Ver Task 2 do NEXT pra lista exata do que
-- falta por conta.

-- ─── Backfindr — 6 personas reais, já publicando em produção ───────────────
-- requires_approval = false: páginas de nicho automáticas, baixo risco,
-- conteúdo repetitivo por design (decisão 1 da proposta, 30/08/2026).

insert into media_personas (persona_slug, product_slug, display_name, requires_approval, default_targets)
values
  ('backfindr-pet', 'backfindr', 'Backfindr — Pet', false, '[
    { "platform": "facebook", "placement": "feed", "accountRef": "1058341297366140", "aspectRatio": "1:1" },
    { "platform": "instagram", "placement": "feed", "accountRef": "17841416288148947", "aspectRatio": "4:5" }
  ]'::jsonb),
  ('backfindr-celular', 'backfindr', 'Backfindr — Celular', false, '[
    { "platform": "facebook", "placement": "feed", "accountRef": "472039546624261", "aspectRatio": "1:1" },
    { "platform": "instagram", "placement": "feed", "accountRef": "17841416288148947", "aspectRatio": "4:5" }
  ]'::jsonb),
  ('backfindr-veiculo', 'backfindr', 'Backfindr — Veículo', false, '[
    { "platform": "facebook", "placement": "feed", "accountRef": "607774492681517", "aspectRatio": "1:1" },
    { "platform": "instagram", "placement": "feed", "accountRef": "17841416288148947", "aspectRatio": "4:5" }
  ]'::jsonb),
  ('backfindr-bicicleta', 'backfindr', 'Backfindr — Bicicleta', false, '[
    { "platform": "facebook", "placement": "feed", "accountRef": "301459970061606", "aspectRatio": "1:1" },
    { "platform": "instagram", "placement": "feed", "accountRef": "17841416288148947", "aspectRatio": "4:5" }
  ]'::jsonb),
  ('backfindr-geral', 'backfindr', 'Backfindr — Geral', false, '[
    { "platform": "facebook", "placement": "feed", "accountRef": "229182413876628", "aspectRatio": "1:1" },
    { "platform": "instagram", "placement": "feed", "accountRef": "17841416288148947", "aspectRatio": "4:5" }
  ]'::jsonb),
  -- protect compartilha a mesma Page do Facebook de "geral" e NÃO entra no
  -- Instagram (excluído pelo nó If do workflow original).
  ('backfindr-protect', 'backfindr', 'Backfindr — Protect', false, '[
    { "platform": "facebook", "placement": "feed", "accountRef": "229182413876628", "aspectRatio": "1:1" }
  ]'::jsonb)
on conflict (persona_slug) do update set
  product_slug      = excluded.product_slug,
  display_name      = excluded.display_name,
  requires_approval = excluded.requires_approval,
  default_targets   = excluded.default_targets;

-- ─── NEXT — contas pendentes de conexão (Task 2 do NEXT) ────────────────────
-- default_targets fica '[]' (vazio) até Marcos conectar as páginas reais —
-- nunca inventar page_id/account_id. requires_approval segue a mesma regra
-- já decidida: false pra empresa/produto, true pra persona de voz.

insert into media_personas (persona_slug, product_slug, display_name, requires_approval, default_targets)
values
  -- Empresa — falta só Facebook (Instagram já existe, ID ainda não levantado)
  ('jack-chicken', 'jack_chicken', 'Jack Chicken', false, '[]'::jsonb),
  -- Personas de voz — tom sensível, aprovação humana obrigatória.
  -- product_slug fica NULL de propósito: produto/plataforma ainda não
  -- identificado (ver docs/media_hub_proposal.md §2.2) — não inventar.
  ('dona-arlinda', null, 'Dona Arlinda', true, '[]'::jsonb),
  ('mestre', null, 'Mestre das Coisas Importantes', true, '[]'::jsonb)
on conflict (persona_slug) do nothing;
