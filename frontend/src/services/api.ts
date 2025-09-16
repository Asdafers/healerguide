import axios, { AxiosError } from 'axios'
import type {
  SeasonResponse,
  DungeonResponse,
  BossEncounterResponse,
  AbilityResponse,
  ErrorResponse,
  DamageProfile,
  ApiError,
} from '../types'

// API Client Configuration
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api/v1'

const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ErrorResponse>) => {
    const apiError: ApiError = new Error(
      error.response?.data?.message || error.message || 'An error occurred'
    )
    apiError.status = error.response?.status
    apiError.response = error.response?.data
    throw apiError
  }
)

// Browser detection
export const isChromeSupported = (): boolean => {
  const userAgent = navigator.userAgent

  // Check for Chrome but exclude Edge (which contains "Chrome" in user agent)
  const isChrome = /Chrome/.test(userAgent) && !/Edg/.test(userAgent)

  return isChrome
}

// API Functions

// Seasons
export const getSeasons = async (activeOnly = false): Promise<SeasonResponse[]> => {
  const params = activeOnly ? { active_only: true } : {}
  const response = await apiClient.get<SeasonResponse[]>('/seasons', { params })
  return response.data
}

export const getSeason = async (seasonId: string): Promise<SeasonResponse> => {
  const response = await apiClient.get<SeasonResponse>(`/seasons/${seasonId}`)
  return response.data
}

// Dungeons
export const getDungeons = async (seasonId?: string): Promise<DungeonResponse[]> => {
  if (seasonId) {
    const response = await apiClient.get<DungeonResponse[]>(`/seasons/${seasonId}/dungeons`)
    return response.data
  }

  // If no seasonId, get active season first
  const seasons = await getSeasons(true)
  if (seasons.length === 0) {
    throw new Error('No active season found')
  }

  const response = await apiClient.get<DungeonResponse[]>(`/seasons/${seasons[0].id}/dungeons`)
  return response.data
}

export const getDungeon = async (dungeonId: string): Promise<DungeonResponse> => {
  const response = await apiClient.get<DungeonResponse>(`/dungeons/${dungeonId}`)
  return response.data
}

// Boss Encounters
export const getBossEncounters = async (dungeonId: string): Promise<BossEncounterResponse[]> => {
  const response = await apiClient.get<BossEncounterResponse[]>(`/dungeons/${dungeonId}/bosses`)
  return response.data
}

export const getBossEncounter = async (bossId: string): Promise<BossEncounterResponse> => {
  const response = await apiClient.get<BossEncounterResponse>(`/bosses/${bossId}`)
  return response.data
}

// Abilities
export const getAbilitiesByBoss = async (
  bossId: string,
  damageProfile?: DamageProfile
): Promise<AbilityResponse[]> => {
  const params = damageProfile ? { damage_profile: damageProfile } : {}
  const response = await apiClient.get<AbilityResponse[]>(`/bosses/${bossId}/abilities`, { params })
  return response.data
}

export const getAbility = async (abilityId: string): Promise<AbilityResponse> => {
  const response = await apiClient.get<AbilityResponse>(`/abilities/${abilityId}`)
  return response.data
}

// Health Check
export const getHealthStatus = async (): Promise<{ status: string; database: string }> => {
  const response = await apiClient.get<{ status: string; database: string }>('/health')
  return response.data
}

// Error handler for offline scenarios
export const handleApiError = (error: ApiError): string => {
  if (!navigator.onLine) {
    return 'Connection lost. Please check your internet connection.'
  }

  if (error.status === 404) {
    return 'The requested data was not found.'
  }

  if (error.status === 500) {
    return 'Server error. Please try again later.'
  }

  return error.message || 'An unexpected error occurred.'
}