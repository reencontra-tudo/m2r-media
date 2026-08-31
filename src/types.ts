// m2r-media — tipos TypeScript espelhando o schema de
// migrations/0001_media_hub_schema.sql. Fonte única de verdade do formato;
// o SQL é a implementação, este arquivo é o contrato de consumo.

export type MediaType = 'image' | 'video';

export type MediaAssetStatus =
  | 'generated'
  | 'approved'
  | 'rejected'
  | 'published'
  | 'publish_failed'
  | 'metrics_collected';

export type MediaTargetStatus = 'pending' | 'published' | 'failed';

export type MediaActorType = 'user' | 'system' | 'bot';

export interface MediaPersona {
  personaSlug: string;
  /** Nullable de propósito: personas de voz sem produto confirmado ainda (ver 0002_seed). */
  productSlug: string | null;
  displayName: string;
  requiresApproval: boolean;
  defaultTargets: MediaTargetSpec[];
  createdAt: string;
  updatedAt: string;
}

/** Um alvo de publicação padrão de uma persona — generaliza o Page ID hardcoded no node do n8n. */
export interface MediaTargetSpec {
  platform: string;
  placement: string;
  accountRef: string;
  aspectRatio?: string;
}

export interface MediaAsset {
  id: string;
  productSlug: string;
  personaSlug: string | null;
  category: string;
  mediaType: MediaType;
  /** 'manual_upload' | 'ai:gpt-image-1' | 'ai:flow' | 'ai:veo' | 'ai:capcut' | 'stock' | ... */
  generationSource: string;
  storageBucket: string;
  /** Convenção: {productSlug}/{personaSlug|"_"}/{category}/{id}.{ext} */
  storageKey: string;
  checksumSha256?: string;
  widthPx?: number;
  heightPx?: number;
  durationSeconds?: number;
  status: MediaAssetStatus;
  createdByActorType: MediaActorType;
  createdByActorId?: string;
  /** ID de execução do n8n (ou processo gerador), pra rastrear origem sem depender de log externo. */
  correlationId?: string;
  createdAt: string;
  updatedAt: string;
}

export interface MediaTarget {
  id: string;
  mediaAssetId: string;
  platform: string;
  placement: string;
  accountRef: string;
  aspectRatio?: string;
  maxDurationSeconds?: number;
  caption?: string;
  hashtags: string[];
  status: MediaTargetStatus;
  externalPostId?: string;
  publishedAt?: string;
  lastError?: string;
  createdAt: string;
  updatedAt: string;
}

export interface MediaEngagementSnapshot {
  id: string;
  mediaTargetId: string;
  impressions?: number;
  reach?: number;
  likes?: number;
  comments?: number;
  shares?: number;
  clicks?: number;
  periodStart: string;
  periodEnd: string;
  syncedAt: string;
}
