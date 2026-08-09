const customerList = [
  { pagePath: '/pages/home/index', text: '首页', iconPath: '/static/icons/home.png', selectedIconPath: '/static/icons/home-active.png' },
  { pagePath: '/pages/hall/index', text: '大厅', iconPath: '/static/icons/list.png', selectedIconPath: '/static/icons/list.png' },
  { pagePath: '/pages/players/index', text: '找陪玩', iconPath: '/static/icons/gamepad.png', selectedIconPath: '/static/icons/gamepad.png', center: true },
  { pagePath: '/pages/messages/index', text: '消息', iconPath: '/static/icons/bell.png', selectedIconPath: '/static/icons/bell.png' },
  { pagePath: '/pages/profile/index', text: '我的', iconPath: '/static/icons/profile.png', selectedIconPath: '/static/icons/profile-active.png' }
]
const playerList = [
  { pagePath: '/pages/home/index', text: '工作台', iconPath: '/static/icons/home.png', selectedIconPath: '/static/icons/home-active.png' },
  { pagePath: '/pages/hall/index', text: '大厅', iconPath: '/static/icons/list.png', selectedIconPath: '/static/icons/list.png' },
  { pagePath: '/pages/players/index', text: '开始接单', iconPath: '/static/icons/gamepad.png', selectedIconPath: '/static/icons/gamepad.png', center: true },
  { pagePath: '/pages/messages/index', text: '邀请', iconPath: '/static/icons/bell.png', selectedIconPath: '/static/icons/bell.png' },
  { pagePath: '/pages/profile/index', text: '我的', iconPath: '/static/icons/profile.png', selectedIconPath: '/static/icons/profile-active.png' }
]
Component({
  data: { selected: 0, list: customerList, mode: 'customer', hidden: false },
  lifetimes: {
    attached() { this.refresh() },
    ready() { this.refresh() }
  },
  pageLifetimes: { show() { this.refresh() } },
  methods: {
    refresh() {
      const mode = wx.getStorageSync('peiwan_app_mode') === 'player' ? 'player' : 'customer'
      const pages = getCurrentPages()
      const route = pages.length ? `/${pages[pages.length - 1].route}` : '/pages/home/index'
      const list = mode === 'player' ? playerList : customerList
      const routeIndex = list.findIndex(item => item.pagePath === route)
      this.setData({ mode, list, selected: routeIndex >= 0 ? routeIndex : 0 })
    },
    switchTab(event) {
      const index = Number(event.currentTarget.dataset.index)
      const item = this.data.list[index]
      if (!item) return
      this.setData({ selected: index })
      wx.switchTab({
        url: item.pagePath,
        success: () => {
          const pages = getCurrentPages()
          const page = pages[pages.length - 1]
          const tabBar = page && typeof page.getTabBar === 'function' ? page.getTabBar() : null
          if (tabBar && typeof tabBar.refresh === 'function') tabBar.refresh()
        },
        fail: () => this.refresh()
      })
    }
  }
})
