<template>
  <view class="profile-page tab-page">
    <view class="header-bg" :class="{ compact: auth.isPlayer }">
      <view class="orb orb-one" /><view class="orb orb-two" />
      <view class="topbar"><view class="setting" @click="planned('设置中心')"><image src="/static/icons/gear.png" /></view></view>
      <view class="user-card">
        <view class="avatar"><image v-if="auth.user?.avatar" :src="assetUrl(auth.user.avatar)" mode="aspectFill" /><text v-else>{{ avatarText }}</text></view>
        <view class="user-main">
          <view class="name-row">
            <text class="nickname">{{ auth.user?.nickName || auth.user?.userName || '未登录' }}</text>
            <view v-if="auth.isPlayer" class="role-switch-trigger" @click="openRoleSheet">
              <text>{{ currentModeLabel }}</text><text class="swap-arrows">⇄</text>
            </view>
            <text v-else-if="auth.loggedIn" class="verified">已登录</text>
          </view>
          <view class="account">账号：{{ auth.user?.userName || '登录后查看' }}</view>
          <view class="role-row"><text v-for="tag in profileTags" :key="tag.text" class="role-tag" :class="tag.type">{{ tag.text }}</text></view>
        </view>
        <text class="chevron" @click="goUserProfile">›</text>
      </view>
      <view v-if="!auth.isPlayer" class="identity-banner">
        <view><view class="identity-title">{{ identityTitle }}</view><view class="identity-desc">{{ identityDescription }}</view></view>
        <view class="identity-action" @click="identityAction">{{ auth.isPlayer ? '进入工作台' : '了解入驻' }}</view>
      </view>
    </view>

    <view class="content" :class="{ compact: auth.isPlayer }">
      <view class="section order-section">
        <view class="section-head" @click="goCustomerOrders"><text>我的订单</text><view>全部订单 <text class="arrow">›</text></view></view>
        <view class="shortcut-grid order-grid">
          <view v-for="item in orderEntries" :key="item.label" class="shortcut" @click="openOrder(item.status)">
            <view class="icon-wrap" :style="{ background: item.background }"><image :src="item.icon" /></view>
            <text>{{ item.label }}</text>
          </view>
        </view>
      </view>

      <view v-if="auth.isPlayer" class="section player-section">
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
          <view class="shortcut" @click="planned('收益中心')"><view class="line-icon"><image src="/static/icons/wallet.png" /></view><text>收益中心</text><text class="soon">规划中</text></view>
        </view>
      </view>

      <view class="section">
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
        <view v-for="item in listEntries" :key="item.label" class="list-item" @click="planned(item.label)">
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
import { getWorkbench } from '@/api/player'
import { assetUrl } from '@/services/http'
import type { RecordData } from '@/types/api'

const auth = useAuthStore()
const mode = useAppModeStore()
const workbench = ref<RecordData>({})
const roleSheetVisible = ref(false)
onShow(async () => {
  if (auth.loggedIn && !auth.user) await auth.loadUser().catch(() => undefined)
  if (auth.isPlayer) workbench.value = await getWorkbench().catch(() => ({}))
})
onHide(() => closeRoleSheet())

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
const profileTags = computed(() => {
  const tags = roleLabels.value.map(text => ({ text, type: 'role' }))
  if (auth.isPlayer) {
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
const identityTitle = computed(() => auth.isPlayer ? '陪玩师身份已开通' : '成为陪玩师')
const identityDescription = computed(() => auth.isPlayer ? '接单、履约和服务进度集中管理' : '展示实力，和更多玩家一起游戏')

const orderEntries = [
  { label: '待付款', status: 'PENDING_PAYMENT', icon: '/static/icons/wallet.png', background: '#e3e7d8' },
  { label: '待接单', status: 'WAIT_ASSIGN', icon: '/static/icons/hourglass.png', background: '#eee2c8' },
  { label: '服务中', status: 'IN_SERVICE', icon: '/static/icons/gamepad.png', background: '#dce8dd' },
  { label: '待确认', status: 'PENDING_CONFIRM', icon: '/static/icons/check.png', background: '#efe0d7' },
  { label: '售后', status: 'AFTER_SALE', icon: '/static/icons/after-sale.png', background: '#dde4db' },
]
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
function goCustomerOrders() { uni.navigateTo({ url: '/pages/customer/orders' }) }
function openOrder(status: string) { uni.navigateTo({ url: `/subpackages/customer/order-list?status=${status}` }) }
function goWorkbench() { mode.switchMode('player'); switchMainTab('/pages/home/index', 0) }
function goDispatch() { uni.navigateTo({ url: '/subpackages/player/dispatches' }) }
function goPlayerOrders() { uni.navigateTo({ url: '/subpackages/player/orders' }) }
function goPlayerProfile() { uni.navigateTo({ url: '/subpackages/player/profile-edit' }) }
function goUserProfile() { uni.navigateTo({ url: '/subpackages/customer/profile-edit' }) }
function identityAction() { auth.isPlayer ? goWorkbench() : planned('陪玩师入驻') }
function serviceAction(key: string, label: string) {
  if (key === 'customer-service') return planned('在线客服')
  if (key === 'after-sale') return openOrder('AFTER_SALE')
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
.header-bg { position: relative; padding: 78rpx 28rpx 72rpx; color: #fff; background: linear-gradient(145deg, #242044, #5f46d6 68%, #7658ef); }
.orb { position: absolute; border-radius: 50%; background: rgba(255,255,255,.08); }.orb-one { width: 330rpx; height: 330rpx; right: -100rpx; top: -120rpx; }.orb-two { width: 180rpx; height: 180rpx; left: -80rpx; bottom: -80rpx; }
.topbar { position: relative; display: flex; align-items: center; justify-content: flex-end; margin-bottom: 24rpx; }.setting { width: 62rpx; height: 62rpx; display: flex; align-items: center; justify-content: center; border-radius: 50%; background: rgba(255,255,255,.12); }.setting image { width: 32rpx; height: 32rpx; }
.user-card { position: relative; display: flex; align-items: center; }.avatar { width: 112rpx; height: 112rpx; flex: none; border: 6rpx solid rgba(255,255,255,.28); border-radius: 50%; display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg,#8c75ff,#6849ef); font-size: 45rpx; font-weight: 800; }.user-main { min-width: 0; flex: 1; margin-left: 24rpx; }.name-row { display: flex; align-items: center; gap: 14rpx; }.nickname { max-width: 310rpx; overflow: hidden; white-space: nowrap; text-overflow: ellipsis; font-size: 38rpx; font-weight: 800; }.verified { padding: 5rpx 12rpx; border-radius: 100rpx; color: #e7e1ff; background: rgba(255,255,255,.13); font-size: 18rpx; }.account { margin-top: 10rpx; color: rgba(255,255,255,.62); font-size: 23rpx; }.role-row { display: flex; flex-wrap: wrap; gap: 9rpx; margin-top: 15rpx; }.role-tag { padding: 6rpx 13rpx; border-radius: 100rpx; color: #fff; background: rgba(19,16,45,.25); font-size: 18rpx; }.role-tag.online { color: #d9fff4; background: rgba(26,180,137,.3); }.role-tag.rating { color: #fff2c2; background: rgba(220,157,38,.28); }.role-tag.count { color: #ddebff; background: rgba(70,139,220,.27); }.role-tag.status { color: #e6e3ef; background: rgba(255,255,255,.12); }.chevron { padding: 20rpx 5rpx 20rpx 25rpx; color: rgba(255,255,255,.7); font-size: 52rpx; }
.identity-banner { position: absolute; left: 28rpx; right: 28rpx; bottom: -54rpx; min-height: 108rpx; padding: 24rpx 26rpx; box-sizing: border-box; border: 1rpx solid rgba(255,255,255,.55); border-radius: 24rpx; display: flex; align-items: center; justify-content: space-between; color: #39334e; background: linear-gradient(105deg,#fff,#f2eeff); box-shadow: 0 15rpx 35rpx rgba(43,34,88,.18); }.identity-title { font-size: 27rpx; font-weight: 800; }.identity-desc { margin-top: 8rpx; color: #8b8699; font-size: 20rpx; }.identity-action { padding: 14rpx 20rpx; border-radius: 100rpx; color: #fff; background: #7257e9; font-size: 21rpx; }
.content { padding: 82rpx 24rpx calc(250rpx + env(safe-area-inset-bottom)); }.section { margin-bottom: 22rpx; padding: 28rpx 24rpx; border-radius: 25rpx; background: #fff; box-shadow: 0 7rpx 25rpx rgba(31,38,58,.035); }.section-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 28rpx; }.section-head>text { font-size: 30rpx; font-weight: 800; }.section-head>view { color: #999eac; font-size: 22rpx; }.arrow { margin-left: 6rpx; color: #b0b4bf; font-size: 32rpx; }
.header-bg.compact { padding-bottom: 38rpx; }
.content.compact { padding-top: 24rpx; }
.role-switch-trigger { flex: none; padding: 7rpx 12rpx; border-radius: 18rpx; display: flex; align-items: center; gap: 7rpx; color: #f5eedb; background: rgba(255,255,255,.13); font-size: 18rpx; }
.swap-arrows { font-size: 22rpx; line-height: 1; }
.shortcut-grid { display: grid; }.order-grid { grid-template-columns: repeat(5,1fr); }.shortcut { position: relative; display: flex; flex-direction: column; align-items: center; gap: 12rpx; color: #454958; font-size: 22rpx; text-align: center; }.icon-wrap { width: 66rpx; height: 66rpx; border-radius: 21rpx; display: flex; align-items: center; justify-content: center; }.icon-wrap image { width: 40rpx; height: 40rpx; }.soon { color: #b1b5c1; font-size: 17rpx; }
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
.orb{background:rgba(240,232,208,.07)}.setting{background:rgba(255,250,235,.13)}.avatar{border-color:rgba(240,229,197,.38);border-radius:10rpx 32rpx 10rpx 32rpx;background:#963d31;font-family:STKaiti,KaiTi,serif}.avatar image{width:100%;height:100%;border-radius:inherit}.nickname{font-family:STKaiti,KaiTi,serif;letter-spacing:2rpx}
.identity-banner,.section{border:1rpx solid rgba(54,79,68,.18);border-radius:10rpx 26rpx 10rpx 26rpx;background:rgba(255,252,241,.92);box-shadow:0 12rpx 30rpx rgba(38,54,45,.08)}.identity-action{background:#315c50}.content{background:linear-gradient(rgba(239,234,217,.76),rgba(239,234,217,.92))}
.section-head>text{font-family:STKaiti,KaiTi,serif;color:#1d3027}.player-banner{background:linear-gradient(110deg,#365f52,#243f37);border-left:7rpx solid #963d31}.icon-wrap,.service-icon,.line-icon{position:relative;border:1rpx solid rgba(49,92,80,.25);border-radius:5rpx 18rpx 5rpx 18rpx}.icon-wrap::after,.service-icon::after{content:'';position:absolute;right:4rpx;bottom:4rpx;width:8rpx;height:8rpx;border-radius:50%;background:#963d31;opacity:.65}.line-icon{border-color:#aabcae}.logout{color:#963d31;background:rgba(255,252,241,.9)}.login{background:#315c50}.footer{color:#68766e}
</style>
