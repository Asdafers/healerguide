import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import BossDetail from '../../src/components/BossDetail/BossDetail'

// Mock the API service
vi.mock('../../src/services/api', () => ({
  getBossEncounter: vi.fn(),
  getAbilitiesByBoss: vi.fn(),
}))

// Mock data
const mockBossEncounter = {
  id: '550e8400-e29b-41d4-a716-446655440002',
  name: 'Avanoxx',
  healingSummary: 'Heavy raid damage during web phases requires major cooldowns',
  positioning: 'Stay spread for web mechanics, center for add phases',
  cooldownPriority: 'Save major cooldowns for Alerting Shrill phases',
  orderIndex: 1,
  abilityCount: 4,
}

const mockAbilities = [
  {
    id: '550e8400-e29b-41d4-a716-446655440003',
    name: 'Alerting Shrill',
    description: 'Piercing scream that damages all players',
    damageProfile: 'Critical',
    healerAction: 'Use major healing cooldown immediately',
    castTime: 3,
    cooldown: 45,
    isChanneled: false,
    affectedTargets: 5,
  },
  {
    id: '550e8400-e29b-41d4-a716-446655440004',
    name: 'Toxic Pools',
    description: 'Creates pools of acid that damage players',
    damageProfile: 'High',
    healerAction: 'Heal damage over time effects',
    castTime: 2,
    cooldown: 30,
    isChanneled: false,
    affectedTargets: 3,
  },
]

const renderWithRouter = (component: React.ReactElement) => {
  return render(<BrowserRouter>{component}</BrowserRouter>)
}

describe('BossDetail Component', () => {
  // T021: Component test BossDetail displays encounter information
  it('displays boss encounter information correctly', async () => {
    const { getBossEncounter, getAbilitiesByBoss } = await import('../../src/services/api')
    vi.mocked(getBossEncounter).mockResolvedValue(mockBossEncounter)
    vi.mocked(getAbilitiesByBoss).mockResolvedValue(mockAbilities)

    renderWithRouter(<BossDetail bossId="550e8400-e29b-41d4-a716-446655440002" />)

    await waitFor(() => {
      expect(screen.getByText('Avanoxx')).toBeInTheDocument()
    })

    // Check healer-specific information
    expect(screen.getByText('Heavy raid damage during web phases requires major cooldowns')).toBeInTheDocument()
    expect(screen.getByText('Stay spread for web mechanics, center for add phases')).toBeInTheDocument()
    expect(screen.getByText('Save major cooldowns for Alerting Shrill phases')).toBeInTheDocument()
  })

  it('displays boss abilities with color coding', async () => {
    const { getBossEncounter, getAbilitiesByBoss } = await import('../../src/services/api')
    vi.mocked(getBossEncounter).mockResolvedValue(mockBossEncounter)
    vi.mocked(getAbilitiesByBoss).mockResolvedValue(mockAbilities)

    renderWithRouter(<BossDetail bossId="550e8400-e29b-41d4-a716-446655440002" />)

    await waitFor(() => {
      expect(screen.getByText('Alerting Shrill')).toBeInTheDocument()
    })

    // Check abilities are displayed
    expect(screen.getByText('Alerting Shrill')).toBeInTheDocument()
    expect(screen.getByText('Toxic Pools')).toBeInTheDocument()

    // Check damage profiles are shown
    expect(screen.getByText('Critical')).toBeInTheDocument()
    expect(screen.getByText('High')).toBeInTheDocument()
  })

  it('shows loading state while fetching data', () => {
    const { getBossEncounter, getAbilitiesByBoss } = vi.mocked(require('../../src/services/api'))
    getBossEncounter.mockImplementation(() => new Promise(() => {}))
    getAbilitiesByBoss.mockImplementation(() => new Promise(() => {}))

    renderWithRouter(<BossDetail bossId="550e8400-e29b-41d4-a716-446655440002" />)

    expect(screen.getByText('Loading boss encounter...')).toBeInTheDocument()
  })

  it('displays error state when API calls fail', async () => {
    const { getBossEncounter, getAbilitiesByBoss } = await import('../../src/services/api')
    vi.mocked(getBossEncounter).mockRejectedValue(new Error('API Error'))
    vi.mocked(getAbilitiesByBoss).mockRejectedValue(new Error('API Error'))

    renderWithRouter(<BossDetail bossId="550e8400-e29b-41d4-a716-446655440002" />)

    await waitFor(() => {
      expect(screen.getByText(/Error loading boss encounter/)).toBeInTheDocument()
    })
  })

  it('organizes healer information into clear sections', async () => {
    const { getBossEncounter, getAbilitiesByBoss } = await import('../../src/services/api')
    vi.mocked(getBossEncounter).mockResolvedValue(mockBossEncounter)
    vi.mocked(getAbilitiesByBoss).mockResolvedValue(mockAbilities)

    renderWithRouter(<BossDetail bossId="550e8400-e29b-41d4-a716-446655440002" />)

    await waitFor(() => {
      expect(screen.getByText('Healing Summary')).toBeInTheDocument()
    })

    // Check section headings
    expect(screen.getByText('Healing Summary')).toBeInTheDocument()
    expect(screen.getByText('Positioning')).toBeInTheDocument()
    expect(screen.getByText('Cooldown Priority')).toBeInTheDocument()
    expect(screen.getByText('Abilities')).toBeInTheDocument()
  })

  it('filters abilities by damage profile when requested', async () => {
    const { getBossEncounter, getAbilitiesByBoss } = await import('../../src/services/api')
    vi.mocked(getBossEncounter).mockResolvedValue(mockBossEncounter)
    vi.mocked(getAbilitiesByBoss).mockResolvedValue([mockAbilities[0]]) // Only critical

    renderWithRouter(
      <BossDetail
        bossId="550e8400-e29b-41d4-a716-446655440002"
        damageProfileFilter="Critical"
      />
    )

    await waitFor(() => {
      expect(screen.getByText('Alerting Shrill')).toBeInTheDocument()
    })

    // Should only show critical abilities
    expect(screen.getByText('Alerting Shrill')).toBeInTheDocument()
    expect(screen.queryByText('Toxic Pools')).not.toBeInTheDocument()
  })

  it('highlights critical abilities for healer attention', async () => {
    const { getBossEncounter, getAbilitiesByBoss } = await import('../../src/services/api')
    vi.mocked(getBossEncounter).mockResolvedValue(mockBossEncounter)
    vi.mocked(getAbilitiesByBoss).mockResolvedValue(mockAbilities)

    renderWithRouter(<BossDetail bossId="550e8400-e29b-41d4-a716-446655440002" />)

    await waitFor(() => {
      const criticalAbility = screen.getByTestId('ability-card-550e8400-e29b-41d4-a716-446655440003')
      expect(criticalAbility).toHaveClass('damage-critical')
    })
  })

  it('displays boss order index', async () => {
    const { getBossEncounter, getAbilitiesByBoss } = await import('../../src/services/api')
    vi.mocked(getBossEncounter).mockResolvedValue(mockBossEncounter)
    vi.mocked(getAbilitiesByBoss).mockResolvedValue(mockAbilities)

    renderWithRouter(<BossDetail bossId="550e8400-e29b-41d4-a716-446655440002" />)

    await waitFor(() => {
      expect(screen.getByText('Boss 1')).toBeInTheDocument()
    })
  })
})