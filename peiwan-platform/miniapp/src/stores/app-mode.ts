import { defineStore } from 'pinia'
import { useAuthStore } from './auth'

export type AppMode = 'customer' | 'player'
const MODE_KEY = 'peiwan_app_mode'

export const useAppModeStore = defineStore('app-mode', {
  state: () => ({ mode: (uni.getStorageSync(MODE_KEY) || 'customer') as AppMode }),
  getters: { isPlayerMode: state => state.mode === 'player' },
  actions: {
    switchMode(mode: AppMode) {
      const auth = useAuthStore()
      if (mode === 'player' && !auth.isPlayer) throw new Error('当前账号没有陪玩师身份')
      this.mode = mode
      uni.setStorageSync(MODE_KEY, mode)
      // #ifdef MP-WEIXIN
      const pages = getCurrentPages()
      const tabBar = (pages[pages.length - 1] as unknown as { getTabBar?: () => { refresh?: () => void } })?.getTabBar?.()
      tabBar?.refresh?.()
      // #endif
    },
  },
})
