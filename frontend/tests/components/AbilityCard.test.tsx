import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import AbilityCard from '../../src/components/AbilityCard/AbilityCard'

// Mock ability data
const mockAbilities = {
  critical: {
    id: '550e8400-e29b-41d4-a716-446655440003',
    name: 'Alerting Shrill',
    description: 'Piercing scream that damages all players',
    damageProfile: 'Critical' as const,
    healerAction: 'Use major healing cooldown immediately',
    castTime: 3,
    cooldown: 45,
    isChanneled: false,
    affectedTargets: 5,
  },
  high: {
    id: '550e8400-e29b-41d4-a716-446655440004',
    name: 'Toxic Pools',
    description: 'Creates pools of acid that damage players',
    damageProfile: 'High' as const,
    healerAction: 'Heal damage over time effects',
    castTime: 2,
    cooldown: 30,
    isChanneled: false,
    affectedTargets: 3,
  },
  moderate: {
    id: '550e8400-e29b-41d4-a716-446655440005',
    name: 'Web Bolt',
    description: 'Targeted projectile that hits random players',
    damageProfile: 'Moderate' as const,
    healerAction: 'Spot heal targets',
    castTime: 1,
    cooldown: 8,
    isChanneled: false,
    affectedTargets: 2,
  },
  mechanic: {
    id: '550e8400-e29b-41d4-a716-446655440006',
    name: 'Entangling Webs',
    description: 'Roots players in place',
    damageProfile: 'Mechanic' as const,
    healerAction: 'Dispel if available',
    castTime: 2,
    cooldown: 25,
    isChanneled: false,
    affectedTargets: 4,
  },
}

describe('AbilityCard Component', () => {
  // T020: Component test AbilityCard shows correct color coding
  it('displays Critical damage profile with red color', () => {
    render(<AbilityCard ability={mockAbilities.critical} />)

    const card = screen.getByTestId('ability-card')
    expect(card).toHaveClass('damage-critical')
    expect(screen.getByText('Alerting Shrill')).toBeInTheDocument()
    expect(screen.getByText('Critical')).toBeInTheDocument()
  })

  it('displays High damage profile with orange color', () => {
    render(<AbilityCard ability={mockAbilities.high} />)

    const card = screen.getByTestId('ability-card')
    expect(card).toHaveClass('damage-high')
    expect(screen.getByText('Toxic Pools')).toBeInTheDocument()
    expect(screen.getByText('High')).toBeInTheDocument()
  })

  it('displays Moderate damage profile with yellow color', () => {
    render(<AbilityCard ability={mockAbilities.moderate} />)

    const card = screen.getByTestId('ability-card')
    expect(card).toHaveClass('damage-moderate')
    expect(screen.getByText('Web Bolt')).toBeInTheDocument()
    expect(screen.getByText('Moderate')).toBeInTheDocument()
  })

  it('displays Mechanic damage profile with blue color', () => {
    render(<AbilityCard ability={mockAbilities.mechanic} />)

    const card = screen.getByTestId('ability-card')
    expect(card).toHaveClass('damage-mechanic')
    expect(screen.getByText('Entangling Webs')).toBeInTheDocument()
    expect(screen.getByText('Mechanic')).toBeInTheDocument()
  })

  it('shows ability description and healer action', () => {
    render(<AbilityCard ability={mockAbilities.critical} />)

    expect(screen.getByText('Piercing scream that damages all players')).toBeInTheDocument()
    expect(screen.getByText('Use major healing cooldown immediately')).toBeInTheDocument()
  })

  it('displays cast time and cooldown information', () => {
    render(<AbilityCard ability={mockAbilities.critical} />)

    expect(screen.getByText('Cast: 3s')).toBeInTheDocument()
    expect(screen.getByText('Cooldown: 45s')).toBeInTheDocument()
  })

  it('shows affected targets count', () => {
    render(<AbilityCard ability={mockAbilities.critical} />)

    expect(screen.getByText('Targets: 5')).toBeInTheDocument()
  })

  it('displays instant cast abilities correctly', () => {
    const instantAbility = {
      ...mockAbilities.moderate,
      castTime: 0,
    }

    render(<AbilityCard ability={instantAbility} />)

    expect(screen.getByText('Cast: Instant')).toBeInTheDocument()
  })

  it('shows channeled ability indicator', () => {
    const channeledAbility = {
      ...mockAbilities.high,
      isChanneled: true,
    }

    render(<AbilityCard ability={channeledAbility} />)

    expect(screen.getByText('Channeled')).toBeInTheDocument()
  })

  it('highlights critical abilities with special styling', () => {
    render(<AbilityCard ability={mockAbilities.critical} />)

    const card = screen.getByTestId('ability-card')
    expect(card).toHaveClass('damage-critical')

    // Critical abilities should have bold text or special emphasis
    const abilityName = screen.getByText('Alerting Shrill')
    expect(abilityName).toHaveClass('font-bold')
  })

  it('renders card with proper accessibility attributes', () => {
    render(<AbilityCard ability={mockAbilities.critical} />)

    const card = screen.getByTestId('ability-card')
    expect(card).toHaveAttribute('role', 'article')
    expect(card).toHaveAttribute('aria-label', expect.stringContaining('Alerting Shrill'))
  })
})