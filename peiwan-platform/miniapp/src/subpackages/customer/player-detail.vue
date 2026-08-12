<template>
  <view class="detail-page">
    <view class="hero">
      <image v-if="player.coverUrl" class="cover" :src="assetUrl(player.coverUrl)" mode="aspectFill" />
      <view class="hero-shade" />
      <view class="profile">
        <view class="avatar">
          <image v-if="player.avatarUrl" :src="assetUrl(player.avatarUrl)" mode="aspectFill" />
          <text v-else>{{ String(player.nickname || '陪').slice(0, 1) }}</text>
          <label :class="statusTone(player.workStatus)" />
        </view>
        <view class="identity">
          <view><text>{{ player.nickname || '陪玩师' }}</text><label>{{ statusText(player.workStatus) }}</label></view>
          <view class="stats"><text>★ {{ score(player.ratingScore) }}</text><text>{{ player.orderCount || 0 }} 单</text><text>{{ player.ratingCount || 0 }} 条评价</text></view>
        </view>
      </view>
    </view>

    <view class="content">
      <view class="card intro-card">
        <view class="section-title">关于我</view>
        <view class="intro">{{ player.introduction || '期待与你一起开黑，轻松享受每一局。' }}</view>
        <view class="tag-row"><text v-for="tag in tags" :key="String(tag.id)" :style="tagStyle(tag)">{{ tag.tagName }}</text></view>
      </view>

      <view class="card game-card">
        <view class="section-head"><view class="section-title">认证游戏</view><text>{{ games.length }} 项</text></view>
        <scroll-view scroll-x class="game-scroll" :show-scrollbar="false">
          <view class="game-row">
            <view v-for="game in games" :key="String(game.id)" class="game-option" :class="{ active: Number(game.gameId) === selectedGameId }" @click="selectGame(game)">
              <text>{{ game.gameName }}</text>
              <label>{{ game.playerLevelName || '平台认证' }}</label>
              <view v-if="game.rankName">{{ game.rankName }}</view>
            </view>
          </view>
        </scroll-view>
        <view v-if="selectedGame" class="game-summary">
          <view><text>陪玩等级</text><label>{{ selectedGame.playerLevelName || '平台认证' }}</label></view>
          <view><text>当前段位</text><label>{{ selectedGame.rankName || '暂未填写' }}</label></view>
          <view><text>常用区服</text><label>{{ selectedGame.serverName || '不限区服' }}</label></view>
          <view><text>游戏经验</text><label>{{ selectedGame.experienceYears ? `${selectedGame.experienceYears} 年` : '经验丰富' }}</label></view>
        </view>
      </view>

      <view class="service-head"><view><text>可预约服务</text><label>选择服务后将指定 {{ player.nickname }} 接单</label></view><view class="seal">指定</view></view>
      <view v-if="loading" class="empty">正在加载可预约服务...</view>
      <view v-for="item in products" :key="String(item.id)" class="service-card" :class="{ disabled: player.workStatus !== 'AVAILABLE' }" @click="openProduct(item)">
        <image v-if="item.coverUrl" :src="assetUrl(item.coverUrl)" mode="aspectFill" />
        <view v-else class="service-mark">{{ String(item.gameName || '服').slice(0, 1) }}</view>
        <view class="service-copy"><view>{{ item.productName }}</view><text>{{ item.subtitle || '平台担保 · 全程留痕' }}</text><label class="price-line"><text>¥</text><strong>{{ money(item.minPrice) }}</strong><text>起</text></label></view>
        <text class="arrow">›</text>
      </view>
      <view v-if="!loading && !products.length" class="empty">该游戏暂时没有可预约服务</view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getCatalogPlayer, getCatalogProducts } from '@/api/customer'
import { assetUrl } from '@/services/http'
import { requireLogin } from '@/utils/auth-guard'
import type { RecordData } from '@/types/api'

const player = ref<RecordData>({})
const products = ref<RecordData[]>([])
const selectedGameId = ref(0)
const loading = ref(false)
const games = computed(() => (player.value.games || []) as RecordData[])
const tags = computed(() => (player.value.tags || []) as RecordData[])
const selectedGame = computed(() => games.value.find(game => Number(game.gameId) === selectedGameId.value) || ({} as RecordData))

onLoad(async query => {
  if (!requireLogin('登录后才能查看陪玩师服务并预约')) return
  const id = Number(query?.id || 0)
  if (!id) return uni.showToast({ title: '陪玩师参数不完整', icon: 'none' })
  player.value = await getCatalogPlayer(id)
  const primary = games.value.find(game => Boolean(game.primary)) || games.value[0]
  if (primary) await selectGame(primary)
})

async function selectGame(game: RecordData) {
  const gameId = Number(game.gameId || 0)
  if (!gameId) return
  selectedGameId.value = gameId
  loading.value = true
  try {
    products.value = (await getCatalogProducts({ gameId, productType: 'SERVICE', size: 50 })).records || []
  } finally { loading.value = false }
}

function openProduct(item: RecordData) {
  if (String(player.value.workStatus) !== 'AVAILABLE') return uni.showToast({ title: '该陪玩师当前不可接单', icon: 'none' })
  const game = selectedGame.value
  const name = encodeURIComponent(String(player.value.nickname || '所选陪玩师'))
  uni.navigateTo({ url: `/subpackages/customer/product-detail?id=${item.id}&requestedPlayerId=${player.value.id}&requestedPlayerName=${name}&playerLevelId=${game.playerLevelId || ''}` })
}
function score(value: unknown) { const result = Number(value || 0); return result > 0 ? result.toFixed(1) : '新秀' }
function money(value: unknown) { return Number(value || 0).toFixed(2) }
function statusText(value: unknown) { return ({ AVAILABLE:'可接单', BUSY:'服务中', OFFLINE:'休息中', SUSPENDED:'暂停服务' } as Record<string,string>)[String(value)] || '休息中' }
function statusTone(value: unknown) { return String(value) === 'AVAILABLE' ? 'online' : String(value) === 'BUSY' ? 'busy' : 'offline' }
function tagStyle(tag: RecordData) { const color = String(tag.tagColor || '#315c50'); return `color:${color};border-color:${color}55;background:${color}12` }
</script>

<style scoped lang="scss">
.detail-page{min-height:100vh;background:#eee9da}.hero{position:relative;height:390rpx;overflow:hidden;background:linear-gradient(145deg,#315c50,#1b342b)}.cover,.hero-shade{position:absolute;inset:0;width:100%;height:100%}.hero-shade{background:linear-gradient(180deg,rgba(18,39,31,.12),rgba(16,37,29,.92))}.profile{position:absolute;left:30rpx;right:30rpx;bottom:42rpx;display:flex;align-items:center;color:#fffaf0}.avatar{position:relative;width:132rpx;height:132rpx;flex:none;border:5rpx solid rgba(255,250,240,.75);border-radius:50%;display:flex;align-items:center;justify-content:center;background:#963d31;font-family:STKaiti,KaiTi,serif;font-size:48rpx}.avatar image{width:100%;height:100%;border-radius:50%}.avatar label{position:absolute;right:3rpx;bottom:4rpx;width:22rpx;height:22rpx;border:5rpx solid #fffaf0;border-radius:50%;background:#9ba49e}.avatar label.online{background:#43c38b}.avatar label.busy{background:#d89a47}.identity{min-width:0;flex:1;margin-left:25rpx}.identity>view:first-child{display:flex;align-items:center;gap:13rpx}.identity>view:first-child text{overflow:hidden;font-family:STKaiti,KaiTi,serif;font-size:42rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.identity>view:first-child label{flex:none;padding:5rpx 12rpx;border-radius:17rpx;background:rgba(255,255,255,.16);font-size:18rpx}.stats{margin-top:17rpx;display:flex;gap:22rpx;color:rgba(255,250,240,.78);font-size:20rpx}.content{position:relative;margin-top:-18rpx;padding:0 24rpx 80rpx}.card{border-radius:14rpx 30rpx 14rpx 30rpx}.section-title{font-family:STKaiti,KaiTi,serif;font-size:32rpx;font-weight:800}.intro{color:#5f6e66;line-height:1.8}.tag-row{margin-top:20rpx;display:flex;flex-wrap:wrap;gap:12rpx}.tag-row text{padding:7rpx 14rpx;border:1rpx solid;border-radius:18rpx;font-size:19rpx}.section-head{display:flex;align-items:center;justify-content:space-between}.section-head>text{color:#89928d;font-size:20rpx}.game-scroll{margin-top:20rpx;white-space:nowrap}.game-row{display:flex;gap:14rpx}.game-option{min-width:280rpx;padding:20rpx 22rpx;border:1rpx solid rgba(49,92,80,.2);border-radius:8rpx 22rpx 8rpx 22rpx;box-sizing:border-box;background:#f6f1e3}.game-option.active{border-color:#315c50;background:#dfe8dc;box-shadow:inset 5rpx 0 #315c50}.game-option text,.game-option label,.game-option view{display:block;overflow:hidden;white-space:nowrap;text-overflow:ellipsis}.game-option text{font-weight:800}.game-option label{margin-top:7rpx;color:#315c50;font-size:19rpx}.game-option view{margin-top:6rpx;color:#858e89;font-size:18rpx}.game-summary{margin-top:22rpx;padding-top:18rpx;border-top:1rpx solid rgba(49,92,80,.12);display:grid;grid-template-columns:1fr 1fr;gap:18rpx 28rpx}.game-summary>view{min-width:0;display:flex;align-items:center;justify-content:space-between;gap:12rpx}.game-summary text{flex:none;color:#879089;font-size:19rpx}.game-summary label{min-width:0;overflow:hidden;color:#354b40;font-size:20rpx;white-space:nowrap;text-overflow:ellipsis}.service-head{margin:35rpx 7rpx 20rpx;display:flex;align-items:center;justify-content:space-between}.service-head text,.service-head label{display:block}.service-head text{font-family:STKaiti,KaiTi,serif;font-size:34rpx;font-weight:800}.service-head label{margin-top:7rpx;color:#7c8881;font-size:19rpx}.seal{padding:7rpx;border:3rpx double #963d31;color:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.service-card{position:relative;margin-bottom:18rpx;padding:18rpx 52rpx 18rpx 18rpx;border:1rpx solid rgba(49,92,80,.17);border-radius:12rpx 28rpx 12rpx 28rpx;display:flex;align-items:center;background:rgba(255,252,241,.94);box-shadow:0 10rpx 26rpx rgba(35,53,43,.07)}.service-card>image,.service-mark{width:125rpx;height:125rpx;flex:none;border-radius:7rpx 23rpx 7rpx 23rpx}.service-mark{display:flex;align-items:center;justify-content:center;color:#fffaf0;background:#315c50;font-family:STKaiti,KaiTi,serif;font-size:42rpx}.service-copy{min-width:0;flex:1;margin-left:20rpx}.service-copy>view{overflow:hidden;font-size:28rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.service-copy>text{display:block;margin-top:8rpx;overflow:hidden;color:#7d8881;font-size:19rpx;white-space:nowrap;text-overflow:ellipsis}.price-line{margin-top:10rpx;display:flex;align-items:baseline;gap:4rpx;color:#963d31;font-size:19rpx;white-space:nowrap}.price-line strong{font-size:29rpx}.arrow{position:absolute;right:18rpx;color:#315c50;font-size:38rpx}.empty{padding:70rpx 20rpx;color:#859088;text-align:center}
.service-card.disabled{opacity:.58}
</style>
