<template>
  <view class="order-content">
    <view v-if="loading && !orders.length" class="skeleton-list">
      <view v-for="index in 3" :key="index" class="skeleton-card" />
    </view>
    <view v-else-if="!orders.length" class="empty-order">
      <view class="empty-icon"><image src="/static/icons/orders.png" /></view>
      <text>{{ emptyText }}</text><label>去服务大厅看看喜欢的陪玩服务吧</label>
      <button @click="goHall">去逛逛</button>
    </view>
    <view v-else class="order-list">
      <view v-for="item in orders" :key="String(item.id)" class="order-card" @click="detail(Number(item.id))">
        <view class="order-top">
          <view><text>{{ formatTime(item.createTime) }}</text><label>订单 {{ shortNo(item.orderNo) }}</label></view>
          <text class="status" :class="customerOrderStatusTone(item.orderStatus)">{{ customerOrderStatusText(item.orderStatus) }}</text>
        </view>
        <view class="order-product">
          <view class="product-cover">
            <image v-if="item.coverUrl" :src="assetUrl(item.coverUrl)" mode="aspectFill" />
            <image v-else class="fallback" src="/static/icons/gamepad.png" mode="aspectFit" />
          </view>
          <view class="product-copy">
            <view class="product-name">{{ item.productName || '陪玩服务' }}</view>
            <text>{{ [item.gameName, item.skuName].filter(Boolean).join(' · ') || '品质陪玩服务' }}</text>
            <label v-if="item.playerName">陪玩师：{{ item.playerName }}</label>
            <label v-else>{{ statusDescription(item.orderStatus) }}</label>
          </view>
        </view>
        <view class="order-bottom">
          <view><text>实付</text><label>¥{{ money(item.payableAmount) }}</label></view>
          <button @click.stop="detail(Number(item.id))">{{ actionText(item.orderStatus) }}</button>
        </view>
      </view>
      <view v-if="loading" class="list-tip">正在加载...</view>
      <view v-else-if="!hasMore" class="list-tip">没有更多订单了</view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import { getCustomerOrders } from '@/api/customer'
import { assetUrl } from '@/services/http'
import { customerOrderStatusText, customerOrderStatusTone } from '@/utils/order-status'
import type { RecordData } from '@/types/api'

const props = withDefaults(defineProps<{ status?: string; emptyText?: string }>(), { status: '', emptyText: '暂无相关订单' })
const orders = ref<RecordData[]>([])
const loading = ref(false)
const current = ref(1)
const total = ref(0)
const hasMore = ref(true)
let requestVersion = 0

watch(() => props.status, () => load(true), { immediate: true })

async function load(reset = true) {
  if (!reset && loading.value) return
  const version = ++requestVersion
  const requestedStatus = props.status
  const requestedPage = reset ? 1 : current.value
  loading.value = true
  if (reset) { current.value = 1; orders.value = []; hasMore.value = true }
  try {
    const result = await getCustomerOrdersPage(requestedStatus, requestedPage)
    if (version !== requestVersion) return
    orders.value = reset ? result.records || [] : [...orders.value, ...(result.records || [])]
    total.value = Number(result.total || 0)
    hasMore.value = orders.value.length < total.value
    current.value = hasMore.value ? requestedPage + 1 : requestedPage
  } finally { if (version === requestVersion) loading.value = false }
}
function getCustomerOrdersPage(status: string, page: number) {
  return getCustomerOrders(status, page, 10)
}
function loadMore() { if (!loading.value && hasMore.value) load(false) }
function detail(id: number) { uni.navigateTo({ url: `/subpackages/customer/order-detail?id=${id}` }) }
function goHall() { uni.switchTab({ url: '/pages/hall/index' }) }
function money(value: unknown) { return Number(value || 0).toFixed(2) }
function shortNo(value: unknown) { const text = String(value || ''); return text.length > 12 ? text.slice(-12) : text || '--' }
function formatTime(value: unknown) { const text = String(value || '').replace('T', ' '); return text.length >= 16 ? text.slice(0, 16) : text || '--' }
function statusDescription(value: unknown) {
  const status = String(value || '')
  if (status === 'PENDING_PAYMENT') return '等待付款后开始匹配'
  if (status === 'WAIT_ASSIGN') return '平台正在匹配陪玩师'
  if (status === 'ASSIGNED') return '陪玩师已接单，等待开始'
  if (status === 'IN_SERVICE') return '服务正在进行中'
  if (status === 'PENDING_CONFIRM') return '平台正在审核服务结果'
  if (status === 'WAIT_CUSTOMER_CONFIRM') return '等待你确认服务完成'
  if (status === 'AFTER_SALE') return '售后正在处理中'
  return '查看订单服务详情'
}
function actionText(value: unknown) {
  const status = String(value || '')
  if (status === 'PENDING_PAYMENT') return '去支付'
  if (status === 'WAIT_CUSTOMER_CONFIRM') return '去确认'
  if (status === 'AFTER_SALE') return '看进度'
  return '查看详情'
}
defineExpose({ load, loadMore })
</script>

<style scoped lang="scss">
.order-list{display:flex;flex-direction:column;gap:20rpx}.order-card{overflow:hidden;border:1rpx solid rgba(49,92,80,.15);border-radius:24rpx;background:rgba(255,252,241,.96);box-shadow:0 12rpx 30rpx rgba(38,54,45,.075)}.order-top{padding:21rpx 24rpx;border-bottom:1rpx solid rgba(49,92,80,.09);display:flex;align-items:center;justify-content:space-between}.order-top>view text,.order-top>view label{display:block}.order-top>view text{color:#3a5045;font-size:21rpx;font-weight:700}.order-top>view label{margin-top:5rpx;color:#a0a69f;font-size:16rpx}.status{padding:7rpx 14rpx;border-radius:18rpx;color:#315c50;background:#e4eee7;font-size:19rpx;font-weight:700}.status.warning{color:#9a5a28;background:#f8ead5}.status.success{background:#dfece5}.status.muted-status{color:#7d817e;background:#ecebe5}.status.danger{color:#9a432f;background:#f5dfd9}.order-product{padding:24rpx;display:flex;gap:20rpx}.product-cover{width:132rpx;height:112rpx;flex:none;overflow:hidden;border-radius:18rpx;background:linear-gradient(135deg,#dce8dd,#eee6d3)}.product-cover image{width:100%;height:100%}.product-cover .fallback{width:60rpx;height:60rpx;margin:26rpx 36rpx;opacity:.68}.product-copy{min-width:0;flex:1}.product-name{overflow:hidden;color:#24382e;font-family:STKaiti,KaiTi,serif;font-size:29rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.product-copy>text{display:block;margin-top:10rpx;overflow:hidden;color:#6f7d75;font-size:20rpx;white-space:nowrap;text-overflow:ellipsis}.product-copy>label{display:block;margin-top:15rpx;color:#9a725c;font-size:19rpx}.order-bottom{padding:18rpx 24rpx;border-top:1rpx solid rgba(49,92,80,.09);display:flex;align-items:center;justify-content:space-between}.order-bottom>view{display:flex;align-items:baseline;gap:8rpx}.order-bottom>view text{color:#8a938d;font-size:18rpx}.order-bottom>view label{color:#963d31;font-size:28rpx;font-weight:800}.order-bottom button{height:58rpx;margin:0;padding:0 25rpx;border:1rpx solid #315c50;border-radius:22rpx;color:#fffaf0;background:#315c50;line-height:58rpx;font-size:20rpx}.empty-order{padding:140rpx 0 90rpx;text-align:center}.empty-icon{width:105rpx;height:105rpx;margin:0 auto;border-radius:50%;display:flex;align-items:center;justify-content:center;background:#dfe8db}.empty-icon image{width:58rpx;height:58rpx;opacity:.7}.empty-order>text,.empty-order>label{display:block}.empty-order>text{margin-top:25rpx;color:#3d5147;font-size:27rpx;font-weight:700}.empty-order>label{margin-top:10rpx;color:#929b95;font-size:20rpx}.empty-order button{width:210rpx;height:66rpx;margin:28rpx auto 0;border-radius:24rpx;color:#fffaf0;background:#315c50;font-size:21rpx;line-height:66rpx}.list-tip{padding:22rpx 0;color:#9aa29c;text-align:center;font-size:19rpx}.skeleton-list{display:flex;flex-direction:column;gap:20rpx}.skeleton-card{height:260rpx;border-radius:24rpx;background:linear-gradient(100deg,#e8e5da 30%,#f5f1e6 50%,#e8e5da 70%);background-size:200% 100%;animation:shimmer 1.2s infinite}@keyframes shimmer{to{background-position:-200% 0}}
</style>
