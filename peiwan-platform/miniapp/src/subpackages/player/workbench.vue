<template>
  <view class="page">
    <view class="title heading">接单工作台</view>
    <view v-if="!auth.isPlayer" class="card muted">当前账号没有陪玩师角色，无法进入接单功能。</view>
    <template v-else>
      <view class="card">
        <view class="row">
          <view><view>当前状态</view><view class="status">{{ workStatusLabel }}</view></view>
          <button size="mini" :disabled="toggling" @click="toggle">{{ toggling ? '切换中...' : workStatus === 'AVAILABLE' ? '暂停接单' : '开始接单' }}</button>
        </view>
      </view>
      <view class="card action" @click="dispatches">待响应派单 <text>查看 ›</text></view>
      <view class="card action" @click="orders">我的服务订单 <text>查看 ›</text></view>
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
</script>

<style scoped>
.heading { margin-bottom: 28rpx; }
.row, .action { display: flex; align-items: center; justify-content: space-between; }
.status { margin-top: 10rpx; color: #315c50; font-size: 34rpx; font-weight: 800; }
.row button { margin: 0; color: #fffaf0; background: #315c50; }
.action { color: #263a31; }.action text { color: #829087; }
</style>
