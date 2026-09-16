-- 0004_events.sql
-- Tabela `events` da Central de Mídia.
--
-- Por que existe: o objetivo declarado do projeto (media_hub_proposal.md §4.2)
-- tem DOIS pilares — "todo estado que hoje só existe dentro do n8n vira dado
-- consultável" E "cada transição de status vira um evento no formato que o
-- resto da casa já usa". As migrações 0001-0003 entregaram o primeiro pilar;
-- o segundo não existia: o workflow escrevia em media_assets/media_targets e
-- não emitia evento nenhum, então o M2R Intelligence não recebia nada.
--
-- Por que aqui e não na tabela de outro produto: m2r-events/EVENTS.md §1 é
-- explícito — "não existe (ainda) um coletor central de eventos. Cada produto
-- grava os eventos na PRÓPRIA tabela `events` do seu banco". A Central de
-- Mídia é um produto/serviço próprio, com banco próprio, então grava aqui.
--
-- Atenção ao campo `product`: NÃO é 'media-hub'. É sempre o dono real da
-- mídia ('backfindr', 'jack_chicken', 'm2rplace'...), conforme a decisão 4
-- fechada em 30/08/2026 — é o que permite ao M2R Intelligence agregar por
-- produto. A proveniência de que foi a Central de Mídia quem emitiu fica em
-- `metadata`. Consequência prática: só personas com `product_slug` definido
-- podem emitir; as personas de voz (Mestre, Dona Arlinda) têm product_slug
-- nulo e default_targets vazio, então hoje não publicam nem emitem.
--
-- Formato: espelha o envelope M2REvent de m2r-events/src/types.ts. Segue o
-- mesmo conjunto de colunas que o M2RAds já grava em server/lib/events.ts
-- (recordEvent) — não inventa uma quinta convenção. `created_at` é o campo
-- `timestamp` do envelope; o nome segue object_events.sql (Backfindr) e as
-- demais tabelas deste schema.

create extension if not exists pgcrypto;

create table if not exists events (
  id           uuid primary key default gen_random_uuid(),
  type         text not null,
  product      text not null,
  entity_type  text,
  entity_id    text,
  actor_type   text not null check (actor_type in ('user', 'system', 'bot')),
  actor_id     text,
  payload      jsonb not null default '{}'::jsonb,
  metadata     jsonb not null default '{}'::jsonb,
  created_at   timestamptz not null default now()
);

comment on table events is
  'Eventos no formato m2r-events emitidos pela Central de Mídia. `product` = dono real da mídia, nunca "media-hub" (decisão 4, 30/08/2026). `type` fica sem CHECK de propósito: a lista canônica vive em m2r-events/src/types.ts e um CHECK aqui viraria uma segunda fonte de verdade que envelhece sozinha. Eventos são imutáveis — sem updated_at nem trigger.';

comment on column events.entity_type is
  'media_asset | media_target — qual entidade o evento descreve.';
comment on column events.metadata is
  'Proveniência e contexto: { emitter: "m2r-media", workflowId, executionId, personaSlug }.';

create index if not exists events_type_created_at_idx on events(type, created_at desc);
create index if not exists events_product_created_at_idx on events(product, created_at desc);
create index if not exists events_entity_idx on events(entity_type, entity_id);
