<template>
  <div class="art-full-height">
    <ElCard class="mb-3" shadow="never">
      <ElForm inline>
        <ElFormItem label="关键词">
          <ElInput
            v-model="query.keyword"
            clearable
            placeholder="工单编号或标题"
            @keyup.enter="search"
          />
        </ElFormItem>
        <ElFormItem label="问题类型">
          <ElSelect v-model="query.category" clearable class="!w-36">
            <ElOption
              v-for="item in categories"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="状态">
          <ElSelect v-model="query.status" clearable class="!w-36">
            <ElOption
              v-for="item in statuses"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </ElSelect>
        </ElFormItem>
        <ElFormItem>
          <ElButton type="primary" @click="search">查询</ElButton>
          <ElButton @click="reset">重置</ElButton>
        </ElFormItem>
      </ElForm>
    </ElCard>

    <ElCard shadow="never">
      <ElTable v-loading="loading" :data="rows" row-key="id">
        <ElTableColumn prop="ticketNo" label="工单编号" min-width="205" />
        <ElTableColumn prop="userName" label="用户" min-width="120" />
        <ElTableColumn prop="orderNo" label="关联订单" min-width="190">
          <template #default="{ row }">{{ row.orderNo || '-' }}</template>
        </ElTableColumn>
        <ElTableColumn label="类型" width="110">
          <template #default="{ row }">{{ categoryText(row.category) }}</template>
        </ElTableColumn>
        <ElTableColumn prop="subject" label="问题标题" min-width="220" show-overflow-tooltip />
        <ElTableColumn label="状态" width="120">
          <template #default="{ row }"
            ><ElTag :type="statusTone(row.status)">{{ statusText(row.status) }}</ElTag></template
          >
        </ElTableColumn>
        <ElTableColumn label="待处理" width="90" align="center">
          <template #default="{ row }">
            <ElBadge v-if="row.adminUnreadCount" :value="row.adminUnreadCount" />
            <span v-else>-</span>
          </template>
        </ElTableColumn>
        <ElTableColumn label="最近消息" width="180"><template #default="{ row }">{{ formatDateTime(row.lastMessageAt) }}</template></ElTableColumn>
        <ElTableColumn label="操作" width="90" fixed="right">
          <template #default="{ row }"
            ><ElButton link type="primary" @click="open(row)">处理</ElButton></template
          >
        </ElTableColumn>
      </ElTable>
      <div class="mt-4 flex justify-end">
        <ElPagination
          v-model:current-page="query.current"
          v-model:page-size="query.size"
          :total="total"
          layout="total, sizes, prev, pager, next"
          @change="load"
        />
      </div>
    </ElCard>

    <ElDrawer v-model="visible" title="客服工单" size="760px" destroy-on-close>
      <template v-if="detail">
        <ElDescriptions :column="2" border>
          <ElDescriptionsItem label="工单编号">{{ detail.ticketNo }}</ElDescriptionsItem>
          <ElDescriptionsItem label="状态"
            ><ElTag :type="statusTone(detail.status)">{{
              statusText(detail.status)
            }}</ElTag></ElDescriptionsItem
          >
          <ElDescriptionsItem label="用户">{{ detail.userName }}</ElDescriptionsItem>
          <ElDescriptionsItem label="关联订单">{{ detail.orderNo || '-' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="问题类型">{{
            categoryText(detail.category)
          }}</ElDescriptionsItem>
          <ElDescriptionsItem label="负责客服">{{
            detail.assignedAdminName || '待领取'
          }}</ElDescriptionsItem>
          <ElDescriptionsItem label="问题标题" :span="2">{{ detail.subject }}</ElDescriptionsItem>
        </ElDescriptions>

        <div class="message-list">
          <div
            v-for="message in detail.messages"
            :key="message.id"
            class="message-row"
            :class="{ admin: message.senderRole === 'ADMIN' }"
          >
            <div class="message-meta"
              >{{ message.senderRole === 'ADMIN' ? '平台客服' : message.senderName }} ·
              {{ formatDateTime(message.createdAt) }}</div
            >
            <div class="message-bubble">{{ message.content }}</div>
          </div>
        </div>

        <div v-if="detail.status !== 'CLOSED'" class="reply-box">
          <ElInput
            v-model="replyContent"
            type="textarea"
            :rows="4"
            maxlength="4000"
            show-word-limit
            placeholder="输入客服回复"
          />
          <div class="reply-actions">
            <ElSelect v-model="nextStatus" class="!w-36">
              <ElOption
                v-for="item in statusActions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </ElSelect>
            <ElButton @click="changeStatus">更新状态</ElButton>
            <ElButton type="primary" :loading="replying" @click="reply">发送回复</ElButton>
          </div>
        </div>
      </template>
    </ElDrawer>
  </div>
</template>

<script setup lang="ts">
  import { formatDateTime } from '@/utils/date'
  import {
    fetchCustomerServiceTicket,
    fetchCustomerServiceTickets,
    replyCustomerServiceTicket,
    updateCustomerServiceTicketStatus
  } from '@/api/business-manage'

  const categories = [
    { label: '订单问题', value: 'ORDER' },
    { label: '支付问题', value: 'PAYMENT' },
    { label: '服务问题', value: 'SERVICE' },
    { label: '售后问题', value: 'AFTER_SALE' },
    { label: '账号问题', value: 'ACCOUNT' },
    { label: '其他问题', value: 'OTHER' }
  ]
  const statuses = [
    { label: '待处理', value: 'PENDING' },
    { label: '处理中', value: 'PROCESSING' },
    { label: '等待用户', value: 'WAIT_CUSTOMER' },
    { label: '已解决', value: 'RESOLVED' },
    { label: '已关闭', value: 'CLOSED' }
  ]
  const statusActions = statuses.filter((item) => item.value !== 'PENDING')
  const loading = ref(false)
  const replying = ref(false)
  const visible = ref(false)
  const rows = ref<any[]>([])
  const total = ref(0)
  const detail = ref<any>()
  const replyContent = ref('')
  const nextStatus = ref('PROCESSING')
  const query = reactive({ current: 1, size: 20, keyword: '', category: '', status: '' })

  async function load() {
    loading.value = true
    try {
      const data = await fetchCustomerServiceTickets(query)
      rows.value = data.records
      total.value = data.total
    } finally {
      loading.value = false
    }
  }
  function search() {
    query.current = 1
    load()
  }
  function reset() {
    Object.assign(query, { current: 1, keyword: '', category: '', status: '' })
    load()
  }
  async function open(row: any) {
    detail.value = await fetchCustomerServiceTicket(row.id)
    replyContent.value = ''
    nextStatus.value = detail.value.status === 'PENDING' ? 'PROCESSING' : detail.value.status
    visible.value = true
    load()
  }
  async function reply() {
    if (!replyContent.value.trim()) return ElMessage.warning('请输入回复内容')
    replying.value = true
    try {
      await replyCustomerServiceTicket(detail.value.id, replyContent.value.trim())
      ElMessage.success('回复已发送')
      replyContent.value = ''
      detail.value = await fetchCustomerServiceTicket(detail.value.id)
      load()
    } finally {
      replying.value = false
    }
  }
  async function changeStatus() {
    await updateCustomerServiceTicketStatus(detail.value.id, nextStatus.value)
    ElMessage.success('工单状态已更新')
    detail.value = await fetchCustomerServiceTicket(detail.value.id)
    load()
  }
  function categoryText(value: string) {
    return categories.find((item) => item.value === value)?.label || value
  }
  function statusText(value: string) {
    return statuses.find((item) => item.value === value)?.label || value
  }
  function statusTone(value: string) {
    return (
      (
        {
          PENDING: 'danger',
          PROCESSING: 'warning',
          WAIT_CUSTOMER: 'primary',
          RESOLVED: 'success',
          CLOSED: 'info'
        } as any
      )[value] || 'info'
    )
  }
  onMounted(load)
</script>

<style scoped>
  .message-list {
    max-height: 430px;
    margin: 20px 0;
    padding: 18px;
    overflow-y: auto;
    border-radius: 10px;
    background: #f6f7f9;
  }
  .message-row {
    display: flex;
    margin-bottom: 18px;
    flex-direction: column;
    align-items: flex-start;
  }
  .message-row.admin {
    align-items: flex-end;
  }
  .message-meta {
    margin-bottom: 5px;
    color: #909399;
    font-size: 12px;
  }
  .message-bubble {
    max-width: 78%;
    padding: 11px 14px;
    border-radius: 10px;
    color: #303133;
    background: #fff;
    white-space: pre-wrap;
    word-break: break-word;
  }
  .message-row.admin .message-bubble {
    color: #fff;
    background: #4f7cff;
  }
  .reply-box {
    padding-top: 16px;
    border-top: 1px solid #ebeef5;
  }
  .reply-actions {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    margin-top: 12px;
  }
</style>
