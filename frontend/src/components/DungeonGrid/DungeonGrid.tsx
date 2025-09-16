import React from 'react'
import { Link } from 'react-router-dom'
import { useDungeons } from '../../hooks/useHealerData'
import type { DungeonGridProps } from '../../types'
import './DungeonGrid.css'

const DungeonGrid: React.FC<DungeonGridProps> = ({ seasonId }) => {
  const { data: dungeons, loading, error, refetch } = useDungeons(seasonId)

  if (loading) {
    return (
      <div className="dungeon-grid-loading">
        <div className="loading-spinner" />
        <p>Loading dungeons...</p>
      </div>
    )
  }

  if (error) {
    return (
      <div className="dungeon-grid-error">
        <h3>Error loading dungeons</h3>
        <p>{error.message}</p>
        <button onClick={refetch} className="retry-button">
          Retry
        </button>
      </div>
    )
  }

  if (!dungeons || dungeons.length === 0) {
    return (
      <div className="dungeon-grid-empty">
        <h3>No dungeons found</h3>
        <p>No dungeons are available for the current season.</p>
      </div>
    )
  }

  return (
    <div className="dungeon-grid-container">
      <h2>The War Within Season Dungeons</h2>
      <div className="grid grid-cols-4" data-testid="dungeon-grid">
        {dungeons.map((dungeon) => (
          <Link
            key={dungeon.id}
            to={`/dungeon/${dungeon.id}`}
            className="dungeon-card card"
            aria-label={`View details for ${dungeon.name}`}
          >
            <div className="dungeon-card-header">
              <h3 className="dungeon-name">{dungeon.name}</h3>
              <span className="dungeon-short-name">({dungeon.shortName})</span>
            </div>

            <div className="dungeon-stats">
              <div className="stat">
                <span className="stat-value">{dungeon.estimatedDuration} min</span>
                <span className="stat-label">Duration</span>
              </div>
              <div className="stat">
                <span className="stat-value">{dungeon.bossCount} bosses</span>
                <span className="stat-label">Encounters</span>
              </div>
            </div>

            <div className="difficulty-rating">
              <span className="difficulty-label">Difficulty: {dungeon.difficultyRating}</span>
              <div className="difficulty-stars">
                {Array.from({ length: 5 }, (_, i) => (
                  <span
                    key={i}
                    className={`star ${i < dungeon.difficultyRating ? 'filled' : 'empty'}`}
                  >
                    ★
                  </span>
                ))}
              </div>
            </div>

            {dungeon.healerNotes && (
              <div className="healer-notes">
                <p>{dungeon.healerNotes}</p>
              </div>
            )}

            <div className="card-footer">
              <span className="view-details">View Details →</span>
            </div>
          </Link>
        ))}
      </div>
    </div>
  )
}

export default DungeonGrid