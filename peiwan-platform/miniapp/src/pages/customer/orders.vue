<template>
  <PlayerOrderList v-if="mode.isPlayerMode" ref="playerOrders" />
  <view v-else class="orders-page page tab-page">
    <view class="orders-head"><view><text>我的订单</text><label>服务进度，一目了然</label></view><view class="seal">单</view></view>
    <scroll-view class="filter-scroll" scroll-x :show-scrollbar="false">
      <view class="filters"><view v-for="item in filters" :key="item.value" :class="{ active: status === item.value }" @click="status = item.value">{{ item.label }}</view></view>
    </scroll-view>
    <CustomerOrderCards ref="customerOrders" :status="status" empty-text="暂无顾客订单" />
  </view>
</template>

<script setup lang="ts">
import { nextTick, ref } from 'vue'
import { onReachBottom, onShow } from '@dcloudio/uni-app'
import CustomerOrderCards from '@/components/CustomerOrderCards.vue'
import PlayerOrderList from '@/components/PlayerOrderList.vue'
import { useAppModeStore } from '@/stores/app-mode'
import { requireLogin } from '@/utils/auth-guard'

const mode = useAppModeStore()
const status = ref('')
const customerOrders = ref<InstanceType<typeof CustomerOrderCards>>()
const playerOrders = ref<InstanceType<typeof PlayerOrderList>>()
const filters = [
  { label: '全部', value: '' }, { label: '待付款', value: 'PENDING_PAYMENT' }, { label: '待接单', value: 'WAIT_ASSIGN' },
  { label: '服务中', value: 'ACTIVE_SERVICE' }, { label: '待确认', value: 'PENDING_CONFIRMATION' }, { label: '售后', value: 'AFTER_SALE' },
]
onShow(async () => {
  if (!requireLogin('登录后才能查看订单')) return
  await nextTick()
  if (mode.isPlayerMode) await playerOrders.value?.load()
  else await customerOrders.value?.load(true)
})
onReachBottom(() => { if (!mode.isPlayerMode) customerOrders.value?.loadMore() })
</script>

<style scoped lang="scss">
.orders-page{min-height:100vh;padding-bottom:calc(230rpx + env(safe-area-inset-bottom));background:radial-gradient(circle at 88% 0,rgba(87,126,105,.16),transparent 32%),#eee9da}.orders-head{min-height:135rpx;padding:27rpx 30rpx;border-radius:24rpx;box-sizing:border-box;display:flex;align-items:center;justify-content:space-between;color:#fff4da;background:linear-gradient(125deg,#1d4034,#496e5e);box-shadow:0 14rpx 32rpx rgba(35,58,48,.16)}.orders-head text,.orders-head label{display:block}.orders-head text{font-family:STKaiti,KaiTi,serif;font-size:37rpx;font-weight:800;letter-spacing:2rpx}.orders-head label{margin-top:9rpx;color:rgba(255,244,218,.62);font-size:19rpx}.seal{width:60rpx;height:60rpx;border:2rpx solid rgba(241,201,157,.7);color:#efcaa3;line-height:60rpx;text-align:center;font-family:STKaiti,KaiTi,serif;font-size:28rpx;transform:rotate(6deg)}.filter-scroll{margin:24rpx 0 20rpx;white-space:nowrap}.filters{display:inline-flex;gap:13rpx}.filters>view{padding:12rpx 25rpx;border:1rpx solid rgba(49,92,80,.15);border-radius:25rpx;color:#68766e;background:rgba(255,252,241,.78);font-size:21rpx}.filters>view.active{border-color:#315c50;color:#fffaf0;background:#315c50}
</style>
