const defaults = {
  development: 'http://127.0.0.1:8080',
  production: 'https://api.example.com',
} as const

export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || defaults[import.meta.env.PROD ? 'production' : 'development']
