<script setup lang="ts">
import { onLaunch } from '@dcloudio/uni-app'
import { useAuthStore } from '@/stores/auth'
import { useAppModeStore } from '@/stores/app-mode'

onLaunch(async () => {
  await useAuthStore().restore()
  useAppModeStore().ensureAllowed()
})
</script>

<style lang="scss">
page { background: #eee9da; color: #17241f; font-size: 28rpx; }
button::after { border: 0; }
.page { min-height: 100vh; padding: 28rpx; box-sizing: border-box; background-color: #eee9da; background-image: radial-gradient(circle at 88% 2%,rgba(91,126,108,.15),transparent 34%),linear-gradient(180deg,rgba(244,240,225,.86),rgba(244,240,225,.96)); background-repeat: no-repeat; }
.card { position: relative; overflow: hidden; background: rgba(255,253,244,.9); border: 1rpx solid rgba(54,79,68,.18); border-radius: 12rpx 28rpx 12rpx 28rpx; padding: 28rpx; margin-bottom: 24rpx; box-shadow: 0 10rpx 28rpx rgba(31,48,39,.07); }
.card::after { content: ''; position: absolute; right: -24rpx; top: -24rpx; width: 72rpx; height: 72rpx; border: 2rpx solid rgba(141,52,39,.12); border-radius: 50%; }
.primary { background: #315c50 !important; color: #fffaf0 !important; border-radius: 8rpx 18rpx 8rpx 18rpx !important; }
.muted { color: #68766e; }
.title { color: #18251f; font-family: STKaiti, KaiTi, serif; font-size: 40rpx; font-weight: 800; letter-spacing: 2rpx; }
.tab-page { padding-bottom: calc(250rpx + env(safe-area-inset-bottom)) !important; }
.customer-head{padding:34rpx 10rpx 20rpx;display:flex;align-items:flex-end;justify-content:space-between}.customer-head .eyebrow{margin-bottom:10rpx;font-size:20rpx}.customer-head .title{font-size:43rpx}.customer-seal{padding:8rpx 10rpx;border:3rpx double #963d31;color:#963d31;font-family:STKaiti,KaiTi,serif;font-size:22rpx;font-weight:800;transform:rotate(5deg)}
.service-search{height:82rpx;margin:8rpx 0 22rpx;padding:0 10rpx 0 24rpx;border:1rpx solid rgba(49,92,80,.18);border-radius:42rpx;display:flex;align-items:center;background:rgba(255,252,241,.94);box-shadow:0 9rpx 24rpx rgba(35,53,43,.06)}.service-search image{width:34rpx;height:34rpx;opacity:.72}.service-search input{flex:1;margin-left:14rpx;color:#66736c;font-size:24rpx}.service-search>view{min-width:78rpx;padding:11rpx 18rpx;border-radius:28rpx;box-sizing:border-box;color:#fffaf0;background:#315c50;font-size:20rpx;text-align:center}
.mode-grid{height:630rpx;display:grid;grid-template-columns:1fr 1fr;grid-template-rows:1fr 1fr .92fr;gap:18rpx}.mode-card{position:relative;overflow:hidden;border:1rpx solid rgba(49,92,80,.2);border-radius:12rpx 30rpx 12rpx 30rpx;background:linear-gradient(145deg,#fffaf0,#e4eadf);box-shadow:0 12rpx 28rpx rgba(37,54,45,.1)}.primary-mode{grid-row:span 2;background:linear-gradient(160deg,#294f44 0%,#3e6e5e 53%,#e7ddc7 53.5%,#f7efdb 100%)}.package-mode{background:linear-gradient(145deg,#f8ead0,#e7c995)}.consult-mode{background:linear-gradient(145deg,#e1ece5,#bcd3c6)}.activity-mode{background:linear-gradient(145deg,#f7e2ca,#e7bd98)}.appoint-mode{background:linear-gradient(145deg,#dce8de,#bcd0c2)}
.mode-copy{position:relative;z-index:2;padding:24rpx 22rpx}.mode-copy text,.mode-copy label{display:block}.mode-copy text{color:#20372d;font-family:STKaiti,KaiTi,serif;font-size:30rpx;font-weight:800;letter-spacing:1rpx}.mode-copy label{margin-top:8rpx;color:#64736b;font-size:20rpx}.mode-copy>view{display:inline-block;margin-top:20rpx;padding:9rpx 16rpx;border:1rpx solid rgba(255,255,255,.42);border-radius:18rpx;color:#f8f1df;background:rgba(24,46,38,.22);font-size:19rpx}.primary-mode .mode-copy text{color:#fffaf0;font-size:35rpx}.primary-mode .mode-copy label{color:rgba(255,250,240,.78)}
.mode-art{position:absolute;z-index:1;inset:0;width:100%;height:100%}
.home-announcement{height:78rpx;margin-top:22rpx;padding:0 20rpx;border:1rpx solid rgba(49,92,80,.16);border-radius:39rpx;display:flex;align-items:center;box-sizing:border-box;background:rgba(255,252,241,.9);box-shadow:0 8rpx 22rpx rgba(35,53,43,.05)}.announcement-badge{flex:none;padding:8rpx 14rpx;border-radius:20rpx;color:#fffaf0;background:#963d31;font-size:19rpx;font-weight:700}.home-announcement>text{min-width:0;flex:1;margin-left:15rpx;overflow:hidden;color:#40544a;font-size:21rpx;white-space:nowrap;text-overflow:ellipsis}.home-announcement>label{flex:none;margin-left:12rpx;color:#929a95;font-size:18rpx}.announcement-arrow{flex:none;margin-left:10rpx;color:#315c50;font-size:34rpx;line-height:1}
</style>
