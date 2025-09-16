// API Response Types
export interface SeasonResponse {
  id: string
  majorVersion: string
  name: string
  isActive: boolean
  dungeonCount: number
}

export interface DungeonResponse {
  id: string
  name: string
  shortName: string
  healerNotes?: string
  estimatedDuration: number
  difficultyRating: number
  bossCount: number
}

export interface BossEncounterResponse {
  id: string
  name: string
  healingSummary?: string
  positioning?: string
  cooldownPriority?: string
  orderIndex: number
  abilityCount: number
}

export interface AbilityResponse {
  id: string
  name: string
  description?: string
  damageProfile: DamageProfile
  healerAction?: string
  castTime: number
  cooldown: number
  isChanneled: boolean
  affectedTargets: number
}

export enum DamageProfile {
  Critical = 'Critical',
  High = 'High',
  Moderate = 'Moderate',
  Mechanic = 'Mechanic',
}

export interface ErrorResponse {
  error: string
  message: string
  details?: Record<string, string>
}

// Component Props Types
export interface DungeonGridProps {
  seasonId?: string
}

export interface AbilityCardProps {
  ability: AbilityResponse
  compact?: boolean
}

export interface BossDetailProps {
  bossId: string
  damageProfileFilter?: DamageProfile
}

export interface ErrorBoundaryProps {
  children: React.ReactNode
  fallback?: React.ComponentType<{ error: Error }>
}

// Hook Types
export interface UseApiState<T> {
  data: T | null
  loading: boolean
  error: Error | null
  refetch: () => Promise<void>
}

// Utility Types
export type ApiEndpoint =
  | 'seasons'
  | 'dungeons'
  | 'bosses'
  | 'abilities'

export interface ApiError extends Error {
  status?: number
  response?: ErrorResponse
}