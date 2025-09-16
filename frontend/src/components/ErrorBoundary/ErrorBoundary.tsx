import React, { Component, ErrorInfo, ReactNode } from 'react'
import { isChromeSupported } from '../../services/api'
import type { ErrorBoundaryProps } from '../../types'
import './ErrorBoundary.css'

interface State {
  hasError: boolean
  error?: Error
}

class ErrorBoundary extends Component<ErrorBoundaryProps, State> {
  constructor(props: ErrorBoundaryProps) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return {
      hasError: true,
      error,
    }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo)
  }

  componentDidMount() {
    // Check browser compatibility on mount
    if (!isChromeSupported()) {
      // Don't set error state, just render browser warning
      this.forceUpdate()
    }
  }

  render(): ReactNode {
    // Check browser support first
    if (!isChromeSupported()) {
      return (
        <div className="browser-warning-container">
          <div className="browser-warning" data-testid="browser-warning" role="alert">
            <div className="warning-icon">
              <span>🚫</span>
            </div>
            <div className="warning-content">
              <h2>Browser not supported</h2>
              <p>
                This application is designed specifically for Chrome browser.
                Please use Chrome for the best healer experience.
              </p>
              <div className="browser-actions">
                <a
                  href="https://www.google.com/chrome/"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="download-button"
                >
                  Download Chrome
                </a>
                <button
                  onClick={() => window.location.reload()}
                  className="reload-button"
                >
                  I'm using Chrome - Reload
                </button>
              </div>
              <div className="browser-details">
                <details>
                  <summary>Why Chrome only?</summary>
                  <p>
                    HealerKit is optimized for Chrome to ensure consistent performance,
                    reliable color-coded ability recognition, and proper healer workflow
                    functionality during Mythic+ encounters.
                  </p>
                </details>
              </div>
            </div>
          </div>
        </div>
      )
    }

    // If there's a JavaScript error, render error boundary
    if (this.state.hasError) {
      if (this.props.fallback) {
        const FallbackComponent = this.props.fallback
        return <FallbackComponent error={this.state.error!} />
      }

      return (
        <div className="error-boundary-container">
          <div className="error-boundary-content">
            <div className="error-icon">
              <span>⚠️</span>
            </div>
            <div className="error-details">
              <h2>Something went wrong</h2>
              <p>
                An unexpected error occurred while loading the healer interface.
                Please refresh the page to continue.
              </p>
              <div className="error-actions">
                <button
                  onClick={() => window.location.reload()}
                  className="reload-button primary"
                >
                  Refresh Page
                </button>
                <button
                  onClick={() => this.setState({ hasError: false, error: undefined })}
                  className="retry-button secondary"
                >
                  Try Again
                </button>
              </div>
              {process.env.NODE_ENV === 'development' && this.state.error && (
                <details className="error-debug">
                  <summary>Debug Information</summary>
                  <pre>{this.state.error.stack}</pre>
                </details>
              )}
            </div>
          </div>
        </div>
      )
    }

    // No errors, render children normally
    return this.props.children
  }
}

export default ErrorBoundary