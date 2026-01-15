import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import api from '../api/axios'

const TicketDetails = () => {
  const { id } = useParams()
  const { user } = useAuth()
  const navigate = useNavigate()
  const [ticket, setTicket] = useState(null)
  const [loading, setLoading] = useState(true)
  const [updating, setUpdating] = useState(false)
  const [assigning, setAssigning] = useState(false)
  const [status, setStatus] = useState('')
  const [priority, setPriority] = useState('')
  const [agentId, setAgentId] = useState('')
  const [agents, setAgents] = useState([])
  const [replyContent, setReplyContent] = useState('')
  const [submittingReply, setSubmittingReply] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    fetchTicket()
    if (user?.role === 'ADMIN') {
      fetchAgents()
    }
  }, [id, user])

  const fetchTicket = async () => {
    try {
      const response = await api.get(`/tickets/${id}`)
      setTicket(response.data)
      setStatus(response.data.status)
      setPriority(response.data.priority)
    } catch (error) {
      console.error('Failed to fetch ticket:', error)
      setError('Failed to load ticket')
    } finally {
      setLoading(false)
    }
  }

  const fetchAgents = async () => {
    try {
      // In a real app, you'd have an endpoint to fetch all agents
      // For now, we'll handle assignment differently
    } catch (error) {
      console.error('Failed to fetch agents:', error)
    }
  }

  const handleUpdate = async () => {
    setUpdating(true)
    setError('')
    try {
      const response = await api.put(`/tickets/${id}`, {
        status,
        priority,
      })
      setTicket(response.data)
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to update ticket')
    } finally {
      setUpdating(false)
    }
  }

  const handleAssign = async () => {
    if (!agentId) {
      setError('Please select an agent')
      return
    }
    setAssigning(true)
    setError('')
    try {
      const response = await api.put(`/tickets/${id}/assign`, {
        agentId: parseInt(agentId),
      })
      setTicket(response.data)
      setAgentId('')
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to assign ticket')
    } finally {
      setAssigning(false)
    }
  }

  const handleDelete = async () => {
    if (!window.confirm('Are you sure you want to delete this ticket?')) {
      return
    }
    try {
      await api.delete(`/tickets/${id}`)
      navigate('/tickets')
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to delete ticket')
    }
  }

  const handleSubmitReply = async () => {
    if (!replyContent.trim()) {
      setError('Reply content cannot be empty')
      return
    }
    setSubmittingReply(true)
    setError('')
    try {
      await api.post(`/tickets/${id}/replies`, {
        content: replyContent,
      })
      setReplyContent('')
      fetchTicket() // Refresh ticket to get updated replies
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to submit reply')
    } finally {
      setSubmittingReply(false)
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
    return <div className="text-center py-8">Loading ticket...</div>
  }

  if (!ticket) {
    return <div className="text-center py-8 text-red-600">Ticket not found</div>
  }

  return (
    <div className="max-w-4xl mx-auto">
      <div className="flex justify-between items-center mb-6">
        <button
          onClick={() => navigate('/tickets')}
          className="text-blue-600 hover:text-blue-800"
        >
          ← Back to Tickets
        </button>
        {user?.role === 'ADMIN' && (
          <button
            onClick={handleDelete}
            className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition"
          >
            Delete Ticket
          </button>
        )}
      </div>

      <div className="bg-white rounded-lg shadow p-6 mb-6">
        <div className="flex justify-between items-start mb-4">
          <h2 className="text-3xl font-bold text-gray-800">{ticket.title}</h2>
          <div className="flex gap-2">
            <span
              className={`px-3 py-1 rounded-full text-sm font-semibold ${getStatusColor(
                ticket.status
              )}`}
            >
              {ticket.status}
            </span>
            <span
              className={`px-3 py-1 rounded-full text-sm font-semibold ${getPriorityColor(
                ticket.priority
              )}`}
            >
              {ticket.priority}
            </span>
          </div>
        </div>

        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-700 mb-2">Description</h3>
          <p className="text-gray-600 whitespace-pre-wrap">{ticket.description}</p>
        </div>

        <div className="grid grid-cols-2 gap-4 text-sm text-gray-600 mb-6">
          <div>
            <span className="font-semibold">Created by:</span> {ticket.createdBy.name}
          </div>
          <div>
            <span className="font-semibold">Assigned to:</span>{' '}
            {ticket.assignedTo ? ticket.assignedTo.name : 'Unassigned'}
          </div>
          <div>
            <span className="font-semibold">Created at:</span>{' '}
            {new Date(ticket.createdAt).toLocaleString()}
          </div>
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-4">
            {error}
          </div>
        )}

        <div className="border-t pt-6 space-y-4">
          <h3 className="text-lg font-semibold text-gray-700">Update Ticket</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Status
              </label>
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="OPEN">Open</option>
                <option value="IN_PROGRESS">In Progress</option>
                <option value="CLOSED">Closed</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Priority
              </label>
              <select
                value={priority}
                onChange={(e) => setPriority(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="LOW">Low</option>
                <option value="MEDIUM">Medium</option>
                <option value="HIGH">High</option>
              </select>
            </div>
          </div>
          <button
            onClick={handleUpdate}
            disabled={updating}
            className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition"
          >
            {updating ? 'Updating...' : 'Update Ticket'}
          </button>
        </div>

        {user?.role === 'ADMIN' && (
          <div className="border-t pt-6 mt-6">
            <h3 className="text-lg font-semibold text-gray-700 mb-4">Assign to Agent</h3>
            <div className="flex gap-4">
              <input
                type="number"
                value={agentId}
                onChange={(e) => setAgentId(e.target.value)}
                placeholder="Agent ID"
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
              <button
                onClick={handleAssign}
                disabled={assigning || !agentId}
                className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition"
              >
                {assigning ? 'Assigning...' : 'Assign'}
              </button>
            </div>
            <p className="text-xs text-gray-500 mt-2">
              Note: Enter the agent's user ID to assign this ticket
            </p>
          </div>
        )}

        {/* Replies Section */}
        <div className="border-t pt-6 mt-6">
          <h3 className="text-lg font-semibold text-gray-700 mb-4">
            Replies ({ticket.replies?.length || 0})
          </h3>

          {/* Replies List */}
          <div className="space-y-4 mb-6">
            {ticket.replies && ticket.replies.length > 0 ? (
              ticket.replies.map((reply) => (
                <div key={reply.id} className="bg-gray-50 rounded-lg p-4">
                  <div className="flex justify-between items-start mb-2">
                    <div>
                      <span className="font-semibold text-gray-800">{reply.user.name}</span>
                      <span className="text-xs text-gray-500 ml-2">
                        ({reply.user.role})
                      </span>
                    </div>
                    <span className="text-xs text-gray-500">
                      {new Date(reply.createdAt).toLocaleString()}
                    </span>
                  </div>
                  <p className="text-gray-700 whitespace-pre-wrap">{reply.content}</p>
                </div>
              ))
            ) : (
              <p className="text-gray-500 text-center py-4">No replies yet</p>
            )}
          </div>

          {/* Reply Form */}
          <div className="border-t pt-4">
            <h4 className="text-md font-semibold text-gray-700 mb-3">Add a Reply</h4>
            <textarea
              value={replyContent}
              onChange={(e) => setReplyContent(e.target.value)}
              placeholder="Write your reply..."
              rows={4}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent mb-3"
            />
            <button
              onClick={handleSubmitReply}
              disabled={submittingReply || !replyContent.trim()}
              className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition"
            >
              {submittingReply ? 'Submitting...' : 'Submit Reply'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default TicketDetails

