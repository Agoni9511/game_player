<template>
  <view class="order-page page">
    <view class="page-head">
      <view><text>{{ title }}</text><label>{{ subtitle }}</label></view>
      <view class="seal">单</view>
    </view>
    <CustomerOrderCards v-if="ready" ref="list" :status="status" :empty-text="`暂无${title}订单`" />
  </view>
</template>

<script setup lang="ts">
import { computed, nextTick, ref } from 'vue'
import { onLoad, onReachBottom, onShow } from '@dcloudio/uni-app'
import CustomerOrderCards from '@/components/CustomerOrderCards.vue'
import { requireLogin } from '@/utils/auth-guard'
import { customerOrderStatusLabels } from '@/utils/order-status'

const status = ref('')
const ready = ref(false)
const list = ref<InstanceType<typeof CustomerOrderCards>>()
const title = computed(() => customerOrderStatusLabels[status.value] || '全部订单')
const subtitle = computed(() => ({
  PENDING_PAYMENT: '及时支付，平台才会开始匹配服务',
  WAIT_ASSIGN: '订单正在大厅等待合适的陪玩师',
  ACTIVE_SERVICE: '查看已接单与正在服务的订单',
  PENDING_CONFIRMATION: '查看审核进度并确认服务结果',
  AFTER_SALE: '跟进售后处理状态与结果',
}[status.value] || '查看全部服务订单与当前进度'))

onLoad(query => { status.value = String(query?.status || ''); ready.value = true })
onShow(async () => {
  if (!requireLogin('登录后才能查看订单')) return
  await nextTick()
  await list.value?.load(true)
})
onReachBottom(() => list.value?.loadMore())
</script>

<style scoped lang="scss">
.order-page{min-height:100vh;padding-bottom:70rpx;background:radial-gradient(circle at 88% 0,rgba(87,126,105,.16),transparent 32%),#eee9da}.page-head{min-height:135rpx;margin-bottom:24rpx;padding:27rpx 30rpx;border-radius:24rpx;box-sizing:border-box;display:flex;align-items:center;justify-content:space-between;color:#fff4da;background:linear-gradient(125deg,#1d4034,#496e5e);box-shadow:0 14rpx 32rpx rgba(35,58,48,.16)}.page-head text,.page-head label{display:block}.page-head text{font-family:STKaiti,KaiTi,serif;font-size:37rpx;font-weight:800;letter-spacing:2rpx}.page-head label{margin-top:9rpx;color:rgba(255,244,218,.62);font-size:19rpx}.seal{width:60rpx;height:60rpx;border:2rpx solid rgba(241,201,157,.7);color:#efcaa3;line-height:60rpx;text-align:center;font-family:STKaiti,KaiTi,serif;font-size:28rpx;transform:rotate(6deg)}
</style>
