<template>
  <view class="page order-page">
    <view v-if="loading" class="loading">正在加载订单…</view>

    <template v-else-if="detail.id">
      <view class="status-card">
        <view class="seal">凌</view>
        <view>
          <view class="status-title">{{ statusInfo.label }}</view>
          <view class="status-desc">{{ statusInfo.desc }}</view>
        </view>
      </view>

      <view class="card">
        <view class="section-title">服务内容</view>
        <view class="product-name">{{ firstItem.productName || detail.productName || '陪玩服务' }}</view>
        <view class="spec-line">
          <text>{{ firstItem.skuName || detail.skuName || '默认规格' }}</text>
          <text>×{{ firstItem.quantity || 1 }}</text>
        </view>
        <view class="amount-line">
          <text>订单金额</text>
          <text class="amount">¥{{ money(detail.payableAmount) }}</text>
        </view>
      </view>

      <view class="card">
        <view class="section-title">游戏资料</view>
        <InfoRow label="游戏" :value="text(game.game_name)" />
        <InfoRow label="游戏账号" :value="text(game.game_account)" />
        <InfoRow label="游戏昵称" :value="text(game.game_nickname)" />
        <InfoRow v-if="game.server_name" label="服务器" :value="text(game.server_name)" />
        <InfoRow v-if="game.rank_name" label="段位" :value="text(game.rank_name)" />
        <InfoRow v-if="game.extra_requirement" label="服务需求" :value="text(game.extra_requirement)" multiline />
      </view>

      <view v-if="detail.playerName" class="card">
        <view class="section-title">服务陪玩师</view>
        <InfoRow label="陪玩师" :value="text(detail.playerName)" />
        <InfoRow v-if="detail.customerConfirmDeadline" label="确认截止" :value="formatTime(detail.customerConfirmDeadline)" />
      </view>

      <view class="card">
        <view class="section-title">订单信息</view>
        <InfoRow label="订单编号" :value="text(detail.orderNo)" copyable />
        <InfoRow label="创建时间" :value="formatTime(detail.createTime)" />
      </view>

      <view class="safe-tip">平台担保交易 · 请勿私下转账</view>
      <view class="action-space" />
      <view v-if="showActions" class="action-bar">
        <button v-if="canCancel" class="secondary" @click="cancelOrder">取消订单</button>
        <button v-if="canAfterSale" class="secondary" @click="afterSale">申请售后</button>
        <button v-if="detail.orderStatus === 'WAIT_CUSTOMER_CONFIRM'" class="primary action-primary" @click="confirm">确认服务完成</button>
        <button v-if="detail.orderStatus === 'PENDING_PAYMENT'" class="primary action-primary" @click="pay">去支付</button>
      </view>
    </template>

    <view v-else class="card empty">订单不存在或暂时无法查看</view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import InfoRow from '@/components/InfoRow.vue'
import { cancelCustomerOrder, confirmOrder, getCustomerOrder } from '@/api/customer'
import type { RecordData } from '@/types/api'

const id = ref(0)
const detail = ref<RecordData>({})
const loading = ref(true)
const statusMap: Record<string, { label: string; desc: string }> = {
  PENDING_PAYMENT: { label: '等待支付', desc: '订单已创建，支付后将进入派单流程' },
  WAIT_ASSIGN: { label: '等待接单', desc: '平台正在为你匹配合适的陪玩师' },
  ASSIGNED: { label: '已派单', desc: '陪玩师已接单，请留意服务开始时间' },
  IN_SERVICE: { label: '服务中', desc: '陪玩师正在为你服务' },
  PENDING_CONFIRM: { label: '待审核', desc: '陪玩师已提交完成，平台正在审核' },
  WAIT_CUSTOMER_CONFIRM: { label: '待你确认', desc: '服务已通过审核，请确认服务结果' },
  COMPLETED: { label: '已完成', desc: '本次服务已圆满完成' },
  CANCELLED: { label: '已取消', desc: '订单已取消' },
  AFTER_SALE: { label: '售后中', desc: '客服正在处理你的售后申请' }
}
const firstItem = computed<RecordData>(() => (detail.value.items as RecordData[] | undefined)?.[0] || {})
const game = computed<RecordData>(() => (detail.value.gameProfile as RecordData | undefined) || {})
const statusInfo = computed(() => statusMap[String(detail.value.orderStatus)] || { label: '订单进行中', desc: '服务状态正在更新' })
const canCancel = computed(() => ['PENDING_PAYMENT', 'WAIT_ASSIGN'].includes(String(detail.value.orderStatus)))
const canAfterSale = computed(() => ['PENDING_CONFIRM', 'WAIT_CUSTOMER_CONFIRM'].includes(String(detail.value.orderStatus)))
const showActions = computed(() => canCancel.value || canAfterSale.value || ['PENDING_PAYMENT', 'WAIT_CUSTOMER_CONFIRM'].includes(String(detail.value.orderStatus)))

onLoad((query) => { id.value = Number(query?.id || 0) })
onShow(() => { if (id.value) load() })

async function load() {
  loading.value = true
  try { detail.value = await getCustomerOrder(id.value) } finally { loading.value = false }
}
async function confirm() {
  const result = await uni.showModal({ title: '确认完成', content: '确认陪玩服务已完成且没有问题吗？' })
  if (!result.confirm) return
  await confirmOrder(id.value)
  uni.showToast({ title: '已确认' })
  await load()
}
async function cancelOrder() {
  const result = await uni.showModal({ title: '取消订单', content: '确定取消这笔订单吗？' })
  if (!result.confirm) return
  await cancelCustomerOrder(id.value)
  uni.showToast({ title: '订单已取消' })
  await load()
}
function pay() { uni.showToast({ title: '余额支付将在下一步接入', icon: 'none' }) }
function afterSale() { uni.navigateTo({ url: `/subpackages/customer/after-sale?id=${id.value}` }) }
function text(value: unknown) { return value === null || value === undefined || value === '' ? '-' : String(value) }
function money(value: unknown) { const n = Number(value || 0); return Number.isFinite(n) ? n.toFixed(2) : '0.00' }
function formatTime(value: unknown) { return value ? String(value).replace('T', ' ').slice(0, 19) : '-' }
</script>

<style scoped>
.order-page{padding-bottom:calc(180rpx + env(safe-area-inset-bottom))}.loading,.empty{text-align:center;color:#68766e;padding:90rpx 20rpx}.status-card{display:flex;align-items:center;gap:24rpx;margin:6rpx 0 30rpx;padding:30rpx;background:linear-gradient(135deg,#244d43,#426d60);color:#fffaf0;border-radius:12rpx 34rpx 12rpx 34rpx;box-shadow:0 14rpx 30rpx rgba(36,77,67,.18)}.seal{display:flex;align-items:center;justify-content:center;width:78rpx;height:78rpx;border:4rpx double rgba(255,248,225,.78);font-family:STKaiti,KaiTi,serif;font-size:38rpx;border-radius:8rpx;transform:rotate(-4deg)}.status-title{font-family:STKaiti,KaiTi,serif;font-size:40rpx;font-weight:800;letter-spacing:3rpx}.status-desc{margin-top:8rpx;color:rgba(255,250,240,.75);font-size:24rpx}.section-title{margin-bottom:22rpx;font-family:STKaiti,KaiTi,serif;font-size:34rpx;font-weight:800}.product-name{font-size:32rpx;font-weight:700}.spec-line,.amount-line{display:flex;justify-content:space-between;margin-top:18rpx;color:#68766e}.amount-line{align-items:flex-end;padding-top:22rpx;border-top:1rpx solid rgba(54,79,68,.12)}.amount{color:#9a432f;font-size:40rpx;font-weight:800}.safe-tip{text-align:center;color:#8a928d;font-size:24rpx}.action-space{height:30rpx}.action-bar{position:fixed;z-index:20;left:0;right:0;bottom:0;display:flex;gap:18rpx;padding:18rpx 28rpx calc(18rpx + env(safe-area-inset-bottom));background:rgba(255,253,244,.96);box-shadow:0 -8rpx 24rpx rgba(31,48,39,.08)}.action-bar button{flex:1;margin:0;font-size:28rpx}.secondary{color:#315c50;background:#f8f5e9;border:1rpx solid rgba(49,92,80,.3);border-radius:8rpx 18rpx 8rpx 18rpx}.action-primary{flex:1.5!important}
</style>
