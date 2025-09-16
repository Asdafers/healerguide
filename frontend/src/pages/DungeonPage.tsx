import React from 'react'
import { useParams, Link } from 'react-router-dom'
import { useApi } from '../hooks/useHealerData'
import { getDungeon, getBossEncounters } from '../services/api'
import type { DungeonResponse, BossEncounterResponse } from '../types'

const DungeonPage: React.FC = () => {
  const { id } = useParams<{ id: string }>()

  const { data: dungeon, loading: dungeonLoading, error: dungeonError } = useApi(
    () => getDungeon(id!),
    [id]
  )

  const { data: bosses, loading: bossesLoading, error: bossesError } = useApi(
    () => getBossEncounters(id!),
    [id]
  )

  if (!id) {
    return (
      <div className="dungeon-page-error">
        <h2>Invalid dungeon</h2>
        <p>No dungeon ID provided.</p>
        <Link to="/" className="back-button">
          ← Back to Dungeons
        </Link>
      </div>
    )
  }

  if (dungeonLoading || bossesLoading) {
    return (
      <div className="dungeon-page-loading">
        <div className="loading-spinner" />
        <p>Loading dungeon details...</p>
      </div>
    )
  }

  if (dungeonError || bossesError) {
    const error = dungeonError || bossesError
    return (
      <div className="dungeon-page-error">
        <h2>Error loading dungeon</h2>
        <p>{error?.message}</p>
        <Link to="/" className="back-button">
          ← Back to Dungeons
        </Link>
      </div>
    )
  }

  if (!dungeon || !bosses) {
    return (
      <div className="dungeon-page-error">
        <h2>Dungeon not found</h2>
        <p>The requested dungeon could not be found.</p>
        <Link to="/" className="back-button">
          ← Back to Dungeons
        </Link>
      </div>
    )
  }

  return (
    <div className="dungeon-page">
      {/* Navigation */}
      <nav className="breadcrumb">
        <Link to="/" className="breadcrumb-link">
          Dungeons
        </Link>
        <span className="breadcrumb-separator">›</span>
        <span className="breadcrumb-current">{dungeon.shortName}</span>
      </nav>

      {/* Dungeon Header */}
      <div className="dungeon-header">
        <div className="dungeon-title">
          <h1>{dungeon.name}</h1>
          <div className="dungeon-metadata">
            <span className="duration">{dungeon.estimatedDuration} minutes</span>
            <span className="difficulty">
              Difficulty: {dungeon.difficultyRating}/5
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
            </span>
            <span className="boss-count">{dungeon.bossCount} bosses</span>
          </div>
        </div>

        {dungeon.healerNotes && (
          <div className="dungeon-healer-notes">
            <h3>⚕️ Healer Notes</h3>
            <p>{dungeon.healerNotes}</p>
          </div>
        )}
      </div>

      {/* Boss Encounters */}
      <div className="boss-encounters-section">
        <h2>Boss Encounters</h2>
        <div className="boss-encounters-grid">
          {bosses
            .sort((a, b) => a.orderIndex - b.orderIndex)
            .map((boss) => (
              <Link
                key={boss.id}
                to={`/boss/${boss.id}`}
                className="boss-encounter-card card"
              >
                <div className="boss-encounter-header">
                  <h3>{boss.name}</h3>
                  <span className="boss-order">Boss {boss.orderIndex}</span>
                </div>

                {boss.healingSummary && (
                  <div className="healing-summary">
                    <h4>Healing Summary</h4>
                    <p>{boss.healingSummary}</p>
                  </div>
                )}

                <div className="boss-stats">
                  <span className="ability-count">{boss.abilityCount} abilities</span>
                </div>

                <div className="card-footer">
                  <span className="view-details">View Boss Details →</span>
                </div>
              </Link>
            ))}
        </div>
      </div>
    </div>
  )
}

export default DungeonPage