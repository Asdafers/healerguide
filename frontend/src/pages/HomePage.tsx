import React, { useEffect } from 'react'
import DungeonGrid from '../components/DungeonGrid/DungeonGrid'
import { useSeasons, useOnlineStatus } from '../hooks/useHealerData'

const HomePage: React.FC = () => {
  const { data: seasons, loading, error, refetch } = useSeasons(true) // Get active season only
  const isOnline = useOnlineStatus()

  useEffect(() => {
    // Show offline indicator when connection is lost
    if (!isOnline) {
      console.log('Connection lost - showing offline state')
    }
  }, [isOnline])

  return (
    <div className="home-page">
      {/* Offline Indicator */}
      {!isOnline && (
        <div className="offline-indicator" data-testid="offline-indicator">
          <span className="offline-icon">📡</span>
          <span>Offline</span>
        </div>
      )}

      {/* Connection Required Message for Offline */}
      {!isOnline ? (
        <div className="connection-required">
          <h2>Connection required</h2>
          <p>This feature requires an internet connection.</p>
          <div className="offline-instructions" data-testid="offline-message">
            <ul>
              <li>Check your internet connection</li>
              <li>Try refreshing the page</li>
              <li>Contact support if the problem persists</li>
            </ul>
          </div>
        </div>
      ) : (
        <>
          {/* Season Information */}
          {loading && (
            <div className="season-loading">
              <div className="loading-spinner" />
              <p>Loading season information...</p>
            </div>
          )}

          {error && (
            <div className="season-error">
              <h3>Unable to load season information</h3>
              <p>{error.message}</p>
              <button onClick={refetch} className="retry-button">
                Retry
              </button>
            </div>
          )}

          {seasons && seasons.length > 0 && (
            <div className="season-info">
              <div className="season-badge">
                <span className="season-version">{seasons[0].majorVersion}</span>
                <span className="season-name">{seasons[0].name}</span>
                <span className="season-status">Active</span>
              </div>
            </div>
          )}

          {/* Dungeon Grid */}
          <DungeonGrid seasonId={seasons?.[0]?.id} />

          {/* Healer Tips */}
          <div className="healer-tips">
            <h3>💡 Healer Tips</h3>
            <div className="tips-grid">
              <div className="tip-card">
                <h4>Color Coding</h4>
                <div className="color-legend">
                  <div className="color-item damage-critical">
                    <span className="color-dot"></span>
                    <span>Critical - Immediate action required</span>
                  </div>
                  <div className="color-item damage-high">
                    <span className="color-dot"></span>
                    <span>High - Significant healing needed</span>
                  </div>
                  <div className="color-item damage-moderate">
                    <span className="color-dot"></span>
                    <span>Moderate - Standard response</span>
                  </div>
                  <div className="color-item damage-mechanic">
                    <span className="color-dot"></span>
                    <span>Mechanic - Positioning/utility focus</span>
                  </div>
                </div>
              </div>
              <div className="tip-card">
                <h4>Using This Guide</h4>
                <ul>
                  <li>Click any dungeon to view boss encounters</li>
                  <li>Focus on Critical abilities first</li>
                  <li>Check positioning notes for each fight</li>
                  <li>Plan cooldown usage with your team</li>
                </ul>
              </div>
            </div>
          </div>
        </>
      )}
    </div>
  )
}

export default HomePage