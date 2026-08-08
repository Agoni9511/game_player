<template>
  <view v-if="visible" class="mask" @touchmove.stop.prevent>
    <view class="dialog">
      <view class="dialog-head">
        <view><view class="title">下单须知</view><view class="subtitle">请完整阅读俱乐部服务规则</view></view>
        <view class="close" @click="$emit('close')">×</view>
      </view>

      <scroll-view scroll-y class="image-scroll">
        <image class="notice-image" src="/static/first-visit-notice.jpg" mode="widthFix" />
      </scroll-view>

      <view class="actions">
        <view class="check-row" @click="agreed=!agreed">
          <view class="checkbox" :class="{ checked: agreed }">{{ agreed ? '✓' : '' }}</view>
          <text>我已仔细阅读并同意遵守以上规则</text>
        </view>
        <view class="confirm" :class="{ disabled: !agreed }" @click="confirm">同意并进入</view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'

const props = defineProps<{ visible: boolean }>()
const emit = defineEmits<{ confirm: []; close: [] }>()
const agreed = ref(false)

watch(() => props.visible, value => { if (value) agreed.value = false })

function confirm() {
  if (!agreed.value) return uni.showToast({ title: '请先勾选同意规则', icon: 'none' })
  emit('confirm')
}
</script>

<style scoped lang="scss">
.mask { position: fixed; z-index: 9999; inset: 0; padding: 70rpx 34rpx; box-sizing: border-box; display: flex; align-items: center; justify-content: center; background: rgba(12,10,26,.76); backdrop-filter: blur(8rpx); }
.dialog { width: 100%; max-height: 90vh; overflow: hidden; border-radius: 30rpx; background: #fff; box-shadow: 0 32rpx 100rpx rgba(0,0,0,.36); }
.dialog-head { height: 104rpx; padding: 0 28rpx; display: flex; align-items: center; justify-content: space-between; color: #fff; background: linear-gradient(105deg,#292347,#7257ea); }
.title { font-size: 31rpx; font-weight: 800; }.subtitle { margin-top: 5rpx; color: rgba(255,255,255,.62); font-size: 19rpx; }.close { width: 54rpx; height: 54rpx; border-radius: 50%; display: flex; align-items: center; justify-content: center; color: rgba(255,255,255,.8); background: rgba(255,255,255,.12); font-size: 38rpx; }
.image-scroll { height: 850rpx; background: #f7f5ec; }.notice-image { display: block; width: 100%; }
.actions { padding: 22rpx 28rpx 27rpx; border-top: 1rpx solid #eee; background: #fff; }.check-row { display: flex; align-items: center; justify-content: center; gap: 11rpx; color: #707584; font-size: 21rpx; }.checkbox { width: 30rpx; height: 30rpx; border: 2rpx solid #c5c9d3; border-radius: 8rpx; line-height: 30rpx; text-align: center; color: #fff; }.checkbox.checked { border-color: #7357ef; background: #7357ef; }.confirm { height: 82rpx; margin-top: 18rpx; border-radius: 18rpx; display: flex; align-items: center; justify-content: center; color: #fff; background: linear-gradient(100deg,#8067ff,#6547ed); font-size: 27rpx; font-weight: 700; box-shadow: 0 12rpx 28rpx rgba(105,75,229,.23); }.confirm.disabled { opacity: .45; }
</style>
