import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import axios from 'axios'

const TicketList = () => {
  const [tickets, setTickets] = useState([])
  const [problemTypes, setProblemTypes] = useState([])
  const [loading, setLoading] = useState(true)
  const [filters, setFilters] = useState({
    status: '',
    priority: '',
    problemTypeId: '',
    isPublic: '',
  })
  const { user } = useAuth()
  const navigate = useNavigate()

  useEffect(() => {
    fetchProblemTypes()
    fetchTickets()
  }, [])

  useEffect(() => {
    fetchTickets()
  }, [filters])

  const fetchProblemTypes = async () => {
    try {
      const response = await axios.get('http://localhost:8085/api/problem-types')
      setProblemTypes(response.data)
    } catch (error) {
      console.error('Failed to fetch problem types:', error)
    }
  }

  const fetchTickets = async () => {
    try {
      const params = new URLSearchParams()
      if (filters.status) params.append('status', filters.status)
      if (filters.priority) params.append('priority', filters.priority)
      if (filters.problemTypeId) params.append('problemTypeId', filters.problemTypeId)
      if (filters.isPublic !== '') params.append('isPublic', filters.isPublic)

      const response = await axios.get(`http://localhost:8085/api/tickets?${params.toString()}`)
      setTickets(response.data)
    } catch (error) {
      console.error('Failed to fetch tickets:', error)
    } finally {
      setLoading(false)
    }
  }

  const getStatusColor = (status) => {
    switch (status) {
      case 'OPEN':
        return 'bg-green-100 text-green-800'
      case 'IN_PROGRESS':
        return 'bg-yellow-100 text-yellow-800'
      case 'CLOSED':
        return 'bg-gray-100 text-gray-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'HIGH':
        return 'bg-red-100 text-red-800'
      case 'MEDIUM':
        return 'bg-orange-100 text-orange-800'
      case 'LOW':
        return 'bg-blue-100 text-blue-800'
      default:
        return 'bg-gray-100 text-gray-800'
    }
  }

  if (loading) {
    return <div className="text-center py-8">Loading tickets...</div>
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-3xl font-bold text-gray-800">Tickets</h2>
        {(user?.role === 'ADMIN' || user?.role === 'USER') && (
          <button
            onClick={() => navigate('/tickets/create')}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
          >
            Create Ticket
          </button>
        )}
      </div>

      <div className="bg-white rounded-lg shadow p-4 mb-6">
        <h3 className="text-lg font-semibold mb-4">Filters</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Status</label>
            <select
              value={filters.status}
              onChange={(e) => setFilters({ ...filters, status: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg"
            >
              <option value="">All</option>
              <option value="OPEN">Open</option>
              <option value="IN_PROGRESS">In Progress</option>
              <option value="CLOSED">Closed</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Priority</label>
            <select
              value={filters.priority}
              onChange={(e) => setFilters({ ...filters, priority: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg"
            >
              <option value="">All</option>
              <option value="LOW">Low</option>
              <option value="MEDIUM">Medium</option>
              <option value="HIGH">High</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Problem Type</label>
            <select
              value={filters.problemTypeId}
              onChange={(e) => setFilters({ ...filters, problemTypeId: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg"
            >
              <option value="">All</option>
              {problemTypes.map((type) => (
                <option key={type.id} value={type.id}>
                  {type.name}
                </option>
              ))}
            </select>
          </div>
          {user?.role === 'ADMIN' && (
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">Visibility</label>
              <select
                value={filters.isPublic}
                onChange={(e) => setFilters({ ...filters, isPublic: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg"
              >
                <option value="">All</option>
                <option value="true">Public</option>
                <option value="false">Private</option>
              </select>
            </div>
          )}
        </div>
      </div>

      {tickets.length === 0 ? (
        <div className="bg-white rounded-lg shadow p-8 text-center text-gray-500">
          No tickets found
        </div>
      ) : (
        <div className="grid gap-4">
          {tickets.map((ticket) => (
            <div
              key={ticket.id}
              onClick={() => navigate(`/tickets/${ticket.id}`)}
              className="bg-white rounded-lg shadow p-6 hover:shadow-lg transition cursor-pointer"
            >
              <div className="flex justify-between items-start mb-4">
                <h3 className="text-xl font-semibold text-gray-800">
                  {ticket.title}
                </h3>
                <div className="flex gap-2">
                  <span
                    className={`px-3 py-1 rounded-full text-xs font-semibold ${getStatusColor(
                      ticket.status
                    )}`}
                  >
                    {ticket.status}
                  </span>
                  <span
                    className={`px-3 py-1 rounded-full text-xs font-semibold ${getPriorityColor(
                      ticket.priority
                    )}`}
                  >
                    {ticket.priority}
                  </span>
                </div>
              </div>
              <p className="text-gray-600 mb-4 line-clamp-2">
                {ticket.description}
              </p>
              <div className="flex justify-between items-center text-sm text-gray-500">
                <div>
                  <span>Created by: {ticket.createdBy.name}</span>
                  {ticket.assignedTo && (
                    <span className="ml-4">Assigned to: {ticket.assignedTo.name}</span>
                  )}
                </div>
                <div className="flex gap-2 items-center">
                  {ticket.problemType && (
                    <span className="px-2 py-1 bg-purple-100 text-purple-800 rounded text-xs">
                      {ticket.problemType.name}
                    </span>
                  )}
                  {ticket.isPublic ? (
                    <span className="px-2 py-1 bg-green-100 text-green-800 rounded text-xs">Public</span>
                  ) : (
                    <span className="px-2 py-1 bg-gray-100 text-gray-800 rounded text-xs">Private</span>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}

export default TicketList

