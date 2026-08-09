<template>
  <view v-if="mode.isPlayerMode" class="page tab-page player-mode">
    <view class="player-head"><view class="eyebrow">接单中心</view><view class="title">准备好开始今天的服务了吗？</view><text>开启后可接收平台派单邀请</text></view>
    <view class="status-card"><view><text>当前状态</text><view>{{ workStatusLabel }}</view></view><button :disabled="toggling || workStatus === 'BUSY'" @click="toggleStatus">{{ toggling ? '切换中...' : workStatus === 'AVAILABLE' ? '暂停接单' : '开始接单' }}</button></view>
    <view class="work-stats"><view><text>{{ workbench.pendingDispatchCount || 0 }}</text><label>待响应</label></view><view><text>{{ workbench.activeOrderCount || 0 }}</text><label>服务中</label></view><view><text>{{ workbench.completedOrderCount || 0 }}</text><label>已完成</label></view></view>
    <view class="work-actions"><view @click="goPage('/subpackages/player/dispatches')">待抢订单</view><view @click="goPage('/subpackages/player/orders')">服务订单</view></view>
  </view>

  <view v-else class="players-page">
    <view class="players-head"><view><text>找到默契队友</text><label>平台审核陪玩师，按风格安心选择</label></view><view class="head-seal">严选</view></view>
    <view class="player-search"><image src="/static/icons/search.png"/><input v-model.trim="keyword" placeholder="搜索昵称、游戏或标签" confirm-type="search"/><text v-if="keyword" @click="keyword=''">×</text></view>
    <scroll-view scroll-x class="filter-scroll" :show-scrollbar="false"><view class="filter-row"><view :class="{active:!gameFilter}" @click="gameFilter=''">全部游戏</view><view v-for="game in games" :key="String(game.id)" :class="{active:gameFilter===String(game.gameName)}" @click="gameFilter=String(game.gameName)">{{ game.gameName }}</view></view></scroll-view>
    <view class="availability"><view :class="{active:!availableOnly}" @click="availableOnly=false">全部陪玩师</view><view :class="{active:availableOnly}" @click="availableOnly=true"><text></text>当前可接单</view><label>{{ visiblePlayers.length }} 位</label></view>

    <view class="player-grid">
      <view v-for="item in visiblePlayers" :key="String(item.id)" class="player-card" @click="openPlayer(item)">
        <view class="avatar-wrap">
          <image v-if="item.avatarUrl" :src="assetUrl(item.avatarUrl)" mode="aspectFill"/>
          <view v-else class="avatar-fallback">{{ String(item.nickname || '陪').slice(0,1) }}</view>
          <view class="status-dot" :class="statusTone(item.workStatus)"></view>
        </view>
        <view class="player-main">
          <view class="name-row"><text>{{ item.nickname }}</text><label>{{ statusText(item.workStatus) }}</label></view>
          <view class="game-line"><text>{{ item.primaryGame || '多游戏陪玩' }}</text><label>★ {{ score(item.ratingScore) }}</label><label>{{ item.orderCount || 0 }} 单</label></view>
          <view class="intro">{{ item.introduction || '期待与你一起开黑，轻松享受每一局。' }}</view>
          <view class="tag-row"><text v-for="tag in tags(item).slice(0,3)" :key="String(tag.id)" :style="tagStyle(tag)">{{ tag.tagName }}</text></view>
        </view>
        <view class="card-arrow">›</view>
      </view>
    </view>
    <view v-if="!loading && !visiblePlayers.length" class="empty">暂时没有符合条件的陪玩师</view>
    <view v-if="loading" class="empty">正在寻找合适的队友...</view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getCatalogGames, getCatalogPlayers } from '@/api/customer'
import { getWorkbench, updateWorkStatus } from '@/api/player'
import { assetUrl } from '@/services/http'
import { useAppModeStore } from '@/stores/app-mode'
import type { RecordData } from '@/types/api'

const mode = useAppModeStore()
const players = ref<RecordData[]>([])
const games = ref<RecordData[]>([])
const keyword = ref('')
const gameFilter = ref('')
const availableOnly = ref(false)
const loading = ref(false)
const workbench = ref<RecordData>({})
const toggling = ref(false)
const workStatus = computed(() => String((workbench.value.player as RecordData | undefined)?.workStatus || 'OFFLINE'))
const workStatusLabel = computed(() => statusText(workStatus.value))
const visiblePlayers = computed(() => {
  const key = keyword.value.toLowerCase()
  return players.value.filter(item => {
    if (availableOnly.value && String(item.workStatus) !== 'AVAILABLE') return false
    if (gameFilter.value && String(item.primaryGame || '') !== gameFilter.value) return false
    if (!key) return true
    const tagText = tags(item).map(tag => tag.tagName).join(' ')
    return [item.nickname, item.primaryGame, item.introduction, tagText].some(value => String(value || '').toLowerCase().includes(key))
  })
})

onShow(async () => {
  mode.ensureAllowed()
  if (mode.isPlayerMode) {
    workbench.value = await getWorkbench().catch(() => ({}))
    return
  }
  loading.value = true
  try {
    const [playerPage, gameRows] = await Promise.all([getCatalogPlayers(), getCatalogGames()])
    players.value = playerPage.records || []
    games.value = gameRows || []
  } finally {
    loading.value = false
  }
})

function tags(item: RecordData) { return (item.tags || []) as RecordData[] }
function score(value: unknown) { const result = Number(value || 0); return result > 0 ? result.toFixed(1) : '新秀' }
function statusText(value: unknown) { return ({ AVAILABLE:'可接单', BUSY:'服务中', OFFLINE:'休息中', SUSPENDED:'暂停服务' } as Record<string,string>)[String(value)] || '休息中' }
function statusTone(value: unknown) { return String(value) === 'AVAILABLE' ? 'online' : String(value) === 'BUSY' ? 'busy' : 'offline' }
function tagStyle(tag: RecordData) { const color = String(tag.tagColor || '#315c50'); return `color:${color};border-color:${color}55;background:${color}12` }
function openPlayer(item: RecordData) {
  uni.showModal({
    title: String(item.nickname || '陪玩师资料'),
    content: `${item.primaryGame || '多游戏陪玩'} · 评分 ${score(item.ratingScore)}\n\n${item.introduction || '该陪玩师暂未填写个人介绍。'}`,
    confirmText: '查看服务',
    cancelText: '继续浏览',
    success: result => { if (result.confirm) uni.switchTab({ url: '/pages/hall/index' }) },
  })
}
async function toggleStatus() {
  if (toggling.value || workStatus.value === 'BUSY') return
  const target = workStatus.value === 'AVAILABLE' ? 'OFFLINE' : 'AVAILABLE'
  toggling.value = true
  try { await updateWorkStatus(target); workbench.value = await getWorkbench(); uni.showToast({ title: target === 'AVAILABLE' ? '已开始接单' : '已暂停接单' }) }
  finally { toggling.value = false }
}
function goPage(url: string) { uni.navigateTo({ url }) }
</script>

<style scoped>
.players-page,.player-mode{min-height:100vh;padding:32rpx 26rpx calc(250rpx + env(safe-area-inset-bottom));box-sizing:border-box;background-color:#eee9da;background-image:radial-gradient(circle at 88% 2%,rgba(91,126,108,.15),transparent 34%),linear-gradient(180deg,rgba(244,240,225,.86),rgba(244,240,225,.96))}.players-head{padding:20rpx 8rpx 26rpx;display:flex;align-items:center;justify-content:space-between}.players-head text,.players-head label{display:block}.players-head text{font-family:STKaiti,KaiTi,serif;font-size:43rpx;font-weight:800}.players-head label{margin-top:9rpx;color:#748078;font-size:21rpx}.head-seal{padding:9rpx;border:3rpx double #963d31;color:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.player-search{height:82rpx;padding:0 22rpx;border:1rpx solid rgba(49,92,80,.2);border-radius:42rpx;display:flex;align-items:center;background:rgba(255,252,241,.94);box-shadow:0 9rpx 24rpx rgba(35,53,43,.06)}.player-search image{width:34rpx;height:34rpx}.player-search input{flex:1;margin-left:15rpx;font-size:24rpx}.player-search>text{width:46rpx;height:46rpx;border-radius:50%;color:#718078;background:#e5e9df;line-height:43rpx;text-align:center;font-size:31rpx}.filter-scroll{margin-top:22rpx;white-space:nowrap}.filter-row{display:flex;gap:12rpx}.filter-row>view{padding:13rpx 23rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:28rpx;color:#708078;background:rgba(255,252,241,.74);font-size:21rpx}.filter-row .active{border-color:#315c50;color:#fffaf0;background:#315c50}.availability{margin:24rpx 4rpx 18rpx;display:flex;align-items:center;gap:12rpx}.availability>view{padding:9rpx 15rpx;border-radius:22rpx;color:#728078;background:#e3e7dc;font-size:19rpx}.availability>view.active{color:#fffaf0;background:#55786b}.availability>view text{display:inline-block;width:10rpx;height:10rpx;margin-right:7rpx;border-radius:50%;background:#4cb88a}.availability>label{margin-left:auto;color:#89938d;font-size:19rpx}.player-grid{display:flex;flex-direction:column;gap:18rpx}.player-card{position:relative;min-height:178rpx;padding:22rpx 54rpx 22rpx 20rpx;border:1rpx solid rgba(49,92,80,.17);border-radius:28rpx;display:flex;box-sizing:border-box;background:rgba(255,252,241,.92);box-shadow:0 10rpx 26rpx rgba(35,53,43,.07)}.avatar-wrap{position:relative;width:126rpx;height:126rpx;flex:none}.avatar-wrap image,.avatar-fallback{width:100%;height:100%;border-radius:32rpx;display:flex;align-items:center;justify-content:center;color:#fffaf0;background:#315c50;font-family:STKaiti,KaiTi,serif;font-size:45rpx}.status-dot{position:absolute;right:-3rpx;bottom:-3rpx;width:24rpx;height:24rpx;border:5rpx solid #fffaf0;border-radius:50%;background:#9ca49f}.status-dot.online{background:#43b985}.status-dot.busy{background:#d89a48}.player-main{min-width:0;flex:1;margin-left:20rpx}.name-row{display:flex;align-items:center}.name-row>text{overflow:hidden;font-family:STKaiti,KaiTi,serif;font-size:29rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.name-row>label{flex:none;margin-left:10rpx;padding:4rpx 9rpx;border-radius:14rpx;color:#315c50;background:#dfe9df;font-size:16rpx}.game-line{margin-top:8rpx;display:flex;align-items:center;gap:10rpx;color:#89918c;font-size:17rpx}.game-line>text{max-width:150rpx;overflow:hidden;color:#315c50;white-space:nowrap;text-overflow:ellipsis}.intro{margin-top:9rpx;overflow:hidden;color:#68766e;font-size:19rpx;line-height:29rpx;white-space:nowrap;text-overflow:ellipsis}.tag-row{height:37rpx;margin-top:9rpx;overflow:hidden;display:flex;gap:7rpx}.tag-row text{padding:4rpx 9rpx;border:1rpx solid;border-radius:15rpx;font-size:15rpx;white-space:nowrap}.card-arrow{position:absolute;right:20rpx;top:69rpx;color:#315c50;font-size:36rpx}.empty{padding:90rpx 20rpx;color:#89928d;text-align:center}.player-head{padding:48rpx 12rpx 34rpx}.player-head .eyebrow{color:#557669;font-size:21rpx;font-weight:700;letter-spacing:4rpx}.player-head .title{margin-top:13rpx}.player-head>text{display:block;margin-top:12rpx;color:#78847d;font-size:22rpx}.status-card{padding:30rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:28rpx;display:flex;align-items:center;justify-content:space-between;background:rgba(255,252,241,.93)}.status-card>view>text{color:#7a867f;font-size:20rpx}.status-card>view>view{margin-top:8rpx;color:#315c50;font-size:36rpx;font-weight:800}.status-card button{margin:0;border-radius:28rpx;color:#fffaf0;background:#315c50}.work-stats{margin-top:18rpx;display:grid;grid-template-columns:repeat(3,1fr);gap:14rpx}.work-stats view{padding:25rpx 8rpx;border-radius:24rpx;text-align:center;background:rgba(255,252,241,.88)}.work-stats text,.work-stats label{display:block}.work-stats text{font-size:34rpx;font-weight:800}.work-stats label{margin-top:7rpx;color:#7a867f;font-size:18rpx}.work-actions{margin-top:20rpx;display:grid;grid-template-columns:1fr 1fr;gap:15rpx}.work-actions view{padding:26rpx;border-radius:26rpx;color:#315c50;text-align:center;background:#dfe8dc}
</style>
