<template><view class="empty"><text class="emoji">🎮</text><text>{{ text }}</text></view></template>
<script setup lang="ts">withDefaults(defineProps<{ text?: string }>(), { text: '暂时没有数据' })</script>
<style scoped>.empty{padding:100rpx 20rpx;text-align:center;color:#969dad;display:flex;flex-direction:column;gap:20rpx}.emoji{font-size:72rpx}</style>
