import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen } from '@testing-library/react'
import ErrorBoundary from '../../src/components/ErrorBoundary/ErrorBoundary'

// Mock user agent detection
const mockUserAgent = vi.fn()

Object.defineProperty(window.navigator, 'userAgent', {
  get: () => mockUserAgent(),
  configurable: true,
})

// Test component that throws an error
const ThrowError = ({ shouldThrow }: { shouldThrow: boolean }) => {
  if (shouldThrow) {
    throw new Error('Test error')
  }
  return <div>No error</div>
}

describe('ErrorBoundary Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  // T022: Component test ErrorBoundary handles browser detection
  it('detects Chrome browser and renders children normally', () => {
    mockUserAgent.mockReturnValue('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')

    render(
      <ErrorBoundary>
        <div>Chrome content</div>
      </ErrorBoundary>
    )

    expect(screen.getByText('Chrome content')).toBeInTheDocument()
    expect(screen.queryByText(/browser not supported/i)).not.toBeInTheDocument()
  })

  it('detects Firefox browser and shows warning message', () => {
    mockUserAgent.mockReturnValue('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0')

    render(
      <ErrorBoundary>
        <div>Firefox content</div>
      </ErrorBoundary>
    )

    expect(screen.getByText(/browser not supported/i)).toBeInTheDocument()
    expect(screen.getByText(/please use Chrome/i)).toBeInTheDocument()
    expect(screen.queryByText('Firefox content')).not.toBeInTheDocument()
  })

  it('detects Safari browser and shows warning message', () => {
    mockUserAgent.mockReturnValue('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15')

    render(
      <ErrorBoundary>
        <div>Safari content</div>
      </ErrorBoundary>
    )

    expect(screen.getByText(/browser not supported/i)).toBeInTheDocument()
    expect(screen.getByText(/please use Chrome/i)).toBeInTheDocument()
    expect(screen.queryByText('Safari content')).not.toBeInTheDocument()
  })

  it('detects Edge browser and shows warning message', () => {
    mockUserAgent.mockReturnValue('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0')

    render(
      <ErrorBoundary>
        <div>Edge content</div>
      </ErrorBoundary>
    )

    expect(screen.getByText(/browser not supported/i)).toBeInTheDocument()
    expect(screen.getByText(/please use Chrome/i)).toBeInTheDocument()
    expect(screen.queryByText('Edge content')).not.toBeInTheDocument()
  })

  it('catches JavaScript errors and displays error boundary', () => {
    mockUserAgent.mockReturnValue('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')

    // Suppress error output in test
    const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {})

    render(
      <ErrorBoundary>
        <ThrowError shouldThrow={true} />
      </ErrorBoundary>
    )

    expect(screen.getByText(/something went wrong/i)).toBeInTheDocument()
    expect(screen.getByText(/please refresh the page/i)).toBeInTheDocument()
    expect(screen.queryByText('No error')).not.toBeInTheDocument()

    consoleSpy.mockRestore()
  })

  it('renders children normally when no error occurs', () => {
    mockUserAgent.mockReturnValue('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')

    render(
      <ErrorBoundary>
        <ThrowError shouldThrow={false} />
      </ErrorBoundary>
    )

    expect(screen.getByText('No error')).toBeInTheDocument()
    expect(screen.queryByText(/something went wrong/i)).not.toBeInTheDocument()
  })

  it('displays browser warning with proper styling', () => {
    mockUserAgent.mockReturnValue('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0')

    render(
      <ErrorBoundary>
        <div>Content</div>
      </ErrorBoundary>
    )

    const warning = screen.getByTestId('browser-warning')
    expect(warning).toHaveClass('browser-warning')
    expect(warning).toBeInTheDocument()
  })

  it('includes link to Chrome download in browser warning', () => {
    mockUserAgent.mockReturnValue('Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0')

    render(
      <ErrorBoundary>
        <div>Content</div>
      </ErrorBoundary>
    )

    const chromeLink = screen.getByRole('link', { name: /download Chrome/i })
    expect(chromeLink).toHaveAttribute('href', 'https://www.google.com/chrome/')
    expect(chromeLink).toHaveAttribute('target', '_blank')
  })

  it('handles unknown browsers gracefully', () => {
    mockUserAgent.mockReturnValue('Unknown Browser/1.0')

    render(
      <ErrorBoundary>
        <div>Unknown browser content</div>
      </ErrorBoundary>
    )

    expect(screen.getByText(/browser not supported/i)).toBeInTheDocument()
    expect(screen.getByText(/please use Chrome/i)).toBeInTheDocument()
  })

  it('detects Chrome variants correctly', () => {
    // Test Chromium
    mockUserAgent.mockReturnValue('Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')

    render(
      <ErrorBoundary>
        <div>Chromium content</div>
      </ErrorBoundary>
    )

    expect(screen.getByText('Chromium content')).toBeInTheDocument()
    expect(screen.queryByText(/browser not supported/i)).not.toBeInTheDocument()
  })
})