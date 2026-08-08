<template>
  <view class="detail-page">
    <view class="hero" :class="product.gameId === 2 ? 'valorant' : 'delta'">
      <image v-if="product.coverUrl" :src="String(product.coverUrl)" mode="aspectFill" />
      <view v-else class="hero-copy"><text>{{ product.gameName || '凌竞严选' }}</text><label>战术陪玩服务</label></view>
      <view class="seal">凌竞</view>
    </view>
    <view class="content">
      <view class="card intro-card">
        <view class="tags"><text>{{ product.gameName }}</text><text>{{ product.categoryName }}</text></view>
        <view class="product-name">{{ product.productName || '服务详情' }}</view>
        <view class="subtitle">{{ product.subtitle || '平台严选，透明履约' }}</view>
        <view class="price"><text>¥</text><strong>{{ money(selectedSku.price || product.minPrice) }}</strong><label> / {{ unitLabel(selectedSku.unitType) }}</label></view>
      </view>

      <view class="card">
        <view class="section-title">选择服务规格</view>
        <view class="sku-list">
          <view v-for="sku in skus" :key="String(sku.id)" class="sku" :class="{ active: Number(selectedSku.id) === Number(sku.id) }" @click="selectedSku = sku">
            <view><text>{{ sku.skuName }}</text><label v-if="sku.serviceMinutes">约 {{ sku.serviceMinutes }} 分钟</label></view><strong>¥{{ money(sku.price) }}</strong>
          </view>
        </view>
      </view>

      <view class="card">
        <view class="section-title">服务内容</view>
        <view class="description">{{ product.description || '由平台审核通过的陪玩师提供服务，订单进度全程可查。' }}</view>
        <view v-for="item in components" :key="String(item.serviceId)" class="service-line"><text>✓</text><view>{{ item.serviceName }} · {{ item.quantity }} {{ unitLabel(item.unitType) }}</view></view>
      </view>

      <view class="card guarantee"><view class="section-title">平台保障</view><view class="guarantee-grid"><view><text>保</text><label>平台担保</label></view><view><text>审</text><label>陪玩师审核</label></view><view><text>证</text><label>履约留证</label></view><view><text>售</text><label>售后处理</label></view></view></view>
    </view>

    <view class="action-bar"><view class="service" @click="contact"><image src="/static/icons/headset.svg"/><text>客服</text></view><view class="buy" @click="nextStep">立即下单</view></view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getCatalogProduct } from '@/api/customer'
import type { RecordData } from '@/types/api'

const product = ref<RecordData>({})
const selectedSku = ref<RecordData>({})
const skus = computed(() => (product.value.skus || []) as RecordData[])
const components = computed(() => (product.value.components || []) as RecordData[])
onLoad(async query => { const id = Number(query?.id || 0); if (!id) return; product.value = await getCatalogProduct(id); selectedSku.value = skus.value[0] || {} })
function money(value: unknown) { return Number(value || 0).toFixed(2) }
function unitLabel(value: unknown) { return ({ HOUR: '小时', GAME: '局', ORDER: '单' } as Record<string, string>)[String(value || '')] || '份' }
function contact() { uni.showModal({ title: '联系平台客服', content: '在线客服通道将在消息中心接入；当前开发版请联系平台管理员。', showCancel: false }) }
function nextStep() { if (!selectedSku.value.id) return uni.showToast({ title: '请选择服务规格', icon: 'none' }); uni.navigateTo({ url: `/subpackages/customer/confirm-order?productId=${product.value.id}&skuId=${selectedSku.value.id}` }) }
</script>

<style scoped lang="scss">
.detail-page{min-height:100vh;padding-bottom:150rpx;background:#eee9da url('/static/ink-tactical-bg.jpg') center top/100% auto no-repeat}.hero{position:relative;height:380rpx;overflow:hidden;background:linear-gradient(145deg,rgba(68,103,87,.95),rgba(28,48,40,.95))}.hero.valorant{background:linear-gradient(145deg,#80604e,#293e35)}.hero>image{width:100%;height:100%}.hero-copy{height:100%;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#f7f0dc}.hero-copy text{font-family:STKaiti,KaiTi,serif;font-size:55rpx;font-weight:800}.hero-copy label{margin-top:18rpx;letter-spacing:9rpx}.seal{position:absolute;right:35rpx;bottom:35rpx;padding:10rpx;border:3rpx double #f1d5c5;color:#fff3df;background:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.content{position:relative;margin-top:-35rpx;padding:0 24rpx}.card{margin-bottom:22rpx}.intro-card{padding-top:34rpx}.tags{display:flex;gap:10rpx}.tags text{padding:6rpx 13rpx;color:#315c50;background:#dfe7db;font-size:19rpx}.tags text+text{color:#89653f;background:#eee3cd}.product-name{margin-top:18rpx;font-family:STKaiti,KaiTi,serif;color:#17251f;font-size:40rpx;font-weight:800}.subtitle{margin-top:10rpx;color:#78847d;font-size:22rpx}.price{margin-top:24rpx;color:#963d31}.price strong{font-size:45rpx}.price label{color:#80766c;font-size:20rpx}.section-title{margin-bottom:22rpx;font-family:STKaiti,KaiTi,serif;font-size:31rpx;font-weight:800}.sku{min-height:76rpx;margin-bottom:14rpx;padding:17rpx 20rpx;border:1rpx solid #cad3c7;border-radius:7rpx 18rpx 7rpx 18rpx;display:flex;align-items:center;justify-content:space-between}.sku.active{border-color:#315c50;background:#e3eadf;box-shadow:inset 5rpx 0 #315c50}.sku text,.sku label{display:block}.sku label{margin-top:7rpx;color:#858f88;font-size:18rpx}.sku strong{color:#963d31}.description{color:#606e66;line-height:1.75}.service-line{margin-top:17rpx;display:flex;gap:13rpx;color:#394e44}.service-line>text{color:#315c50;font-weight:800}.guarantee-grid{display:grid;grid-template-columns:repeat(4,1fr)}.guarantee-grid view{display:flex;flex-direction:column;align-items:center;gap:10rpx}.guarantee-grid text{width:53rpx;height:53rpx;border:2rpx solid #315c50;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#315c50;font-family:STKaiti,KaiTi,serif;font-weight:800}.guarantee-grid label{color:#68756e;font-size:19rpx}.action-bar{position:fixed;z-index:20;left:0;right:0;bottom:0;height:112rpx;padding:12rpx 24rpx calc(12rpx + env(safe-area-inset-bottom));display:flex;align-items:center;gap:20rpx;background:rgba(255,252,241,.97);box-shadow:0 -8rpx 28rpx rgba(40,55,46,.12)}.service{width:85rpx;display:flex;flex-direction:column;align-items:center;color:#56675e;font-size:18rpx}.service image{width:42rpx;height:42rpx}.buy{height:84rpx;flex:1;border-radius:8rpx 23rpx 8rpx 23rpx;display:flex;align-items:center;justify-content:center;color:#fff8e9;background:#315c50;font-weight:800;letter-spacing:3rpx}
</style>
