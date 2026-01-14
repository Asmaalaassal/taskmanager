import { Outlet, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

const Dashboard = () => {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="flex">
        {/* Sidebar */}
        <aside className="w-64 bg-white shadow-lg min-h-screen">
          <div className="p-6">
            <h1 className="text-2xl font-bold text-gray-800 mb-8">
              Ticket Manager
            </h1>
            <nav className="space-y-2">
              <button
                onClick={() => navigate('/tickets')}
                className="w-full text-left px-4 py-2 rounded-lg hover:bg-blue-50 text-gray-700 hover:text-blue-600 transition"
              >
                Tickets
              </button>
              {(user?.role === 'ADMIN' || user?.role === 'USER') && (
                <button
                  onClick={() => navigate('/tickets/create')}
                  className="w-full text-left px-4 py-2 rounded-lg hover:bg-blue-50 text-gray-700 hover:text-blue-600 transition"
                >
                  Create Ticket
                </button>
              )}
              {user?.role === 'ADMIN' && (
                <button
                  onClick={() => navigate('/agents')}
                  className="w-full text-left px-4 py-2 rounded-lg hover:bg-blue-50 text-gray-700 hover:text-blue-600 transition"
                >
                  Manage Agents
                </button>
              )}
            </nav>
          </div>
          <div className="absolute bottom-0 w-64 p-6 border-t">
            <div className="mb-4">
              <p className="text-sm font-medium text-gray-700">{user?.name}</p>
              <p className="text-xs text-gray-500">{user?.email}</p>
              <span className="inline-block mt-2 px-2 py-1 text-xs font-semibold rounded bg-blue-100 text-blue-800">
                {user?.role}
              </span>
            </div>
            <button
              onClick={handleLogout}
              className="w-full px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition"
            >
              Logout
            </button>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 p-8">
          <Outlet />
        </main>
      </div>
    </div>
  )
}

export default Dashboard

