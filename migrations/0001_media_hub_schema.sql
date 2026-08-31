-- 0001_media_hub_schema.sql
-- Central de Mídia — esquema canônico de asset, aprovação e distribuição
-- multi-plataforma. Generaliza o motor n8n do AutoPost do Backfindr (hoje
-- hardcoded pra Facebook/Instagram de 6 nichos) pra qualquer produto/persona
-- M2RPrime. Design completo: reencontra-tudo/m2rintelligence
-- docs/media_hub_proposal.md (aprovado por Marcos em 30/08/2026).
--
-- Engine: Postgres (Supabase). Segue o mesmo estilo tabular já usado em
-- object_events.sql (Backfindr) e drizzle/schema.ts (m2rintelligence).

create extension if not exists pgcrypto;

-- ─── media_personas ─────────────────────────────────────────────────────────
-- Onde mora o gate de aprovação por conta publicável. Generaliza o
-- mapeamento nicho→Page ID hoje hardcoded dentro do node do n8n.
create table if not exists media_personas (
  persona_slug      text primary key,
  -- Nullable de propósito: personas de voz (Mestre, Dona Arlinda) ainda não
  -- têm produto/plataforma confirmado — nunca inventar o dado, deixar
  -- explicitamente pendente até Marcos decidir (ver seed 0002).
  product_slug      text,
  display_name      text not null,
  requires_approval boolean not null default false,
  default_targets   jsonb not null default '[]'::jsonb,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

comment on table media_personas is
  'Uma linha = uma conta publicável (produto/persona). requires_approval: default false pra páginas de nicho automáticas (baixo risco, conteúdo repetitivo por design); default true pra personas de voz (tom sensível, exige revisão humana). default_targets: [{ platform, placement, accountRef, aspectRatio }] — generaliza o Page ID hardcoded no node de publicação.';

-- ─── media_assets ───────────────────────────────────────────────────────────
create table if not exists media_assets (
  id                     uuid primary key default gen_random_uuid(),
  product_slug           text not null,
  persona_slug           text references media_personas(persona_slug),
  category               text not null,
  media_type             text not null check (media_type in ('image', 'video')),
  generation_source      text not null,
  storage_bucket         text not null,
  storage_key            text not null,
  checksum_sha256        text,
  width_px               integer,
  height_px              integer,
  duration_seconds       numeric,
  status                 text not null default 'generated'
                           check (status in ('generated', 'approved', 'rejected', 'published', 'publish_failed', 'metrics_collected')),
  created_by_actor_type  text not null check (created_by_actor_type in ('user', 'system', 'bot')),
  created_by_actor_id    text,
  correlation_id         text,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

comment on table media_assets is
  'O asset em si. product_slug/persona_slug identificam o dono real da mídia (nunca um "media-hub" fictício). storage_key convenção: {product_slug}/{persona_slug|"_"}/{category}/{id}.{ext} — generaliza o padrão já provado do app Backfindr ({folder}/{entityId}/...).';

create index if not exists media_assets_product_slug_idx on media_assets(product_slug);
create index if not exists media_assets_persona_slug_idx on media_assets(persona_slug);
create index if not exists media_assets_status_idx on media_assets(status);
create index if not exists media_assets_checksum_idx on media_assets(checksum_sha256);

-- ─── media_targets ──────────────────────────────────────────────────────────
-- Um asset pode ir pra vários lugares, com formato/conta diferentes por
-- plataforma — é literalmente o que o AutoPost já faz hoje entre Facebook e
-- Instagram, só que sem registrar isso em lugar nenhum.
create table if not exists media_targets (
  id                     uuid primary key default gen_random_uuid(),
  media_asset_id         uuid not null references media_assets(id) on delete cascade,
  platform               text not null,
  placement              text not null,
  account_ref            text not null,
  aspect_ratio           text,
  max_duration_seconds   numeric,
  caption                text,
  hashtags               jsonb not null default '[]'::jsonb,
  status                 text not null default 'pending'
                           check (status in ('pending', 'published', 'failed')),
  external_post_id       text,
  published_at           timestamptz,
  last_error             text,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now()
);

comment on table media_targets is
  'account_ref = Page ID / IG user ID / TikTok Shop ID — hoje hardcoded no node do n8n, aqui vira dado. platform: facebook | instagram | tiktok | tiktok_shop | ... placement: feed | stories | reels | shop_video | ...';

create index if not exists media_targets_media_asset_id_idx on media_targets(media_asset_id);
create index if not exists media_targets_platform_account_idx on media_targets(platform, account_ref);
create index if not exists media_targets_status_idx on media_targets(status);

-- ─── media_engagement_snapshots ─────────────────────────────────────────────
-- Sempre agregado e periódico — nunca modelar como se fosse tempo real
-- quando a fonte só expõe agregados por período (mesmo princípio já
-- registrado em m2r-events/EVENTS.md sobre ad_metrics_synced).
create table if not exists media_engagement_snapshots (
  id                uuid primary key default gen_random_uuid(),
  media_target_id   uuid not null references media_targets(id) on delete cascade,
  impressions       integer,
  reach             integer,
  likes             integer,
  comments          integer,
  shares            integer,
  clicks            integer,
  period_start      timestamptz not null,
  period_end        timestamptz not null,
  synced_at         timestamptz not null default now()
);

create index if not exists media_engagement_snapshots_target_idx on media_engagement_snapshots(media_target_id);
create index if not exists media_engagement_snapshots_period_idx on media_engagement_snapshots(period_start, period_end);

-- ─── updated_at triggers (mesmo padrão de manutenção simples) ──────────────
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists media_personas_set_updated_at on media_personas;
create trigger media_personas_set_updated_at
  before update on media_personas
  for each row execute function set_updated_at();

drop trigger if exists media_assets_set_updated_at on media_assets;
create trigger media_assets_set_updated_at
  before update on media_assets
  for each row execute function set_updated_at();

drop trigger if exists media_targets_set_updated_at on media_targets;
create trigger media_targets_set_updated_at
  before update on media_targets
  for each row execute function set_updated_at();
