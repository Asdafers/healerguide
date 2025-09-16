import React from 'react'
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import HomePage from './pages/HomePage'
import DungeonPage from './pages/DungeonPage'
import BossPage from './pages/BossPage'
import ErrorBoundary from './components/ErrorBoundary/ErrorBoundary'
import './App.css'

function App() {
  return (
    <ErrorBoundary>
      <Router>
        <div className="App">
          <header className="App-header">
            <h1>HealerKit - Chrome Web App</h1>
          </header>
          <main>
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/dungeon/:id" element={<DungeonPage />} />
              <Route path="/boss/:id" element={<BossPage />} />
            </Routes>
          </main>
        </div>
      </Router>
    </ErrorBoundary>
  )
}

export default App