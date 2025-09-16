import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import DungeonGrid from '../../src/components/DungeonGrid/DungeonGrid'

// Mock the API service
vi.mock('../../src/services/api', () => ({
  getDungeons: vi.fn(),
}))

// Mock data
const mockDungeons = [
  {
    id: '550e8400-e29b-41d4-a716-446655440001',
    name: 'Ara-Kara, City of Echoes',
    shortName: 'Ara-Kara',
    healerNotes: 'Focus on spread positioning for echoing abilities',
    estimatedDuration: 35,
    difficultyRating: 3,
    bossCount: 3,
  },
  {
    id: '550e8400-e29b-41d4-a716-446655440007',
    name: 'The Stonevault',
    shortName: 'Stonevault',
    healerNotes: 'Heavy physical damage phases',
    estimatedDuration: 40,
    difficultyRating: 4,
    bossCount: 4,
  },
]

const renderWithRouter = (component: React.ReactElement) => {
  return render(<BrowserRouter>{component}</BrowserRouter>)
}

describe('DungeonGrid Component', () => {
  // T019: Component test DungeonGrid renders dungeon list
  it('renders dungeon list with correct information', async () => {
    const { getDungeons } = await import('../../src/services/api')
    vi.mocked(getDungeons).mockResolvedValue(mockDungeons)

    renderWithRouter(<DungeonGrid />)

    // Wait for dungeons to load
    await waitFor(() => {
      expect(screen.getByText('Ara-Kara, City of Echoes')).toBeInTheDocument()
    })

    // Check all dungeons are displayed
    expect(screen.getByText('Ara-Kara, City of Echoes')).toBeInTheDocument()
    expect(screen.getByText('The Stonevault')).toBeInTheDocument()

    // Check dungeon details
    expect(screen.getByText('35 min')).toBeInTheDocument()
    expect(screen.getByText('40 min')).toBeInTheDocument()
    expect(screen.getByText('3 bosses')).toBeInTheDocument()
    expect(screen.getByText('4 bosses')).toBeInTheDocument()
  })

  it('displays loading state while fetching dungeons', () => {
    const { getDungeons } = vi.mocked(require('../../src/services/api'))
    getDungeons.mockImplementation(() => new Promise(() => {})) // Never resolves

    renderWithRouter(<DungeonGrid />)

    expect(screen.getByText('Loading dungeons...')).toBeInTheDocument()
  })

  it('displays error state when API call fails', async () => {
    const { getDungeons } = await import('../../src/services/api')
    vi.mocked(getDungeons).mockRejectedValue(new Error('API Error'))

    renderWithRouter(<DungeonGrid />)

    await waitFor(() => {
      expect(screen.getByText(/Error loading dungeons/)).toBeInTheDocument()
    })
  })

  it('renders responsive grid layout', async () => {
    const { getDungeons } = await import('../../src/services/api')
    vi.mocked(getDungeons).mockResolvedValue(mockDungeons)

    renderWithRouter(<DungeonGrid />)

    await waitFor(() => {
      const grid = screen.getByTestId('dungeon-grid')
      expect(grid).toHaveClass('grid')
    })
  })

  it('shows difficulty rating with correct styling', async () => {
    const { getDungeons } = await import('../../src/services/api')
    vi.mocked(getDungeons).mockResolvedValue(mockDungeons)

    renderWithRouter(<DungeonGrid />)

    await waitFor(() => {
      // Check difficulty ratings are displayed
      const difficulty3 = screen.getByText('Difficulty: 3')
      const difficulty4 = screen.getByText('Difficulty: 4')

      expect(difficulty3).toBeInTheDocument()
      expect(difficulty4).toBeInTheDocument()
    })
  })

  it('displays healer notes for each dungeon', async () => {
    const { getDungeons } = await import('../../src/services/api')
    vi.mocked(getDungeons).mockResolvedValue(mockDungeons)

    renderWithRouter(<DungeonGrid />)

    await waitFor(() => {
      expect(screen.getByText('Focus on spread positioning for echoing abilities')).toBeInTheDocument()
      expect(screen.getByText('Heavy physical damage phases')).toBeInTheDocument()
    })
  })
})