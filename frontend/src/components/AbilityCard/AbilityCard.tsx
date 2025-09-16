import React from 'react'
import { DamageProfile, type AbilityCardProps } from '../../types'
import './AbilityCard.css'

const AbilityCard: React.FC<AbilityCardProps> = ({ ability, compact = false }) => {
  const getDamageProfileClass = (profile: DamageProfile): string => {
    switch (profile) {
      case DamageProfile.Critical:
        return 'damage-critical'
      case DamageProfile.High:
        return 'damage-high'
      case DamageProfile.Moderate:
        return 'damage-moderate'
      case DamageProfile.Mechanic:
        return 'damage-mechanic'
      default:
        return 'damage-moderate'
    }
  }

  const formatCastTime = (castTime: number): string => {
    return castTime === 0 ? 'Instant' : `${castTime}s`
  }

  const getDamageProfileLabel = (profile: DamageProfile): string => {
    return profile
  }

  const cardClasses = [
    'ability-card',
    'card',
    getDamageProfileClass(ability.damageProfile),
    compact ? 'compact' : '',
    ability.damageProfile === DamageProfile.Critical ? 'critical-emphasis' : '',
  ]
    .filter(Boolean)
    .join(' ')

  return (
    <div
      className={cardClasses}
      data-testid={`ability-card${ability.id ? `-${ability.id}` : ''}`}
      role="article"
      aria-label={`${ability.name} - ${ability.damageProfile} damage ability`}
    >
      <div className="ability-header">
        <h4 className={`ability-name ${ability.damageProfile === DamageProfile.Critical ? 'font-bold' : ''}`}>
          {ability.name}
        </h4>
        <span className={`damage-profile-badge ${getDamageProfileClass(ability.damageProfile)}`}>
          {getDamageProfileLabel(ability.damageProfile)}
        </span>
      </div>

      {ability.description && !compact && (
        <p className="ability-description">{ability.description}</p>
      )}

      <div className="ability-stats">
        <div className="stat-row">
          <div className="stat-item">
            <span className="stat-label">Cast:</span>
            <span className="stat-value">{formatCastTime(ability.castTime)}</span>
          </div>
          <div className="stat-item">
            <span className="stat-label">Cooldown:</span>
            <span className="stat-value">{ability.cooldown}s</span>
          </div>
          <div className="stat-item">
            <span className="stat-label">Targets:</span>
            <span className="stat-value">{ability.affectedTargets}</span>
          </div>
        </div>

        {ability.isChanneled && (
          <div className="ability-modifier">
            <span className="channeled-indicator">Channeled</span>
          </div>
        )}
      </div>

      {ability.healerAction && (
        <div className="healer-action">
          <div className="healer-action-header">
            <span className="healer-icon">⚕️</span>
            <span className="healer-label">Healer Action</span>
          </div>
          <p className="healer-action-text">{ability.healerAction}</p>
        </div>
      )}

      {ability.damageProfile === DamageProfile.Critical && (
        <div className="critical-warning">
          <span className="warning-icon">⚠️</span>
          <span className="warning-text">Immediate action required!</span>
        </div>
      )}
    </div>
  )
}

export default AbilityCard