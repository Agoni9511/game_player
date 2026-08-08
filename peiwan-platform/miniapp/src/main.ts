import { createSSRApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import { useAuthStore } from '@/stores/auth'

export function createApp() {
  const app = createSSRApp(App)
  const pinia = createPinia()
  app.use(pinia)
  uni.$on('auth:expired', () => {
    const auth = useAuthStore(pinia)
    auth.token = ''
    auth.user = null
  })
  return { app, Pinia: pinia }
}
