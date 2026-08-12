<template>
  <view class="transactions-page page">
    <view class="summary-card">
      <view><text>资金明细</text><label>每一笔余额变化都有记录</label></view>
      <view class="seal">账</view>
    </view>

    <scroll-view class="filter-scroll" scroll-x :show-scrollbar="false">
      <view class="filters">
        <view v-for="item in filters" :key="item.value" :class="{ active: filter === item.value }" @click="selectFilter(item.value)">{{ item.label }}</view>
      </view>
    </scroll-view>

    <view v-if="!loading && !records.length" class="empty-state">
      <view>¥</view><text>暂无资金变动记录</text><label>充值、消费或退款后会显示在这里</label>
    </view>
    <view v-else class="transaction-list">
      <view v-for="item in records" :key="String(field(item, 'id'))" class="transaction-card">
        <view class="transaction-icon" :class="tone(item)">{{ iconText(item) }}</view>
        <view class="transaction-main">
          <view class="transaction-head"><text>{{ title(item) }}</text><label :class="tone(item)">{{ sign(item) }}¥{{ money(field(item, 'amount')) }}</label></view>
          <view class="transaction-meta"><text>{{ balanceTypeText(item) }}</text><text>余额 ¥{{ money(field(item, 'balanceAfter', 'balance_after')) }}</text></view>
          <view class="transaction-foot"><text>{{ formatTime(field(item, 'createdAt', 'created_at')) }}</text><label>{{ field(item, 'businessNo', 'business_no') }}</label></view>
        </view>
      </view>
    </view>
    <view v-if="loading" class="loading">正在加载...</view>
    <view v-else-if="records.length && !hasMore" class="finished">已经到底了</view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onLoad, onPullDownRefresh, onReachBottom } from '@dcloudio/uni-app'
import { getCustomerWalletTransactions } from '@/api/customer'
import { requireLogin } from '@/utils/auth-guard'
import type { RecordData } from '@/types/api'

const filters = [
  { label: '全部', value: '' },
  { label: '充值', value: 'RECHARGE' },
  { label: '消费', value: 'ORDER_PAYMENT' },
  { label: '退款', value: 'ORDER_REFUND' },
]
const filter = ref('')
const records = ref<RecordData[]>([])
const current = ref(1)
const total = ref(0)
const loading = ref(false)
const hasMore = ref(true)

onLoad(() => {
  if (requireLogin('登录后才能查看资金明细')) load(true)
})
onPullDownRefresh(async () => { await load(true); uni.stopPullDownRefresh() })
onReachBottom(() => { if (!loading.value && hasMore.value) load(false) })

async function selectFilter(value: string) {
  if (filter.value === value) return
  filter.value = value
  await load(true)
}
async function load(reset: boolean) {
  if (loading.value) return
  loading.value = true
  if (reset) { current.value = 1; records.value = []; hasMore.value = true }
  try {
    const result = await getCustomerWalletTransactions({ current: current.value, size: 20, businessType: filter.value })
    records.value = reset ? result.records || [] : [...records.value, ...(result.records || [])]
    total.value = Number(result.total || 0)
    hasMore.value = records.value.length < total.value
    if (hasMore.value) current.value += 1
  } finally { loading.value = false }
}
function field(item: RecordData, ...names: string[]) {
  for (const name of names) if (item[name] !== undefined && item[name] !== null) return item[name]
  return ''
}
function businessType(item: RecordData) { return String(field(item, 'businessType', 'business_type')) }
function direction(item: RecordData) { return String(field(item, 'direction')).toUpperCase() }
function tone(item: RecordData) { return direction(item) === 'IN' ? 'income' : 'expense' }
function sign(item: RecordData) { return direction(item) === 'IN' ? '+' : '-' }
function iconText(item: RecordData) { return ({ RECHARGE: '充', ORDER_PAYMENT: '支', ORDER_REFUND: '退' } as Record<string, string>)[businessType(item)] || '账' }
function title(item: RecordData) {
  const remark = String(field(item, 'remark'))
  if (remark) return remark
  return ({ RECHARGE: '钱包充值', ORDER_PAYMENT: '订单支付', ORDER_REFUND: '订单退款' } as Record<string, string>)[businessType(item)] || '余额变动'
}
function balanceTypeText(item: RecordData) { return String(field(item, 'balanceType', 'balance_type')) === 'BONUS' ? '赠送余额' : '本金余额' }
function money(value: unknown) { return Number(value || 0).toFixed(2) }
function formatTime(value: unknown) {
  const text = String(value || '').replace('T', ' ')
  return text.length >= 19 ? text.slice(0, 19) : text || '--'
}
</script>

<style scoped lang="scss">
.transactions-page{min-height:100vh;padding-bottom:70rpx;background:radial-gradient(circle at 88% 1%,rgba(89,127,106,.16),transparent 30%),#eee9da}.summary-card{position:relative;overflow:hidden;min-height:130rpx;padding:30rpx 32rpx;border-radius:14rpx 36rpx 14rpx 36rpx;box-sizing:border-box;display:flex;align-items:center;justify-content:space-between;color:#fff3d8;background:linear-gradient(125deg,#1b3c31,#416858);box-shadow:0 15rpx 34rpx rgba(33,57,47,.17)}.summary-card>view:first-child text{display:block;font-family:STKaiti,KaiTi,serif;font-size:37rpx;font-weight:800;letter-spacing:3rpx}.summary-card>view:first-child label{display:block;margin-top:10rpx;color:rgba(255,243,216,.6);font-size:19rpx}.seal{width:62rpx;height:62rpx;border:2rpx solid rgba(244,205,159,.72);color:#eec9a2;line-height:62rpx;text-align:center;font-family:STKaiti,KaiTi,serif;font-size:29rpx;transform:rotate(7deg)}.filter-scroll{margin:25rpx 0 20rpx;white-space:nowrap}.filters{display:inline-flex;gap:14rpx;padding:0 2rpx}.filters>view{padding:13rpx 28rpx;border:1rpx solid rgba(49,92,80,.15);border-radius:28rpx;color:#68766e;background:rgba(255,252,241,.74);font-size:22rpx}.filters>view.active{border-color:#315c50;color:#fffaf0;background:#315c50}.transaction-list{display:flex;flex-direction:column;gap:14rpx}.transaction-card{padding:25rpx 24rpx;border:1rpx solid rgba(54,79,68,.14);border-radius:12rpx 28rpx 12rpx 28rpx;display:flex;gap:20rpx;background:rgba(255,252,241,.93);box-shadow:0 8rpx 22rpx rgba(38,54,45,.055)}.transaction-icon{width:68rpx;height:68rpx;flex:none;border-radius:22rpx;line-height:68rpx;text-align:center;font-family:STKaiti,KaiTi,serif;font-size:27rpx;font-weight:800}.transaction-icon.income{color:#315c50;background:#dce8dd}.transaction-icon.expense{color:#963d31;background:#eee0d7}.transaction-main{min-width:0;flex:1}.transaction-head{display:flex;align-items:center;justify-content:space-between;gap:16rpx}.transaction-head>text{overflow:hidden;color:#26372f;font-size:25rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.transaction-head label{flex:none;font-size:27rpx;font-weight:800}.transaction-head label.income{color:#315c50}.transaction-head label.expense{color:#963d31}.transaction-meta,.transaction-foot{display:flex;align-items:center;justify-content:space-between}.transaction-meta{margin-top:11rpx;color:#77837c;font-size:19rpx}.transaction-foot{margin-top:13rpx;padding-top:12rpx;border-top:1rpx solid rgba(49,92,80,.09);color:#a0a69f;font-size:17rpx}.transaction-foot label{max-width:280rpx;overflow:hidden;white-space:nowrap;text-overflow:ellipsis}.empty-state{padding:150rpx 0;text-align:center}.empty-state view{width:90rpx;height:90rpx;margin:0 auto;border:2rpx solid rgba(49,92,80,.18);border-radius:50%;color:#557869;line-height:90rpx;font-size:40rpx}.empty-state text,.empty-state label{display:block}.empty-state text{margin-top:24rpx;color:#475a50;font-size:26rpx;font-weight:700}.empty-state label{margin-top:10rpx;color:#9aa29c;font-size:20rpx}.loading,.finished{padding:28rpx 0;color:#929b95;text-align:center;font-size:20rpx}
</style>
