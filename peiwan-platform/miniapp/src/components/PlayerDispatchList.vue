<template>
  <view class="dispatch-board">
    <view class="board-head">
      <view><text>抢单大厅</text><label>{{ list.length + transfers.length }} 个待处理</label></view>
      <view class="refresh" @click="load">刷新</view>
    </view>
    <view v-if="transfers.length" class="group-title"><text>转单邀请</text><label>{{ transfers.length }}</label></view>
    <view v-for="item in transfers" :key="`transfer-${item.id}`" class="task-card transfer-card">
      <view class="task-top"><text class="type transfer">转单</text><label>已审核</label></view>
      <view class="task-title">{{ item.sourcePlayerName || item.source_player_name || '原服务成员' }} 邀请你接替</view>
      <view class="task-sub">{{ shortOrderNo(item.orderNo || item.order_no) }}</view>
      <view class="actions"><button size="mini" @click="respondTransfer(Number(item.id), 'REJECT')">不接</button><button size="mini" class="primary" @click="respondTransfer(Number(item.id), 'ACCEPT')">接单</button></view>
    </view>
    <view v-if="list.length" class="group-title"><text>可接服务</text><label>{{ list.length }}</label></view>
    <view v-for="item in list" :key="String(item.taskId)" class="task-card">
      <view class="task-top"><text class="type">{{ item.gameName || '游戏陪玩' }}</text><label>{{ deadlineText(item.deadlineAt) }}</label></view>
      <view class="task-title">{{ item.productName || '平台派单' }}</view>
      <view class="task-meta">
        <text>{{ item.skuName || '默认规格' }}</text>
        <text v-if="item.serverName || item.rankName">{{ [item.serverName,item.rankName].filter(Boolean).join(' · ') }}</text>
        <text class="missing">缺 {{ item.remainingPlayerCount || 0 }} 人</text>
      </view>
      <view class="actions"><button size="mini" @click="reject(Number(item.taskId))">不接</button><button size="mini" class="primary" @click="accept(item)">接单</button></view>
    </view>
    <EmptyState v-if="!loading && !list.length && !transfers.length" text="当前没有待响应的派单，保持接单状态会收到新邀请" />
    <view v-if="loading" class="loading">正在同步最新派单...</view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { acceptDispatch, getPendingDispatches, rejectDispatch, getPendingServiceTransfers, respondServiceTransfer } from '@/api/player'
import EmptyState from '@/components/EmptyState.vue'
import type { RecordData } from '@/types/api'

const list = ref<RecordData[]>([])
const transfers = ref<RecordData[]>([])
const loading = ref(false)

async function load() {
  loading.value = true
  try { [list.value, transfers.value] = await Promise.all([getPendingDispatches(), getPendingServiceTransfers()]) }
  finally { loading.value = false }
}
async function accept(item: RecordData) { await acceptDispatch(Number(item.taskId)); uni.showToast({ title: Number(item.remainingPlayerCount) > 1 ? '已加入，等待队友' : '接单成功', icon: 'none' }); await load() }
async function reject(id: number) { await rejectDispatch(id, '暂时无法服务'); uni.showToast({ title: '已拒绝' }); await load() }
async function respondTransfer(id: number, action: 'ACCEPT'|'REJECT') { await respondServiceTransfer(id, action); uni.showToast({ title: action === 'ACCEPT' ? '转单接替成功' : '已拒绝' }); await load() }
function deadlineText(value: unknown) { if (!value) return '尽快响应'; return `${String(value).replace('T',' ').slice(5,16)} 前` }
function shortOrderNo(value: unknown) { const orderNo = String(value || '服务订单'); return orderNo.length > 18 ? `订单 …${orderNo.slice(-10)}` : `订单 ${orderNo}` }
defineExpose({ load })
</script>

<style scoped>
.dispatch-board{padding:20rpx 24rpx 210rpx}.board-head{padding:12rpx 4rpx 22rpx;display:flex;align-items:center;justify-content:space-between}.board-head text,.board-head label{display:block}.board-head text{color:#1d3027;font-family:STKaiti,KaiTi,serif;font-size:39rpx;font-weight:800}.board-head label{margin-top:3rpx;color:#89928c;font-size:19rpx}.refresh{padding:9rpx 17rpx;border-radius:24rpx;color:#315c50;background:#e1e7de;font-size:19rpx}.group-title{margin:8rpx 4rpx 12rpx;display:flex;align-items:center;gap:9rpx;color:#56655d;font-size:21rpx;font-weight:700}.group-title label{min-width:30rpx;height:30rpx;border-radius:15rpx;color:#fff;background:#963d31;line-height:30rpx;text-align:center;font-size:16rpx}.task-card{margin-bottom:16rpx;padding:22rpx;border:1rpx solid rgba(54,79,68,.15);border-radius:22rpx;background:rgba(255,252,241,.97);box-shadow:0 7rpx 20rpx rgba(36,54,44,.06)}.transfer-card{border-left:6rpx solid #963d31}.task-top{display:flex;align-items:center;justify-content:space-between}.task-top label{color:#91988f;font-size:18rpx}.type{max-width:360rpx;overflow:hidden;padding:5rpx 12rpx;border-radius:14rpx;color:#315c50;background:#e1e8dd;font-size:18rpx;white-space:nowrap;text-overflow:ellipsis}.type.transfer{color:#963d31;background:#f0e0d7}.task-title{margin-top:14rpx;overflow:hidden;color:#26372f;font-size:28rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.task-sub{margin-top:8rpx;overflow:hidden;color:#8b938e;font-size:18rpx;white-space:nowrap;text-overflow:ellipsis}.task-meta{margin-top:13rpx;display:flex;align-items:center;gap:10rpx;overflow:hidden}.task-meta text{flex:none;padding:5rpx 10rpx;border-radius:12rpx;color:#68766e;background:#eff0e8;font-size:18rpx;white-space:nowrap}.task-meta .missing{margin-left:auto;color:#963d31;background:transparent;font-weight:700}.actions{margin-top:18rpx;display:grid;grid-template-columns:1fr 1.55fr;gap:14rpx}.actions button{width:100%;height:62rpx;margin:0;border:1rpx solid #d6dbd4;border-radius:31rpx;color:#69756e;background:#f6f5ed;line-height:60rpx;font-size:21rpx}.actions button::after{border:0}.actions .primary{border-color:#315c50;color:#fffaf0;background:#315c50}.loading{padding:70rpx;color:#7d8981;text-align:center}
</style>
