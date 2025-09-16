import { useState, useEffect, useCallback } from 'react'
import type {
  SeasonResponse,
  DungeonResponse,
  BossEncounterResponse,
  AbilityResponse,
  UseApiState,
  DamageProfile,
} from '../types'
import {
  getSeasons,
  getDungeons,
  getBossEncounter,
  getAbilitiesByBoss,
  handleApiError,
} from '../services/api'

// Generic API hook
export function useApi<T>(
  apiCall: () => Promise<T>,
  dependencies: unknown[] = []
): UseApiState<T> {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  const fetchData = useCallback(async () => {
    try {
      setLoading(true)
      setError(null)
      const result = await apiCall()
      setData(result)
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error')
      setError(error)
      console.error('API call failed:', handleApiError(error))
    } finally {
      setLoading(false)
    }
  }, dependencies)

  useEffect(() => {
    fetchData()
  }, [fetchData])

  const refetch = useCallback(async () => {
    await fetchData()
  }, [fetchData])

  return { data, loading, error, refetch }
}

// Specific hooks for healer data

export function useSeasons(activeOnly = false): UseApiState<SeasonResponse[]> {
  return useApi(() => getSeasons(activeOnly), [activeOnly])
}

export function useDungeons(seasonId?: string): UseApiState<DungeonResponse[]> {
  return useApi(() => getDungeons(seasonId), [seasonId])
}

export function useBossEncounter(bossId: string): UseApiState<BossEncounterResponse> {
  return useApi(() => getBossEncounter(bossId), [bossId])
}

export function useAbilities(
  bossId: string,
  damageProfile?: DamageProfile
): UseApiState<AbilityResponse[]> {
  return useApi(() => getAbilitiesByBoss(bossId, damageProfile), [bossId, damageProfile])
}

// Combined hook for boss detail page
export function useBossDetail(bossId: string, damageProfileFilter?: DamageProfile) {
  const bossResult = useBossEncounter(bossId)
  const abilitiesResult = useAbilities(bossId, damageProfileFilter)

  return {
    boss: bossResult,
    abilities: abilitiesResult,
    loading: bossResult.loading || abilitiesResult.loading,
    error: bossResult.error || abilitiesResult.error,
    refetch: async () => {
      await Promise.all([bossResult.refetch(), abilitiesResult.refetch()])
    },
  }
}

// Hook for offline detection
export function useOnlineStatus() {
  const [isOnline, setIsOnline] = useState(navigator.onLine)

  useEffect(() => {
    const handleOnline = () => setIsOnline(true)
    const handleOffline = () => setIsOnline(false)

    window.addEventListener('online', handleOnline)
    window.addEventListener('offline', handleOffline)

    return () => {
      window.removeEventListener('online', handleOnline)
      window.removeEventListener('offline', handleOffline)
    }
  }, [])

  return isOnline
}