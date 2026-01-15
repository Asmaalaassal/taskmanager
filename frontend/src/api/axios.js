import axios from 'axios'

// Get API URL from environment variable or use default
// Vite uses VITE_ prefix for environment variables
const API_URL = import.meta.env.VITE_API_URL || 
                (import.meta.env.MODE === 'production' 
                  ? 'http://147.79.101.138:8085/api' 
                  : 'http://localhost:8085/api')

const api = axios.create({
  baseURL: API_URL,
})

// Request interceptor to add token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

export default api

