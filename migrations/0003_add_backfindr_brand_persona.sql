-- 0003_add_backfindr_brand_persona.sql
-- Adiciona a persona de marca "backfindr" (nível empresa, distinta das 6 personas de
-- nicho já semeadas em 0002). A página do Facebook por trás dela já existia e já
-- publicava em produção — não é um alvo novo, é o mesmo Page ID hoje usado pelo AutoPost
-- para as personas 'geral' e 'protect' (era a página "Webjetos Roubados e Perdidos",
-- renomeada para "Backfindr" em 31/08/2026 — ver BACKFINDR.md seção 19, sessão 31/08).
--
-- Confirmado ao vivo (31/08/2026): o Instagram @backfindroficial está nativamente
-- vinculado a essa mesma Página do Facebook (via "Turbinar post do Instagram" no painel
-- da própria Página — mostra os posts reais do @backfindroficial). Mesmo assim,
-- default_targets aqui só tem Facebook de propósito: adicionar Instagram é decisão
-- separada, ainda não tomada.
--
-- Token de acesso dessa página NÃO foi gerado/tocado nesta migration — fica marcado
-- para uma sessão de segurança futura, junto aos outros 5 tokens Meta já catalogados
-- em BACKFINDR.md §17 (🔴 Alto).

insert into media_personas (persona_slug, product_slug, display_name, requires_approval, default_targets)
values (
  'backfindr',
  'backfindr',
  'Backfindr — Marca',
  false,
  '[
    { "platform": "facebook", "placement": "feed", "accountRef": "229182413876628", "aspectRatio": "1:1" }
  ]'::jsonb
)
on conflict (persona_slug) do update set
  product_slug      = excluded.product_slug,
  display_name      = excluded.display_name,
  requires_approval = excluded.requires_approval,
  default_targets   = excluded.default_targets;
