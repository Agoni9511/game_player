<template>
  <view class="page tab-page">
    <template v-if="mode.isPlayerMode">
      <view class="player-hero">
        <image src="/static/icons/gamepad.png" />
        <view class="title">接单状态</view>
        <view class="muted">开启后可接收平台派单邀请</view>
        <view class="status">{{ statusLabel }}</view>
        <button class="primary" :disabled="toggling" @click="toggle">{{ toggling ? '状态切换中...' : workStatus === 'AVAILABLE' ? '暂停接单' : '开始接单' }}</button>
      </view>
    </template>

    <template v-else>
      <view class="catalog-hero">
        <view class="seal">寻伴</view>
        <view class="eyebrow">凌竞服务集</view>
        <view class="title">选游戏，寻同道</view>
        <view class="muted">上分、教学与战术护航，按需选择</view>
        <view class="search"><image src="/static/icons/search.png" /><input v-model.trim="keyword" placeholder="搜索游戏或陪玩服务" confirm-type="search" @confirm="loadProducts" /><text v-if="keyword" @click="keyword=''">×</text></view>
      </view>

      <scroll-view scroll-x class="game-scroll" :show-scrollbar="false">
        <view class="filter-row">
          <view class="filter-chip" :class="{ active: !gameId }" @click="selectGame(0)">全部游戏</view>
          <view v-for="game in games" :key="String(game.id)" class="filter-chip" :class="{ active: gameId === Number(game.id) }" @click="selectGame(Number(game.id))">{{ game.gameName }}</view>
        </view>
      </scroll-view>

      <scroll-view v-if="visibleCategories.length" scroll-x class="category-scroll" :show-scrollbar="false">
        <view class="category-row">
          <view class="category" :class="{ active: !categoryId }" @click="selectCategory(0)">全部服务</view>
          <view v-for="item in visibleCategories" :key="String(item.id)" class="category" :class="{ active: categoryId === Number(item.id) }" @click="selectCategory(Number(item.id))">{{ item.categoryName }}</view>
        </view>
      </scroll-view>

      <view class="section-head"><view><text>精选服务</text><label>{{ total }} 项可选</label></view><text class="ink-mark">严选</text></view>
      <view v-for="item in products" :key="String(item.id)" class="product-card" @click="openProduct(Number(item.id))">
        <view class="cover" :class="item.gameId === 2 ? 'valorant' : 'delta'">
          <image v-if="item.coverUrl" :src="assetUrl(item.coverUrl)" mode="aspectFill" />
          <template v-else><text>{{ gameShort(item.gameName) }}</text><label>{{ item.productType === 'PACKAGE' ? '套餐' : '服务' }}</label></template>
        </view>
        <view class="product-main">
          <view class="tags"><text>{{ item.gameName }}</text><text>{{ item.categoryName }}</text></view>
          <view class="product-name">{{ item.productName }}</view>
          <view class="subtitle">{{ item.subtitle || item.description || '平台严选陪玩服务' }}</view>
          <view class="product-foot"><view class="price-line"><text class="currency">¥</text><text class="price-value">{{ money(item.minPrice) }}</text><text class="price-suffix">起</text></view><view class="detail">查看详情 ›</view></view>
        </view>
      </view>
      <EmptyState v-if="!loading && !products.length" text="暂无符合条件的上架服务" />
      <view v-if="loading" class="loading">正在翻阅服务册...</view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useAppModeStore } from '@/stores/app-mode'
import { getWorkbench, updateWorkStatus } from '@/api/player'
import { getCatalogCategories, getCatalogGames, getCatalogProducts } from '@/api/customer'
import { assetUrl } from '@/services/http'
import EmptyState from '@/components/EmptyState.vue'
import type { RecordData } from '@/types/api'

const mode = useAppModeStore()
const workbench = ref<RecordData>({})
const games = ref<RecordData[]>([])
const categories = ref<RecordData[]>([])
const products = ref<RecordData[]>([])
const keyword = ref('')
const gameId = ref(0)
const categoryId = ref(0)
const productType = ref('')
const total = ref(0)
const loading = ref(false)
const toggling = ref(false)
const workStatus = computed(() => String((workbench.value.player as RecordData | undefined)?.workStatus || 'OFFLINE'))
const statusLabel = computed(() => ({ AVAILABLE: '接单中', BUSY: '服务中', OFFLINE: '休息中' } as Record<string, string>)[workStatus.value] || '休息中')
const flatCategories = computed(() => {
  const result: RecordData[] = []
  const walk = (rows: RecordData[]) => rows.forEach(row => { if (row.enabled !== false) result.push(row); walk((row.children || []) as RecordData[]) })
  walk(categories.value)
  return result
})
const visibleCategories = computed(() => flatCategories.value.filter(item => !gameId.value || Number(item.gameId) === gameId.value))

onShow(async () => {
  if (mode.isPlayerMode) { workbench.value = await getWorkbench(); return }
  const entry = String(uni.getStorageSync('peiwan_catalog_entry') || '')
  productType.value = entry === 'package' ? 'PACKAGE' : ''
  uni.removeStorageSync('peiwan_catalog_entry')
  if (!games.value.length) await loadCatalog()
  else await loadProducts()
})

async function loadCatalog() {
  loading.value = true
  try {
    const [gameRows, categoryRows] = await Promise.all([getCatalogGames(), getCatalogCategories()])
    games.value = gameRows
    categories.value = categoryRows
    await loadProducts()
  } finally { loading.value = false }
}
async function loadProducts() {
  loading.value = true
  try {
    const page = await getCatalogProducts({ keyword: keyword.value || undefined, gameId: gameId.value || undefined, categoryId: categoryId.value || undefined, productType: productType.value || undefined })
    products.value = page.records || []
    total.value = page.total || 0
  } finally { loading.value = false }
}
async function selectGame(id: number) { gameId.value = id; categoryId.value = 0; await loadProducts() }
async function selectCategory(id: number) { categoryId.value = id; await loadProducts() }
async function toggle() {
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
function openProduct(id: number) { uni.navigateTo({ url: `/subpackages/customer/product-detail?id=${id}` }) }
function gameShort(value: unknown) { const name = String(value || '游戏'); return name.length > 4 ? name.slice(0, 4) : name }
function money(value: unknown) { return Number(value || 0).toFixed(0) }
</script>

<style scoped lang="scss">
.catalog-hero{position:relative;padding:38rpx 12rpx 26rpx}.eyebrow{color:#4b6d60;font-size:21rpx;font-weight:700;letter-spacing:5rpx}.catalog-hero .title{margin-top:12rpx;font-size:45rpx}.catalog-hero .muted{margin-top:10rpx}.seal{position:absolute;right:18rpx;top:25rpx;padding:9rpx 8rpx;border:3rpx double #963d31;color:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.search{height:82rpx;margin-top:30rpx;padding:0 22rpx;border:1rpx solid rgba(49,92,80,.22);border-radius:42rpx;display:flex;align-items:center;background:rgba(255,252,241,.92);box-shadow:0 8rpx 22rpx rgba(35,53,43,.05)}.search image{width:34rpx;height:34rpx}.search input{flex:1;margin-left:15rpx;font-size:25rpx}.search>text{width:48rpx;height:48rpx;border-radius:50%;color:#78857d;background:rgba(49,92,80,.08);font-size:32rpx;line-height:45rpx;text-align:center}.game-scroll,.category-scroll{white-space:nowrap}.filter-row,.category-row{display:flex;gap:14rpx;padding:10rpx 2rpx 18rpx}.filter-chip,.category{padding:16rpx 24rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:30rpx;color:#6f7c74;background:rgba(255,252,241,.74);font-size:23rpx}.filter-chip.active,.category.active{border-color:#315c50;color:#fffaf0;background:#315c50}.category-row{padding-top:0}.category{padding:12rpx 20rpx;border-radius:26rpx;font-size:21rpx}.section-head{margin:24rpx 4rpx 20rpx;display:flex;align-items:center;justify-content:space-between}.section-head>view text{font-family:STKaiti,KaiTi,serif;font-size:34rpx;font-weight:800}.section-head label{margin-left:14rpx;color:#7e8982;font-size:20rpx}.ink-mark{color:#963d31;font-family:STKaiti,KaiTi,serif}.product-card{margin-bottom:20rpx;padding:20rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:9rpx 26rpx 9rpx 26rpx;display:flex;background:rgba(255,252,241,.92);box-shadow:0 8rpx 24rpx rgba(41,57,48,.06)}.cover{position:relative;width:168rpx;height:168rpx;flex:none;overflow:hidden;border-radius:7rpx 24rpx 7rpx 24rpx;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#f7f0db;background:linear-gradient(145deg,#547466,#253f36)}.cover.valorant{background:linear-gradient(145deg,#8d654f,#394a3f)}.cover image{width:100%;height:100%}.cover>text{font-family:STKaiti,KaiTi,serif;font-size:32rpx;font-weight:800}.cover>label{margin-top:10rpx;padding:4rpx 12rpx;border:1rpx solid rgba(255,255,255,.45);font-size:18rpx}.product-main{min-width:0;flex:1;margin-left:22rpx}.tags{display:flex;gap:8rpx}.tags text{padding:5rpx 10rpx;color:#4d685d;background:#e1e8dc;font-size:17rpx}.tags text+text{color:#8b643e;background:#eee2cc}.product-name{margin-top:13rpx;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;color:#1b2923;font-size:28rpx;font-weight:800}.subtitle{height:58rpx;margin-top:9rpx;overflow:hidden;color:#7c867f;font-size:20rpx;line-height:29rpx}.product-foot{margin-top:8rpx;display:flex;align-items:flex-end;justify-content:space-between}.price-line{display:flex;align-items:baseline;flex:none;color:#963d31;white-space:nowrap}.currency{margin-right:3rpx;font-size:21rpx}.price-value{font-size:34rpx;font-weight:800;line-height:1}.price-suffix{margin-left:7rpx;color:#8d8175;font-size:18rpx}.detail{flex:none;color:#315c50;font-size:20rpx}.loading{padding:70rpx;color:#78847c;text-align:center}.player-hero{margin-top:80rpx;padding:60rpx 35rpx;border:1rpx solid rgba(49,92,80,.22);border-radius:10rpx 32rpx 10rpx 32rpx;text-align:center;background:rgba(255,252,241,.91)}.player-hero>image{width:110rpx;height:110rpx}.player-hero .title{margin-top:25rpx}.player-hero .muted{margin:18rpx 0 35rpx}.status{margin-bottom:24rpx;color:#315c50;font-size:34rpx;font-weight:800}.player-hero button{width:80%}
</style>
