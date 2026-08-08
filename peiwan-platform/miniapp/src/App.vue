<script setup lang="ts">
import { onLaunch } from '@dcloudio/uni-app'
import { useAuthStore } from '@/stores/auth'

onLaunch(() => useAuthStore().restore())
</script>

<style lang="scss">
page { background: #eee9da; color: #17241f; font-size: 28rpx; }
button::after { border: 0; }
.page { min-height: 100vh; padding: 28rpx; box-sizing: border-box; background-color: #eee9da; background-image: linear-gradient(rgba(244,240,225,.89),rgba(244,240,225,.94)),url('/static/ink-tactical-bg.jpg'); background-size: 100% auto; background-repeat: no-repeat; }
.card { position: relative; overflow: hidden; background: rgba(255,253,244,.9); border: 1rpx solid rgba(54,79,68,.18); border-radius: 12rpx 28rpx 12rpx 28rpx; padding: 28rpx; margin-bottom: 24rpx; box-shadow: 0 10rpx 28rpx rgba(31,48,39,.07); }
.card::after { content: ''; position: absolute; right: -24rpx; top: -24rpx; width: 72rpx; height: 72rpx; border: 2rpx solid rgba(141,52,39,.12); border-radius: 50%; }
.primary { background: #315c50 !important; color: #fffaf0 !important; border-radius: 8rpx 18rpx 8rpx 18rpx !important; }
.muted { color: #68766e; }
.title { color: #18251f; font-family: STKaiti, KaiTi, serif; font-size: 40rpx; font-weight: 800; letter-spacing: 2rpx; }
.tab-page { padding-bottom: calc(250rpx + env(safe-area-inset-bottom)) !important; }
</style>
