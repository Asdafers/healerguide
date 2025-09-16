import React from 'react'
import { useParams, Link } from 'react-router-dom'
import BossDetail from '../components/BossDetail/BossDetail'

const BossPage: React.FC = () => {
  const { id } = useParams<{ id: string }>()

  if (!id) {
    return (
      <div className="boss-page-error">
        <h2>Invalid boss encounter</h2>
        <p>No boss encounter ID provided.</p>
        <Link to="/" className="back-button">
          ← Back to Dungeons
        </Link>
      </div>
    )
  }

  return (
    <div className="boss-page">
      {/* Navigation */}
      <nav className="breadcrumb">
        <Link to="/" className="breadcrumb-link">
          Dungeons
        </Link>
        <span className="breadcrumb-separator">›</span>
        <span className="breadcrumb-current">Boss Encounter</span>
      </nav>

      {/* Boss Detail Component */}
      <BossDetail bossId={id} />
    </div>
  )
}

export default BossPage