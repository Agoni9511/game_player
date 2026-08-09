import { defineStore } from 'pinia'
import { getUserInfo, login } from '@/api/auth'
import { tokenStorage } from '@/services/http'
import type { UserInfo } from '@/types/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({ token: tokenStorage.get(), user: null as UserInfo | null, ready: false }),
  getters: {
    loggedIn: (state) => Boolean(state.token),
    isPlayer: (state) => Boolean(state.user?.roles?.includes('player') || state.user?.buttons?.includes('player:workbench:view')),
    isCustomer: (state) => Boolean(state.user?.roles?.includes('customer')),
  },
  actions: {
    async restore() {
      this.token = tokenStorage.get()
      if (this.token) await this.loadUser().catch(() => undefined)
      this.ready = true
    },
    async signIn(userName: string, password: string) {
      const result = await login(userName, password)
      tokenStorage.set(result.token)
      this.token = result.token
      await this.loadUser()
    },
    async loadUser() { this.user = await getUserInfo() },
    signOut() {
      tokenStorage.clear()
      uni.setStorageSync('peiwan_app_mode', 'customer')
      uni.removeStorageSync('peiwan_pending_tab')
      this.token = ''
      this.user = null
      uni.reLaunch({ url: '/pages/auth/login' })
    },
  },
})
