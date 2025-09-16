import React, { useState } from 'react'
import { useBossDetail } from '../../hooks/useHealerData'
import AbilityCard from '../AbilityCard/AbilityCard'
import { DamageProfile, type BossDetailProps } from '../../types'
import './BossDetail.css'

const BossDetail: React.FC<BossDetailProps> = ({ bossId, damageProfileFilter }) => {
  const [selectedFilter, setSelectedFilter] = useState<DamageProfile | undefined>(damageProfileFilter)
  const { boss, abilities, loading, error, refetch } = useBossDetail(bossId, selectedFilter)

  if (loading) {
    return (
      <div className="boss-detail-loading">
        <div className="loading-spinner" />
        <p>Loading boss encounter...</p>
      </div>
    )
  }

  if (error) {
    return (
      <div className="boss-detail-error">
        <h3>Error loading boss encounter</h3>
        <p>{error.message}</p>
        <button onClick={refetch} className="retry-button">
          Retry
        </button>
      </div>
    )
  }

  if (!boss.data || !abilities.data) {
    return (
      <div className="boss-detail-empty">
        <h3>Boss encounter not found</h3>
        <p>The requested boss encounter could not be found.</p>
      </div>
    )
  }

  const bossData = boss.data
  const abilitiesData = abilities.data

  const handleFilterChange = (filter: DamageProfile | undefined) => {
    setSelectedFilter(filter)
  }

  const getDamageProfileCounts = () => {
    const counts = {
      [DamageProfile.Critical]: 0,
      [DamageProfile.High]: 0,
      [DamageProfile.Moderate]: 0,
      [DamageProfile.Mechanic]: 0,
    }

    abilitiesData.forEach((ability) => {
      counts[ability.damageProfile]++
    })

    return counts
  }

  const damageProfileCounts = getDamageProfileCounts()

  return (
    <div className="boss-detail-container">
      <div className="boss-header">
        <div className="boss-title">
          <h1>{bossData.name}</h1>
          <span className="boss-order">Boss {bossData.orderIndex}</span>
        </div>
        <div className="boss-stats">
          <span className="ability-count">{bossData.abilityCount} abilities</span>
        </div>
      </div>

      <div className="boss-content">
        {/* Healer Information Section */}
        <div className="healer-info-section">
          <h2>Healer Information</h2>

          {bossData.healingSummary && (
            <div className="info-card">
              <h3>Healing Summary</h3>
              <p>{bossData.healingSummary}</p>
            </div>
          )}

          {bossData.positioning && (
            <div className="info-card">
              <h3>Positioning</h3>
              <p>{bossData.positioning}</p>
            </div>
          )}

          {bossData.cooldownPriority && (
            <div className="info-card">
              <h3>Cooldown Priority</h3>
              <p>{bossData.cooldownPriority}</p>
            </div>
          )}
        </div>

        {/* Abilities Section */}
        <div className="abilities-section">
          <div className="abilities-header">
            <h2>Abilities</h2>

            {/* Damage Profile Filter */}
            <div className="damage-profile-filters">
              <button
                className={`filter-button ${!selectedFilter ? 'active' : ''}`}
                onClick={() => handleFilterChange(undefined)}
              >
                All ({abilitiesData.length})
              </button>
              {Object.entries(damageProfileCounts).map(([profile, count]) => (
                <button
                  key={profile}
                  className={`filter-button damage-${profile.toLowerCase()} ${
                    selectedFilter === profile ? 'active' : ''
                  }`}
                  onClick={() => handleFilterChange(profile as DamageProfile)}
                  disabled={count === 0}
                >
                  {profile} ({count})
                </button>
              ))}
            </div>
          </div>

          {abilitiesData.length === 0 ? (
            <div className="no-abilities">
              <p>No abilities found for the selected filter.</p>
            </div>
          ) : (
            <div className="abilities-grid">
              {abilitiesData
                .sort((a, b) => {
                  // Sort by damage profile priority: Critical > High > Moderate > Mechanic
                  const priorityOrder = {
                    [DamageProfile.Critical]: 4,
                    [DamageProfile.High]: 3,
                    [DamageProfile.Moderate]: 2,
                    [DamageProfile.Mechanic]: 1,
                  }
                  return priorityOrder[b.damageProfile] - priorityOrder[a.damageProfile]
                })
                .map((ability) => (
                  <AbilityCard key={ability.id} ability={ability} />
                ))}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default BossDetail