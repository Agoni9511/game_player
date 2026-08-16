<template>
  <view v-if="mode.isPlayerMode" class="notice-page">
    <view class="notice-head"><view><text>服务通知</text><label>{{ dispatches.length + transfers.length + activeOrders.length }} 条待处理</label></view><view @click="loadPlayer">刷新</view></view>
    <view v-for="item in transfers" :key="`transfer-${item.id}`" class="notice-card urgent" @click="openDispatch">
      <view class="notice-icon">转</view><view class="notice-copy"><text>收到成员转单邀请</text><label>{{ item.sourcePlayerName || item.source_player_name || '其他陪玩师' }} 邀请你接替订单 {{ item.orderNo || item.order_no || '' }}</label><view>立即处理 ›</view></view>
    </view>
    <view v-for="item in dispatches" :key="`dispatch-${item.taskId}`" class="notice-card" @click="openDispatch">
      <view class="notice-icon">派</view><view class="notice-copy"><text>新的平台派单</text><label>{{ item.gameName || '游戏陪玩' }} · {{ item.productName || item.skuName || item.taskNo }}</label><view>{{ deadline(item.deadlineAt) }} ›</view></view>
    </view>
    <view v-for="item in activeOrders" :key="`order-${item.id}`" class="notice-card order" @click="openOrder(item)">
      <view class="notice-icon">单</view><view class="notice-copy"><text>{{ statusText(item.orderStatus) }}</text><label>{{ item.gameName || '游戏陪玩' }} · {{ item.productName || item.orderNo }}</label><view>查看服务单 ›</view></view>
    </view>
    <EmptyState v-if="!loading && !dispatches.length && !transfers.length && !activeOrders.length" text="暂无待处理通知，新派单会第一时间显示在这里" />
    <view v-if="loading" class="loading">通知同步中...</view>
  </view>
  <view v-else class="customer-notice page"><view class="title heading">消息中心</view><view class="card message"><image src="/static/icons/bell.png"/><view><view>服务通知</view><text>订单状态和售后进度将在这里展示</text></view></view><view class="planned">用户消息接口尚未开发，当前为功能预留页</view></view>
</template>
<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getPendingDispatches, getPendingServiceTransfers, getPlayerOrders } from '@/api/player'
import { useAppModeStore } from '@/stores/app-mode'
import EmptyState from '@/components/EmptyState.vue'
import type { RecordData } from '@/types/api'
const mode=useAppModeStore(),dispatches=ref<RecordData[]>([]),transfers=ref<RecordData[]>([]),orders=ref<RecordData[]>([]),loading=ref(false)
const activeOrders=computed(()=>orders.value.filter(item=>['ASSIGNED','IN_SERVICE','PAUSED','PENDING_CONFIRM','WAIT_CUSTOMER_CONFIRM','AFTER_SALE'].includes(String(item.orderStatus))))
onShow(()=>{mode.ensureAllowed();if(mode.isPlayerMode)loadPlayer()})
async function loadPlayer(){loading.value=true;try{const [d,t,o]=await Promise.all([getPendingDispatches(),getPendingServiceTransfers(),getPlayerOrders()]);dispatches.value=d;transfers.value=t;orders.value=o.records||[]}finally{loading.value=false}}
function openDispatch(){uni.switchTab({url:'/pages/hall/index'})}
function openOrder(item:RecordData){uni.navigateTo({url:`/subpackages/player/order-detail?id=${item.id}`})}
function deadline(value:unknown){return value?`请在 ${String(value).replace('T',' ').slice(5,16)} 前响应`:'请尽快响应'}
function statusText(value:unknown){return({ASSIGNED:'服务待开始',IN_SERVICE:'服务进行中',PAUSED:'服务已暂停',PENDING_CONFIRM:'完成凭证待审核',WAIT_CUSTOMER_CONFIRM:'等待顾客确认',AFTER_SALE:'订单售后处理中'}as Record<string,string>)[String(value)]||'服务单状态更新'}
</script>
<style scoped>
.notice-page{min-height:100vh;padding:22rpx 24rpx 210rpx;box-sizing:border-box;background:#eee9da}.notice-head{padding:12rpx 4rpx 22rpx;display:flex;align-items:center;justify-content:space-between}.notice-head text,.notice-head label{display:block}.notice-head text{font-family:STKaiti,KaiTi,serif;font-size:39rpx;font-weight:800}.notice-head label{margin-top:3rpx;color:#89928c;font-size:19rpx}.notice-head>view:last-child{padding:9rpx 17rpx;border-radius:24rpx;color:#315c50;background:#dfe7dc;font-size:19rpx}.notice-card{margin-bottom:14rpx;padding:21rpx;border:1rpx solid rgba(49,92,80,.14);border-radius:22rpx;display:flex;align-items:center;background:#fffaf0}.notice-icon{width:60rpx;height:60rpx;flex:none;border-radius:19rpx;color:#fffaf0;background:#315c50;line-height:60rpx;text-align:center;font-family:STKaiti,KaiTi,serif;font-size:25rpx;font-weight:800}.notice-card.urgent .notice-icon{background:#963d31}.notice-card.order .notice-icon{background:#8b6a40}.notice-copy{min-width:0;flex:1;margin-left:16rpx}.notice-copy text,.notice-copy label,.notice-copy view{display:block}.notice-copy text{font-size:24rpx;font-weight:800}.notice-copy label{margin-top:6rpx;overflow:hidden;color:#7b867f;font-size:18rpx;white-space:nowrap;text-overflow:ellipsis}.notice-copy view{margin-top:7rpx;color:#315c50;font-size:17rpx}.loading,.planned{padding:80rpx 20rpx;color:#8b948e;text-align:center}.heading{margin:18rpx 0 30rpx}.message{display:flex;align-items:center;gap:22rpx}.message image{width:70rpx;height:70rpx}.message view view{font-weight:700}.message text{display:block;margin-top:10rpx;color:#959aa8;font-size:22rpx}
</style>
