<template>
  <view class="hall-page">
    <view class="hall-heading">
      <view><text>服务大厅</text><label>按游戏与需求挑选陪玩服务</label></view>
      <view class="hall-seal">严选</view>
    </view>
    <view class="hall-search" @click="openCatalog('')">
      <image src="/static/icons/search.png" />
      <text>搜索游戏、套餐或陪玩服务</text>
      <view>搜索</view>
    </view>
    <view class="hall-grid">
      <view class="hall-card hall-primary" @click="openCatalog('')">
        <image src="/static/home/service-hall.jpg" mode="aspectFill" />
        <view class="shade"></view>
        <view class="copy"><label>全部服务</label><text>按游戏挑选</text><view>单局、小时与专项服务</view></view>
      </view>
      <view class="hall-card" @click="openCatalog('package')">
        <image src="/static/home/curated-package.jpg" mode="aspectFill" />
        <view class="shade"></view>
        <view class="copy"><label>热门推荐</label><text>精选套餐</text><view>组合下单更划算</view></view>
      </view>
      <view class="hall-card" @click="openPlayers">
        <image src="/static/home/choose-player.jpg" mode="aspectFill" />
        <view class="shade"></view>
        <view class="copy"><label>指定陪玩</label><text>选择陪玩</text><view>按风格选择心仪队友</view></view>
      </view>
    </view>
    <view class="hall-tip"><text>保</text><view><view>安心下单</view><label>资料审核 · 订单留痕 · 售后有保障</label></view><view>›</view></view>

    <view class="product-section-head">
      <view><text>热门服务</text><label>{{ products.length }} 项精选</label></view>
      <view @click="openCatalog('')">查看全部 <text>›</text></view>
    </view>
    <view class="product-grid">
      <view v-for="item in products" :key="String(item.id)" class="product-card" @click="openProduct(Number(item.id))">
        <view class="product-cover">
          <image v-if="item.coverUrl" :src="assetUrl(item.coverUrl)" mode="aspectFill" />
          <view v-else class="cover-fallback"><text>{{ gameShort(item.gameName) }}</text><label>{{ item.productType === 'PACKAGE' ? '套餐' : '服务' }}</label></view>
          <view class="product-type">{{ item.productType === 'PACKAGE' ? '组合套餐' : '陪玩服务' }}</view>
        </view>
        <view class="product-body">
          <view class="product-meta"><text>{{ item.gameName }}</text><label>{{ item.categoryName }}</label></view>
          <view class="product-name">{{ item.productName }}</view>
          <view class="product-subtitle">{{ item.subtitle || item.description || '平台严选陪玩服务' }}</view>
          <view class="product-foot"><view><text>¥</text><label>{{ money(item.minPrice) }}</label><text class="price-suffix">起</text></view><text>详情 ›</text></view>
        </view>
      </view>
    </view>
    <view v-if="loading" class="product-loading">正在加载服务...</view>
    <view v-else-if="!products.length" class="product-empty" @click="openCatalog('')">暂无上架服务，查看全部分类 ›</view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getCatalogProducts } from '@/api/customer'
import { assetUrl } from '@/services/http'
import type { RecordData } from '@/types/api'

const products = ref<RecordData[]>([])
const loading = ref(false)

onShow(loadProducts)

async function loadProducts() {
  loading.value = true
  try {
    const page = await getCatalogProducts({ current: 1, size: 6 })
    products.value = page.records || []
  } finally { loading.value = false }
}

function openCatalog(entry: string) {
  const query = entry === 'package' ? '?productType=PACKAGE' : ''
  uni.navigateTo({ url: `/pages/discover/index${query}` })
}
function openProduct(id: number) { uni.navigateTo({ url: `/subpackages/customer/product-detail?id=${id}` }) }
function openPlayers() { uni.switchTab({ url: '/pages/players/index' }) }
function gameShort(value: unknown) { return String(value || '游戏').slice(0, 4) }
function money(value: unknown) { return Number(value || 0).toFixed(0) }
</script>

<style scoped>
.hall-page{min-height:100vh;padding:34rpx 28rpx calc(250rpx + env(safe-area-inset-bottom));box-sizing:border-box;background-color:#eee9da;background-image:radial-gradient(circle at 88% 2%,rgba(91,126,108,.15),transparent 34%),linear-gradient(180deg,rgba(244,240,225,.86),rgba(244,240,225,.96))}.hall-heading{padding:20rpx 8rpx 26rpx;display:flex;align-items:center;justify-content:space-between}.hall-heading text,.hall-heading label{display:block}.hall-heading text{font-family:STKaiti,KaiTi,serif;font-size:44rpx;font-weight:800}.hall-heading label{margin-top:10rpx;color:#748078;font-size:21rpx}.hall-seal{padding:9rpx;border:3rpx double #963d31;color:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.hall-search{height:82rpx;padding:0 10rpx 0 24rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:42rpx;display:flex;align-items:center;background:rgba(255,252,241,.94);box-shadow:0 9rpx 24rpx rgba(35,53,43,.06)}.hall-search image{width:34rpx;height:34rpx;opacity:.72}.hall-search>text{flex:1;margin-left:14rpx;color:#85908a;font-size:24rpx}.hall-search>view{padding:11rpx 18rpx;border-radius:28rpx;color:#fffaf0;background:#315c50;font-size:20rpx}.hall-grid{margin-top:24rpx;display:grid;grid-template-columns:1fr 1fr;gap:18rpx}.hall-card{position:relative;height:250rpx;overflow:hidden;border:1rpx solid rgba(49,92,80,.18);border-radius:28rpx;background:#315c50;box-shadow:0 12rpx 28rpx rgba(37,54,45,.1)}.hall-primary{height:320rpx;grid-column:1/3}.hall-card image,.shade{position:absolute;inset:0;width:100%;height:100%}.shade{background:linear-gradient(180deg,rgba(23,42,34,.06),rgba(23,42,34,.84))}.copy{position:absolute;z-index:2;left:22rpx;right:20rpx;bottom:20rpx;color:#fffaf0}.copy label{display:inline-block;padding:5rpx 11rpx;border-radius:16rpx;background:#963d31;font-size:17rpx}.copy text{display:block;margin-top:10rpx;font-family:STKaiti,KaiTi,serif;font-size:31rpx;font-weight:800}.copy view{margin-top:6rpx;color:rgba(255,250,240,.74);font-size:19rpx}.hall-tip{margin-top:24rpx;padding:22rpx 24rpx;border:1rpx solid rgba(49,92,80,.16);border-radius:28rpx;display:flex;align-items:center;background:rgba(255,252,241,.9)}.hall-tip>text{width:54rpx;height:54rpx;border-radius:50%;color:#fffaf0;background:#315c50;line-height:54rpx;text-align:center;font-family:STKaiti,KaiTi,serif;font-weight:800}.hall-tip>view:nth-child(2){flex:1;margin-left:16rpx}.hall-tip>view:nth-child(2)>view{font-weight:700}.hall-tip label{display:block;margin-top:6rpx;color:#7c8781;font-size:19rpx}.hall-tip>view:last-child{color:#963d31;font-size:34rpx}
.product-section-head{margin:38rpx 4rpx 20rpx;display:flex;align-items:flex-end;justify-content:space-between}.product-section-head>view:first-child text{display:block;color:#1d3027;font-family:STKaiti,KaiTi,serif;font-size:36rpx;font-weight:800}.product-section-head>view:first-child label{display:block;margin-top:7rpx;color:#818c85;font-size:19rpx}.product-section-head>view:last-child{color:#687970;font-size:20rpx}.product-section-head>view:last-child text{margin-left:4rpx;color:#963d31;font-size:27rpx}.product-grid{display:grid;grid-template-columns:1fr 1fr;gap:18rpx}.product-card{overflow:hidden;border:1rpx solid rgba(49,92,80,.17);border-radius:24rpx;background:rgba(255,252,241,.94);box-shadow:0 10rpx 26rpx rgba(38,54,45,.07)}.product-cover{position:relative;height:190rpx;overflow:hidden;background:linear-gradient(135deg,#547466,#263f36)}.product-cover>image{width:100%;height:100%}.cover-fallback{height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#fff4da}.cover-fallback text{font-family:STKaiti,KaiTi,serif;font-size:31rpx;font-weight:800}.cover-fallback label{margin-top:9rpx;font-size:18rpx}.product-type{position:absolute;left:14rpx;top:14rpx;padding:6rpx 11rpx;border-radius:16rpx;color:#fff8e9;background:rgba(27,58,47,.78);font-size:16rpx}.product-body{padding:18rpx 17rpx 19rpx}.product-meta{height:27rpx;overflow:hidden;display:flex;gap:7rpx}.product-meta text,.product-meta label{padding:4rpx 8rpx;border-radius:10rpx;color:#426257;background:#e1e9df;font-size:15rpx;white-space:nowrap}.product-meta label{color:#8a6240;background:#eee2cc}.product-name{margin-top:12rpx;overflow:hidden;color:#1e3027;font-size:25rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.product-subtitle{height:52rpx;margin-top:8rpx;overflow:hidden;color:#7a857e;font-size:18rpx;line-height:26rpx}.product-foot{margin-top:12rpx;display:flex;align-items:flex-end;justify-content:space-between}.product-foot>view{display:flex;align-items:baseline;color:#963d31}.product-foot>view text{font-size:18rpx}.product-foot>view label{font-size:31rpx;font-weight:800;line-height:1}.product-foot .price-suffix{margin-left:4rpx;color:#8a8178;font-size:16rpx}.product-foot>text{color:#416256;font-size:18rpx}.product-loading,.product-empty{padding:70rpx 20rpx;color:#7d8981;text-align:center;font-size:21rpx}
</style>
