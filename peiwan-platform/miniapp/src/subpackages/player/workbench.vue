<template>
  <view class="page">
    <view v-if="!auth.isPlayer" class="card muted">当前账号没有陪玩师角色，无法进入接单功能。</view>
    <template v-else>
      <view class="status-panel">
        <view class="row">
          <view><view>当前状态</view><view class="status">{{ workStatusLabel }}</view></view>
          <button size="mini" :disabled="toggling" @click="toggle">{{ toggling ? '切换中...' : workStatus === 'AVAILABLE' ? '暂停接单' : '开始接单' }}</button>
        </view>
      </view>
      <view class="stats"><view><text>{{ data.pendingDispatchCount || 0 }}</text><label>待响应</label></view><view><text>{{ data.activeOrderCount || 0 }}</text><label>进行中</label></view><view><text>{{ data.completedOrderCount || 0 }}</text><label>已完成</label></view></view>
      <view class="menu-card"><view class="action" @click="dispatches"><view><text>抢单大厅</text><label>查看平台派单和转单邀请</label></view><text>›</text></view><view class="action" @click="orders"><view><text>服务订单</text><label>处理待开始和服务中订单</label></view><text>›</text></view><view class="action" @click="settlement"><view><text>收益中心</text><label>查看余额与结算明细</label></view><text>›</text></view></view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getWorkbench, updateWorkStatus } from '@/api/player'
import { useAuthStore } from '@/stores/auth'
import type { RecordData } from '@/types/api'

const auth = useAuthStore()
const data = ref<RecordData>({})
const toggling = ref(false)
const workStatus = computed(() => String((data.value.player as RecordData | undefined)?.workStatus || 'OFFLINE'))
const workStatusLabel = computed(() => ({ AVAILABLE: '接单中', BUSY: '服务中', OFFLINE: '休息中' } as Record<string, string>)[workStatus.value] || '休息中')

onShow(async () => { if (auth.isPlayer) data.value = await getWorkbench() })

async function toggle() {
  if (toggling.value || workStatus.value === 'BUSY') return
  const target = workStatus.value === 'AVAILABLE' ? 'OFFLINE' : 'AVAILABLE'
  toggling.value = true
  try {
    await updateWorkStatus(target)
    data.value = await getWorkbench()
    uni.showToast({ title: target === 'AVAILABLE' ? '已开始接单' : '已暂停接单', icon: 'success' })
  } finally {
    toggling.value = false
  }
}

const dispatches = () => uni.navigateTo({ url: '/subpackages/player/dispatches' })
const orders = () => uni.navigateTo({ url: '/subpackages/player/orders' })
const settlement = () => uni.navigateTo({ url: '/subpackages/player/settlement' })
</script>

<style scoped>
.page{padding:24rpx 24rpx 80rpx}.status-panel{padding:27rpx;border:1rpx solid rgba(49,92,80,.16);border-radius:24rpx;background:#fffaf0}.row{display:flex;align-items:center;justify-content:space-between}.row>view>view:first-child{color:#7a857e;font-size:21rpx}.status{margin-top:8rpx;color:#315c50;font-size:34rpx;font-weight:800}.row button{height:62rpx;margin:0;padding:0 25rpx;border-radius:31rpx;color:#fffaf0;background:#315c50;line-height:62rpx}.stats{margin:16rpx 0 20rpx;display:grid;grid-template-columns:repeat(3,1fr);gap:13rpx}.stats view{padding:21rpx 8rpx;border:1rpx solid rgba(49,92,80,.13);border-radius:19rpx;text-align:center;background:rgba(255,250,240,.82)}.stats text,.stats label{display:block}.stats text{font-size:31rpx;font-weight:800}.stats label{margin-top:6rpx;color:#7f8983;font-size:18rpx}.menu-card{padding:0 24rpx;border:1rpx solid rgba(49,92,80,.15);border-radius:24rpx;background:#fffaf0}.action{min-height:105rpx;border-bottom:1rpx solid rgba(49,92,80,.1);display:flex;align-items:center;justify-content:space-between}.action:last-child{border:0}.action>view text,.action>view label{display:block}.action>view text{color:#263a31;font-size:25rpx;font-weight:700}.action>view label{margin-top:7rpx;color:#8b948e;font-size:18rpx}.action>text{color:#8a958e;font-size:38rpx}
</style>
