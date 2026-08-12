<template>
  <view class="page tab-page">
    <template v-if="mode.isPlayerMode">
      <view class="card status-card"><view><view class="label">当前状态</view><view class="work-status">{{ workStatusLabel }}</view></view><button size="mini" :disabled="toggling" @click="toggleStatus">{{ toggling ? '切换中...' : workStatus==='AVAILABLE'?'暂停接单':'开始接单' }}</button></view>
      <view class="stats"><view><text>{{ workbench.pendingDispatchCount || 0 }}</text><label>待响应邀请</label></view><view><text>{{ workbench.activeOrderCount || 0 }}</text><label>进行中订单</label></view><view><text>{{ workbench.completedOrderCount || 0 }}</text><label>已完成服务</label></view></view>
      <view class="card"><view class="section-title">快捷处理</view><view class="grid player-grid"><view @click="goPage('/subpackages/player/dispatches')">待抢订单</view><view @click="goPage('/subpackages/player/orders')">服务订单</view><view @click="goPage('/subpackages/player/settlement')">收益中心</view></view></view>
    </template>
    <template v-else>
      <view class="customer-head"><view class="title">今晚，想怎么玩？</view><view class="customer-seal">寻伴</view></view>
      <view class="service-search" @click="openSearch"><image src="/static/icons/search.png" /><input v-model.trim="keyword" disabled placeholder="搜索游戏、套餐或陪玩师" /><view>搜索</view></view>
      <view class="mode-grid">
        <view class="mode-card primary-mode" @click="openHall">
          <view class="mode-copy"><text>服务大厅</text><label>按游戏挑选，即时下单</label><view>去逛逛 ›</view></view><image class="mode-art" src="/static/home/service-hall.jpg" mode="aspectFill" />
        </view>
        <view class="mode-card package-mode" @click="openPackage">
          <view class="mode-copy"><text>精选套餐</text><label>热门组合更划算</label></view><image class="mode-art" src="/static/home/curated-package.jpg" mode="aspectFill" />
        </view>
        <view class="mode-card consult-mode" @click="planned('即时咨询')">
          <view class="mode-copy"><text>即时咨询</text><label>选前先问，快速答疑</label></view><image class="mode-art" src="/static/home/consultation.jpg" mode="aspectFill" />
        </view>
        <view class="mode-card activity-mode" @click="planned('活动中心')">
          <view class="mode-copy"><text>活动中心</text><label>限时福利与主题局</label></view><image class="mode-art" src="/static/home/activity.jpg" mode="aspectFill" />
        </view>
        <view class="mode-card appoint-mode" @click="openPlayers">
          <view class="mode-copy"><text>指定陪玩</text><label>按风格选择心仪队友</label></view><image class="mode-art" src="/static/home/choose-player.jpg" mode="aspectFill" />
        </view>
      </view>
      <view class="home-announcement" @click="openAnnouncement">
        <view class="announcement-badge">公告资讯</view>
        <text>{{ latestAnnouncement.title }}</text>
        <label>{{ latestAnnouncement.date }}</label>
        <view class="announcement-arrow">›</view>
      </view>
      <view class="recommend-section">
        <view class="recommend-head"><view><text>推荐套餐</text><label>高人气组合，玩得更尽兴</label></view><view @click="openPackage">查看更多 ›</view></view>
        <view v-if="recommendations.length" class="recommend-grid">
          <view class="recommend-card recommend-main" @click="openRecommended(recommendations[0])">
            <image :src="String(recommendations[0].coverUrl)" mode="aspectFill" />
            <view class="recommend-shade"></view>
            <view class="recommend-copy"><label>本周主推</label><text>{{ recommendations[0].productName }}</text><view>{{ recommendations[0].subtitle }}</view><strong>¥{{ money(recommendations[0].minPrice) }} 起</strong></view>
          </view>
          <view class="recommend-side">
            <view v-for="item in recommendations.slice(1,3)" :key="String(item.id)" class="recommend-card recommend-small" @click="openRecommended(item)">
              <image :src="String(item.coverUrl)" mode="aspectFill" />
              <view class="recommend-shade"></view>
              <view class="recommend-copy"><text>{{ item.productName }}</text><view>{{ item.subtitle }}</view><strong>¥{{ money(item.minPrice) }} 起</strong></view>
            </view>
          </view>
        </view>
      </view>
      <view class="player-recommend-section">
        <view class="recommend-head"><view><text>推荐陪玩</text><label>平台严选，在线即刻出发</label></view><view @click="openPlayers">查看更多 ›</view></view>
        <scroll-view v-if="recommendedPlayers.length" scroll-x class="player-recommend-scroll" :show-scrollbar="false">
          <view class="player-recommend-row">
            <view v-for="player in recommendedPlayers" :key="String(player.id)" class="player-recommend-card" @click="openPlayer(player)">
              <view class="player-avatar">
                <image v-if="player.avatarUrl" :src="assetUrl(player.avatarUrl)" mode="aspectFill" />
                <text v-else>{{ String(player.nickname || '陪').slice(0, 1) }}</text>
                <label class="online-dot" />
              </view>
              <view class="player-name"><text>{{ player.nickname || '陪玩师' }}</text><label :class="genderClass(player.gender)">{{ genderText(player.gender) }}</label></view>
              <view class="player-status"><text>在线可约</text><label>{{ player.primaryGame || '多游戏陪玩' }}</label></view>
              <view class="player-rating"><text class="rating-score">★ {{ score(player.ratingScore) }}</text><text>{{ player.ratingCount || 0 }} 条评价</text><label>{{ player.orderCount || 0 }} 单</label></view>
              <view class="player-tags"><text v-for="tag in playerTags(player)" :key="String(tag.id)" :style="playerTagStyle(tag)">{{ tag.tagName }}</text><text v-if="!playerTags(player).length">平台认证</text></view>
              <view class="player-intro">{{ player.introduction || '技术在线，认真陪伴每一局。' }}</view>
              <view class="player-action"><text>{{ player.playerLevelName || '认证陪玩师' }}</text><text class="action-link">查看主页 ›</text></view>
            </view>
          </view>
        </scroll-view>
        <view v-else-if="playersLoading" class="player-recommend-empty">正在为你挑选默契队友...</view>
        <view v-else class="player-recommend-empty" @click="openPlayers">暂无在线推荐，去看看全部陪玩师 ›</view>
      </view>
    </template>
  </view>
  <FirstVisitNotice :visible="showNotice" @confirm="acceptNotice" @close="showNotice=false" />
</template>
<style scoped>
.player-recommend-section{margin-top:36rpx}.player-recommend-scroll{width:100%;white-space:nowrap}.player-recommend-row{display:flex;gap:18rpx;padding:2rpx 4rpx 18rpx}.player-recommend-card{width:340rpx;flex:none;padding:22rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:12rpx 30rpx 12rpx 30rpx;box-sizing:border-box;background:rgba(255,252,241,.96);box-shadow:0 10rpx 26rpx rgba(35,53,43,.08)}.player-avatar{position:relative;width:122rpx;height:122rpx;margin:0 auto;border:4rpx solid #e5dfcd;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fffaf0;background:linear-gradient(145deg,#55786b,#29483d);font-family:STKaiti,KaiTi,serif;font-size:40rpx;overflow:visible}.player-avatar image{width:100%;height:100%;border-radius:50%;background:#e8e5d9}.online-dot{position:absolute;right:2rpx;bottom:3rpx;width:21rpx;height:21rpx;border:5rpx solid #fffaf0;border-radius:50%;background:#42ba85}.player-name{margin-top:15rpx;display:flex;align-items:center;justify-content:center;gap:9rpx}.player-name text{max-width:205rpx;overflow:hidden;font-family:STKaiti,KaiTi,serif;font-size:29rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.player-name label{padding:4rpx 10rpx;border-radius:13rpx;font-size:16rpx}.player-name label.male{color:#35709b;background:#e1eff8}.player-name label.female{color:#a44c6d;background:#f8e4ec}.player-name label.unknown{color:#66746d;background:#e5e9e5}.player-status{margin-top:8rpx;display:flex;align-items:center;justify-content:center;gap:10rpx;font-size:18rpx}.player-status text{position:relative;padding-left:15rpx;color:#31805f}.player-status text:before{content:'';position:absolute;left:0;top:8rpx;width:8rpx;height:8rpx;border-radius:50%;background:#42ba85}.player-status label{max-width:160rpx;overflow:hidden;color:#718078;white-space:nowrap;text-overflow:ellipsis}.player-rating{margin-top:15rpx;padding:13rpx 0;border-top:1rpx solid rgba(49,92,80,.1);border-bottom:1rpx solid rgba(49,92,80,.1);display:flex;align-items:center;gap:9rpx;font-size:17rpx}.player-rating .rating-score{color:#963d31;font-size:21rpx;font-weight:700}.player-rating>text{color:#927d64}.player-rating label{margin-left:auto;color:#5e6d65}.player-tags{height:43rpx;margin-top:14rpx;display:flex;gap:8rpx;overflow:hidden}.player-tags text{padding:5rpx 10rpx;border:1rpx solid rgba(138,101,62,.16);border-radius:14rpx;color:#8a653e;background:#eee3cd;font-size:15rpx;white-space:nowrap}.player-intro{height:57rpx;margin-top:12rpx;overflow:hidden;color:#6f7a73;font-size:18rpx;line-height:29rpx;white-space:normal;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}.player-action{margin-top:14rpx;display:flex;align-items:center;color:#8b7660;font-size:17rpx}.player-action .action-link{margin-left:auto;color:#315c50;font-size:18rpx;font-weight:700}.player-recommend-empty{padding:48rpx 20rpx;border:1rpx dashed rgba(49,92,80,.24);border-radius:24rpx;color:#7b8780;text-align:center;background:rgba(255,252,241,.55);font-size:21rpx}
</style>
<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useAuthStore } from '@/stores/auth'
import { useAppModeStore } from '@/stores/app-mode'
import { getWorkbench, updateWorkStatus } from '@/api/player'
import { getCatalogPlayers, getCatalogProducts } from '@/api/customer'
import { assetUrl } from '@/services/http'
import FirstVisitNotice from '@/components/FirstVisitNotice.vue'
import type { RecordData } from '@/types/api'

const NOTICE_KEY = 'peiwan_service_notice_v1'
const latestAnnouncement = {
  title: '凌竞电竞开发测试公告',
  date: '08-09',
  fullDate: '2026年8月9日',
  content: '凌竞电竞小程序当前为开发测试版本，服务大厅、订单流程、钱包余额支付与陪玩师工作台已开放体验。充值、真实微信支付和在线客服仍处于模拟或规划阶段，请勿用于真实交易。',
}
const auth = useAuthStore()
const mode = useAppModeStore()
const showNotice = ref(false)
const keyword = ref('')
const workbench = ref<RecordData>({})
const packageProducts = ref<RecordData[]>([])
const recommendedPlayers = ref<RecordData[]>([])
const playersLoading = ref(false)
const toggling = ref(false)
const workStatus = computed(() => String((workbench.value.player as RecordData | undefined)?.workStatus || 'OFFLINE'))
const workStatusLabel = computed(() => ({ AVAILABLE: '接单中', BUSY: '服务中', OFFLINE: '休息中' } as Record<string, string>)[workStatus.value] || '休息中')
const packageFallbacks: RecordData[] = [
  { id: 'fallback-delta', productName: '战术护航组合', subtitle: '默契开局，稳步撤离', minPrice: 99, coverUrl: '/static/home/service-hall.jpg' },
  { id: 'fallback-growth', productName: '排位进阶套餐', subtitle: '实战陪练，针对提升', minPrice: 168, coverUrl: '/static/home/choose-player.jpg' },
  { id: 'fallback-newcomer', productName: '新人轻享套餐', subtitle: '初次体验，轻松开玩', minPrice: 58, coverUrl: '/static/home/curated-package.jpg' },
]
const recommendations = computed(() => {
  const rows: RecordData[] = packageProducts.value.map((item, index) => ({
    ...item,
    coverUrl: item.coverUrl ? assetUrl(item.coverUrl) : packageFallbacks[index]?.coverUrl,
  }))
  const used = new Set(rows.map(item => String(item.productName || '')))
  return [...rows, ...packageFallbacks.filter(item => !used.has(String(item.productName)))].slice(0, 3)
})

onShow(async () => {
  showNotice.value = !uni.getStorageSync(NOTICE_KEY)
  if (auth.loggedIn && !auth.user) await auth.loadUser().catch(() => undefined)
  mode.ensureAllowed()
  if (mode.isPlayerMode && auth.isPlayer) workbench.value = await getWorkbench()
  if (!mode.isPlayerMode) {
    try {
      packageProducts.value = (await getCatalogProducts({ productType: 'PACKAGE', size: 3 })).records || []
    } catch {
      packageProducts.value = []
    }
    playersLoading.value = true
    try {
      recommendedPlayers.value = (await getCatalogPlayers({ workStatus: 'AVAILABLE', sort: 'RATING', size: 6 })).records || []
    } catch {
      recommendedPlayers.value = []
    } finally {
      playersLoading.value = false
    }
  }
})

function acceptNotice() { uni.setStorageSync(NOTICE_KEY, true); showNotice.value = false }
function openSearch() { uni.navigateTo({ url: '/pages/discover/index' }) }
function openHall() { uni.removeStorageSync('peiwan_catalog_entry'); goTab('/pages/hall/index') }
function openPackage() { uni.navigateTo({ url: '/pages/discover/index?productType=PACKAGE' }) }
function openPlayers() { goTab('/pages/players/index') }
function openPlayer(player: RecordData) { uni.navigateTo({ url: `/subpackages/customer/player-detail?id=${Number(player.id)}` }) }
function openAnnouncement() {
  uni.showModal({
    title: latestAnnouncement.title,
    content: `${latestAnnouncement.fullDate}\n\n${latestAnnouncement.content}`,
    showCancel: false,
    confirmText: '我知道了',
  })
}
function openRecommended(item: RecordData) {
  if (typeof item.id === 'number') {
    uni.navigateTo({ url: `/subpackages/customer/product-detail?id=${item.id}` })
    return
  }
  openPackage()
}
function money(value: unknown) { return Number(value || 0).toFixed(0) }
function score(value: unknown) { const result = Number(value || 0); return result > 0 ? result.toFixed(1) : '新秀' }
function playerTags(player: RecordData) { return ((player.tags || []) as RecordData[]).slice(0, 3) }
function genderText(value: unknown) { return ({ MALE: '♂ 男生', FEMALE: '♀ 女生', UNKNOWN: '保密' } as Record<string, string>)[String(value)] || '保密' }
function genderClass(value: unknown) { return String(value) === 'MALE' ? 'male' : String(value) === 'FEMALE' ? 'female' : 'unknown' }
function playerTagStyle(tag: RecordData) { const color = String(tag.tagColor || '#8a653e'); return `color:${color};border-color:${color}55;background:${color}12` }
async function toggleStatus() {
  if (toggling.value || workStatus.value === 'BUSY') return
  const target = workStatus.value === 'AVAILABLE' ? 'OFFLINE' : 'AVAILABLE'
  toggling.value = true
  try {
    await updateWorkStatus(target)
    workbench.value = await getWorkbench()
    uni.showToast({ title: target === 'AVAILABLE' ? '已开始接单' : '已暂停接单', icon: 'success' })
  } finally {
    toggling.value = false
  }
}
const goTab = (url: string) => {
  uni.switchTab({ url })
}
const goPage = (url: string) => uni.navigateTo({ url })
const planned = (name: string) => uni.showToast({ title: `${name}将在后续版本开放`, icon: 'none' })
</script>
<style scoped>.tab-page{padding-bottom:170rpx}.hero{position:relative;min-height:230rpx;padding:50rpx 18rpx 42rpx}.hero .muted{margin-top:14rpx}.eyebrow{margin-bottom:14rpx;color:#4f6f62;font-weight:700;letter-spacing:4rpx}.seal{position:absolute;right:12rpx;top:35rpx;width:64rpx;height:64rpx;border:4rpx double #963d31;color:#963d31;display:flex;align-items:center;justify-content:center;font-family:STKaiti,KaiTi,serif;font-weight:800;transform:rotate(5deg)}.section-title{font-family:STKaiti,KaiTi,serif;font-size:32rpx;font-weight:800;margin-bottom:22rpx}.notice{background:rgba(195,211,194,.45);border-left:6rpx solid #557869;color:#365247;padding:24rpx;border-radius:4rpx 16rpx 16rpx 4rpx;line-height:1.6}.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16rpx}.grid view{border:1rpx solid rgba(60,87,73,.18);background:rgba(235,238,225,.72);padding:30rpx 10rpx;text-align:center;border-radius:8rpx 18rpx 8rpx 18rpx}.status-card{display:flex;align-items:center;justify-content:space-between}.label{color:#76837b;font-size:22rpx}.work-status{margin-top:10rpx;color:#315c50;font-size:36rpx;font-weight:800}.status-card button{margin:0;background:#315c50;color:#fff}.stats{display:grid;grid-template-columns:repeat(3,1fr);gap:15rpx;margin-bottom:24rpx}.stats view{padding:26rpx 8rpx;border:1rpx solid rgba(54,79,68,.16);border-radius:8rpx 20rpx 8rpx 20rpx;text-align:center;background:rgba(255,253,244,.88)}.stats text{display:block;color:#21332b;font-size:36rpx;font-weight:800}.stats label{display:block;margin-top:9rpx;color:#76837b;font-size:19rpx}.player-grid view{color:#345f53;background:rgba(210,223,207,.62)}.recommend-section{margin-top:30rpx}.recommend-head{margin:0 4rpx 18rpx;display:flex;align-items:flex-end;justify-content:space-between}.recommend-head>view:first-child text,.recommend-head>view:first-child label{display:block}.recommend-head>view:first-child text{font-family:STKaiti,KaiTi,serif;font-size:34rpx;font-weight:800}.recommend-head>view:first-child label{margin-top:6rpx;color:#7b8780;font-size:19rpx}.recommend-head>view:last-child{color:#963d31;font-size:20rpx}.recommend-grid{height:390rpx;display:grid;grid-template-columns:1.12fr .88fr;gap:16rpx}.recommend-side{display:grid;grid-template-rows:1fr 1fr;gap:16rpx}.recommend-card{position:relative;overflow:hidden;border:1rpx solid rgba(49,92,80,.18);border-radius:28rpx;background:#315c50;box-shadow:0 10rpx 26rpx rgba(35,53,43,.1)}.recommend-card image,.recommend-shade{position:absolute;inset:0;width:100%;height:100%}.recommend-shade{background:linear-gradient(180deg,rgba(20,37,30,.04) 18%,rgba(20,37,30,.88) 100%)}.recommend-copy{position:absolute;z-index:2;left:20rpx;right:18rpx;bottom:18rpx;color:#fffaf0}.recommend-copy>label{display:inline-block;margin-bottom:10rpx;padding:5rpx 11rpx;border-radius:16rpx;background:#963d31;font-size:17rpx}.recommend-copy>text{display:block;overflow:hidden;font-family:STKaiti,KaiTi,serif;font-size:29rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.recommend-copy>view{margin-top:7rpx;overflow:hidden;color:rgba(255,250,240,.76);font-size:18rpx;white-space:nowrap;text-overflow:ellipsis}.recommend-copy>strong{display:block;margin-top:11rpx;color:#f5d9aa;font-size:23rpx}.recommend-small .recommend-copy{left:16rpx;right:14rpx;bottom:13rpx}.recommend-small .recommend-copy>text{font-size:23rpx}.recommend-small .recommend-copy>view{margin-top:4rpx;font-size:16rpx}.recommend-small .recommend-copy>strong{margin-top:6rpx;font-size:19rpx}</style>
