<template>
  <view class="detail-page">
    <view class="hero" :class="product.gameId === 2 ? 'valorant' : 'delta'">
      <image v-if="product.coverUrl" :src="assetUrl(product.coverUrl)" mode="aspectFill" />
      <view v-else class="hero-copy"><text>{{ product.gameName || '凌竞严选' }}</text><label>战术陪玩服务</label></view>
      <view class="seal">凌竞</view>
    </view>
    <view class="content">
      <view class="card intro-card">
        <view class="tags"><text>{{ product.gameName }}</text><text>{{ product.categoryName }}</text></view>
        <view class="product-name">{{ product.productName || '服务详情' }}</view>
        <view class="subtitle">{{ product.subtitle || '平台严选，透明履约' }}</view>
        <view class="price"><text class="currency">¥</text><text class="price-value">{{ money(currentPrice) }}</text><text class="price-unit">/ {{ skuUnitLabel(selectedSku.unitType, selectedSku.unitCount) }}</text></view>
      </view>

      <view class="card">
        <view class="section-title">选择服务规格</view>
        <view class="sku-list">
          <view v-for="sku in skus" :key="String(sku.id)" class="sku" :class="{ active: Number(selectedSku.id) === Number(sku.id) }" @click="selectSku(sku)">
            <view><text>{{ sku.skuName }}</text><label>{{ sku.serviceMinutes ? `约 ${sku.serviceMinutes} 分钟 · ` : '' }}{{ sku.playerCount || 1 }} 位陪玩</label></view><text class="sku-price">¥{{ money(skuStartingPrice(sku)) }}{{ hasLevelPrice(sku) ? '起' : '' }}{{ sku.priceType === 'PER_PLAYER' ? '/人' : '' }}</text>
          </view>
        </view>
      </view>

      <view v-if="requestedPlayerId" class="card appointed-card">
        <view class="section-title">已指定陪玩师</view>
        <view class="appointed-player"><view class="appointed-mark">定</view><view><strong>{{ requestedPlayerName }}</strong><label>平台认证陪玩 · 本订单仅推送给该陪玩师</label></view><text @click="cancelAppointment">更换 ›</text></view>
      </view>

      <view v-else-if="product.productType === 'SERVICE' && levelPrices.length" class="card player-choice-card">
        <view class="section-title">选择陪玩方式</view>
        <view class="player-entry" @click="choosePlayer">
          <view class="entry-mark">选</view>
          <view><strong>进入陪玩挑选页</strong><label>按风格、性别、评分与价格找到心仪陪玩</label></view>
          <text>去挑选 ›</text>
        </view>
        <view class="preference-tags"><text>甜美声线</text><text>耐心教学</text><text>欢乐开黑</text><text>深夜在线</text></view>
        <view class="hall-tip"><text>厅</text><view><strong>也可以不指定具体陪玩</strong><label>进入挑选页选择服务预算，订单将发布到大厅智能匹配</label></view></view>
      </view>

      <view class="card">
        <view class="section-title">服务内容</view>
        <view class="description">{{ product.description || '由平台审核通过的陪玩师提供服务，订单进度全程可查。' }}</view>
        <view v-for="item in components" :key="String(item.serviceId)" class="service-line"><text>✓</text><view>{{ item.serviceName }} · {{ item.quantity }} {{ unitLabel(item.unitType) }}</view></view>
      </view>

      <view v-if="commitments.length" class="card commitment-card">
        <view class="section-title">{{ product.productType === 'PACKAGE' ? '套餐承诺' : '服务承诺' }}</view>
        <view v-for="rule in commitments" :key="String(rule.id || `${rule.ruleType}-${rule.sortNo}`)" class="commitment-line">
          <text>诺</text><view><strong>{{ rule.title }}<label v-if="targetText(rule)">{{ targetText(rule) }}</label></strong><p v-if="rule.description">{{ rule.description }}</p><p v-if="rule.failureAction">未达标处理：{{ rule.failureAction }}</p></view>
        </view>
      </view>

      <view class="card guarantee"><view class="section-title">平台保障</view><view class="guarantee-grid"><view><text>保</text><label>平台担保</label></view><view><text>审</text><label>陪玩师审核</label></view><view><text>证</text><label>履约留证</label></view><view><text>售</text><label>售后处理</label></view></view></view>
    </view>

    <view class="action-bar"><view class="service" @click="contact"><image src="/static/icons/headset.png"/><text>客服</text></view><view class="buy" @click="nextStep">{{ requestedPlayerId ? `指定 ${requestedPlayerName} 下单` : product.productType === 'SERVICE' ? '选择陪玩并下单' : '立即下单' }}</view></view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getCatalogProduct } from '@/api/customer'
import { assetUrl } from '@/services/http'
import { requireLogin } from '@/utils/auth-guard'
import type { RecordData } from '@/types/api'

const product = ref<RecordData>({})
const selectedSku = ref<RecordData>({})
const selectedLevelId = ref(0)
const requestedPlayerId = ref(0)
const requestedPlayerName = ref('')
const skus = computed(() => (product.value.skus || []) as RecordData[])
const components = computed(() => (product.value.components || []) as RecordData[])
const commitments = computed(() => ((selectedSku.value.commitments || []) as RecordData[]).filter(item => item.enabled !== false))
const levelPrices = computed(() => ((selectedSku.value.levelPrices || []) as RecordData[]).filter(item => item.enabled !== false))
const selectedLevel = computed(() => levelPrices.value.find(item => Number(item.playerLevelId) === selectedLevelId.value))
const startingPrice = computed(() => { const prices = levelPrices.value.map(item => Number(item.price)).filter(price => price >= 0); return prices.length ? Math.min(...prices) : Number(selectedSku.value.price ?? product.value.minPrice ?? 0) })
const currentPrice = computed(() => requestedPlayerId.value ? (selectedLevel.value?.price ?? selectedSku.value.price) : startingPrice.value)
onLoad(async query => { const id = Number(query?.id || 0); if (!id) return; requestedPlayerId.value = Number(query?.requestedPlayerId || 0); requestedPlayerName.value = decodeURIComponent(String(query?.requestedPlayerName || '所选陪玩师')); selectedLevelId.value = Number(query?.playerLevelId || 0); product.value = await getCatalogProduct(id); selectSku(skus.value[0] || {}) })
function selectSku(sku: RecordData) { selectedSku.value = sku; const prices = ((sku.levelPrices || []) as RecordData[]).filter(item => item.enabled !== false); if (requestedPlayerId.value && !prices.some(item => Number(item.playerLevelId) === selectedLevelId.value)) selectedLevelId.value = 0 }
function money(value: unknown) { return Number(value || 0).toFixed(2) }
function enabledLevelPrices(sku: RecordData) { return ((sku.levelPrices || []) as RecordData[]).filter(item => item.enabled !== false && item.price !== null && item.price !== undefined) }
function hasLevelPrice(sku: RecordData) { return enabledLevelPrices(sku).length > 0 }
function skuStartingPrice(sku: RecordData) { const prices = enabledLevelPrices(sku).map(item => Number(item.price)).filter(price => price >= 0); return prices.length ? Math.min(...prices) : Number(sku.price || 0) }
function unitLabel(value: unknown) { return ({ HOUR: '小时', GAME: '局', ORDER: '单' } as Record<string, string>)[String(value || '')] || '份' }
function skuUnitLabel(value: unknown, count: unknown) { const amount = Number(count || 1); return `${amount > 1 ? amount : ''}${unitLabel(value)}` }
function targetText(rule: RecordData) { return rule.targetValue === null || rule.targetValue === undefined || rule.targetValue === '' ? '' : `${rule.targetValue}${rule.targetUnit || ''}` }
function contact() { uni.showModal({ title: '联系平台客服', content: '在线客服通道将在消息中心接入；当前开发版请联系平台管理员。', showCancel: false }) }
function choosePlayer() { if (!selectedSku.value.id) return uni.showToast({ title: '请选择服务规格', icon: 'none' }); if (!requireLogin('登录后才能选择陪玩并下单')) return; uni.navigateTo({ url: `/subpackages/customer/select-player?productId=${product.value.id}&skuId=${selectedSku.value.id}` }) }
function nextStep() { if (!selectedSku.value.id) return uni.showToast({ title: '请选择服务规格', icon: 'none' }); if (!requestedPlayerId.value && product.value.productType === 'SERVICE') return choosePlayer(); if (!requireLogin('登录后才能提交订单')) return; const name = requestedPlayerId.value ? `&requestedPlayerId=${requestedPlayerId.value}&requestedPlayerName=${encodeURIComponent(requestedPlayerName.value)}` : ''; uni.navigateTo({ url: `/subpackages/customer/confirm-order?productId=${product.value.id}&skuId=${selectedSku.value.id}&playerLevelId=${selectedLevelId.value || ''}${name}` }) }
function cancelAppointment() { requestedPlayerId.value = 0; requestedPlayerName.value = ''; selectSku(selectedSku.value) }
</script>

<style scoped lang="scss">
.detail-page{min-height:100vh;padding-bottom:150rpx;background-color:#eee9da;background-image:radial-gradient(circle at 88% 2%,rgba(91,126,108,.15),transparent 34%),linear-gradient(180deg,rgba(244,240,225,.86),rgba(244,240,225,.96))}.hero{position:relative;height:380rpx;overflow:hidden;background:linear-gradient(145deg,rgba(68,103,87,.95),rgba(28,48,40,.95))}.hero.valorant{background:linear-gradient(145deg,#80604e,#293e35)}.hero>image{width:100%;height:100%}.hero-copy{height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#f7f0dc}.hero-copy text{font-family:STKaiti,KaiTi,serif;font-size:55rpx;font-weight:800}.hero-copy label{margin-top:18rpx;letter-spacing:9rpx}.seal{position:absolute;right:35rpx;bottom:35rpx;padding:10rpx;border:3rpx double #f1d5c5;color:#fff3df;background:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.content{position:relative;margin-top:-35rpx;padding:0 24rpx}.card{margin-bottom:22rpx}.intro-card{padding-top:34rpx}.tags{display:flex;gap:10rpx}.tags text{padding:6rpx 13rpx;color:#315c50;background:#dfe7db;font-size:19rpx}.tags text+text{color:#89653f;background:#eee3cd}.product-name{margin-top:18rpx;font-family:STKaiti,KaiTi,serif;color:#17251f;font-size:40rpx;font-weight:800}.subtitle{margin-top:10rpx;color:#78847d;font-size:22rpx}.price{margin-top:24rpx;display:flex;align-items:baseline;color:#963d31;white-space:nowrap}.price .currency{margin-right:3rpx;font-size:23rpx}.price-value{font-size:45rpx;font-weight:800;line-height:1}.price-unit{margin-left:8rpx;color:#80766c;font-size:20rpx}.section-title{margin-bottom:22rpx;font-family:STKaiti,KaiTi,serif;font-size:31rpx;font-weight:800}.sku{min-height:76rpx;margin-bottom:14rpx;padding:17rpx 20rpx;border:1rpx solid #cad3c7;border-radius:7rpx 18rpx 7rpx 18rpx;display:flex;align-items:center;justify-content:space-between}.sku.active{border-color:#315c50;background:#e3eadf;box-shadow:inset 5rpx 0 #315c50}.sku text,.sku label{display:block}.sku label{margin-top:7rpx;color:#858f88;font-size:18rpx}.sku-price{flex:none;margin-left:18rpx;color:#963d31;font-weight:700}.description{color:#606e66;line-height:1.75}.service-line{margin-top:17rpx;display:flex;gap:13rpx;color:#394e44}.service-line>text{color:#315c50;font-weight:800}.guarantee-grid{display:grid;grid-template-columns:repeat(4,1fr)}.guarantee-grid view{display:flex;flex-direction:column;align-items:center;gap:10rpx}.guarantee-grid text{width:53rpx;height:53rpx;border:2rpx solid #315c50;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#315c50;font-family:STKaiti,KaiTi,serif;font-weight:800}.guarantee-grid label{color:#68756e;font-size:19rpx}.action-bar{position:fixed;z-index:20;left:0;right:0;bottom:0;height:112rpx;padding:12rpx 24rpx calc(12rpx + env(safe-area-inset-bottom));display:flex;align-items:center;gap:20rpx;background:rgba(255,252,241,.97);box-shadow:0 -8rpx 28rpx rgba(40,55,46,.12)}.service{width:85rpx;display:flex;flex-direction:column;align-items:center;color:#56675e;font-size:18rpx}.service image{width:42rpx;height:42rpx}.buy{height:84rpx;flex:1;border-radius:8rpx 23rpx 8rpx 23rpx;display:flex;align-items:center;justify-content:center;color:#fff8e9;background:#315c50;font-weight:800;letter-spacing:3rpx}
.player-entry strong,.player-entry label,.hall-tip strong,.hall-tip label{display:block}.player-entry label,.hall-tip label{margin-top:6rpx;color:#7b877f;font-size:18rpx}.player-entry{padding:22rpx 20rpx;border:1rpx solid rgba(49,92,80,.22);border-radius:8rpx 24rpx 8rpx 24rpx;display:flex;align-items:center;background:linear-gradient(135deg,#eef1e5,#f8f3e5)}.entry-mark{width:62rpx;height:62rpx;margin-right:16rpx;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fffaf0;background:#315c50;font-family:STKaiti,KaiTi,serif;font-weight:800}.player-entry>view:nth-child(2){flex:1}.player-entry>text{color:#315c50;font-size:21rpx;font-weight:700}.preference-tags{margin-top:17rpx;display:flex;flex-wrap:wrap;gap:10rpx}.preference-tags text{padding:7rpx 13rpx;border-radius:17rpx;color:#5f756a;background:#e3e9df;font-size:17rpx}.hall-tip{margin-top:20rpx;padding-top:18rpx;border-top:1rpx solid rgba(49,92,80,.14);display:flex;align-items:center}.hall-tip>text{width:45rpx;height:45rpx;flex:none;margin-right:13rpx;border:1rpx solid #8b6e49;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#8b6e49;font-family:STKaiti,KaiTi,serif}.hall-tip>view{flex:1}
.appointed-card{border-color:rgba(150,61,49,.25);background:linear-gradient(135deg,#fffaf0,#eee3cc)}.appointed-player{display:flex;align-items:center}.appointed-mark{width:64rpx;height:64rpx;flex:none;margin-right:17rpx;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fffaf0;background:#963d31;font-family:STKaiti,KaiTi,serif;font-weight:800}.appointed-player>view:nth-child(2){min-width:0;flex:1}.appointed-player strong,.appointed-player label{display:block}.appointed-player label{margin-top:7rpx;color:#7c827b;font-size:18rpx}.appointed-player>text{flex:none;margin-left:15rpx;color:#315c50;font-size:20rpx}
.commitment-card{border-color:rgba(150,61,49,.2);background:linear-gradient(135deg,#fffdf4,#f4e8dc)}.commitment-line{display:flex;gap:16rpx;padding:18rpx 0;border-bottom:1rpx solid rgba(150,61,49,.1)}.commitment-line:last-child{border-bottom:0}.commitment-line>text{width:43rpx;height:43rpx;flex:none;border-radius:50%;color:#fff8e9;background:#963d31;font-family:STKaiti,KaiTi,serif;line-height:43rpx;text-align:center}.commitment-line>view{min-width:0;flex:1}.commitment-line strong{display:flex;align-items:baseline;justify-content:space-between;color:#3d2c25;font-size:25rpx}.commitment-line label{margin-left:16rpx;color:#963d31;font-size:28rpx}.commitment-line p{margin:8rpx 0 0;color:#776b63;font-size:20rpx;line-height:1.5}
</style>
