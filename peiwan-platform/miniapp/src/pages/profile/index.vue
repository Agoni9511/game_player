<template>
  <view class="profile-page tab-page">
    <view class="header-bg">
      <image class="header-art" src="/static/home/choose-player.jpg" mode="aspectFill" />
      <view class="header-shade" />
      <view class="orb orb-one" /><view class="orb orb-two" />
      <view class="topbar"><view class="setting" @click="planned('设置中心')"><image src="/static/icons/gear.png" /></view></view>
      <view class="user-card" @click="toggleUserDetails">
        <view class="avatar"><image v-if="auth.user?.avatar" :src="assetUrl(auth.user.avatar)" mode="aspectFill" /><text v-else>{{ avatarText }}</text></view>
        <view class="user-main">
          <view class="name-row">
            <text class="nickname">{{ auth.user?.nickName || auth.user?.userName || '未登录' }}</text>
            <view v-if="auth.isPlayer" class="role-switch-trigger" @click.stop="openRoleSheet">
              <text>{{ currentModeLabel }}</text><text class="swap-arrows">⇄</text>
            </view>
            <text v-else-if="auth.loggedIn" class="verified">已登录</text>
          </view>
          <view class="account-line">
            <view class="account">账号：{{ auth.user?.userName || '登录后查看' }}</view>
            <view v-if="!mode.isPlayerMode" class="member-badge" :class="memberBadgeTone">
              <text class="member-badge-icon">◆</text>
              <text>{{ memberBadgeLabel }}</text>
            </view>
          </view>
          <view class="role-row"><text v-for="tag in profileTags" :key="tag.text" class="role-tag" :class="tag.type">{{ tag.text }}</text></view>
        </view>
        <text class="chevron" :class="{ expanded: userDetailsVisible }">⌄</text>
      </view>
      <view v-if="userDetailsVisible" class="user-details">
        <view v-if="!mode.isPlayerMode" class="member-summary">
          <view class="member-mark">{{ memberShortName }}</view>
          <view class="member-copy"><view>{{ memberName }}</view><text>{{ memberBenefit }}</text></view>
          <view class="upgrade-button" @click.stop="goRecharge">{{ isMember ? '继续充值' : '去升级' }}</view>
        </view>
        <view v-else class="member-summary">
          <view class="member-mark">陪</view><view class="member-copy"><view>{{ playerInfo.nickname || '陪玩师资料' }}</view><text>{{ playerStatusLabel }} · 评分 {{ Number(playerInfo.ratingScore || 0).toFixed(1) }}</text></view><view class="upgrade-button" @click.stop="goPlayerProfile">编辑资料</view>
        </view>
        <view v-if="!mode.isPlayerMode" class="profile-facts">
          <view><text>累计充值</text><label>¥{{ totalRecharge }}</label></view>
          <view><text>资料完整度</text><label>{{ profileCompletion }}%</label></view>
          <view><text>绑定手机</text><label>{{ maskedPhone }}</label></view>
          <view class="edit-profile" @click.stop="goUserProfile"><text>个人资料</text><label>编辑 ›</label></view>
        </view>
        <view v-else class="profile-facts"><view><text>待响应邀请</text><label>{{ workbench.pendingDispatchCount || 0 }}</label></view><view><text>进行中订单</text><label>{{ workbench.activeOrderCount || 0 }}</label></view><view><text>累计服务</text><label>{{ workbench.completedOrderCount || 0 }} 单</label></view><view class="edit-profile" @click.stop="goPlayerSettlement"><text>我的收益</text><label>查看 ›</label></view></view>
      </view>
    </view>

    <view class="content">
      <view v-if="auth.loggedIn && !mode.isPlayerMode" class="asset-section">
        <view class="asset-head">
          <view><text>我的资产</text><label>账户数据已加密保护</label></view>
          <view class="asset-actions"><text @click="goRecharge">去充值</text><label @click="goTransactions">资金明细 ›</label></view>
        </view>
        <view class="asset-grid">
          <view v-for="item in assetEntries" :key="item.label" class="asset-item" @click="assetAction(item.label)">
            <text>{{ item.value }}</text><label>{{ item.label }}</label>
          </view>
        </view>
      </view>

      <view class="section order-section">
        <view class="section-head" @click="goOrders"><text>{{ orderSectionTitle }}</text><view>{{ orderSectionAllLabel }} <text class="arrow">›</text></view></view>
        <view class="shortcut-grid order-grid" :class="{ 'player-order-grid': mode.isPlayerMode }">
          <view v-for="item in orderEntries" :key="item.label" class="shortcut" @click="openOrder(item.status)">
            <view class="icon-wrap" :style="{ background: item.background }"><image :src="item.icon" /><text v-if="item.count" class="order-badge">{{ item.count > 99 ? '99+' : item.count }}</text></view>
            <text>{{ item.label }}</text>
          </view>
        </view>
      </view>

      <view v-if="mode.isPlayerMode" class="section player-section">
        <view class="section-head"><text>陪玩师中心</text><view class="online"><text />身份已开通</view></view>
        <view class="player-banner" @click="goWorkbench">
          <view class="controller"><image src="/static/icons/gamepad.png" /></view>
          <view class="player-copy"><view>今天也要快乐接单</view><text>查看邀请、服务订单与工作状态</text></view>
          <view class="enter">进入 ›</view>
        </view>
        <view class="shortcut-grid player-grid">
          <view class="shortcut" @click="goDispatch"><view class="line-icon"><image src="/static/icons/hourglass.png" /></view><text>待抢订单</text></view>
          <view class="shortcut" @click="goPlayerOrders"><view class="line-icon"><image src="/static/icons/list.png" /></view><text>我的接单</text></view>
          <view class="shortcut" @click="goPlayerProfile"><view class="line-icon"><image src="/static/icons/profile.png" /></view><text>我的资料</text></view>
          <view class="shortcut" @click="goPlayerSettlement"><view class="line-icon"><image src="/static/icons/wallet.png" /></view><text>收益中心</text></view>
        </view>
      </view>

      <view v-if="!mode.isPlayerMode" class="section">
        <view class="section-head"><text>我的服务</text></view>
        <view class="shortcut-grid service-grid">
          <view v-for="item in serviceEntries" :key="item.label" class="shortcut" @click="serviceAction(item.key, item.label)">
            <view class="service-icon" :style="{ background: item.background }"><image :src="item.icon" /></view>
            <text>{{ item.label }}</text>
            <text v-if="item.planned" class="soon">规划中</text>
          </view>
        </view>
      </view>

      <view class="section list-section">
        <view v-if="auth.loggedIn && !auth.isPlayer" class="list-item" @click="identityAction">
          <view class="list-left"><view class="mini-icon"><image src="/static/icons/gamepad.png" /></view><text>申请成为陪玩师</text></view>
          <view class="list-right"><text>了解入驻</text><text class="arrow">›</text></view>
        </view>
        <view v-for="item in listEntries" :key="item.label" class="list-item" @click="listAction(item.label)">
          <view class="list-left"><view class="mini-icon"><image :src="item.icon" /></view><text>{{ item.label }}</text></view>
          <view class="list-right"><text v-if="item.note">{{ item.note }}</text><text class="arrow">›</text></view>
        </view>
      </view>

      <button v-if="auth.loggedIn" class="logout" @click="confirmLogout">退出当前账号</button>
      <button v-else class="login" @click="goLogin">登录账号</button>
      <view class="footer">凌竞电竞陪玩服务 · 当前为开发版本</view>
    </view>

    <view v-if="roleSheetVisible" class="role-sheet-mask" @click="closeRoleSheet">
      <view class="role-sheet" @click.stop>
        <view class="sheet-handle" />
        <view class="sheet-title">切换使用身份</view>
        <view class="role-option" :class="{ selected: !mode.isPlayerMode }" @click="selectMode('customer')">
          <view class="role-option-icon customer">客</view>
          <view class="role-option-copy"><view>用户端</view><text>浏览服务、下单和查看订单</text></view>
          <view class="role-check">{{ !mode.isPlayerMode ? '✓' : '' }}</view>
        </view>
        <view class="role-option" :class="{ selected: mode.isPlayerMode }" @click="selectMode('player')">
          <view class="role-option-icon player">陪</view>
          <view class="role-option-copy"><view>陪玩师端</view><text>接单、履约和管理服务状态</text></view>
          <view class="role-check">{{ mode.isPlayerMode ? '✓' : '' }}</view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onHide, onShow } from '@dcloudio/uni-app'
import { useAuthStore } from '@/stores/auth'
import { useAppModeStore, type AppMode } from '@/stores/app-mode'
import { getPlayerOrders, getWorkbench } from '@/api/player'
import { getCustomerOrderSummary, getCustomerWallet } from '@/api/customer'
import { assetUrl } from '@/services/http'
import { navigateToWithLogin, requireLogin } from '@/utils/auth-guard'
import { getPlayerOrderUnreadSummary } from '@/utils/order-status'
import type { RecordData } from '@/types/api'

const auth = useAuthStore()
const mode = useAppModeStore()
const workbench = ref<RecordData>({})
const walletSummary = ref<RecordData>({})
const orderSummary = ref<Record<string, number>>({})
const playerOrderSummary = ref<Record<string, number>>({})
const playerOrderUnreadSummary = ref<Record<string, number>>({})
const roleSheetVisible = ref(false)
const userDetailsVisible = ref(false)
onShow(async () => {
  if (auth.loggedIn && !auth.user) await auth.loadUser().catch(() => undefined)
  if (mode.isPlayerMode) {
    const [bench, orders] = await Promise.all([
      getWorkbench().catch(() => ({})),
      getPlayerOrders().catch(() => ({ records: [], total: 0, current: 1, size: 20 })),
    ])
    workbench.value = bench
    const playerOrders = orders.records as RecordData[]
    playerOrderSummary.value = playerOrders.reduce<Record<string, number>>((summary, order) => {
      const status = String(order.orderStatus || order.order_status || '')
      if (status) summary[status] = (summary[status] || 0) + 1
      return summary
    }, {})
    playerOrderUnreadSummary.value = getPlayerOrderUnreadSummary(playerOrders, Number(auth.user?.userId || 0))
  }
  if (auth.loggedIn && !mode.isPlayerMode) {
    const [wallet, summary] = await Promise.all([getCustomerWallet().catch(() => ({})), getCustomerOrderSummary().catch(() => ({}))])
    walletSummary.value = wallet
    orderSummary.value = summary
  }
})
onHide(() => { closeRoleSheet(); userDetailsVisible.value = false })

const avatarText = computed(() => (auth.user?.nickName || auth.user?.userName || '游').slice(0, 1))
const currentModeLabel = computed(() => mode.isPlayerMode ? '陪玩师' : '用户端')
const roleLabels = computed(() => {
  const roles = auth.user?.roles || []
  const labels: string[] = []
  if (roles.includes('admin')) labels.push('平台管理员')
  if (roles.includes('customer')) labels.push('顾客')
  if (roles.includes('player')) labels.push('陪玩师')
  return labels.length ? labels : ['暂无业务身份']
})
const playerInfo = computed(() => (workbench.value.player || {}) as RecordData)
const playerStatusLabel = computed(() => ({ AVAILABLE:'接单中',BUSY:'服务中',OFFLINE:'休息中' } as Record<string,string>)[String(playerInfo.value.workStatus || '')] || '状态未知')
const walletAccount = computed(() => (walletSummary.value.account || {}) as RecordData)
const memberInfo = computed(() => (walletSummary.value.member || {}) as RecordData)
const memberLevelCode = computed(() => String(memberInfo.value.levelCode || memberInfo.value.level_code || '').toUpperCase())
const isMember = computed(() => Boolean(memberInfo.value.id) && memberInfo.value.enabled !== false)
const memberName = computed(() => isMember.value
  ? String(memberInfo.value.levelName || memberInfo.value.level_name || '会员')
  : '未开通会员')
const memberBadgeLabel = computed(() => memberName.value)
const memberBadgeTone = computed(() => {
  if (!isMember.value) return 'inactive'
  if (memberLevelCode.value === 'GOLD') return 'gold'
  if (memberLevelCode.value === 'SILVER') return 'silver'
  return 'normal'
})
const memberShortName = computed(() => memberName.value.slice(0, 1))
const totalRecharge = computed(() => Number(memberInfo.value.totalRechargeAmount || memberInfo.value.total_recharge_amount || 0).toFixed(2))
const memberBenefit = computed(() => String(memberInfo.value.benefitDescription || memberInfo.value.benefit_description || '开通会员身份，展示专属标识与权益'))
const profileCompletion = computed(() => {
  if (!auth.user) return 0
  const fields = [auth.user.nickName, auth.user.avatar, auth.user.phone, auth.user.email, auth.user.gender && auth.user.gender !== 'UNKNOWN']
  return Math.round(fields.filter(Boolean).length / fields.length * 100)
})
const maskedPhone = computed(() => {
  const phone = String(auth.user?.phone || '')
  return phone.length >= 7 ? `${phone.slice(0, 3)}****${phone.slice(-4)}` : '未绑定'
})
const money = (value: unknown) => Number(value || 0).toFixed(2)
const assetEntries = computed(() => [
  { label: '钱包余额', value: `¥${money(walletAccount.value.totalBalance)}` },
  { label: '赠送金', value: `¥${money(walletAccount.value.bonusBalance)}` },
  { label: '优惠卡券', value: '--' },
  { label: '累计充值', value: `¥${totalRecharge.value}` },
])
const profileTags = computed(() => {
  const tags = roleLabels.value.map(text => ({ text, type: 'role' }))
  if (mode.isPlayerMode) {
    const statusMap: Record<string, string> = { AVAILABLE: '接单中', BUSY: '服务中', OFFLINE: '休息中' }
    const status = String(playerInfo.value.workStatus || '')
    if (status) tags.push({ text: statusMap[status] || status, type: status === 'AVAILABLE' ? 'online' : 'status' })
    const rating = Number(playerInfo.value.ratingScore || 0)
    if (rating > 0) tags.push({ text: `评分 ${rating.toFixed(1)}`, type: 'rating' })
    const count = Number(playerInfo.value.orderCount || 0)
    if (count > 0) tags.push({ text: `服务 ${count} 单`, type: 'count' })
  }
  return tags.slice(0, 4)
})
const customerOrderEntries = computed(() => [
  { label: '待付款', status: 'PENDING_PAYMENT', icon: '/static/icons/wallet.png', background: '#e3e7d8', count: Number(orderSummary.value.PENDING_PAYMENT || 0) },
  { label: '待接单', status: 'WAIT_ASSIGN', icon: '/static/icons/hourglass.png', background: '#eee2c8', count: Number(orderSummary.value.WAIT_ASSIGN || 0) },
  { label: '服务中', status: 'ACTIVE_SERVICE', icon: '/static/icons/gamepad.png', background: '#dce8dd', count: Number(orderSummary.value.ASSIGNED || 0) + Number(orderSummary.value.IN_SERVICE || 0) + Number(orderSummary.value.PAUSED || 0) },
  { label: '待确认', status: 'PENDING_CONFIRMATION', icon: '/static/icons/check.png', background: '#efe0d7', count: Number(orderSummary.value.PENDING_CONFIRM || 0) + Number(orderSummary.value.WAIT_CUSTOMER_CONFIRM || 0) },
  { label: '售后', status: 'AFTER_SALE', icon: '/static/icons/after-sale.png', background: '#dde4db', count: Number(orderSummary.value.AFTER_SALE || 0) },
])
const playerOrderEntries = computed(() => [
  { label: '待开始', status: 'ASSIGNED', icon: '/static/icons/hourglass.png', background: '#eee2c8', count: Number(playerOrderUnreadSummary.value.ASSIGNED || 0) },
  { label: '服务中', status: 'IN_SERVICE', icon: '/static/icons/gamepad.png', background: '#dce8dd', count: Number(playerOrderUnreadSummary.value.IN_SERVICE || 0) + Number(playerOrderUnreadSummary.value.PAUSED || 0) },
  { label: '待审核', status: 'REVIEW', icon: '/static/icons/check.png', background: '#efe0d7', count: Number(playerOrderUnreadSummary.value.REVIEW || 0) },
  { label: '已完成', status: 'COMPLETED', icon: '/static/icons/orders-active.png', background: '#dfe6da', count: Number(playerOrderUnreadSummary.value.COMPLETED || 0) },
])
const orderEntries = computed(() => mode.isPlayerMode ? playerOrderEntries.value : customerOrderEntries.value)
const orderSectionTitle = computed(() => mode.isPlayerMode ? '我的服务单' : '我的订单')
const orderSectionAllLabel = computed(() => mode.isPlayerMode ? '全部服务单' : '全部订单')
const serviceEntries = [
  { key: 'customer-service', label: '联系客服', icon: '/static/icons/headset.png', background: '#dfe6da' },
  { key: 'after-sale', label: '售后记录', icon: '/static/icons/after-sale.png', background: '#eee0d7' },
  { key: 'messages', label: '消息通知', icon: '/static/icons/bell.png', background: '#dce8dd', planned: true },
  { key: 'reviews', label: '我的评价', icon: '/static/icons/star.png', background: '#ede4cb', planned: true },
  { key: 'favorites', label: '我的收藏', icon: '/static/icons/heart.png', background: '#ecdfd6', planned: true },
  { key: 'coupons', label: '优惠卡券', icon: '/static/icons/ticket.png', background: '#dfe5da', planned: true },
  { key: 'complaint', label: '投诉建议', icon: '/static/icons/alert.png', background: '#eadfd4', planned: true },
  { key: 'history', label: '浏览足迹', icon: '/static/icons/history.png', background: '#dce6df', planned: true },
]
const listEntries = [
  { label: '账号与安全', icon: '/static/icons/shield.png', note: '密码管理' },
  { label: '服务规则与安全须知', icon: '/static/icons/document.png', note: '可再次查看' },
  { label: '帮助与反馈', icon: '/static/icons/help.png', note: '' },
  { label: '关于凌竞电竞', icon: '/static/icons/info.png', note: '开发版' },
]

function switchMainTab(url: string, _index: number) { uni.switchTab({ url }) }
function goOrders() {
  navigateToWithLogin(mode.isPlayerMode ? '/subpackages/player/orders' : '/pages/customer/orders', '登录后才能查看订单')
}
function openOrder(status: string) {
  const url = mode.isPlayerMode
    ? `/subpackages/player/orders?status=${status}`
    : `/subpackages/customer/order-list?status=${status}`
  navigateToWithLogin(url, '登录后才能查看订单')
}
function goWorkbench() { mode.switchMode('player'); switchMainTab('/pages/home/index', 0) }
function goDispatch() { navigateToWithLogin('/subpackages/player/dispatches', '登录后才能查看派单邀请') }
function goPlayerOrders() { navigateToWithLogin('/subpackages/player/orders', '登录后才能查看服务订单') }
function goPlayerProfile() { navigateToWithLogin('/subpackages/player/profile-edit', '登录后才能管理陪玩资料') }
function goPlayerSettlement() { navigateToWithLogin('/subpackages/player/settlement', '登录后才能查看收益') }
function goUserProfile() { navigateToWithLogin('/subpackages/customer/profile-edit', '登录后才能编辑个人资料') }
function toggleUserDetails() {
  if (!auth.loggedIn) return goLogin()
  userDetailsVisible.value = !userDetailsVisible.value
}
function goRecharge() { navigateToWithLogin('/subpackages/customer/recharge', '登录后才能进行钱包充值') }
function goTransactions() { navigateToWithLogin('/subpackages/customer/wallet-transactions', '登录后才能查看资金明细') }
function assetAction(label: string) {
  if (label === '钱包余额' || label === '累计充值') return goRecharge()
  planned(label)
}
function identityAction() { navigateToWithLogin('/subpackages/customer/player-application', '登录后才能提交入驻申请') }
function serviceAction(key: string, label: string) {
  if (key === 'customer-service') return planned('在线客服')
  if (!requireLogin(`登录后才能查看${label}`)) return
  if (key === 'after-sale') return openOrder('AFTER_SALE')
  planned(label)
}
function listAction(label: string) {
  if (label === '账号与安全' && !requireLogin('登录后才能管理账号与安全设置')) return
  planned(label)
}
function planned(name: string) { if(name==='服务规则与安全须知'){uni.removeStorageSync('peiwan_service_notice_v1');uni.switchTab({url:'/pages/home/index'});return}uni.showToast({ title: `${name}将在后续版本开放`, icon: 'none' }) }
function goLogin() { uni.navigateTo({ url: '/pages/auth/login' }) }
function setTabBarHidden(hidden: boolean) {
  // #ifdef MP-WEIXIN
  const pages = getCurrentPages()
  const tabBar = (pages[pages.length - 1] as unknown as { getTabBar?: () => { setData?: (data: { hidden: boolean }) => void } })?.getTabBar?.()
  tabBar?.setData?.({ hidden })
  // #endif
}
function openRoleSheet() { roleSheetVisible.value = true; setTabBarHidden(true) }
function closeRoleSheet() { roleSheetVisible.value = false; setTabBarHidden(false) }
function selectMode(value: AppMode) {
  closeRoleSheet()
  if ((value === 'player') === mode.isPlayerMode) return
  mode.switchMode(value)
  uni.showToast({ title: value === 'player' ? '已切换至陪玩师端' : '已切换至用户端' })
  setTimeout(() => switchMainTab('/pages/home/index', 0), 350)
}
function confirmLogout() { uni.showModal({ title: '退出登录', content: '确定退出当前账号吗？', success: result => { if (result.confirm) auth.signOut() } }) }
</script>

<style scoped lang="scss">
.profile-page { min-height: 100vh; background: #f5f6fa; }
.header-bg { position: relative; padding: 78rpx 28rpx 38rpx; color: #fff; background: linear-gradient(145deg, #242044, #5f46d6 68%, #7658ef); }
.orb { position: absolute; border-radius: 50%; background: rgba(255,255,255,.08); }.orb-one { width: 330rpx; height: 330rpx; right: -100rpx; top: -120rpx; }.orb-two { width: 180rpx; height: 180rpx; left: -80rpx; bottom: -80rpx; }
.topbar { position: relative; display: flex; align-items: center; justify-content: flex-end; margin-bottom: 24rpx; }.setting { width: 62rpx; height: 62rpx; display: flex; align-items: center; justify-content: center; border-radius: 50%; background: rgba(255,255,255,.12); }.setting image { width: 32rpx; height: 32rpx; }
.user-card { position: relative; display: flex; align-items: center; }.avatar { width: 112rpx; height: 112rpx; flex: none; border: 6rpx solid rgba(255,255,255,.28); border-radius: 50%; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg,#8c75ff,#6849ef); font-size: 45rpx; font-weight: 800; }.user-main { min-width: 0; flex: 1; margin-left: 24rpx; }.name-row { display: flex; align-items: center; gap: 14rpx; }.nickname { max-width: 310rpx; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; font-size: 38rpx; font-weight: 800; }.verified { padding: 5rpx 12rpx; border-radius: 100rpx; color: #e7e1ff; background: rgba(255,255,255,.13); font-size: 18rpx; }.account-line { display:flex;align-items:center;gap:12rpx;margin-top:10rpx; }.account { min-width:0;overflow:hidden;color:rgba(255,255,255,.62);font-size:23rpx;white-space:nowrap;text-overflow:ellipsis; }.member-badge { flex:none;display:flex;align-items:center;gap:6rpx;padding:5rpx 11rpx;border:1rpx solid;border-radius:18rpx;font-size:18rpx;font-weight:700;line-height:1.25;box-shadow:inset 0 1rpx 0 rgba(255,255,255,.18); }.member-badge-icon { font-size:13rpx; }.member-badge.inactive { border-color:rgba(214,220,217,.18);color:rgba(230,234,232,.45);background:rgba(14,24,21,.42);box-shadow:none; }.member-badge.normal { border-color:rgba(166,222,193,.5);color:#dcf5e8;background:linear-gradient(135deg,rgba(45,112,83,.86),rgba(31,77,60,.86)); }.member-badge.silver { border-color:rgba(241,245,244,.72);color:#294037;background:linear-gradient(135deg,#f3f6f5,#aebbb6 74%,#e9eeec); }.member-badge.gold { border-color:rgba(255,231,158,.9);color:#523810;background:linear-gradient(135deg,#fff0ae,#dcae43 64%,#ffe79b);box-shadow:0 3rpx 12rpx rgba(229,180,72,.28),inset 0 1rpx 0 rgba(255,255,255,.5); }.role-row { display: flex; flex-wrap: wrap; gap: 9rpx; margin-top: 15rpx; }.role-tag { padding: 6rpx 13rpx; border-radius: 100rpx; color: #fff; background: rgba(19,16,45,.25); font-size: 18rpx; }.role-tag.online { color: #d9fff4; background: rgba(26,180,137,.3); }.role-tag.rating { color: #fff2c2; background: rgba(220,157,38,.28); }.role-tag.count { color: #ddebff; background: rgba(70,139,220,.27); }.role-tag.status { color: #e6e3ef; background: rgba(255,255,255,.12); }.chevron { padding: 20rpx 5rpx 20rpx 25rpx; color: rgba(255,255,255,.7); font-size: 52rpx; }
.content { padding: 24rpx 24rpx calc(250rpx + env(safe-area-inset-bottom)); }.section { margin-bottom: 22rpx; padding: 28rpx 24rpx; border-radius: 25rpx; background: #fff; box-shadow: 0 7rpx 25rpx rgba(31,38,58,.035); }.section-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28rpx; }.section-head>text { font-size: 30rpx; font-weight: 800; }.section-head>view { color: #999eac; font-size: 22rpx; }.arrow { margin-left: 6rpx; color: #b0b4bf; font-size: 32rpx; }
.role-switch-trigger { flex: none; padding: 7rpx 12rpx; border-radius: 18rpx; display: flex; align-items: center; gap: 7rpx; color: #f5eedb; background: rgba(255,255,255,.13); font-size: 18rpx; }
.swap-arrows { font-size: 22rpx; line-height: 1; }
.shortcut-grid { display: grid; }.order-grid { grid-template-columns: repeat(5,1fr); }.order-grid.player-order-grid { grid-template-columns: repeat(4,1fr); }.shortcut { position: relative; display: flex; flex-direction: column; align-items: center; gap: 12rpx; color: #454958; font-size: 22rpx; text-align: center; }.icon-wrap { width: 66rpx; height: 66rpx; border-radius: 21rpx; display: flex; align-items: center; justify-content: center; }.icon-wrap image { width: 40rpx; height: 40rpx; }.soon { color: #b1b5c1; font-size: 17rpx; }
.order-badge{position:absolute;z-index:2;right:-13rpx;top:-13rpx;min-width:31rpx;height:31rpx;padding:0 7rpx;border:3rpx solid #fffaf0;border-radius:20rpx;box-sizing:border-box;color:#fff;background:#c6483d;line-height:27rpx;text-align:center;font-family:sans-serif;font-size:16rpx;font-weight:800;box-shadow:0 4rpx 10rpx rgba(150,61,49,.28)}
.online { display: flex; align-items: center; gap: 8rpx; }.online text { width: 11rpx; height: 11rpx; border-radius: 50%; background: #2cc9a5; }.player-banner { margin-bottom: 28rpx; padding: 23rpx; border-radius: 19rpx; display: flex; align-items: center; color: #fff; background: linear-gradient(110deg,#6650de,#8b6df1); }.controller { width: 68rpx; }.controller image { width: 48rpx; height: 48rpx; filter: brightness(0) invert(1); }.player-copy { flex: 1; }.player-copy view { font-size: 27rpx; font-weight: 700; }.player-copy text { display: block; margin-top: 7rpx; color: rgba(255,255,255,.66); font-size: 19rpx; }.enter { font-size: 21rpx; }.player-grid { grid-template-columns: repeat(4,1fr); }.line-icon { width: 58rpx; height: 58rpx; border: 2rpx solid #ded8fb; border-radius: 18rpx; display: flex; align-items: center; justify-content: center; }.line-icon image { width: 37rpx; height: 37rpx; }
.service-grid { grid-template-columns: repeat(4,1fr); row-gap: 34rpx; }.service-icon { width: 64rpx; height: 64rpx; border-radius: 20rpx; display: flex; align-items: center; justify-content: center; }.service-icon image { width: 39rpx; height: 39rpx; }.list-section { padding-top: 5rpx; padding-bottom: 5rpx; }.list-item { min-height: 94rpx; border-bottom: 1rpx solid #f0f1f4; display: flex; align-items: center; justify-content: space-between; }.list-item:last-child { border: 0; }.list-left,.list-right { display: flex; align-items: center; }.mini-icon { width: 50rpx; display: flex; align-items: center; }.mini-icon image { width: 31rpx; height: 31rpx; }.list-left>text { color: #414554; font-size: 26rpx; }.list-right { color: #a4a8b4; font-size: 21rpx; }
.logout,.login { height: 90rpx; line-height: 90rpx; border-radius: 20rpx; font-size: 27rpx; }.logout { color: #e1546a; background: #fff; }.login { color: #fff; background: #7357ef; }.footer { padding: 28rpx 0 12rpx; color: #b0b4bf; font-size: 19rpx; text-align: center; }
.role-sheet-mask { position: fixed; z-index: 1200; inset: 0; display: flex; align-items: flex-end; background: rgba(19,28,24,.48); animation: mask-in .18s ease-out; }
.role-sheet { width: 100%; padding: 18rpx 34rpx calc(38rpx + env(safe-area-inset-bottom)); border-radius: 36rpx 36rpx 0 0; box-sizing: border-box; background: #fffaf0; box-shadow: 0 -16rpx 50rpx rgba(26,42,34,.2); animation: sheet-up .22s ease-out; }
.sheet-handle { width: 72rpx; height: 8rpx; margin: 0 auto 26rpx; border-radius: 8rpx; background: #d5d4c9; }
.sheet-title { margin-bottom: 16rpx; color: #1d3027; font-family: STKaiti,KaiTi,serif; font-size: 34rpx; font-weight: 800; }
.role-option { min-height: 116rpx; padding: 18rpx 14rpx; border-bottom: 1rpx solid rgba(49,92,80,.1); display: flex; align-items: center; gap: 20rpx; }
.role-option:last-child { border-bottom: 0; }
.role-option-icon { width: 76rpx; height: 76rpx; flex: none; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fffaf0; font-family: STKaiti,KaiTi,serif; font-size: 30rpx; font-weight: 800; }
.role-option-icon.customer { background: #557869; }.role-option-icon.player { background: #963d31; }
.role-option-copy { min-width: 0; flex: 1; }.role-option-copy view { color: #26372f; font-size: 28rpx; font-weight: 700; }.role-option-copy text { display: block; margin-top: 8rpx; color: #879189; font-size: 21rpx; }
.role-check { width: 48rpx; height: 48rpx; border: 3rpx solid #c7cbc5; border-radius: 50%; color: transparent; line-height: 45rpx; text-align: center; font-size: 27rpx; font-weight: 800; }
.role-option.selected .role-check { border-color: #315c50; color: #fffaf0; background: #315c50; }
@keyframes mask-in { from { opacity: 0; } }
@keyframes sheet-up { from { transform: translateY(100%); } }
</style>
<style scoped lang="scss">
.profile-page{background-color:#eee9da;background-image:radial-gradient(circle at 88% 2%,rgba(91,126,108,.15),transparent 34%),linear-gradient(180deg,rgba(244,240,225,.86),rgba(244,240,225,.96))}.header-bg{color:#f9f2df;background:linear-gradient(135deg,rgba(24,46,38,.95),rgba(57,92,77,.88));border-bottom:6rpx solid rgba(150,61,49,.7)}
.orb{background:rgba(240,232,208,.07)}.setting{background:rgba(255,250,235,.13)}.avatar{border-color:rgba(240,229,197,.38);border-radius:50%;background:#963d31;font-family:STKaiti,KaiTi,serif}.avatar image{width:100%;height:100%;border-radius:inherit}.nickname{font-family:STKaiti,KaiTi,serif;letter-spacing:2rpx}
.section{border:1rpx solid rgba(54,79,68,.18);border-radius:24rpx;background:rgba(255,252,241,.92);box-shadow:0 12rpx 30rpx rgba(38,54,45,.08)}.content{background:linear-gradient(rgba(239,234,217,.76),rgba(239,234,217,.92))}
.section-head>text{font-family:STKaiti,KaiTi,serif;color:#1d3027}.player-banner{border-left:7rpx solid #963d31;border-radius:20rpx;background:linear-gradient(110deg,#365f52,#243f37)}.icon-wrap,.service-icon,.line-icon{position:relative;border:1rpx solid rgba(49,92,80,.25);border-radius:18rpx}.line-icon{border-color:#aabcae}.logout{color:#963d31;background:rgba(255,252,241,.9)}.login{background:#315c50}.footer{color:#68766e}
.header-bg{overflow:hidden;background:#203c32}
.header-art{position:absolute;z-index:0;inset:0;width:100%;height:100%;opacity:.92}
.header-shade{position:absolute;z-index:1;inset:0;background:linear-gradient(90deg,rgba(16,45,35,.95) 0%,rgba(24,58,46,.82) 48%,rgba(27,56,46,.34) 100%),linear-gradient(180deg,rgba(18,42,34,.08),rgba(18,42,34,.42))}
.orb{z-index:1}.topbar,.user-card,.user-details{position:relative;z-index:2}
.user-card{cursor:pointer}.chevron{width:54rpx;padding:16rpx 0;color:#f3ead4;text-align:center;font-size:42rpx;line-height:1;transition:transform .2s ease}.chevron.expanded{transform:rotate(180deg)}
.user-details{margin-top:26rpx;padding:22rpx 24rpx 20rpx;border:1rpx solid rgba(247,239,216,.25);border-radius:20rpx;background:rgba(13,39,31,.42);box-shadow:inset 0 1rpx 0 rgba(255,255,255,.08);animation:user-details-down .2s ease-out}
.member-summary{display:flex;align-items:center}.member-mark{width:58rpx;height:58rpx;flex:none;border:2rpx solid rgba(246,219,153,.7);border-radius:50%;color:#f3d996;background:rgba(149,61,48,.72);font-family:STKaiti,KaiTi,serif;font-size:27rpx;font-weight:800;line-height:58rpx;text-align:center}.member-copy{min-width:0;flex:1;margin-left:16rpx}.member-copy view{color:#fff5dc;font-size:25rpx;font-weight:800}.member-copy text{display:block;margin-top:5rpx;overflow:hidden;color:rgba(255,245,220,.6);font-size:18rpx;white-space:nowrap;text-overflow:ellipsis}.upgrade-button{flex:none;margin-left:16rpx;padding:10rpx 18rpx;border:1rpx solid rgba(244,218,158,.5);border-radius:24rpx;color:#f5dfa7;background:rgba(255,255,255,.07);font-size:19rpx}
.profile-facts{margin-top:20rpx;padding-top:17rpx;border-top:1rpx solid rgba(247,239,216,.14);display:grid;grid-template-columns:1fr 1fr;gap:16rpx 26rpx}.profile-facts>view{display:flex;align-items:center;justify-content:space-between}.profile-facts text{color:rgba(255,245,220,.58);font-size:18rpx}.profile-facts label{color:#fff5dc;font-size:20rpx}.edit-profile label{color:#f0d796}
.asset-section{position:relative;overflow:hidden;margin-bottom:22rpx;padding:27rpx 24rpx 25rpx;border:1rpx solid rgba(150,61,49,.22);border-radius:24rpx;background:linear-gradient(125deg,rgba(255,252,241,.97),rgba(236,226,201,.94));box-shadow:0 12rpx 30rpx rgba(38,54,45,.09)}.asset-head{position:relative;display:flex;align-items:flex-start;justify-content:space-between}.asset-head>view:first-child text{display:block;color:#1d3027;font-family:STKaiti,KaiTi,serif;font-size:31rpx;font-weight:800}.asset-head>view:first-child label{display:block;margin-top:7rpx;color:#8b9188;font-size:18rpx}.asset-head>view:last-child{padding-top:5rpx;color:#697b71;font-size:20rpx}.asset-head>view:last-child text{margin-left:5rpx;color:#963d31;font-size:28rpx}.asset-grid{position:relative;margin-top:25rpx;display:grid;grid-template-columns:repeat(4,1fr)}.asset-item{position:relative;text-align:center}.asset-item:not(:last-child)::after{content:'';position:absolute;right:0;top:7rpx;width:1rpx;height:50rpx;background:rgba(49,92,80,.13)}.asset-item text,.asset-item label{display:block}.asset-item text{overflow:hidden;color:#263b31;font-size:25rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.asset-item label{margin-top:9rpx;color:#7d887f;font-size:18rpx}
.asset-actions{display:flex;align-items:center;gap:16rpx}.asset-actions>text{margin:0!important;padding:8rpx 18rpx;border-radius:22rpx;color:#fffaf0!important;background:#963d31;font-size:20rpx!important}.asset-actions>label{color:#697b71;font-size:20rpx}
@keyframes user-details-down{from{opacity:0;transform:translateY(-12rpx)}}
</style>
