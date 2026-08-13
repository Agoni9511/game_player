<template>
  <view class="page tab-page">
    <template v-if="mode.isPlayerMode">
      <view class="player-quick-status"><view><text>当前状态</text><label>{{ statusLabel }}</label></view><button :disabled="toggling" @click="toggle">{{ toggling ? '切换中…' : workStatus === 'AVAILABLE' ? '暂停接单' : '开始接单' }}</button></view>
      <view class="player-quick-menu"><view @click="openPlayerPage('/subpackages/player/dispatches')"><text>抢单大厅</text><label>{{ workbench.pendingDispatchCount || 0 }} 个待响应</label><strong>›</strong></view><view @click="openPlayerPage('/subpackages/player/orders')"><text>服务订单</text><label>{{ workbench.activeOrderCount || 0 }} 个进行中</label><strong>›</strong></view><view @click="openPlayerPage('/subpackages/player/settlement')"><text>收益中心</text><label>余额与结算明细</label><strong>›</strong></view><view @click="openPlayerPage('/subpackages/player/profile-edit')"><text>陪玩资料</text><label>头像、标签与游戏能力</label><strong>›</strong></view></view>
    </template>

    <template v-else>
      <view class="catalog-hero">
        <view class="seal">寻伴</view>
        <view class="muted">{{ isPackageCatalog ? '组合服务更省心，套餐下单更划算' : '上分、教学与战术护航，按需选择' }}</view>
        <view class="search"><image src="/static/icons/search.png" /><input v-model.trim="keyword" :placeholder="isPackageCatalog ? '搜索游戏或套餐' : '搜索游戏或陪玩服务'" confirm-type="search" @confirm="loadProducts" /><text v-if="keyword" @click="keyword=''">×</text></view>
      </view>

      <scroll-view scroll-x class="game-scroll" :show-scrollbar="false">
        <view class="filter-row">
          <view class="filter-chip" :class="{ active: !gameId }" @click="selectGame(0)">全部游戏</view>
          <view v-for="game in games" :key="String(game.id)" class="filter-chip" :class="{ active: gameId === Number(game.id) }" @click="selectGame(Number(game.id))">{{ game.gameName }}</view>
        </view>
      </scroll-view>

      <view class="catalog-controls">
        <view class="sort-row">
          <view v-for="item in sortOptions" :key="item.value" :class="{ active: sort === item.value }" @click="selectSort(item.value)">{{ item.shortLabel }}</view>
        </view>
        <view class="filter-trigger" :class="{ active: hasExtraFilters }" @click="filterSheetVisible = true">
          <image src="/static/icons/list.png" />
          <text>筛选</text>
          <view v-if="hasExtraFilters" class="filter-dot" />
        </view>
      </view>
      <scroll-view v-if="activeFilterLabels.length" scroll-x class="selected-scroll" :show-scrollbar="false">
        <view class="selected-row">
          <view v-for="label in activeFilterLabels" :key="label" class="selected-chip" @click="filterSheetVisible = true">{{ label }}</view>
          <view class="clear-filter" @click="clearExtraFilters">清空</view>
        </view>
      </scroll-view>

      <view v-if="filterSheetVisible" class="filter-mask" @click="filterSheetVisible = false">
        <view class="filter-sheet" @click.stop>
          <view class="sheet-handle" />
          <view class="filter-sheet-head"><view><text>筛选套餐</text><label>缩小范围，更快找到合适服务</label></view><text @click="filterSheetVisible = false">×</text></view>
          <scroll-view scroll-y class="filter-sheet-body">
            <view class="filter-group">
              <view class="filter-title">游戏</view>
              <view class="sheet-options"><view class="sheet-chip" :class="{ active: !gameId }" @click="selectGame(0)">全部游戏</view><view v-for="game in games" :key="String(game.id)" class="sheet-chip" :class="{ active: gameId === Number(game.id) }" @click="selectGame(Number(game.id))">{{ game.gameName }}</view></view>
            </view>
            <view v-if="visibleCategories.length" class="filter-group">
              <view class="filter-title">服务分类</view>
              <view class="sheet-options"><view class="sheet-chip" :class="{ active: !categoryId }" @click="selectCategory(0)">全部分类</view><view v-for="item in visibleCategories" :key="String(item.id)" class="sheet-chip" :class="{ active: categoryId === Number(item.id) }" @click="selectCategory(Number(item.id))">{{ item.categoryName }}</view></view>
            </view>
            <view class="filter-group">
              <view class="filter-title">业务类型</view>
              <view class="sheet-options"><view v-for="item in serviceTypes" :key="item.value" class="sheet-chip" :class="{ active: serviceType === item.value }" @click="selectServiceType(item.value)">{{ item.label }}</view></view>
            </view>
            <view class="filter-group">
              <view class="filter-title">陪玩等级 <text v-if="!gameId">选择游戏后可选</text></view>
              <view class="sheet-options"><view class="sheet-chip" :class="{ active: !playerLevelId }" @click="selectLevel(0)">全部等级</view><view v-for="item in playerLevels" :key="String(item.id)" class="sheet-chip" :class="{ active: playerLevelId === Number(item.id) }" @click="selectLevel(Number(item.id))">{{ item.levelName }}</view></view>
            </view>
            <view class="filter-group">
              <view class="filter-title">价格区间</view>
              <view class="sheet-price"><view><text>¥</text><input v-model="minPrice" type="digit" placeholder="最低价" /></view><label>—</label><view><text>¥</text><input v-model="maxPrice" type="digit" placeholder="最高价" /></view></view>
            </view>
          </scroll-view>
          <view class="filter-actions"><button class="reset-button" @click="resetFilters(false)">重置</button><button class="result-button" @click="applyFilters">查看结果</button></view>
        </view>
      </view>

      <view class="section-head"><view><text>{{ isPackageCatalog ? '全部套餐' : '精选服务' }}</text><label>{{ total }} 项可选</label></view><text class="ink-mark">严选</text></view>
      <view v-for="item in products" :key="String(item.id)" class="product-card" @click="openProduct(Number(item.id))">
        <view class="cover" :class="item.gameId === 2 ? 'valorant' : 'delta'">
          <image v-if="item.coverUrl" :src="assetUrl(item.coverUrl)" mode="aspectFill" />
          <template v-else><text>{{ gameShort(item.gameName) }}</text><label>{{ item.productType === 'PACKAGE' ? '套餐' : '服务' }}</label></template>
          <view v-if="item.productType === 'PACKAGE'" class="package-ribbon">组合套餐</view>
        </view>
        <view class="product-main">
          <view class="tags"><text>{{ item.gameName }}</text><text>{{ item.categoryName }}</text></view>
          <view class="product-name">{{ item.productName }}</view>
          <view class="subtitle">{{ item.subtitle || item.description || '平台严选陪玩服务' }}</view>
          <view class="product-foot"><view class="price-line"><text class="currency">¥</text><text class="price-value">{{ money(item.minPrice) }}</text><text class="price-suffix">起</text></view><view class="detail">选套餐 <text>›</text></view></view>
        </view>
      </view>
      <EmptyState v-if="!loading && !products.length" :text="isPackageCatalog ? '暂无符合条件的上架套餐' : '暂无符合条件的上架服务'" />
      <view v-if="loading" class="loading">正在翻阅服务册...</view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { useAppModeStore } from '@/stores/app-mode'
import { getWorkbench, updateWorkStatus } from '@/api/player'
import { getCatalogCategories, getCatalogGames, getCatalogPlayerLevels, getCatalogProducts } from '@/api/customer'
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
const serviceType = ref('')
const playerLevelId = ref(0)
const playerLevels = ref<RecordData[]>([])
const minPrice = ref('')
const maxPrice = ref('')
const sort = ref<'DEFAULT' | 'PRICE_ASC' | 'PRICE_DESC' | 'LATEST'>('DEFAULT')
const productType = ref('')
const routeProductType = ref('')
const total = ref(0)
const loading = ref(false)
const toggling = ref(false)
const filterSheetVisible = ref(false)
const serviceTypes = [
  { label: '全部业务', value: '' }, { label: '陪玩', value: 'COMPANION' },
  { label: '上分', value: 'RANKING' }, { label: '教学', value: 'TEACHING' },
  { label: '护航', value: 'ESCORT' }, { label: '清图', value: 'MAP_CLEAR' }
]
const sortOptions = [
  { label: '综合排序', shortLabel: '综合', value: 'DEFAULT' as const }, { label: '价格从低到高', shortLabel: '价格 ↑', value: 'PRICE_ASC' as const },
  { label: '价格从高到低', shortLabel: '价格 ↓', value: 'PRICE_DESC' as const }, { label: '最新上架', shortLabel: '最新', value: 'LATEST' as const }
]
const workStatus = computed(() => String((workbench.value.player as RecordData | undefined)?.workStatus || 'OFFLINE'))
const statusLabel = computed(() => ({ AVAILABLE: '接单中', BUSY: '服务中', OFFLINE: '休息中' } as Record<string, string>)[workStatus.value] || '休息中')
const isPackageCatalog = computed(() => productType.value === 'PACKAGE')
const flatCategories = computed(() => {
  const result: RecordData[] = []
  const walk = (rows: RecordData[]) => rows.forEach(row => {
    if (row.enabled === false) return
    const children = ((row.children || []) as RecordData[]).filter(item => item.enabled !== false)
    if (children.length) walk(children)
    else if (row.parentId != null) result.push(row)
  })
  walk(categories.value)
  return result
})
const visibleCategories = computed(() => flatCategories.value.filter(item => !gameId.value || Number(item.gameId) === gameId.value))
const activeFilterLabels = computed(() => {
  const labels: string[] = []
  const category = flatCategories.value.find(item => Number(item.id) === categoryId.value)
  const service = serviceTypes.find(item => item.value === serviceType.value)
  const level = playerLevels.value.find(item => Number(item.id) === playerLevelId.value)
  if (category) labels.push(String(category.categoryName))
  if (service?.value) labels.push(service.label)
  if (level) labels.push(String(level.levelName))
  if (minPrice.value || maxPrice.value) labels.push(`¥${minPrice.value || '0'}—${maxPrice.value || '不限'}`)
  return labels
})
const hasExtraFilters = computed(() => activeFilterLabels.value.length > 0)

onLoad(query => {
  routeProductType.value = String(query?.productType || '').toUpperCase() === 'PACKAGE' ? 'PACKAGE' : ''
  uni.setNavigationBarTitle({ title: routeProductType.value ? '精选套餐' : '快捷服务' })
})

onShow(async () => {
  if (mode.isPlayerMode) { workbench.value = await getWorkbench(); return }
  const entry = String(uni.getStorageSync('peiwan_catalog_entry') || '')
  productType.value = routeProductType.value || (entry === 'package' ? 'PACKAGE' : '')
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
    const low = parsePrice(minPrice.value)
    const high = parsePrice(maxPrice.value)
    const page = await getCatalogProducts({ keyword: keyword.value || undefined, gameId: gameId.value || undefined, categoryId: categoryId.value || undefined, productType: productType.value || undefined, serviceType: serviceType.value || undefined, playerLevelId: playerLevelId.value || undefined, minPrice: low, maxPrice: high, sort: sort.value })
    products.value = page.records || []
    total.value = page.total || 0
  } finally { loading.value = false }
}
async function selectGame(id: number) { gameId.value = id; categoryId.value = 0; playerLevelId.value = 0; playerLevels.value = id ? await getCatalogPlayerLevels(id) : []; await loadProducts() }
async function selectCategory(id: number) { categoryId.value = id; await loadProducts() }
async function selectServiceType(value: string) { serviceType.value = value; await loadProducts() }
async function selectLevel(id: number) { playerLevelId.value = id; await loadProducts() }
async function selectSort(value: 'DEFAULT' | 'PRICE_ASC' | 'PRICE_DESC' | 'LATEST') { sort.value = value; await loadProducts() }
async function applyFilters() {
  const low = parsePrice(minPrice.value)
  const high = parsePrice(maxPrice.value)
  if (low !== undefined && high !== undefined && low > high) return uni.showToast({ title: '最低价不能高于最高价', icon: 'none' })
  await loadProducts()
  filterSheetVisible.value = false
}
async function resetFilters(closeSheet = true) {
  gameId.value = 0
  categoryId.value = 0
  serviceType.value = ''
  playerLevelId.value = 0
  playerLevels.value = []
  minPrice.value = ''
  maxPrice.value = ''
  sort.value = 'DEFAULT'
  await loadProducts()
  if (closeSheet) filterSheetVisible.value = false
}
async function clearExtraFilters() {
  categoryId.value = 0
  serviceType.value = ''
  playerLevelId.value = 0
  minPrice.value = ''
  maxPrice.value = ''
  await loadProducts()
}
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
function openPlayerPage(url: string) { uni.navigateTo({ url }) }
function gameShort(value: unknown) { const name = String(value || '游戏'); return name.length > 4 ? name.slice(0, 4) : name }
function money(value: unknown) { return Number(value || 0).toFixed(0) }
function parsePrice(value: string) { const text = value.trim(); if (!text) return undefined; const number = Number(text); return Number.isFinite(number) && number >= 0 ? number : undefined }
</script>

<style scoped lang="scss">
.catalog-hero{position:relative;padding:20rpx 12rpx 22rpx}.catalog-hero .muted{padding-right:82rpx;color:#748078;font-size:21rpx}.seal{position:absolute;right:18rpx;top:10rpx;padding:9rpx 8rpx;border:3rpx double #963d31;color:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.search{height:82rpx;margin-top:18rpx;padding:0 22rpx;border:1rpx solid rgba(49,92,80,.22);border-radius:42rpx;display:flex;align-items:center;background:rgba(255,252,241,.92);box-shadow:0 8rpx 22rpx rgba(35,53,43,.05)}.search image{width:34rpx;height:34rpx}.search input{flex:1;margin-left:15rpx;font-size:25rpx}.search>text{width:48rpx;height:48rpx;border-radius:50%;color:#78857d;background:rgba(49,92,80,.08);font-size:32rpx;line-height:45rpx;text-align:center}.game-scroll,.category-scroll,.option-scroll{white-space:nowrap}.filter-row,.category-row{display:flex;gap:14rpx;padding:10rpx 2rpx 18rpx}.filter-chip,.category{padding:16rpx 24rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:30rpx;color:#6f7c74;background:rgba(255,252,241,.74);font-size:23rpx}.filter-chip.active,.category.active{border-color:#315c50;color:#fffaf0;background:#315c50}.category-row{padding-top:0}.category{padding:12rpx 20rpx;border-radius:26rpx;font-size:21rpx}.catalog-filters{margin:5rpx 0 22rpx;padding:20rpx 18rpx;border:1rpx solid rgba(49,92,80,.16);border-radius:10rpx 28rpx 10rpx 28rpx;background:rgba(255,252,241,.82)}.filter-line,.price-filter{min-height:62rpx;display:flex;align-items:center}.filter-label{width:72rpx;flex:none;color:#334c40;font-size:21rpx;font-weight:800}.option-scroll{min-width:0;flex:1}.option-row{display:flex;align-items:center;gap:10rpx}.mini-chip{padding:9rpx 16rpx;border:1rpx solid rgba(49,92,80,.16);border-radius:20rpx;color:#728078;background:#f5f1e5;font-size:19rpx}.mini-chip.active{border-color:#315c50;color:#fffaf0;background:#315c50}.filter-hint{color:#9aa19d;font-size:18rpx}.price-filter{margin-top:7rpx}.price-input{min-width:0;flex:1;display:flex;align-items:center;gap:9rpx}.price-input input{width:112rpx;height:52rpx;padding:0 14rpx;border:1rpx solid rgba(49,92,80,.2);border-radius:16rpx;box-sizing:border-box;background:#f8f5ea;font-size:20rpx}.price-input text{color:#929991;font-size:18rpx}.price-apply{margin-left:12rpx;padding:10rpx 17rpx;border-radius:17rpx;color:#fffaf0;background:#8b6945;font-size:19rpx}.sort-row{margin-top:14rpx;padding-top:15rpx;border-top:1rpx solid rgba(49,92,80,.1);display:flex;justify-content:space-between}.sort-row view{padding:8rpx 10rpx;color:#7b867f;font-size:19rpx}.sort-row view.active{color:#963d31;font-weight:800}.section-head{margin:24rpx 4rpx 20rpx;display:flex;align-items:center;justify-content:space-between}.section-head>view text{font-family:STKaiti,KaiTi,serif;font-size:34rpx;font-weight:800}.section-head label{margin-left:14rpx;color:#7e8982;font-size:20rpx}.ink-mark{color:#963d31;font-family:STKaiti,KaiTi,serif}.product-card{margin-bottom:20rpx;padding:20rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:9rpx 26rpx 9rpx 26rpx;display:flex;background:rgba(255,252,241,.92);box-shadow:0 8rpx 24rpx rgba(41,57,48,.06)}.cover{position:relative;width:168rpx;height:168rpx;flex:none;overflow:hidden;border-radius:7rpx 24rpx 7rpx 24rpx;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#f7f0db;background:linear-gradient(145deg,#547466,#253f36)}.cover.valorant{background:linear-gradient(145deg,#8d654f,#394a3f)}.cover image{width:100%;height:100%}.cover>text{font-family:STKaiti,KaiTi,serif;font-size:32rpx;font-weight:800}.cover>label{margin-top:10rpx;padding:4rpx 12rpx;border:1rpx solid rgba(255,255,255,.45);font-size:18rpx}.product-main{min-width:0;flex:1;margin-left:22rpx}.tags{display:flex;gap:8rpx}.tags text{padding:5rpx 10rpx;color:#4d685d;background:#e1e8dc;font-size:17rpx}.tags text+text{color:#8b643e;background:#eee2cc}.product-name{margin-top:13rpx;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;color:#1b2923;font-size:28rpx;font-weight:800}.subtitle{height:58rpx;margin-top:9rpx;overflow:hidden;color:#7c867f;font-size:20rpx;line-height:29rpx}.product-foot{margin-top:8rpx;display:flex;align-items:flex-end;justify-content:space-between}.price-line{display:flex;align-items:baseline;flex:none;color:#963d31;white-space:nowrap}.currency{margin-right:3rpx;font-size:21rpx}.price-value{font-size:34rpx;font-weight:800;line-height:1}.price-suffix{margin-left:7rpx;color:#8d8175;font-size:18rpx}.detail{flex:none;color:#315c50;font-size:20rpx}.loading{padding:70rpx;color:#78847c;text-align:center}.player-quick-status{padding:25rpx 24rpx;border:1rpx solid rgba(49,92,80,.16);border-radius:24rpx;display:flex;align-items:center;justify-content:space-between;background:#fffaf0}.player-quick-status text,.player-quick-status label{display:block}.player-quick-status text{color:#7b867f;font-size:20rpx}.player-quick-status label{margin-top:7rpx;color:#315c50;font-size:32rpx;font-weight:800}.player-quick-status button{height:62rpx;margin:0;padding:0 24rpx;border-radius:31rpx;color:#fffaf0;background:#315c50;line-height:62rpx;font-size:21rpx}.player-quick-menu{margin-top:18rpx;padding:0 23rpx;border:1rpx solid rgba(49,92,80,.15);border-radius:24rpx;background:#fffaf0}.player-quick-menu>view{min-height:102rpx;border-bottom:1rpx solid rgba(49,92,80,.1);display:grid;grid-template-columns:1fr auto auto;align-items:center;gap:14rpx}.player-quick-menu>view:last-child{border:0}.player-quick-menu text{font-size:25rpx;font-weight:700}.player-quick-menu label{color:#89928c;font-size:18rpx}.player-quick-menu strong{color:#8d9891;font-size:35rpx;font-weight:400}
.catalog-controls{height:88rpx;margin:2rpx 0 0;padding:0 4rpx 0 8rpx;border-top:1rpx solid rgba(49,92,80,.11);border-bottom:1rpx solid rgba(49,92,80,.11);display:flex;align-items:center;background:rgba(247,243,231,.78)}
.catalog-controls .sort-row{min-width:0;flex:1;margin:0;padding:0;border:0;display:grid;grid-template-columns:repeat(4,1fr)}.catalog-controls .sort-row view{position:relative;padding:25rpx 4rpx;color:#758078;font-size:20rpx;text-align:center}.catalog-controls .sort-row view.active{color:#963d31;font-weight:800}.catalog-controls .sort-row view.active::after{content:'';position:absolute;left:32%;right:32%;bottom:8rpx;height:4rpx;border-radius:3rpx;background:#963d31}
.filter-trigger{position:relative;width:122rpx;height:88rpx;flex:none;margin-left:3rpx;padding:0 12rpx 0 17rpx;border-left:1rpx solid rgba(49,92,80,.12);box-sizing:border-box;display:flex;align-items:center;justify-content:center;gap:9rpx;color:#617168;font-size:20rpx}.filter-trigger image{width:28rpx;height:28rpx;opacity:.68}.filter-trigger.active{color:#315c50;font-weight:700}.filter-trigger.active image{opacity:1}.filter-dot{position:absolute;right:10rpx;top:22rpx;width:10rpx;height:10rpx;border:2rpx solid #f5f0e3;border-radius:50%;background:#963d31}
.selected-scroll{white-space:nowrap}.selected-row{padding:15rpx 2rpx 3rpx;display:flex;align-items:center;gap:10rpx}.selected-chip{padding:8rpx 14rpx;border:1rpx solid rgba(150,61,49,.22);border-radius:20rpx;color:#7e493f;background:#f2e5d8;font-size:18rpx}.clear-filter{padding:8rpx 10rpx;color:#7d8780;font-size:18rpx}
.filter-mask{position:fixed;z-index:200;inset:0;display:flex;align-items:flex-end;background:rgba(12,24,19,.5);animation:mask-in .18s ease}.filter-sheet{width:100%;max-height:82vh;padding-bottom:calc(18rpx + env(safe-area-inset-bottom));border-radius:34rpx 34rpx 0 0;box-sizing:border-box;background:#f7f2e4;box-shadow:0 -18rpx 50rpx rgba(15,30,24,.2);animation:sheet-up .22s ease-out}.sheet-handle{width:74rpx;height:7rpx;margin:16rpx auto 8rpx;border-radius:5rpx;background:#c7c3b6}.filter-sheet-head{padding:10rpx 28rpx 22rpx;display:flex;align-items:center;justify-content:space-between}.filter-sheet-head>view text,.filter-sheet-head>view label{display:block}.filter-sheet-head>view text{color:#21352c;font-family:STKaiti,KaiTi,serif;font-size:34rpx;font-weight:800}.filter-sheet-head>view label{margin-top:5rpx;color:#899089;font-size:18rpx}.filter-sheet-head>text{width:54rpx;height:54rpx;border-radius:50%;color:#6d7770;background:#ebe6d8;font-size:37rpx;line-height:50rpx;text-align:center}.filter-sheet-body{height:56vh;padding:0 28rpx;box-sizing:border-box}.filter-group{padding:18rpx 0 10rpx;border-top:1rpx solid rgba(49,92,80,.1)}.filter-title{margin-bottom:15rpx;color:#2c4037;font-size:23rpx;font-weight:800}.filter-title text{margin-left:10rpx;color:#9a9f99;font-size:17rpx;font-weight:400}.sheet-options{display:flex;flex-wrap:wrap;gap:13rpx 12rpx}.sheet-chip{min-width:142rpx;padding:14rpx 18rpx;border:1rpx solid transparent;border-radius:20rpx;box-sizing:border-box;color:#68766f;background:#ebe8db;font-size:20rpx;text-align:center}.sheet-chip.active{border-color:#315c50;color:#fffaf0;background:#315c50;box-shadow:0 5rpx 13rpx rgba(49,92,80,.16)}.sheet-price{display:flex;align-items:center;gap:14rpx}.sheet-price>view{height:68rpx;min-width:0;flex:1;padding:0 18rpx;border:1rpx solid rgba(49,92,80,.15);border-radius:20rpx;display:flex;align-items:center;background:#fffdf5}.sheet-price>view text{color:#963d31;font-size:21rpx}.sheet-price input{min-width:0;flex:1;margin-left:8rpx;font-size:22rpx}.sheet-price>label{color:#a4a59f}.filter-actions{padding:18rpx 28rpx 0;display:grid;grid-template-columns:1fr 2fr;gap:14rpx;border-top:1rpx solid rgba(49,92,80,.1)}.filter-actions button{height:78rpx;margin:0;border-radius:39rpx;font-size:24rpx;line-height:78rpx}.filter-actions button::after{border:0}.reset-button{color:#40584d;background:#e8e5d8}.result-button{color:#fffaf0;background:linear-gradient(110deg,#315c50,#23453b)}
.package-ribbon{position:absolute;left:0;top:0;padding:7rpx 13rpx 8rpx;border-radius:0 0 16rpx 0;color:#fff8e8;background:rgba(150,61,49,.9);font-size:16rpx;font-weight:700}.product-card{position:relative;border-radius:22rpx;padding:17rpx}.cover{width:178rpx;height:178rpx;border-radius:18rpx}.product-main{margin-left:20rpx}.product-name{font-size:27rpx}.subtitle{height:54rpx;line-height:27rpx}.section-head{margin-top:28rpx}.detail{padding:9rpx 14rpx;border-radius:22rpx;color:#fffaf0;background:#315c50;font-size:18rpx}.detail text{margin-left:3rpx}
@keyframes sheet-up{from{transform:translateY(100%)}}@keyframes mask-in{from{opacity:0}}
</style>
