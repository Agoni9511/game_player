<template>
  <view class="hall-page">
    <view class="hall-heading">
      <view><text>服务大厅</text><label>按游戏与需求挑选陪玩服务</label></view>
      <view class="hall-seal">严选</view>
    </view>
    <view class="hall-search" @click="openCatalog('')">
      <image src="/static/icons/search.png" />
      <text>搜索游戏、套餐或陪玩服务</text>
      <view>搜索</view>
    </view>
    <view class="hall-grid">
      <view class="hall-card hall-primary" @click="openCatalog('')">
        <image src="/static/home/service-hall.jpg" mode="aspectFill" />
        <view class="shade"></view>
        <view class="copy"><label>全部服务</label><text>按游戏挑选</text><view>单局、小时与专项服务</view></view>
      </view>
      <view class="hall-card" @click="openCatalog('package')">
        <image src="/static/home/curated-package.jpg" mode="aspectFill" />
        <view class="shade"></view>
        <view class="copy"><label>热门推荐</label><text>精选套餐</text><view>组合下单更划算</view></view>
      </view>
      <view class="hall-card" @click="openCatalog('')">
        <image src="/static/home/choose-player.jpg" mode="aspectFill" />
        <view class="shade"></view>
        <view class="copy"><label>平台严选</label><text>品质服务</text><view>资料审核，履约留痕</view></view>
      </view>
    </view>
    <view class="hall-tip"><text>保</text><view><view>安心下单</view><label>资料审核 · 订单留痕 · 售后有保障</label></view><view>›</view></view>
  </view>
</template>

<script setup lang="ts">
function openCatalog(entry: string) {
  if (entry) uni.setStorageSync('peiwan_catalog_entry', entry)
  else uni.removeStorageSync('peiwan_catalog_entry')
  uni.navigateTo({ url: '/pages/discover/index' })
}
</script>

<style scoped>
.hall-page{min-height:100vh;padding:34rpx 28rpx calc(250rpx + env(safe-area-inset-bottom));box-sizing:border-box;background-color:#eee9da;background-image:radial-gradient(circle at 88% 2%,rgba(91,126,108,.15),transparent 34%),linear-gradient(180deg,rgba(244,240,225,.86),rgba(244,240,225,.96))}.hall-heading{padding:20rpx 8rpx 26rpx;display:flex;align-items:center;justify-content:space-between}.hall-heading text,.hall-heading label{display:block}.hall-heading text{font-family:STKaiti,KaiTi,serif;font-size:44rpx;font-weight:800}.hall-heading label{margin-top:10rpx;color:#748078;font-size:21rpx}.hall-seal{padding:9rpx;border:3rpx double #963d31;color:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.hall-search{height:82rpx;padding:0 10rpx 0 24rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:42rpx;display:flex;align-items:center;background:rgba(255,252,241,.94);box-shadow:0 9rpx 24rpx rgba(35,53,43,.06)}.hall-search image{width:34rpx;height:34rpx;opacity:.72}.hall-search>text{flex:1;margin-left:14rpx;color:#85908a;font-size:24rpx}.hall-search>view{padding:11rpx 18rpx;border-radius:28rpx;color:#fffaf0;background:#315c50;font-size:20rpx}.hall-grid{margin-top:24rpx;display:grid;grid-template-columns:1fr 1fr;gap:18rpx}.hall-card{position:relative;height:250rpx;overflow:hidden;border:1rpx solid rgba(49,92,80,.18);border-radius:28rpx;background:#315c50;box-shadow:0 12rpx 28rpx rgba(37,54,45,.1)}.hall-primary{height:320rpx;grid-column:1/3}.hall-card image,.shade{position:absolute;inset:0;width:100%;height:100%}.shade{background:linear-gradient(180deg,rgba(23,42,34,.06),rgba(23,42,34,.84))}.copy{position:absolute;z-index:2;left:22rpx;right:20rpx;bottom:20rpx;color:#fffaf0}.copy label{display:inline-block;padding:5rpx 11rpx;border-radius:16rpx;background:#963d31;font-size:17rpx}.copy text{display:block;margin-top:10rpx;font-family:STKaiti,KaiTi,serif;font-size:31rpx;font-weight:800}.copy view{margin-top:6rpx;color:rgba(255,250,240,.74);font-size:19rpx}.hall-tip{margin-top:24rpx;padding:22rpx 24rpx;border:1rpx solid rgba(49,92,80,.16);border-radius:28rpx;display:flex;align-items:center;background:rgba(255,252,241,.9)}.hall-tip>text{width:54rpx;height:54rpx;border-radius:50%;color:#fffaf0;background:#315c50;line-height:54rpx;text-align:center;font-family:STKaiti,KaiTi,serif;font-weight:800}.hall-tip>view:nth-child(2){flex:1;margin-left:16rpx}.hall-tip>view:nth-child(2)>view{font-weight:700}.hall-tip label{display:block;margin-top:6rpx;color:#7c8781;font-size:19rpx}.hall-tip>view:last-child{color:#963d31;font-size:34rpx}
</style>
