import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import PrivateRoute from './components/PrivateRoute'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import TicketList from './pages/TicketList'
import CreateTicket from './pages/CreateTicket'
import TicketDetails from './pages/TicketDetails'
import AgentManagement from './pages/AgentManagement'

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/"
            element={
              <PrivateRoute>
                <Dashboard />
              </PrivateRoute>
            }
          >
            <Route index element={<Navigate to="/tickets" replace />} />
            <Route path="tickets" element={<TicketList />} />
            <Route path="tickets/create" element={<CreateTicket />} />
            <Route path="tickets/:id" element={<TicketDetails />} />
            <Route path="agents" element={<AgentManagement />} />
          </Route>
        </Routes>
      </Router>
    </AuthProvider>
  )
}

export default App

