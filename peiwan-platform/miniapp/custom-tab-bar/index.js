const customerList = [
  { pagePath: '/pages/home/index', text: '首页', iconPath: '/static/icons/home.svg', selectedIconPath: '/static/icons/home.svg' },
  { pagePath: '/pages/customer/orders', text: '订单', iconPath: '/static/icons/orders.svg', selectedIconPath: '/static/icons/orders.svg' },
  { pagePath: '/pages/discover/index', text: '找陪玩', iconPath: '/static/icons/gamepad.svg', selectedIconPath: '/static/icons/gamepad.svg', center: true },
  { pagePath: '/pages/messages/index', text: '消息', iconPath: '/static/icons/bell.svg', selectedIconPath: '/static/icons/bell.svg' },
  { pagePath: '/pages/profile/index', text: '我的', iconPath: '/static/icons/profile.svg', selectedIconPath: '/static/icons/profile.svg' }
]
const playerList = [
  { pagePath: '/pages/home/index', text: '工作台', iconPath: '/static/icons/home.svg', selectedIconPath: '/static/icons/home.svg' },
  { pagePath: '/pages/customer/orders', text: '服务单', iconPath: '/static/icons/orders.svg', selectedIconPath: '/static/icons/orders.svg' },
  { pagePath: '/pages/discover/index', text: '开始接单', iconPath: '/static/icons/gamepad.svg', selectedIconPath: '/static/icons/gamepad.svg', center: true },
  { pagePath: '/pages/messages/index', text: '邀请', iconPath: '/static/icons/bell.svg', selectedIconPath: '/static/icons/bell.svg' },
  { pagePath: '/pages/profile/index', text: '我的', iconPath: '/static/icons/profile.svg', selectedIconPath: '/static/icons/profile.svg' }
]
Component({
  data: { selected: 0, list: customerList, mode: 'customer' },
  lifetimes: { attached() { setTimeout(() => this.refresh(), 30) } },
  pageLifetimes: { show() { setTimeout(() => this.refresh(), 30) } },
  methods: {
    refresh() {
      const mode = wx.getStorageSync('peiwan_app_mode') === 'player' ? 'player' : 'customer'
      const pages = getCurrentPages()
      const route = pages.length ? `/${pages[pages.length - 1].route}` : '/pages/home/index'
      const list = mode === 'player' ? playerList : customerList
      const pending = wx.getStorageSync('peiwan_pending_tab')
      const routeIndex = list.findIndex(item => item.pagePath === route)
      const pendingValid = pending && pending.mode === mode && Date.now() - Number(pending.at || 0) < 1500
      const selected = pendingValid ? Number(pending.index) : Math.max(0, routeIndex)
      if (!pendingValid && pending) wx.removeStorageSync('peiwan_pending_tab')
      this.setData({ mode, list, selected })
    },
    switchTab(event) {
      const index = Number(event.currentTarget.dataset.index)
      const item = this.data.list[index]
      if (!item) return
      this.setData({ selected: index })
      wx.setStorageSync('peiwan_pending_tab', { index, mode: this.data.mode, path: item.pagePath, at: Date.now() })
      wx.switchTab({ url: item.pagePath })
    }
  }
})
