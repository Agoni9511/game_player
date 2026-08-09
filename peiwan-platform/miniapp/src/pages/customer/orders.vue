<template>
  <PlayerOrderList v-if="mode.isPlayerMode" ref="playerOrders" />
  <view v-else class="page">
    <view class="title heading">我的订单</view>
    <view v-for="item in orders" :key="String(item.id)" class="card" @click="detail(Number(item.id))">
      <view class="row"><text>{{ item.orderNo || '服务订单' }}</text><text class="status" :class="customerOrderStatusTone(item.orderStatus)">{{ customerOrderStatusText(item.orderStatus) }}</text></view>
      <view class="muted name">{{ item.productName || item.customerRemark || '陪玩服务' }}</view>
    </view>
    <EmptyState v-if="!loading&&!orders.length" text="暂无顾客订单，可前往首页选择陪玩服务" />
  </view>
</template>
<script setup lang="ts">
import{nextTick,ref}from'vue';import{onShow}from'@dcloudio/uni-app';import{getCustomerOrders}from'@/api/customer';import{useAppModeStore}from'@/stores/app-mode';import{customerOrderStatusText,customerOrderStatusTone}from'@/utils/order-status';import EmptyState from '@/components/EmptyState.vue';import PlayerOrderList from '@/components/PlayerOrderList.vue';import type{RecordData}from'@/types/api';const mode=useAppModeStore(),orders=ref<RecordData[]>([]),loading=ref(false),playerOrders=ref<InstanceType<typeof PlayerOrderList>>();onShow(async()=>{if(mode.isPlayerMode){await nextTick();await playerOrders.value?.load();return}loading.value=true;try{orders.value=(await getCustomerOrders()).records||[]}catch{orders.value=[]}finally{loading.value=false}});const detail=(id:number)=>uni.navigateTo({url:`/subpackages/customer/order-detail?id=${id}`})
</script>
<style scoped>.heading{margin:16rpx 0 30rpx}.row{display:flex;justify-content:space-between;gap:20rpx;font-weight:600}.status{flex:none;padding:4rpx 12rpx;border-radius:6rpx;color:#315c50;background:#e5eee8;font-size:24rpx}.status.warning{color:#9a5a28;background:#f8ead5}.status.success{color:#315c50;background:#dfece5}.status.muted-status{color:#7d817e;background:#ecebe5}.status.danger{color:#9a432f;background:#f5dfd9}.name{margin-top:20rpx}</style>
