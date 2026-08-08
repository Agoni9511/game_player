<template>
  <view class="info-row" :class="{ multiline }" @click="copy">
    <text class="label">{{ label }}</text>
    <view class="value-wrap">
      <text class="value">{{ displayValue }}</text>
      <text v-if="copyable && displayValue !== '-'" class="copy">复制</text>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed } from 'vue'

const props = withDefaults(defineProps<{
  label: string
  value?: string | number
  multiline?: boolean
  copyable?: boolean
}>(), { value: '-', multiline: false, copyable: false })
const displayValue = computed(() => props.value === null || props.value === undefined || props.value === '' ? '-' : String(props.value))

function copy() {
  if (!props.copyable || displayValue.value === '-') return
  uni.setClipboardData({ data: displayValue.value, showToast: false, success: () => uni.showToast({ title: '已复制' }) })
}
</script>

<style scoped>
.info-row{display:flex;justify-content:space-between;gap:28rpx;padding:19rpx 0;border-bottom:1rpx solid rgba(54,79,68,.1);font-size:27rpx}.info-row:last-child{border-bottom:0}.label{flex:none;color:#748078}.value-wrap{display:flex;justify-content:flex-end;align-items:center;gap:12rpx;min-width:0}.value{color:#26352e;text-align:right;word-break:break-all}.copy{flex:none;padding:3rpx 9rpx;color:#8d3427;border:1rpx solid rgba(141,52,39,.3);border-radius:5rpx;font-size:20rpx}.multiline{align-items:flex-start}.multiline .value{line-height:1.65}
</style>
