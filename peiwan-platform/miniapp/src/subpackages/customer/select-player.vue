<template>
  <view class="select-page">
    <view class="page-head">
      <view><text>挑选心仪陪玩</text><label>{{ product.gameName }} · {{ selectedSku.skuName }}</label></view>
      <view class="seal">择伴</view>
    </view>

    <view class="hall-card" @click="publishToHall">
      <view class="hall-mark">厅</view>
      <view><strong>不指定具体陪玩</strong><label>平台智能匹配，¥{{ money(startingPrice) }} 起，选择预算后发布大厅</label></view>
      <text>›</text>
    </view>

    <view class="search"><image src="/static/icons/search.png"/><input v-model.trim="keyword" placeholder="搜索昵称、介绍或风格标签" confirm-type="search" @confirm="loadPlayers"/><text v-if="keyword" @click="clearSearch">×</text></view>

    <view class="filter-block">
      <view class="filter-title"><strong>偏好风格</strong><text>选择你更在意的陪伴体验</text></view>
      <scroll-view scroll-x class="filter-scroll" :show-scrollbar="false">
        <view class="chip-row">
          <view :class="{ active: !tagId }" @click="selectTag(0)">全部风格</view>
          <view v-for="tag in tags" :key="String(tag.id)" :class="{ active: tagId === Number(tag.id) }" @click="selectTag(Number(tag.id))">{{ tag.tagName }}</view>
        </view>
      </scroll-view>
      <view class="compact-row">
        <view class="gender-row"><view v-for="item in genders" :key="item.value" :class="{ active: gender === item.value }" @click="selectGender(item.value)">{{ item.label }}</view></view>
        <picker :range="sortOptions" range-key="label" :value="sortIndex" @change="selectSort"><view class="sort-picker">{{ sortOptions[sortIndex].label }}⌄</view></picker>
      </view>
    </view>

    <view class="filter-line"><view :class="{ active: availableOnly }" @click="toggleAvailable"><text></text>只看可接单</view><label>{{ total }} 位符合条件</label></view>

    <view v-for="player in players" :key="String(player.id)" class="player-card" :class="{ disabled: player.workStatus !== 'AVAILABLE' }" @click="selectPlayer(player)">
      <view class="avatar-wrap"><image v-if="player.avatarUrl" :src="assetUrl(player.avatarUrl)" mode="aspectFill"/><view v-else>{{ String(player.nickname || '陪').slice(0,1) }}</view><text :class="statusTone(player.workStatus)"></text></view>
      <view class="player-main">
        <view class="name-row"><strong>{{ player.nickname }}</strong><label v-if="genderText(player.gender)">{{ genderText(player.gender) }}</label><text>{{ statusText(player.workStatus) }}</text></view>
        <view class="tag-row"><text v-for="tag in playerTags(player)" :key="String(tag.id)">{{ tag.tagName }}</text><label v-if="!playerTags(player).length">平台认证</label></view>
        <view class="intro">{{ player.introduction || '期待与你并肩作战，认真陪伴每一局。' }}</view>
        <view class="meta"><text>★ {{ score(player.ratingScore) }}</text><text>{{ player.orderCount || 0 }} 单</text><strong>¥{{ playerPrice(player) }}</strong><label>/ {{ skuUnit }}</label></view>
      </view>
      <view class="arrow">›</view>
    </view>

    <view v-if="loading" class="empty">正在寻找合适的陪玩师...</view>
    <view v-else-if="!players.length" class="empty">当前条件下暂无陪玩师，可以放宽筛选或发布到大厅</view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getCatalogPlayers, getCatalogPlayerTags, getCatalogProduct } from '@/api/customer'
import { assetUrl } from '@/services/http'
import { requireLogin } from '@/utils/auth-guard'
import type { RecordData } from '@/types/api'

const product = ref<RecordData>({})
const selectedSku = ref<RecordData>({})
const players = ref<RecordData[]>([])
const tags = ref<RecordData[]>([])
const keyword = ref('')
const tagId = ref(0)
const gender = ref('')
const availableOnly = ref(true)
const loading = ref(false)
const total = ref(0)
const sortIndex = ref(0)
const genders = [{ label: '不限', value: '' }, { label: '女生', value: 'FEMALE' }, { label: '男生', value: 'MALE' }]
const sortOptions = [
  { label: '综合推荐', value: 'DEFAULT' },
  { label: '评分最高', value: 'RATING' },
  { label: '服务最多', value: 'ORDERS' },
  { label: '价格从低到高', value: 'PRICE_ASC' },
  { label: '价格从高到低', value: 'PRICE_DESC' }
] as const
const levelPrices = computed(() => ((selectedSku.value.levelPrices || []) as RecordData[]).filter(item => item.enabled !== false))
const startingPrice = computed(() => { const prices = levelPrices.value.map(item => Number(item.price)); return prices.length ? Math.min(...prices) : Number(selectedSku.value.price || 0) })
const skuUnit = computed(() => `${Number(selectedSku.value.unitCount || 1) > 1 ? selectedSku.value.unitCount : ''}${unitLabel(selectedSku.value.unitType)}`)

onLoad(async query => {
  if (!requireLogin('登录后才能选择陪玩并下单')) return
  const productId = Number(query?.productId || 0)
  const skuId = Number(query?.skuId || 0)
  if (!productId || !skuId) return uni.showToast({ title: '商品参数不完整', icon: 'none' })
  const [detail, tagRows] = await Promise.all([getCatalogProduct(productId), getCatalogPlayerTags()])
  product.value = detail
  tags.value = tagRows || []
  selectedSku.value = ((product.value.skus || []) as RecordData[]).find(item => Number(item.id) === skuId) || {}
  if (!selectedSku.value.id) return uni.showToast({ title: '服务规格已失效', icon: 'none' })
  await loadPlayers()
})

async function loadPlayers() {
  if (!product.value.gameId) return
  loading.value = true
  try {
    const page = await getCatalogPlayers({
      keyword: keyword.value || undefined,
      gameId: Number(product.value.gameId),
      skuId: Number(selectedSku.value.id),
      tagId: tagId.value || undefined,
      gender: gender.value || undefined,
      workStatus: availableOnly.value ? 'AVAILABLE' : undefined,
      sort: sortOptions[sortIndex.value].value
    })
    players.value = page.records || []
    total.value = Number(page.total || 0)
  } finally { loading.value = false }
}
async function selectTag(id: number) { tagId.value = id; await loadPlayers() }
async function selectGender(value: string) { gender.value = value; await loadPlayers() }
async function selectSort(event: { detail: { value: string | number } }) { sortIndex.value = Number(event.detail.value); await loadPlayers() }
async function toggleAvailable() { availableOnly.value = !availableOnly.value; await loadPlayers() }
async function clearSearch() { keyword.value = ''; await loadPlayers() }
function publishToHall() {
  const prices = [...levelPrices.value].sort((a, b) => Number(a.price) - Number(b.price))
  if (!prices.length) return uni.showToast({ title: '当前规格暂无可用报价', icon: 'none' })
  const names = prices.length === 3 ? ['经济匹配', '品质匹配', '高阶匹配'] : prices.map((_, index) => `预算方案 ${index + 1}`)
  uni.showActionSheet({
    itemList: prices.map((item, index) => `${names[index]}  ¥${money(item.price)}`),
    success: result => goConfirm(Number(prices[result.tapIndex].playerLevelId))
  })
}
function selectPlayer(player: RecordData) {
  if (String(player.workStatus) !== 'AVAILABLE') return uni.showToast({ title: '该陪玩师当前不可接单', icon: 'none' })
  goConfirm(Number(player.playerLevelId), Number(player.id), String(player.nickname || '所选陪玩师'))
}
function goConfirm(playerLevelId: number, requestedPlayerId = 0, requestedPlayerName = '') {
  const name = requestedPlayerName ? `&requestedPlayerName=${encodeURIComponent(requestedPlayerName)}` : ''
  uni.navigateTo({ url: `/subpackages/customer/confirm-order?productId=${product.value.id}&skuId=${selectedSku.value.id}&playerLevelId=${playerLevelId}&requestedPlayerId=${requestedPlayerId || ''}${name}` })
}
function playerTags(player: RecordData) { return ((player.tags || []) as RecordData[]).slice(0, 3) }
function playerPrice(player: RecordData) { return money(player.servicePrice ?? selectedSku.value.price) }
function money(value: unknown) { return Number(value || 0).toFixed(2) }
function score(value: unknown) { const result = Number(value || 0); return result ? result.toFixed(1) : '暂无' }
function unitLabel(value: unknown) { return ({ HOUR: '小时', GAME: '局', ORDER: '单' } as Record<string, string>)[String(value || '')] || '份' }
function genderText(value: unknown) { return ({ FEMALE: '女生', MALE: '男生' } as Record<string, string>)[String(value)] || '' }
function statusText(value: unknown) { return ({ AVAILABLE:'可接单', BUSY:'服务中', OFFLINE:'休息中', SUSPENDED:'暂停服务' } as Record<string,string>)[String(value)] || '休息中' }
function statusTone(value: unknown) { return String(value) === 'AVAILABLE' ? 'online' : String(value) === 'BUSY' ? 'busy' : '' }
</script>

<style scoped lang="scss">
.select-page{min-height:100vh;padding:28rpx 24rpx 90rpx;box-sizing:border-box;background-color:#eee9da;background-image:radial-gradient(circle at 88% 2%,rgba(91,126,108,.16),transparent 34%),linear-gradient(180deg,rgba(244,240,225,.88),rgba(244,240,225,.97))}.page-head{padding:20rpx 8rpx 30rpx;display:flex;align-items:center;justify-content:space-between}.page-head text,.page-head label{display:block}.page-head text{font-family:STKaiti,KaiTi,serif;font-size:44rpx;font-weight:800}.page-head label{margin-top:8rpx;color:#738078;font-size:21rpx}.seal{padding:8rpx;border:3rpx double #963d31;color:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.hall-card{padding:24rpx;border:1rpx solid rgba(49,92,80,.22);border-radius:8rpx 28rpx 8rpx 28rpx;display:flex;align-items:center;background:#315c50;color:#fff9e9;box-shadow:0 12rpx 30rpx rgba(36,65,53,.15)}.hall-mark{width:62rpx;height:62rpx;margin-right:18rpx;border:2rpx solid rgba(255,255,255,.55);border-radius:50%;display:flex;align-items:center;justify-content:center;font-family:STKaiti,KaiTi,serif;font-weight:800}.hall-card>view:nth-child(2){flex:1}.hall-card strong,.hall-card label{display:block}.hall-card label{margin-top:8rpx;color:#dbe5d8;font-size:18rpx}.hall-card>text{font-size:38rpx}.search{height:82rpx;margin-top:24rpx;padding:0 22rpx;border:1rpx solid rgba(49,92,80,.2);border-radius:42rpx;display:flex;align-items:center;background:rgba(255,252,241,.94)}.search image{width:34rpx;height:34rpx}.search input{flex:1;margin-left:15rpx;font-size:24rpx}.search>text{font-size:34rpx}.filter-block{margin-top:18rpx;padding:20rpx;border:1rpx solid rgba(49,92,80,.14);border-radius:8rpx 25rpx 8rpx 25rpx;background:rgba(255,252,241,.78)}.filter-title{display:flex;align-items:baseline}.filter-title strong{font-family:STKaiti,KaiTi,serif;font-size:27rpx}.filter-title text{margin-left:12rpx;color:#89928d;font-size:17rpx}.filter-scroll{margin-top:17rpx;white-space:nowrap}.chip-row{display:flex;gap:12rpx}.chip-row view,.gender-row view{padding:11rpx 19rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:25rpx;color:#6f7d75;background:#faf6e9;font-size:19rpx}.chip-row view.active,.gender-row view.active{border-color:#315c50;color:#fffaf0;background:#315c50}.compact-row{margin-top:18rpx;display:flex;align-items:center;justify-content:space-between}.gender-row{display:flex;gap:9rpx}.sort-picker{padding:10rpx 15rpx;color:#315c50;font-size:19rpx}.filter-line{margin:20rpx 4rpx 16rpx;display:flex;align-items:center;justify-content:space-between}.filter-line view{padding:10rpx 16rpx;border-radius:22rpx;color:#78847d;background:#e2e7dc;font-size:19rpx}.filter-line view.active{color:#fffaf0;background:#55786b}.filter-line view text{display:inline-block;width:10rpx;height:10rpx;margin-right:7rpx;border-radius:50%;background:#49bd89}.filter-line label{color:#89928d;font-size:19rpx}.player-card{position:relative;margin-bottom:18rpx;padding:22rpx 48rpx 22rpx 20rpx;border:1rpx solid rgba(49,92,80,.17);border-radius:8rpx 28rpx 8rpx 28rpx;display:flex;background:rgba(255,252,241,.94);box-shadow:0 10rpx 26rpx rgba(35,53,43,.07)}.player-card.disabled{opacity:.62}.avatar-wrap{position:relative;width:118rpx;height:118rpx;flex:none}.avatar-wrap image,.avatar-wrap>view{width:100%;height:100%;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fffaf0;background:#315c50;font-family:STKaiti,KaiTi,serif;font-size:42rpx}.avatar-wrap>text{position:absolute;right:0;bottom:0;width:22rpx;height:22rpx;border:5rpx solid #fffaf0;border-radius:50%;background:#9ba49e}.avatar-wrap>text.online{background:#45b985}.avatar-wrap>text.busy{background:#d99b49}.player-main{min-width:0;flex:1;margin-left:19rpx}.name-row{display:flex;align-items:center;gap:9rpx}.name-row strong{max-width:180rpx;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;font-family:STKaiti,KaiTi,serif;font-size:29rpx}.name-row label{padding:4rpx 9rpx;border-radius:13rpx;color:#89653f;background:#eee3cd;font-size:16rpx}.name-row>text{margin-left:auto;color:#77847c;font-size:17rpx}.tag-row{height:37rpx;margin-top:7rpx;overflow:hidden;display:flex;gap:7rpx}.tag-row text,.tag-row label{padding:4rpx 9rpx;border-radius:11rpx;color:#315c50;background:#e1e9df;font-size:16rpx}.intro{margin-top:7rpx;overflow:hidden;color:#758078;font-size:18rpx;white-space:nowrap;text-overflow:ellipsis}.meta{margin-top:9rpx;display:flex;align-items:center;gap:12rpx;color:#8a918d;font-size:17rpx}.meta strong{margin-left:auto;color:#963d31;font-size:23rpx}.meta label{color:#8a918d;font-size:16rpx}.arrow{position:absolute;right:16rpx;top:75rpx;color:#315c50;font-size:34rpx}.empty{padding:90rpx 20rpx;color:#859088;text-align:center}
</style>
