<template>
  <view class="page">
    <view class="title heading">待响应邀请</view>
    <view v-for="item in transfers" :key="`transfer-${item.id}`" class="card transfer">
      <view class="card-head"><view>成员转单邀请</view><text>平台已审核</text></view>
      <view class="muted info">订单 {{ item.order_no }}：{{ item.source_player_name }} 希望由你接替</view>
      <view class="buttons"><button size="mini" @click="respondTransfer(Number(item.id), 'REJECT')">拒绝</button><button size="mini" class="primary" @click="respondTransfer(Number(item.id), 'ACCEPT')">接受转单</button></view>
    </view>
    <view v-for="item in list" :key="String(item.taskId)" class="card">
      <view class="card-head"><view>{{ item.taskNo || item.orderNo || '派单邀请' }}</view><text>{{ item.memberCount || 0 }}/{{ item.requiredPlayerCount || 1 }} 人</text></view>
      <view class="muted info">{{ item.productName || item.gameName }}</view><view class="quota">还需 {{ item.remainingPlayerCount || 0 }} 位陪玩师</view>
      <view class="buttons"><button size="mini" @click="reject(Number(item.taskId))">拒绝</button><button size="mini" class="primary" @click="accept(item)">接受</button></view>
    </view>
    <EmptyState v-if="!list.length && !transfers.length" />
  </view>
</template>
<script setup lang="ts">
import { ref } from 'vue';import { onShow } from '@dcloudio/uni-app';import { acceptDispatch,getPendingDispatches,rejectDispatch,getPendingServiceTransfers,respondServiceTransfer } from '@/api/player';import EmptyState from '@/components/EmptyState.vue';import type { RecordData } from '@/types/api';
const list=ref<RecordData[]>([]),transfers=ref<RecordData[]>([]);async function load(){[list.value,transfers.value]=await Promise.all([getPendingDispatches(),getPendingServiceTransfers()])}onShow(load);async function accept(item:RecordData){await acceptDispatch(Number(item.taskId));uni.showToast({title:Number(item.remainingPlayerCount)>1?'已加入，等待队友':'接单成功',icon:'none'});await load()}async function reject(id:number){await rejectDispatch(id,'暂时无法服务');uni.showToast({title:'已拒绝'});await load()}async function respondTransfer(id:number,action:'ACCEPT'|'REJECT'){await respondServiceTransfer(id,action);uni.showToast({title:action==='ACCEPT'?'转单接替成功':'已拒绝'});await load()}
</script>
<style scoped>.heading{margin-bottom:30rpx}.card-head{display:flex;align-items:center;justify-content:space-between}.card-head text,.quota{color:#315c50;font-size:23rpx}.info{margin:18rpx 0}.quota{padding:14rpx 18rpx;border-radius:12rpx;background:#edf2e9}.transfer{border-left:8rpx solid #7659ef}.buttons{display:flex;justify-content:flex-end;gap:20rpx;margin-top:20rpx}.buttons button{margin:0}</style>
