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

      <view v-if="detail.playerName || members.length" class="card">
        <view class="section-title">服务陪玩师（{{ members.length || detail.memberCount || 1 }}/{{ detail.requiredPlayerCount || 1 }}）</view>
        <InfoRow v-for="member in members" :key="String(member.id)" :label="text(member.playerName || member.player_name)" value="已加入服务" />
        <InfoRow v-if="!members.length" label="陪玩师" :value="text(detail.playerName)" />
        <InfoRow v-if="detail.customerConfirmDeadline" label="确认截止" :value="formatTime(detail.customerConfirmDeadline)" />
      </view>

      <view class="card">
        <view class="section-title">订单信息</view>
        <InfoRow label="订单编号" :value="text(detail.orderNo)" copyable />
        <InfoRow label="创建时间" :value="formatTime(detail.createTime)" />
      </view>

      <view v-if="detail.orderStatus === 'PENDING_PAYMENT'" class="card payment-card">
        <view class="section-head"><view class="section-title">选择支付方式</view><text>开发测试</text></view>
        <view class="payment-methods">
          <view :class="{ active: paymentMethod === 'BALANCE' }" @click="paymentMethod = 'BALANCE'">
            <view class="method-icon balance">余</view><view><strong>钱包支付</strong><text>余额与赠送金组合支付</text></view><label>{{ paymentMethod === 'BALANCE' ? '✓' : '' }}</label>
          </view>
          <view :class="{ active: paymentMethod === 'MOCK_WECHAT' }" @click="paymentMethod = 'MOCK_WECHAT'">
            <view class="method-icon wechat">微</view><view><strong>模拟微信支付</strong><text>开发测试，不产生真实扣款</text></view><label>{{ paymentMethod === 'MOCK_WECHAT' ? '✓' : '' }}</label>
          </view>
        </view>
        <template v-if="paymentMethod === 'BALANCE'">
          <view class="wallet-line"><text>钱包可用余额</text><strong>¥{{ money(walletBalance) }}</strong></view>
          <view class="payment-split"><view><text>现金余额支付</text><label>¥{{ money(cashPayment) }}</label></view><view><text>赠送金抵扣</text><label>-¥{{ money(bonusDeduction) }}</label></view></view>
          <view v-if="!walletEnough" class="balance-warning">余额不足，还差 ¥{{ money(balanceShortfall) }}</view>
        </template>
        <view v-else class="mock-notice"><text>测试</text><view><strong>模拟微信支付环境</strong><label>确认后直接模拟支付成功，仅用于流程验收，不会调用微信或产生真实交易。</label></view></view>
      </view>

      <view v-else-if="payment.id || payment.paymentNo" class="card payment-card paid-card">
        <view class="section-head"><view class="section-title">支付信息</view><text>{{ paymentStatusText }}</text></view>
        <InfoRow label="支付方式" :value="paymentChannelText" />
        <InfoRow label="支付单号" :value="text(payment.paymentNo)" copyable />
        <InfoRow v-if="payment.paymentChannel !== 'MOCK_WECHAT'" label="现金支付" :value="`¥${money(payment.cashAmount)}`" />
        <InfoRow v-if="payment.paymentChannel !== 'MOCK_WECHAT'" label="赠送金抵扣" :value="`¥${money(payment.bonusAmount)}`" />
      </view>

      <view class="safe-tip">平台担保交易 · 请勿私下转账</view>
      <view class="action-space" />
      <view v-if="showActions" class="action-bar">
        <button v-if="canCancel" class="secondary" @click="cancelOrder">取消订单</button>
        <button v-if="canAfterSale" class="secondary" @click="afterSale">申请售后</button>
        <button v-if="detail.orderStatus === 'WAIT_CUSTOMER_CONFIRM'" class="primary action-primary" @click="confirm">确认服务完成</button>
        <button v-if="detail.orderStatus === 'PENDING_PAYMENT'" class="primary action-primary" :disabled="paying" @click="pay">{{ paying ? '支付处理中...' : `${paymentMethod === 'MOCK_WECHAT' ? '模拟支付' : '钱包支付'} ¥${money(detail.payableAmount)}` }}</button>
      </view>
    </template>

    <view v-else class="card empty">订单不存在或暂时无法查看</view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import InfoRow from '@/components/InfoRow.vue'
import { cancelCustomerOrder, confirmOrder, getCustomerOrder, getCustomerOrderPayment, getCustomerWallet, mockWechatPayCustomerOrder, payCustomerOrder } from '@/api/customer'
import { requireLogin } from '@/utils/auth-guard'
import type { RecordData } from '@/types/api'

const id = ref(0)
const detail = ref<RecordData>({})
const wallet = ref<RecordData>({})
const payment = ref<RecordData>({})
const loading = ref(true)
const paying = ref(false)
const paymentMethod = ref<'BALANCE' | 'MOCK_WECHAT'>('BALANCE')
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
const members = computed<RecordData[]>(() => (detail.value.members as RecordData[] | undefined) || [])
const statusInfo = computed(() => statusMap[String(detail.value.orderStatus)] || { label: '订单进行中', desc: '服务状态正在更新' })
const canCancel = computed(() => ['PENDING_PAYMENT', 'WAIT_ASSIGN'].includes(String(detail.value.orderStatus)))
const canAfterSale = computed(() => ['PENDING_CONFIRM', 'WAIT_CUSTOMER_CONFIRM'].includes(String(detail.value.orderStatus)))
const showActions = computed(() => canCancel.value || canAfterSale.value || ['PENDING_PAYMENT', 'WAIT_CUSTOMER_CONFIRM'].includes(String(detail.value.orderStatus)))
const walletAccount = computed<RecordData>(() => (wallet.value.account as RecordData | undefined) || {})
const walletBalance = computed(() => Number(walletAccount.value.totalBalance || 0))
const payableAmount = computed(() => Number(detail.value.payableAmount || 0))
const cashPayment = computed(() => Math.min(Number(walletAccount.value.cashBalance || 0), payableAmount.value))
const bonusDeduction = computed(() => Math.max(0, payableAmount.value - cashPayment.value))
const walletEnough = computed(() => walletBalance.value >= payableAmount.value)
const balanceShortfall = computed(() => Math.max(0, payableAmount.value - walletBalance.value))
const paymentStatusText = computed(() => ({ PAID:'支付成功',REFUNDED:'已退款' } as Record<string,string>)[String(payment.value.status)] || '已支付')
const paymentChannelText = computed(() => String(payment.value.paymentChannel) === 'MOCK_WECHAT' ? '模拟微信支付' : '钱包支付')

onLoad((query) => { id.value = Number(query?.id || 0) })
onShow(() => { if (requireLogin('登录后才能查看订单详情') && id.value) load() })

async function load() {
  loading.value = true
  try {
    detail.value = await getCustomerOrder(id.value)
    const [walletResult, paymentResult] = await Promise.all([
      getCustomerWallet().catch(() => ({})),
      getCustomerOrderPayment(id.value).catch(() => ({})),
    ])
    wallet.value = walletResult
    payment.value = paymentResult
  } finally { loading.value = false }
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
async function pay() {
  if (paying.value || String(detail.value.orderStatus) !== 'PENDING_PAYMENT') return
  if (paymentMethod.value === 'BALANCE') wallet.value = await getCustomerWallet()
  if (paymentMethod.value === 'BALANCE' && !walletEnough.value) {
    const result = await uni.showModal({ title: '钱包余额不足', content: `当前余额 ¥${money(walletBalance.value)}，还需 ¥${money(balanceShortfall.value)}。可先充值钱包后继续支付。`, cancelText: '暂不充值', confirmText: '去充值' })
    if (result.confirm) uni.navigateTo({ url: '/subpackages/customer/recharge' })
    return
  }
  const mockWechat = paymentMethod.value === 'MOCK_WECHAT'
  const result = await uni.showModal({
    title: mockWechat ? '确认模拟微信支付' : '确认钱包支付',
    content: mockWechat ? `本次将模拟支付 ¥${money(payableAmount.value)}\n仅用于开发测试，不会产生真实扣款。` : `订单金额 ¥${money(payableAmount.value)}\n现金余额支付 ¥${money(cashPayment.value)}\n赠送金抵扣 ¥${money(bonusDeduction.value)}`,
    confirmText: '确认支付',
  })
  if (!result.confirm) return
  paying.value = true
  const storageKey = `peiwan_order_pay_request_${paymentMethod.value}_${id.value}`
  let requestNo = String(uni.getStorageSync(storageKey) || '')
  if (!requestNo) {
    requestNo = `${mockWechat ? 'MWX' : 'BAL'}${id.value}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
    uni.setStorageSync(storageKey, requestNo)
  }
  uni.showLoading({ title: '支付处理中', mask: true })
  try {
    if (mockWechat) await mockWechatPayCustomerOrder(id.value, requestNo)
    else await payCustomerOrder(id.value, requestNo)
    uni.removeStorageSync(storageKey)
    await load()
  } finally {
    paying.value = false
    uni.hideLoading()
  }
  uni.showToast({ title: '支付成功', icon: 'success' })
}
function afterSale() { uni.navigateTo({ url: `/subpackages/customer/after-sale?id=${id.value}` }) }
function text(value: unknown) { return value === null || value === undefined || value === '' ? '-' : String(value) }
function money(value: unknown) { const n = Number(value || 0); return Number.isFinite(n) ? n.toFixed(2) : '0.00' }
function formatTime(value: unknown) { return value ? String(value).replace('T', ' ').slice(0, 19) : '-' }
</script>

<style scoped>
.order-page{padding-bottom:calc(180rpx + env(safe-area-inset-bottom))}.loading,.empty{text-align:center;color:#68766e;padding:90rpx 20rpx}.status-card{display:flex;align-items:center;gap:24rpx;margin:6rpx 0 30rpx;padding:30rpx;background:linear-gradient(135deg,#244d43,#426d60);color:#fffaf0;border-radius:12rpx 34rpx 12rpx 34rpx;box-shadow:0 14rpx 30rpx rgba(36,77,67,.18)}.seal{display:flex;align-items:center;justify-content:center;width:78rpx;height:78rpx;border:4rpx double rgba(255,248,225,.78);font-family:STKaiti,KaiTi,serif;font-size:38rpx;border-radius:8rpx;transform:rotate(-4deg)}.status-title{font-family:STKaiti,KaiTi,serif;font-size:40rpx;font-weight:800;letter-spacing:3rpx}.status-desc{margin-top:8rpx;color:rgba(255,250,240,.75);font-size:24rpx}.section-title{margin-bottom:22rpx;font-family:STKaiti,KaiTi,serif;font-size:34rpx;font-weight:800}.product-name{font-size:32rpx;font-weight:700}.spec-line,.amount-line{display:flex;justify-content:space-between;margin-top:18rpx;color:#68766e}.amount-line{align-items:flex-end;padding-top:22rpx;border-top:1rpx solid rgba(54,79,68,.12)}.amount{color:#9a432f;font-size:40rpx;font-weight:800}.safe-tip{text-align:center;color:#8a928d;font-size:24rpx}.action-space{height:30rpx}.action-bar{position:fixed;z-index:20;left:0;right:0;bottom:0;display:flex;gap:18rpx;padding:18rpx 28rpx calc(18rpx + env(safe-area-inset-bottom));background:rgba(255,253,244,.96);box-shadow:0 -8rpx 24rpx rgba(31,48,39,.08)}.action-bar button{flex:1;margin:0;font-size:28rpx}.secondary{color:#315c50;background:#f8f5e9;border:1rpx solid rgba(49,92,80,.3);border-radius:8rpx 18rpx 8rpx 18rpx}.action-primary{flex:1.5!important}
.payment-card{border-color:rgba(49,92,80,.24);background:linear-gradient(135deg,#fffdf4,#e8eee4)}.section-head{display:flex;align-items:flex-start;justify-content:space-between}.section-head>text{padding:6rpx 12rpx;border-radius:15rpx;color:#315c50;background:#dbe7df;font-size:18rpx}.wallet-line{display:flex;align-items:baseline;justify-content:space-between}.wallet-line text{color:#64736b}.wallet-line strong{color:#315c50;font-size:34rpx}.payment-split{margin-top:20rpx;padding-top:18rpx;border-top:1rpx solid rgba(49,92,80,.13)}.payment-split>view{display:flex;justify-content:space-between;margin-top:12rpx;color:#7a857e;font-size:22rpx}.payment-split label{color:#44594e}.balance-warning{margin-top:20rpx;padding:14rpx;border-radius:12rpx;color:#963d31;background:#f5e1d9;font-size:21rpx;text-align:center}.paid-card{background:linear-gradient(135deg,#fffdf4,#e1ebe3)}button[disabled]{opacity:.65}
.payment-methods{margin-bottom:24rpx}.payment-methods>view{min-height:92rpx;margin-top:14rpx;padding:15rpx 17rpx;border:2rpx solid rgba(49,92,80,.13);border-radius:9rpx 22rpx 9rpx 22rpx;display:flex;align-items:center;background:rgba(255,253,246,.75)}.payment-methods>view.active{border-color:#315c50;background:#e0e9df;box-shadow:inset 5rpx 0 #315c50}.method-icon{width:58rpx;height:58rpx;flex:none;margin-right:15rpx;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;font-family:STKaiti,KaiTi,serif;font-weight:800}.method-icon.balance{background:#315c50}.method-icon.wechat{background:#16a66a}.payment-methods>view>view:nth-child(2){min-width:0;flex:1}.payment-methods strong,.payment-methods text{display:block}.payment-methods text{margin-top:5rpx;color:#7a857e;font-size:18rpx}.payment-methods>view>label{width:40rpx;height:40rpx;border:2rpx solid #b9c3bc;border-radius:50%;color:#fff;background:#fff;line-height:37rpx;text-align:center}.payment-methods>view.active>label{border-color:#315c50;background:#315c50}.mock-notice{padding:18rpx;border:1rpx solid rgba(22,166,106,.22);border-radius:12rpx 22rpx 12rpx 22rpx;display:flex;align-items:flex-start;background:#e5f2e9}.mock-notice>text{flex:none;margin-right:14rpx;padding:5rpx 9rpx;border-radius:12rpx;color:#fff;background:#16a66a;font-size:17rpx}.mock-notice strong,.mock-notice label{display:block}.mock-notice label{margin-top:7rpx;color:#68786f;font-size:19rpx;line-height:1.55}
</style>
