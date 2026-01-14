import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import axios from 'axios'

const AgentManagement = () => {
  const [agents, setAgents] = useState([])
  const [problemTypes, setProblemTypes] = useState([])
  const [loading, setLoading] = useState(true)
  const [showCreateForm, setShowCreateForm] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    specializationIds: [],
  })
  const [error, setError] = useState('')
  const [submitting, setSubmitting] = useState(false)
  const navigate = useNavigate()

  useEffect(() => {
    fetchAgents()
    fetchProblemTypes()
  }, [])

  const fetchAgents = async () => {
    try {
      const response = await axios.get('http://localhost:8085/api/agents')
      setAgents(response.data)
    } catch (error) {
      console.error('Failed to fetch agents:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchProblemTypes = async () => {
    try {
      const response = await axios.get('http://localhost:8085/api/problem-types')
      setProblemTypes(response.data)
    } catch (error) {
      console.error('Failed to fetch problem types:', error)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setSubmitting(true)

    try {
      await axios.post('http://localhost:8085/api/agents', formData)
      setShowCreateForm(false)
      setFormData({ name: '', email: '', password: '', specializationIds: [] })
      fetchAgents()
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to create agent')
    } finally {
      setSubmitting(false)
    }
  }

  const toggleSpecialization = (id) => {
    setFormData((prev) => ({
      ...prev,
      specializationIds: prev.specializationIds.includes(id)
        ? prev.specializationIds.filter((sid) => sid !== id)
        : [...prev.specializationIds, id],
    }))
  }

  if (loading) {
    return <div className="text-center py-8">Loading agents...</div>
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-3xl font-bold text-gray-800">Agent Management</h2>
        <button
          onClick={() => setShowCreateForm(!showCreateForm)}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
        >
          {showCreateForm ? 'Cancel' : 'Create Agent'}
        </button>
      </div>

      {showCreateForm && (
        <div className="bg-white rounded-lg shadow p-6 mb-6">
          <h3 className="text-xl font-semibold mb-4">Create New Agent</h3>
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-4">
              {error}
            </div>
          )}
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Name
                </label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Email
                </label>
                <input
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  required
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Password
              </label>
              <input
                type="password"
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Specializations
              </label>
              <div className="grid grid-cols-2 gap-2">
                {problemTypes.map((type) => (
                  <label key={type.id} className="flex items-center space-x-2">
                    <input
                      type="checkbox"
                      checked={formData.specializationIds.includes(type.id)}
                      onChange={() => toggleSpecialization(type.id)}
                      className="w-4 h-4 text-blue-600 border-gray-300 rounded"
                    />
                    <span className="text-sm text-gray-700">{type.name}</span>
                  </label>
                ))}
              </div>
            </div>
            <button
              type="submit"
              disabled={submitting || formData.specializationIds.length === 0}
              className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition"
            >
              {submitting ? 'Creating...' : 'Create Agent'}
            </button>
          </form>
        </div>
      )}

      <div className="grid gap-4">
        {agents.length === 0 ? (
          <div className="bg-white rounded-lg shadow p-8 text-center text-gray-500">
            No agents found
          </div>
        ) : (
          agents.map((agent) => (
            <div key={agent.id} className="bg-white rounded-lg shadow p-6">
              <div className="flex justify-between items-start">
                <div>
                  <h3 className="text-xl font-semibold text-gray-800">{agent.name}</h3>
                  <p className="text-gray-600">{agent.email}</p>
                </div>
                <span className="px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-semibold">
                  AGENT
                </span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  )
}

export default AgentManagement

