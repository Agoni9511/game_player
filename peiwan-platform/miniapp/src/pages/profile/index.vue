<template>
  <view class="profile-page tab-page">
    <view class="header-bg">
      <view class="orb orb-one" /><view class="orb orb-two" />
      <view class="topbar"><view class="setting" @click="planned('设置中心')"><image src="/static/icons/gear.svg" /></view></view>
      <view class="user-card">
        <view class="avatar">{{ avatarText }}</view>
        <view class="user-main">
          <view class="name-row"><text class="nickname">{{ auth.user?.nickName || auth.user?.userName || '未登录' }}</text><text v-if="auth.loggedIn" class="verified">已登录</text></view>
          <view class="account">账号：{{ auth.user?.userName || '登录后查看' }}</view>
          <view class="role-row"><text v-for="tag in profileTags" :key="tag.text" class="role-tag" :class="tag.type">{{ tag.text }}</text></view>
        </view>
        <text class="chevron" @click="planned('个人资料编辑')">›</text>
      </view>
      <view class="identity-banner">
        <view><view class="identity-title">{{ identityTitle }}</view><view class="identity-desc">{{ identityDescription }}</view></view>
        <view class="identity-action" @click="identityAction">{{ auth.isPlayer ? '进入工作台' : '了解入驻' }}</view>
      </view>
    </view>

    <view class="content">
      <view v-if="auth.isPlayer" class="mode-switch section">
        <view><view class="mode-title">当前使用身份</view><view class="mode-desc">切换后首页、订单和底部导航会同步变化</view></view>
        <view class="switch-box"><view :class="{ active: !mode.isPlayerMode }" @click="changeMode('customer')">顾客</view><view :class="{ active: mode.isPlayerMode }" @click="changeMode('player')">陪玩师</view></view>
      </view>
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
          <view class="controller"><image src="/static/icons/gamepad.svg" /></view>
          <view class="player-copy"><view>今天也要快乐接单</view><text>查看邀请、服务订单与工作状态</text></view>
          <view class="enter">进入 ›</view>
        </view>
        <view class="shortcut-grid player-grid">
          <view class="shortcut" @click="goDispatch"><view class="line-icon"><image src="/static/icons/hourglass.svg" /></view><text>待抢订单</text></view>
          <view class="shortcut" @click="goPlayerOrders"><view class="line-icon"><image src="/static/icons/list.svg" /></view><text>我的接单</text></view>
          <view class="shortcut" @click="planned('服务价格')"><view class="line-icon"><image src="/static/icons/price.svg" /></view><text>服务价格</text><text class="soon">规划中</text></view>
          <view class="shortcut" @click="planned('收益中心')"><view class="line-icon"><image src="/static/icons/wallet.svg" /></view><text>收益中心</text><text class="soon">规划中</text></view>
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
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useAuthStore } from '@/stores/auth'
import { useAppModeStore, type AppMode } from '@/stores/app-mode'
import { getWorkbench } from '@/api/player'
import type { RecordData } from '@/types/api'

const auth = useAuthStore()
const mode = useAppModeStore()
const workbench = ref<RecordData>({})
onShow(async () => {
  if (auth.loggedIn && !auth.user) await auth.loadUser().catch(() => undefined)
  if (auth.isPlayer) workbench.value = await getWorkbench().catch(() => ({}))
})

const avatarText = computed(() => (auth.user?.nickName || auth.user?.userName || '游').slice(0, 1))
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
  { label: '待付款', status: 'PENDING_PAYMENT', icon: '/static/icons/wallet.svg', background: '#e3e7d8' },
  { label: '待接单', status: 'WAIT_ASSIGN', icon: '/static/icons/hourglass.svg', background: '#eee2c8' },
  { label: '服务中', status: 'IN_SERVICE', icon: '/static/icons/gamepad.svg', background: '#dce8dd' },
  { label: '待确认', status: 'PENDING_CONFIRM', icon: '/static/icons/check.svg', background: '#efe0d7' },
  { label: '售后', status: 'AFTER_SALE', icon: '/static/icons/after-sale.svg', background: '#dde4db' },
]
const serviceEntries = [
  { key: 'customer-service', label: '联系客服', icon: '/static/icons/headset.svg', background: '#dfe6da' },
  { key: 'after-sale', label: '售后记录', icon: '/static/icons/after-sale.svg', background: '#eee0d7' },
  { key: 'messages', label: '消息通知', icon: '/static/icons/bell.svg', background: '#dce8dd', planned: true },
  { key: 'reviews', label: '我的评价', icon: '/static/icons/star.svg', background: '#ede4cb', planned: true },
  { key: 'favorites', label: '我的收藏', icon: '/static/icons/heart.svg', background: '#ecdfd6', planned: true },
  { key: 'coupons', label: '优惠卡券', icon: '/static/icons/ticket.svg', background: '#dfe5da', planned: true },
  { key: 'complaint', label: '投诉建议', icon: '/static/icons/alert.svg', background: '#eadfd4', planned: true },
  { key: 'history', label: '浏览足迹', icon: '/static/icons/history.svg', background: '#dce6df', planned: true },
]
const listEntries = [
  { label: '账号与安全', icon: '/static/icons/shield.svg', note: '密码管理' },
  { label: '服务规则与安全须知', icon: '/static/icons/document.svg', note: '可再次查看' },
  { label: '帮助与反馈', icon: '/static/icons/help.svg', note: '' },
  { label: '关于凌竞电竞', icon: '/static/icons/info.svg', note: '开发版' },
]

function switchMainTab(url: string, index: number) { uni.setStorageSync('peiwan_pending_tab', { index, mode: mode.mode, path: url, at: Date.now() }); uni.switchTab({ url }) }
function goCustomerOrders() { switchMainTab('/pages/customer/orders', 1) }
function openOrder(status: string) { uni.navigateTo({ url: `/subpackages/customer/order-list?status=${status}` }) }
function goWorkbench() { mode.switchMode('player'); switchMainTab('/pages/home/index', 0) }
function goDispatch() { uni.navigateTo({ url: '/subpackages/player/dispatches' }) }
function goPlayerOrders() { uni.navigateTo({ url: '/subpackages/player/orders' }) }
function identityAction() { auth.isPlayer ? goWorkbench() : planned('陪玩师入驻') }
function serviceAction(key: string, label: string) {
  if (key === 'customer-service') return planned('在线客服')
  if (key === 'after-sale') return openOrder('AFTER_SALE')
  planned(label)
}
function planned(name: string) { if(name==='服务规则与安全须知'){uni.removeStorageSync('peiwan_service_notice_v1');uni.switchTab({url:'/pages/home/index'});return}uni.showToast({ title: `${name}将在后续版本开放`, icon: 'none' }) }
function goLogin() { uni.navigateTo({ url: '/pages/auth/login' }) }
function changeMode(value: AppMode) { mode.switchMode(value); uni.showToast({ title: value === 'player' ? '已切换至陪玩师端' : '已切换至顾客端' }); setTimeout(() => switchMainTab('/pages/home/index', 0), 350) }
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
.mode-switch{display:flex;align-items:center;justify-content:space-between}.mode-title{color:#343242;font-size:26rpx;font-weight:800}.mode-desc{margin-top:8rpx;color:#9b9fac;font-size:18rpx}.switch-box{padding:6rpx;border-radius:16rpx;display:flex;background:#f1eff8}.switch-box view{padding:13rpx 17rpx;border-radius:12rpx;color:#9295a2;font-size:20rpx}.switch-box .active{color:#fff;background:#7357ef;box-shadow:0 5rpx 13rpx rgba(90,65,200,.2)}
.shortcut-grid { display: grid; }.order-grid { grid-template-columns: repeat(5,1fr); }.shortcut { position: relative; display: flex; flex-direction: column; align-items: center; gap: 12rpx; color: #454958; font-size: 22rpx; text-align: center; }.icon-wrap { width: 66rpx; height: 66rpx; border-radius: 21rpx; display: flex; align-items: center; justify-content: center; }.icon-wrap image { width: 40rpx; height: 40rpx; }.soon { color: #b1b5c1; font-size: 17rpx; }
.online { display: flex; align-items: center; gap: 8rpx; }.online text { width: 11rpx; height: 11rpx; border-radius: 50%; background: #2cc9a5; }.player-banner { margin-bottom: 28rpx; padding: 23rpx; border-radius: 19rpx; display: flex; align-items: center; color: #fff; background: linear-gradient(110deg,#6650de,#8b6df1); }.controller { width: 68rpx; }.controller image { width: 48rpx; height: 48rpx; filter: brightness(0) invert(1); }.player-copy { flex: 1; }.player-copy view { font-size: 27rpx; font-weight: 700; }.player-copy text { display: block; margin-top: 7rpx; color: rgba(255,255,255,.66); font-size: 19rpx; }.enter { font-size: 21rpx; }.player-grid { grid-template-columns: repeat(4,1fr); }.line-icon { width: 58rpx; height: 58rpx; border: 2rpx solid #ded8fb; border-radius: 18rpx; display: flex; align-items: center; justify-content: center; }.line-icon image { width: 37rpx; height: 37rpx; }
.service-grid { grid-template-columns: repeat(4,1fr); row-gap: 34rpx; }.service-icon { width: 64rpx; height: 64rpx; border-radius: 20rpx; display: flex; align-items: center; justify-content: center; }.service-icon image { width: 39rpx; height: 39rpx; }.list-section { padding-top: 5rpx; padding-bottom: 5rpx; }.list-item { min-height: 94rpx; border-bottom: 1rpx solid #f0f1f4; display: flex; align-items: center; justify-content: space-between; }.list-item:last-child { border: 0; }.list-left,.list-right { display: flex; align-items: center; }.mini-icon { width: 50rpx; display: flex; align-items: center; }.mini-icon image { width: 31rpx; height: 31rpx; }.list-left>text { color: #414554; font-size: 26rpx; }.list-right { color: #a4a8b4; font-size: 21rpx; }
.logout,.login { height: 90rpx; line-height: 90rpx; border-radius: 20rpx; font-size: 27rpx; }.logout { color: #e1546a; background: #fff; }.login { color: #fff; background: #7357ef; }.footer { padding: 28rpx 0 12rpx; color: #b0b4bf; font-size: 19rpx; text-align: center; }
</style>
<style scoped lang="scss">
.profile-page{background:#eee9da url('/static/ink-tactical-bg.jpg') center top/100% auto no-repeat}.header-bg{color:#f9f2df;background:linear-gradient(135deg,rgba(24,46,38,.95),rgba(57,92,77,.88));border-bottom:6rpx solid rgba(150,61,49,.7)}
.orb{background:rgba(240,232,208,.07)}.setting{background:rgba(255,250,235,.13)}.avatar{border-color:rgba(240,229,197,.38);border-radius:10rpx 32rpx 10rpx 32rpx;background:#963d31;font-family:STKaiti,KaiTi,serif}.nickname{font-family:STKaiti,KaiTi,serif;letter-spacing:2rpx}
.identity-banner,.section{border:1rpx solid rgba(54,79,68,.18);border-radius:10rpx 26rpx 10rpx 26rpx;background:rgba(255,252,241,.92);box-shadow:0 12rpx 30rpx rgba(38,54,45,.08)}.identity-action,.switch-box .active{background:#315c50}.content{background:linear-gradient(rgba(239,234,217,.76),rgba(239,234,217,.92))}
.section-head>text,.mode-title{font-family:STKaiti,KaiTi,serif;color:#1d3027}.switch-box{background:#e5e6d9}.player-banner{background:linear-gradient(110deg,#365f52,#243f37);border-left:7rpx solid #963d31}.icon-wrap,.service-icon,.line-icon{position:relative;border:1rpx solid rgba(49,92,80,.25);border-radius:5rpx 18rpx 5rpx 18rpx}.icon-wrap::after,.service-icon::after{content:'';position:absolute;right:4rpx;bottom:4rpx;width:8rpx;height:8rpx;border-radius:50%;background:#963d31;opacity:.65}.line-icon{border-color:#aabcae}.logout{color:#963d31;background:rgba(255,252,241,.9)}.login{background:#315c50}.footer{color:#68766e}
</style>
