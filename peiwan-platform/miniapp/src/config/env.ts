const defaults = {
  development: 'http://192.168.1.114:8080',
  production: 'https://api.example.com',
} as const

export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || defaults[import.meta.env.PROD ? 'production' : 'development']
