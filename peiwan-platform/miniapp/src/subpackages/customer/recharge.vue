<template>
  <view class="recharge-page page">
    <view class="wallet-card">
      <view class="wallet-top"><text>可用余额</text><label>测试环境</label></view>
      <view class="balance"><text>¥</text>{{ money(account.totalBalance) }}</view>
      <view class="balance-split">
        <view><text>本金余额</text><label>¥{{ money(account.cashBalance) }}</label></view>
        <view><text>赠送余额</text><label>¥{{ money(account.bonusBalance) }}</label></view>
      </view>
    </view>

    <view class="section-title"><view>选择充值金额</view><text>到账后立即计入钱包</text></view>
    <view v-if="loading" class="empty">正在加载充值套餐...</view>
    <view v-else-if="!plans.length" class="empty">暂无可用充值套餐</view>
    <view v-else class="plan-grid">
      <view v-for="plan in plans" :key="Number(plan.id)" class="plan-card" :class="{ active: selectedId === Number(plan.id) }" @click="selectedId = Number(plan.id)">
        <view class="amount"><text>¥</text>{{ money(plan.rechargeAmount) }}</view>
        <text v-if="Number(plan.bonusAmount) > 0" class="bonus">赠 ¥{{ money(plan.bonusAmount) }}</text>
        <text v-else class="bonus muted">无赠送</text>
        <view v-if="selectedId === Number(plan.id)" class="selected-mark">✓</view>
      </view>
    </view>

    <view class="rule-card">
      <view>充值说明</view>
      <text>充值本金计入累计充值金额，用于匹配会员身份等级。</text>
      <text>赠送金额仅进入赠送余额，不计入累计充值。</text>
      <text>当前为开发测试环境，充值为模拟入账，不会产生真实扣款。</text>
    </view>

    <view class="footer-action">
      <view><text>到账</text><label>¥{{ arrivalAmount }}</label></view>
      <button :disabled="!selectedPlan || submitting" @click="submit">{{ submitting ? '充值处理中...' : '确认模拟充值' }}</button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { getCustomerRechargePlans, getCustomerWallet, rechargeCustomerWallet } from '@/api/customer'
import { requireLogin } from '@/utils/auth-guard'
import type { RecordData } from '@/types/api'

const wallet = ref<RecordData>({})
const plans = ref<RecordData[]>([])
const selectedId = ref(0)
const loading = ref(true)
const submitting = ref(false)
const account = computed<RecordData>(() => (wallet.value.account as RecordData | undefined) || {})
const selectedPlan = computed(() => plans.value.find(plan => Number(plan.id) === selectedId.value))
const arrivalAmount = computed(() => money(Number(selectedPlan.value?.rechargeAmount || 0) + Number(selectedPlan.value?.bonusAmount || 0)))
const money = (value: unknown) => Number(value || 0).toFixed(2)

onLoad(async () => {
  if (!requireLogin('登录后才能进行钱包充值')) return
  try {
    const [walletResult, planResult] = await Promise.all([getCustomerWallet(), getCustomerRechargePlans()])
    wallet.value = walletResult
    plans.value = planResult
    selectedId.value = Number(planResult[0]?.id || 0)
  } finally { loading.value = false }
})

async function submit() {
  const plan = selectedPlan.value
  if (!plan || submitting.value) return
  const result = await uni.showModal({
    title: '确认模拟充值',
    content: `充值本金 ¥${money(plan.rechargeAmount)}\n赠送金额 ¥${money(plan.bonusAmount)}\n预计到账 ¥${arrivalAmount.value}\n\n本操作仅用于开发测试，不会真实扣款。`,
    confirmText: '确认充值',
  })
  if (!result.confirm) return
  submitting.value = true
  const storageKey = `peiwan_recharge_request_${Number(plan.id)}`
  let requestNo = String(uni.getStorageSync(storageKey) || '')
  if (!requestNo) {
    requestNo = `RC${Number(plan.id)}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
    uni.setStorageSync(storageKey, requestNo)
  }
  uni.showLoading({ title: '充值处理中', mask: true })
  try {
    await rechargeCustomerWallet(Number(plan.id), requestNo)
    uni.removeStorageSync(storageKey)
    wallet.value = await getCustomerWallet()
    uni.showToast({ title: '充值成功', icon: 'success' })
  } finally {
    submitting.value = false
    uni.hideLoading()
  }
}
</script>

<style scoped lang="scss">
.recharge-page{min-height:100vh;padding-bottom:190rpx;background:radial-gradient(circle at 90% 3%,rgba(94,132,111,.18),transparent 34%),#eee9da}.wallet-card{position:relative;overflow:hidden;padding:34rpx 34rpx 30rpx;border:1rpx solid rgba(237,220,172,.32);border-radius:28rpx;color:#fff4d9;background:linear-gradient(135deg,#17382d,#315c50 68%,#507566);box-shadow:0 18rpx 38rpx rgba(28,55,44,.2)}.wallet-card::after{content:'';position:absolute;right:-68rpx;top:-82rpx;width:250rpx;height:250rpx;border:1rpx solid rgba(250,235,193,.15);border-radius:50%}.wallet-top{position:relative;z-index:1;display:flex;align-items:center;justify-content:space-between}.wallet-top>text{font-size:23rpx}.wallet-top label{padding:6rpx 14rpx;border:1rpx solid rgba(255,244,217,.28);border-radius:18rpx;color:rgba(255,244,217,.7);font-size:17rpx}.balance{position:relative;z-index:1;margin-top:18rpx;font-size:58rpx;font-weight:800;letter-spacing:1rpx}.balance>text{margin-right:8rpx;font-size:28rpx}.balance-split{position:relative;z-index:1;margin-top:30rpx;padding-top:22rpx;border-top:1rpx solid rgba(255,244,217,.15);display:grid;grid-template-columns:1fr 1fr}.balance-split>view{display:flex;flex-direction:column;gap:7rpx}.balance-split text{color:rgba(255,244,217,.58);font-size:18rpx}.balance-split label{font-size:24rpx}.section-title{margin:34rpx 5rpx 20rpx;display:flex;align-items:flex-end;justify-content:space-between}.section-title view{color:#1d3027;font-family:STKaiti,KaiTi,serif;font-size:34rpx;font-weight:800}.section-title text{color:#89938c;font-size:19rpx}.plan-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:18rpx}.plan-card{position:relative;overflow:hidden;min-height:145rpx;padding:24rpx;border:2rpx solid rgba(49,92,80,.13);border-radius:24rpx;box-sizing:border-box;background:rgba(255,252,241,.94);box-shadow:0 8rpx 20rpx rgba(35,55,45,.05)}.plan-card.active{border-color:#315c50;background:linear-gradient(135deg,#fffdf4,#e1e9dd);box-shadow:0 10rpx 24rpx rgba(49,92,80,.13)}.amount{color:#263b31;font-size:38rpx;font-weight:800}.amount text{margin-right:3rpx;font-size:22rpx}.bonus{display:block;margin-top:10rpx;color:#963d31;font-size:20rpx}.bonus.muted{color:#a0a69f}.selected-mark{position:absolute;right:-25rpx;top:-25rpx;width:72rpx;height:72rpx;padding:31rpx 0 0 13rpx;box-sizing:border-box;border-radius:50%;color:#fff;background:#315c50;font-size:20rpx}.rule-card{margin-top:28rpx;padding:25rpx 26rpx;border-left:6rpx solid #963d31;border-radius:20rpx;background:rgba(255,250,235,.75)}.rule-card view{margin-bottom:12rpx;color:#315c50;font-weight:800}.rule-card text{display:block;margin-top:8rpx;color:#77837c;font-size:20rpx;line-height:1.55}.empty{padding:80rpx 0;color:#8b938d;text-align:center}.footer-action{position:fixed;z-index:20;left:0;right:0;bottom:0;padding:20rpx 26rpx calc(20rpx + env(safe-area-inset-bottom));display:flex;align-items:center;gap:28rpx;border-top:1rpx solid rgba(49,92,80,.12);background:rgba(255,252,241,.96);box-shadow:0 -12rpx 32rpx rgba(38,54,45,.08)}.footer-action>view{flex:1}.footer-action>view text{display:block;color:#8b938d;font-size:18rpx}.footer-action>view label{display:block;margin-top:3rpx;color:#963d31;font-size:34rpx;font-weight:800}.footer-action button{width:360rpx;height:84rpx;margin:0;border-radius:22rpx;color:#fffaf0;background:#315c50;font-size:25rpx;font-weight:800}.footer-action button[disabled]{opacity:.5}
</style>
