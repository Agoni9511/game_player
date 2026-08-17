<template>
  <view class="ticket-page">
    <template v-if="detail">
      <view class="detail-head">
        <view class="back" @click="closeDetail">‹ 返回工单列表</view>
        <view class="ticket-title"><text>{{ detail.subject }}</text><label>{{ detail.ticketNo }}</label></view>
        <view class="status">{{ statusText(String(detail.status)) }}</view>
      </view>
      <scroll-view scroll-y class="messages">
        <view v-for="message in detail.messages" :key="String(message.id)" class="message" :class="{ own: message.senderRole !== 'ADMIN' }">
          <label>{{ message.senderRole === 'ADMIN' ? '平台客服' : '我' }} · {{ formatTime(message.createdAt) }}</label>
          <view>{{ message.content }}</view>
        </view>
      </scroll-view>
      <view v-if="detail.status !== 'CLOSED'" class="reply-bar">
        <textarea v-model="replyContent" maxlength="4000" auto-height placeholder="继续描述问题或回复客服" />
        <button :disabled="replying" @click="reply">发送</button>
      </view>
      <view v-else class="closed-tip">该工单已经关闭，如有新问题请重新发起咨询</view>
    </template>

    <template v-else>
      <view class="hero"><view class="hero-mark">客</view><view><text>平台客服</text><label>提交问题后，客服将在管理端持续跟进</label></view></view>
      <button class="create-entry" @click="creating = !creating">{{ creating ? '收起填写' : '+ 发起客服咨询' }}</button>
      <view v-if="creating" class="create-card">
        <view class="field"><text>问题类型</text><picker :range="categoryLabels" :value="categoryIndex" @change="changeCategory"><view>{{ categoryLabels[categoryIndex] }} ›</view></picker></view>
        <view v-if="form.orderId" class="field"><text>关联订单</text><view>#{{ form.orderId }}</view></view>
        <view class="field"><text>问题标题</text><input v-model="form.subject" maxlength="120" placeholder="简要说明遇到的问题" /></view>
        <view class="field content-field"><text>问题描述</text><textarea v-model="form.content" maxlength="4000" auto-height placeholder="请提供尽量完整的信息，订单问题可从订单页进入并自动关联" /></view>
        <button class="submit" :disabled="submitting" @click="submit">{{ submitting ? '提交中…' : '提交工单' }}</button>
      </view>

      <view class="section-title">我的客服工单</view>
      <view v-for="ticket in tickets" :key="String(ticket.id)" class="ticket-card" @click="open(ticket)">
        <view class="ticket-row"><text>{{ ticket.subject }}</text><label :class="String(ticket.status).toLowerCase()">{{ statusText(String(ticket.status)) }}</label></view>
        <view class="ticket-no">{{ ticket.ticketNo }}<text v-if="ticket.orderNo"> · {{ ticket.orderNo }}</text></view>
        <view class="ticket-foot"><text>{{ categoryText(String(ticket.category)) }} · {{ formatTime(ticket.lastMessageAt) }}</text><view v-if="ticket.customerUnreadCount">{{ ticket.customerUnreadCount }} 条新回复</view></view>
      </view>
      <view v-if="!loading && !tickets.length" class="empty">暂无客服工单，有问题可以随时发起咨询</view>
      <view v-if="loading" class="empty">工单加载中…</view>
    </template>
  </view>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import { createCustomerServiceTicket, getCustomerServiceTicket, getCustomerServiceTickets, replyCustomerServiceTicket } from '@/api/customer'
import type { RecordData } from '@/types/api'

const categories = [
  { label: '订单问题', value: 'ORDER' }, { label: '支付问题', value: 'PAYMENT' },
  { label: '服务问题', value: 'SERVICE' }, { label: '售后问题', value: 'AFTER_SALE' },
  { label: '账号问题', value: 'ACCOUNT' }, { label: '其他问题', value: 'OTHER' }
]
const categoryLabels = categories.map(item => item.label)
const categoryIndex = ref(0)
const tickets = ref<RecordData[]>([])
type TicketDetail = RecordData & { messages: RecordData[] }
const detail = ref<TicketDetail>()
const initialTicketId = ref(0)
const creating = ref(false)
const loading = ref(false)
const submitting = ref(false)
const replying = ref(false)
const replyContent = ref('')
const form = reactive<{ orderId?: number; category: string; subject: string; content: string }>({ category: 'ORDER', subject: '', content: '' })

onLoad(query => {
  const orderId = Number(query?.orderId || 0)
  initialTicketId.value = Number(query?.ticketId || 0)
  if (orderId) { form.orderId = orderId; form.subject = `订单 #${orderId} 咨询`; creating.value = true }
})
onShow(load)
async function load() { loading.value = true; try { tickets.value = (await getCustomerServiceTickets()).records || []; if (initialTicketId.value) { detail.value = await getCustomerServiceTicket(initialTicketId.value) as TicketDetail; initialTicketId.value = 0 } } finally { loading.value = false } }
function changeCategory(event: any) { categoryIndex.value = Number(event.detail.value); form.category = categories[categoryIndex.value].value }
async function submit() {
  if (!form.subject.trim()) return uni.showToast({ title: '请填写问题标题', icon: 'none' })
  if (!form.content.trim()) return uni.showToast({ title: '请填写问题描述', icon: 'none' })
  submitting.value = true
  try {
    const result = await createCustomerServiceTicket({ ...form, subject: form.subject.trim(), content: form.content.trim() })
    uni.showToast({ title: '工单已提交' })
    creating.value = false
    form.subject = ''; form.content = ''; form.orderId = undefined
    await load(); detail.value = await getCustomerServiceTicket(result.id) as TicketDetail
  } finally { submitting.value = false }
}
async function open(ticket: RecordData) { detail.value = await getCustomerServiceTicket(Number(ticket.id)) as TicketDetail; replyContent.value = ''; load() }
function closeDetail() { detail.value = undefined; replyContent.value = ''; load() }
async function reply() {
  if (!replyContent.value.trim()) return uni.showToast({ title: '请输入回复内容', icon: 'none' })
  replying.value = true
  try { await replyCustomerServiceTicket(Number(detail.value?.id), replyContent.value.trim()); replyContent.value = ''; detail.value = await getCustomerServiceTicket(Number(detail.value?.id)) as TicketDetail }
  finally { replying.value = false }
}
function categoryText(value: string) { return categories.find(item => item.value === value)?.label || value }
function statusText(value: string) { return ({ PENDING: '待客服处理', PROCESSING: '客服处理中', WAIT_CUSTOMER: '等待我的回复', RESOLVED: '已解决', CLOSED: '已关闭' } as Record<string,string>)[value] || value }
function formatTime(value: unknown) { return value ? String(value).replace('T', ' ').slice(0, 16) : '--' }
</script>

<style scoped lang="scss">
.ticket-page{min-height:100vh;padding:24rpx 24rpx 80rpx;box-sizing:border-box;background:#eee9da}.hero{padding:30rpx 26rpx;border-radius:10rpx 30rpx 10rpx 30rpx;display:flex;align-items:center;color:#fff7e7;background:linear-gradient(135deg,#234a3c,#507664)}.hero-mark{width:72rpx;height:72rpx;flex:none;margin-right:18rpx;border:3rpx double #eed69f;display:flex;align-items:center;justify-content:center;font-family:STKaiti,KaiTi,serif;font-size:34rpx}.hero text,.hero label{display:block}.hero text{font-family:STKaiti,KaiTi,serif;font-size:35rpx;font-weight:800}.hero label{margin-top:8rpx;color:rgba(255,247,231,.7);font-size:19rpx}.create-entry,.submit{height:78rpx;margin-top:20rpx;border:0;border-radius:8rpx 22rpx 8rpx 22rpx;color:#fff9ea;background:#315c50;font-size:23rpx;font-weight:800;line-height:78rpx}.create-card,.ticket-card,.detail-head{margin-top:20rpx;padding:25rpx;border:1rpx solid rgba(49,92,80,.13);border-radius:20rpx;background:#fffaf0}.field{padding:21rpx 0;border-bottom:1rpx solid rgba(49,92,80,.11);display:flex;align-items:center}.field>text{width:145rpx;flex:none;color:#45574f}.field input,.field picker,.field>view{min-width:0;flex:1}.content-field{align-items:flex-start}.field textarea{min-height:130rpx;flex:1;line-height:1.6}.section-title{margin:32rpx 4rpx 14rpx;color:#234137;font-family:STKaiti,KaiTi,serif;font-size:31rpx;font-weight:800}.ticket-card{margin-top:13rpx}.ticket-row{display:flex;align-items:center}.ticket-row>text{min-width:0;flex:1;overflow:hidden;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.ticket-row label{margin-left:14rpx;padding:5rpx 10rpx;color:#92642b;background:#f1e4c9;font-size:18rpx}.ticket-row label.resolved,.ticket-row label.closed{color:#6d7771;background:#e4e6e2}.ticket-no{margin-top:9rpx;color:#7f8882;font-size:19rpx}.ticket-foot{margin-top:18rpx;padding-top:14rpx;border-top:1rpx dashed #dbd4c8;display:flex;justify-content:space-between;color:#7c847f;font-size:18rpx}.ticket-foot view{color:#963d31;font-weight:800}.empty{padding:80rpx 20rpx;color:#87908a;text-align:center}.back{color:#315c50;font-size:21rpx}.ticket-title{margin-top:19rpx}.ticket-title text,.ticket-title label{display:block}.ticket-title text{font-size:31rpx;font-weight:800}.ticket-title label{margin-top:8rpx;color:#89908c;font-size:19rpx}.status{margin-top:15rpx;color:#986a2e}.messages{height:58vh;margin-top:18rpx;padding:20rpx;box-sizing:border-box;border-radius:18rpx;background:rgba(255,250,240,.65)}.message{margin-bottom:20rpx;display:flex;flex-direction:column;align-items:flex-start}.message.own{align-items:flex-end}.message label{margin-bottom:6rpx;color:#8a918d;font-size:17rpx}.message view{max-width:78%;padding:17rpx 20rpx;border-radius:6rpx 20rpx 20rpx;color:#31453d;background:#fff}.message.own view{color:#fff9ea;background:#315c50}.reply-bar{margin-top:16rpx;padding:18rpx;border-radius:18rpx;background:#fffaf0}.reply-bar textarea{min-height:90rpx;width:100%;line-height:1.5}.reply-bar button{height:66rpx;margin:12rpx 0 0 auto;padding:0 30rpx;border:0;border-radius:18rpx;color:#fff;background:#315c50;font-size:21rpx;line-height:66rpx}.closed-tip{padding:45rpx;color:#898e8a;text-align:center}
</style>
