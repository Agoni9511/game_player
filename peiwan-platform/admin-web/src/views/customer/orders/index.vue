<template>
  <div class="art-full-height">
    <ElCard class="mb-3">
      <ElForm inline>
        <ElFormItem label="订单状态">
          <ElSelect v-model="query.status" clearable class="!w-44">
            <ElOption v-for="x in statuses" :key="x.value" :label="x.label" :value="x.value" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem><ElButton type="primary" @click="load">查询</ElButton></ElFormItem>
      </ElForm>
    </ElCard>

    <ElCard>
      <ElTable v-loading="loading" :data="rows">
        <ElTableColumn prop="orderNo" label="订单号" min-width="190" />
        <ElTableColumn prop="productName" label="服务商品" min-width="170" />
        <ElTableColumn prop="skuName" label="规格" min-width="130" />
        <ElTableColumn prop="playerName" label="陪玩师" width="120" />
        <ElTableColumn label="金额" width="110"><template #default="{ row }">¥{{ money(row.payableAmount) }}</template></ElTableColumn>
        <ElTableColumn label="状态" width="130"><template #default="{ row }"><ElTag :type="statusType(row.orderStatus)">{{ text(row.orderStatus) }}</ElTag></template></ElTableColumn>
        <ElTableColumn label="确认截止" width="180"><template #default="{ row }">{{ formatDateTime(row.customerConfirmDeadline) }}</template></ElTableColumn>
        <ElTableColumn label="操作" width="160" fixed="right">
          <template #default="{ row }">
            <ElButton v-if="row.orderStatus === 'PENDING_PAYMENT'" link type="success" @click="openPayment(row)">去付款</ElButton>
            <ElButton link type="primary" @click="open(row)">查看</ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
      <div class="flex justify-end mt-4"><ElPagination v-model:current-page="query.current" :total="total" @change="load" layout="total,prev,pager,next" /></div>
    </ElCard>

    <ElDrawer v-model="visible" title="订单与服务详情" size="680px">
      <template v-if="detail">
        <ElDescriptions :column="2" border>
          <ElDescriptionsItem label="订单号">{{ detail.orderNo }}</ElDescriptionsItem>
          <ElDescriptionsItem label="状态">{{ text(detail.orderStatus) }}</ElDescriptionsItem>
          <ElDescriptionsItem label="订单金额">¥{{ money(detail.payableAmount) }}</ElDescriptionsItem>
          <ElDescriptionsItem label="陪玩师">{{ detail.playerName || '待分配' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="确认截止">{{ formatDateTime(detail.customerConfirmDeadline) }}</ElDescriptionsItem>
        </ElDescriptions>
        <div v-if="detail.orderStatus === 'PENDING_PAYMENT'" class="mt-5">
          <ElAlert title="订单尚未付款，付款成功后才会进入陪玩师匹配和派单流程。" type="warning" :closable="false" class="mb-4" />
          <ElButton type="success" @click="openPayment(detail)">去付款</ElButton>
        </div>
        <template v-if="detail.fulfillment">
          <h4>服务完成说明</h4>
          <p>{{ detail.fulfillment.completion_note }}</p>
          <div><ElImage v-for="url in detail.fulfillment.proofUrls" :key="url" :src="url" :preview-src-list="detail.fulfillment.proofUrls" class="proof" fit="cover" /></div>
        </template>
        <ElAlert v-if="detail.afterSale" class="mt-4" :title="`售后状态：${detail.afterSale.after_sale_status}`" :description="detail.afterSale.description" :closable="false" />
        <div v-if="detail.orderStatus === 'WAIT_CUSTOMER_CONFIRM' && !detail.afterSale" class="mt-5">
          <ElButton type="success" @click="confirm">确认服务完成</ElButton>
          <ElButton type="danger" @click="afterSaleVisible = true">申请售后</ElButton>
        </div>
      </template>
    </ElDrawer>

    <ElDialog v-model="paymentVisible" title="微信扫码支付" width="460px" :close-on-click-modal="false" align-center>
      <div v-if="paymentOrder" class="payment-panel">
        <div class="payment-order">订单号：{{ paymentOrder.orderNo }}</div>
        <div class="payment-amount"><span>支付金额</span><strong>¥{{ money(paymentOrder.payableAmount) }}</strong></div>
        <div class="qr-frame">
          <QrcodeVue :value="paymentQrValue" :size="220" level="M" />
          <div class="wechat-mark">微信支付</div>
        </div>
        <p>请使用微信扫一扫完成支付</p>
        <ElAlert title="本地演示二维码，不会发起真实支付或扣款。" type="info" :closable="false" show-icon />
      </div>
      <template #footer>
        <ElButton @click="paymentVisible = false">稍后支付</ElButton>
        <ElButton type="success" :loading="paying" @click="completeMockPayment">模拟支付成功</ElButton>
      </template>
    </ElDialog>

    <ElDialog v-model="afterSaleVisible" title="申请售后" width="600px">
      <ElForm label-width="90px">
        <ElFormItem label="问题类型"><ElSelect v-model="afterForm.reasonType"><ElOption label="服务未完成" value="NOT_COMPLETED" /><ElOption label="服务质量问题" value="QUALITY" /><ElOption label="其他" value="OTHER" /></ElSelect></ElFormItem>
        <ElFormItem label="问题说明" required><ElInput v-model="afterForm.description" type="textarea" :rows="4" /></ElFormItem>
        <ElFormItem label="问题凭证"><LocalFileUpload v-model="afterForm.proofUrl" kind="PROOF" /></ElFormItem>
      </ElForm>
      <template #footer><ElButton @click="afterSaleVisible = false">取消</ElButton><ElButton type="primary" @click="saveAfterSale">提交</ElButton></template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import QrcodeVue from 'qrcode.vue'
  import LocalFileUpload from '@/components/business/local-file-upload.vue'
  import { createAfterSale, fetchCustomerOrder, fetchCustomerOrders, confirmCustomerOrder, mockWechatPayCustomerOrder } from '@/api/business-manage'
  import { formatDateTime } from '@/utils/date'

  const loading = ref(false), paying = ref(false), rows = ref<any[]>([]), total = ref(0)
  const visible = ref(false), paymentVisible = ref(false), afterSaleVisible = ref(false)
  const detail = ref<any>(), paymentOrder = ref<any>()
  const paymentRequestNo = ref(''), paymentQrValue = ref('')
  const query = reactive({ current: 1, size: 20, status: '' })
  const afterForm = reactive({ reasonType: 'QUALITY', description: '', proofUrl: '' })
  const statuses = [
    { label: '待付款', value: 'PENDING_PAYMENT' }, { label: '待派单', value: 'WAIT_ASSIGN' },
    { label: '已接单', value: 'ASSIGNED' }, { label: '服务中', value: 'IN_SERVICE' },
    { label: '等待确认', value: 'WAIT_CUSTOMER_CONFIRM' }, { label: '售后中', value: 'AFTER_SALE' },
    { label: '已完成', value: 'COMPLETED' }
  ]

  async function load() { loading.value = true; try { const data = await fetchCustomerOrders(query); rows.value = data.records; total.value = data.total } finally { loading.value = false } }
  async function open(row:any) { detail.value = await fetchCustomerOrder(row.id); visible.value = true }
  function openPayment(row:any) {
    paymentOrder.value = row
    paymentRequestNo.value = `WEB-WX-${row.id}-${Date.now()}`
    paymentQrValue.value = `peiwan-mock-pay://order/${row.id}?orderNo=${encodeURIComponent(row.orderNo || '')}&amount=${money(row.payableAmount)}&requestNo=${paymentRequestNo.value}`
    paymentVisible.value = true
  }
  async function completeMockPayment() {
    if (!paymentOrder.value || paying.value) return
    paying.value = true
    try {
      await mockWechatPayCustomerOrder(paymentOrder.value.id, paymentRequestNo.value)
      ElMessage.success('模拟支付成功，订单已进入派单流程')
      paymentVisible.value = false
      if (detail.value?.id === paymentOrder.value.id) detail.value = await fetchCustomerOrder(paymentOrder.value.id)
      await load()
    } finally { paying.value = false }
  }
  async function confirm() { await ElMessageBox.confirm('确认本次服务已经完成吗？', '确认完成'); await confirmCustomerOrder(detail.value.id); ElMessage.success('订单已完成'); visible.value = false; load() }
  async function saveAfterSale() { if (!afterForm.description.trim()) return ElMessage.warning('请填写问题说明'); await createAfterSale(detail.value.id, { reasonType: afterForm.reasonType, description: afterForm.description, proofUrls: afterForm.proofUrl ? [afterForm.proofUrl] : [] }); ElMessage.success('售后申请已提交'); afterSaleVisible.value = false; visible.value = false; load() }
  const text = (status:string) => ({ PENDING_PAYMENT:'待付款', WAIT_ASSIGN:'待派单', ASSIGNED:'已接单', IN_SERVICE:'服务中', PENDING_CONFIRM:'待平台审核', WAIT_CUSTOMER_CONFIRM:'等待您确认', AFTER_SALE:'售后中', COMPLETED:'已完成', CANCELLED:'已取消' } as Record<string,string>)[status] || status
  const statusType = (status:string) => status === 'PENDING_PAYMENT' ? 'warning' : status === 'COMPLETED' ? 'success' : status === 'CANCELLED' ? 'info' : 'primary'
  const money = (value:unknown) => Number(value || 0).toFixed(2)
  onMounted(load)
</script>

<style scoped>
  .proof { width: 120px; height: 120px; margin: 0 12px 12px 0; border-radius: 8px; }
  .payment-panel { text-align: center; }
  .payment-order { color: var(--el-text-color-secondary); font-size: 13px; }
  .payment-amount { margin: 18px 0; display: flex; align-items: baseline; justify-content: center; gap: 10px; }
  .payment-amount span { color: var(--el-text-color-regular); }
  .payment-amount strong { color: #e34d59; font-size: 30px; }
  .qr-frame { width: 260px; margin: 0 auto; padding: 18px 18px 12px; box-sizing: border-box; border: 1px solid var(--el-border-color); border-radius: 12px; background: #fff; box-shadow: 0 8px 28px rgb(0 0 0 / 8%); }
  .wechat-mark { margin-top: 8px; color: #07c160; font-size: 14px; font-weight: 700; }
  .payment-panel > p { margin: 14px 0; color: var(--el-text-color-regular); }
</style>
