<template>
  <ElDialog v-model="visible" fullscreen destroy-on-close class="order-create-page" :show-close="false">
    <template #header>
      <div class="page-header">
        <div>
          <h2>创建陪玩订单</h2>
          <p>代用户选择商品、游戏资料和服务要求，订单价格按销售规格及陪玩等级自动计算。</p>
        </div>
        <ElButton circle @click="visible = false"><ArtSvgIcon icon="ri:close-line" /></ElButton>
      </div>
    </template>

    <div v-loading="loading" class="page-body">
      <ElForm ref="formRef" :model="form" :rules="rules" label-position="top">
        <div class="content-grid">
          <div class="form-column">
            <ElCard shadow="never" class="section-card">
              <template #header><SectionTitle number="1" title="订单商品" desc="确定下单用户、商品及销售规格" /></template>
              <ElRow :gutter="18">
                <ElCol :span="8"><ElFormItem label="下单用户" prop="customerId"><ElSelect v-model="form.customerId" filterable class="w-full" placeholder="搜索用户名或昵称" @change="customerChanged"><ElOption v-for="x in customers" :key="x.id" :label="`${x.label}（${x.username}）`" :value="x.id" /></ElSelect></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="商品" prop="productId"><ElSelect v-model="form.productId" filterable class="w-full" placeholder="选择已上架商品" @change="productChanged"><ElOption v-for="x in products" :key="x.id" :label="`${x.productName} · ${x.gameName || ''}`" :value="x.id" /></ElSelect></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="销售规格" prop="skuId"><ElSelect v-model="form.skuId" class="w-full" placeholder="先选择商品" @change="skuChanged"><ElOption v-for="x in enabledSkus" :key="x.id" :label="`${x.skuName} · ¥${money(x.price)}`" :value="x.id" /></ElSelect></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="购买数量" prop="quantity"><ElInputNumber v-model="form.quantity" :min="selectedSku?.minQuantity || 1" :max="selectedSku?.maxQuantity" class="!w-full" /></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="商品所属游戏"><ElInput :model-value="productDetail?.gameName || '-'" disabled /></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="服务人数"><ElInput :model-value="selectedSku ? `${selectedSku.playerCount || 1} 人` : '-'" disabled /></ElFormItem></ElCol>
              </ElRow>
            </ElCard>

            <ElCard shadow="never" class="section-card">
              <template #header><SectionTitle number="2" title="游戏资料" desc="优先复用用户保存的账号，也可以为本单临时填写" /></template>
              <ElRow :gutter="18">
                <ElCol :span="8"><ElFormItem label="保存的游戏账号"><ElSelect v-model="form.customerGameProfileId" clearable class="w-full" placeholder="不使用保存账号" @change="profileChanged"><ElOption v-for="x in gameProfiles.filter((p:any)=>p.id)" :key="x.id" :label="`${x.gameNickname}（${x.gameAccount}）`" :value="x.id" /></ElSelect></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="游戏账号" prop="gameAccount"><ElInput v-model="form.gameAccount" :disabled="Boolean(form.customerGameProfileId)" placeholder="登录账号或游戏 ID" /></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="游戏昵称" prop="gameNickname"><ElInput v-model="form.gameNickname" :disabled="Boolean(form.customerGameProfileId)" /></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="区服"><ElSelect v-model="form.serverId" clearable class="w-full"><ElOption v-for="x in servers" :key="x.id" :label="x.serverName" :value="x.id" /></ElSelect></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="当前段位"><ElSelect v-model="form.currentRankId" clearable filterable class="w-full"><ElOptionGroup v-for="x in rankSystems" :key="x.id" :label="x.systemName"><ElOption v-for="r in x.ranks || []" :key="r.id" :label="r.rankName" :value="r.id" /></ElOptionGroup></ElSelect></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="目标段位"><ElSelect v-model="form.targetRankId" clearable filterable class="w-full"><ElOptionGroup v-for="x in rankSystems" :key="x.id" :label="x.systemName"><ElOption v-for="r in x.ranks || []" :key="r.id" :label="r.rankName" :value="r.id" /></ElOptionGroup></ElSelect></ElFormItem></ElCol>
              </ElRow>
            </ElCard>

            <ElCard shadow="never" class="section-card">
              <template #header><SectionTitle number="3" title="服务与联系信息" desc="可限定陪玩等级或指定陪玩师，留空则按派单规则匹配" /></template>
              <ElRow :gutter="18">
                <ElCol :span="8"><ElFormItem label="陪玩等级"><ElSelect v-model="form.playerLevelId" clearable class="w-full" :disabled="Boolean(form.requestedPlayerId)" @change="levelChanged"><ElOption v-for="x in playerLevels" :key="x.id" :label="x.level_name || x.levelName" :value="x.id" /></ElSelect></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="指定陪玩师"><ElSelect v-model="form.requestedPlayerId" clearable filterable class="w-full" placeholder="不指定，后续统一派单" @change="playerChanged"><ElOption v-for="x in filteredPlayers" :key="x.id" :label="`${x.nickname}（${x.player_no}）· ${x.level_name || '未设等级'}`" :value="x.id" /></ElSelect></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="陪玩师状态"><ElInput :model-value="selectedPlayer ? workStatusText(selectedPlayer.work_status) : '未指定'" disabled /></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="联系人" prop="contactName"><ElInput v-model="form.contactName" /></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="联系电话" prop="contactPhone"><ElInput v-model="form.contactPhone" maxlength="11" /></ElFormItem></ElCol>
                <ElCol :span="24"><ElFormItem label="服务要求"><ElInput v-model="form.extraRequirement" type="textarea" :rows="3" placeholder="例如常用位置、沟通偏好、希望完成的目标等" /></ElFormItem></ElCol>
                <ElCol :span="24"><ElFormItem label="订单备注"><ElInput v-model="form.customerRemark" type="textarea" :rows="2" placeholder="仅作为本订单补充说明" /></ElFormItem></ElCol>
              </ElRow>
            </ElCard>

            <ElCard shadow="never" class="section-card">
              <template #header><SectionTitle number="4" title="收款信息" desc="可创建待付款订单，也可记录线下已收款" /></template>
              <ElRow :gutter="18">
                <ElCol :span="8"><ElFormItem label="收款状态"><ElRadioGroup v-model="form.paymentStatus"><ElRadioButton value="UNPAID">待付款</ElRadioButton><ElRadioButton value="PAID">已收款</ElRadioButton></ElRadioGroup></ElFormItem></ElCol>
                <ElCol v-if="form.paymentStatus === 'PAID'" :span="8"><ElFormItem label="收款方式"><ElSelect v-model="form.paymentChannel" class="w-full"><ElOption label="现金" value="MANUAL_CASH" /><ElOption label="微信" value="MANUAL_WECHAT" /><ElOption label="支付宝" value="MANUAL_ALIPAY" /><ElOption label="其他" value="MANUAL_OTHER" /></ElSelect></ElFormItem></ElCol>
                <ElCol :span="8"><ElFormItem label="创建后状态"><ElInput :model-value="form.paymentStatus === 'PAID' ? '待派单' : '待付款'" disabled /></ElFormItem></ElCol>
              </ElRow>
            </ElCard>
          </div>

          <div class="summary-column">
            <ElCard shadow="never" class="summary-card">
              <template #header><strong>订单确认</strong></template>
              <div class="summary-product"><span>{{ productDetail?.productName || '尚未选择商品' }}</span><small>{{ selectedSku?.skuName || '请选择销售规格' }}</small></div>
              <div class="summary-line"><span>规格单价</span><b>¥{{ money(effectiveUnitPrice) }}</b></div>
              <div class="summary-line"><span>购买数量</span><b>× {{ form.quantity || 1 }}</b></div>
              <div class="summary-line"><span>服务人数</span><b>{{ selectedSku?.playerCount || 1 }} 人</b></div>
              <div class="summary-line"><span>计价方式</span><b>{{ priceTypeText }}</b></div>
              <ElDivider />
              <div class="total-line"><span>预计应付</span><strong>¥{{ money(estimatedTotal) }}</strong></div>
              <ElAlert v-if="form.playerLevelId" class="mt-4" type="info" :closable="false" title="已按所选陪玩等级预估价格，最终价格由后端订单快照确认。" />
              <ElButton type="primary" size="large" class="create-button" :loading="saving" @click="submit">确认创建订单</ElButton>
              <ElButton size="large" class="cancel-button" @click="visible = false">取消</ElButton>
            </ElCard>
          </div>
        </div>
      </ElForm>
    </div>
  </ElDialog>
</template>

<script setup lang="ts">
  import { h } from 'vue'
  import type { FormInstance, FormRules } from 'element-plus'
  import { createOrder, confirmOrderPayment, fetchOrderCreateOptions, fetchOrderCustomers, fetchProduct, fetchProducts } from '@/api/business-manage'

  const props = defineProps<{ modelValue: boolean }>()
  const emit = defineEmits<{ 'update:modelValue': [value: boolean]; saved: [] }>()
  const visible = computed({ get: () => props.modelValue, set: (value) => emit('update:modelValue', value) })
  const SectionTitle = (_: any, ctx: any) => h('div', { class: 'section-title' }, [h('span', ctx.attrs.number), h('div', [h('strong', ctx.attrs.title), h('small', ctx.attrs.desc)])])
  const formRef = ref<FormInstance>()
  const loading = ref(false), saving = ref(false)
  const customers = ref<any[]>([]), products = ref<any[]>([]), productDetail = ref<any>(), gameProfiles = ref<any[]>([]), servers = ref<any[]>([]), rankSystems = ref<any[]>([]), playerLevels = ref<any[]>([]), players = ref<any[]>([])
  const form = reactive<any>({})
  const rules: FormRules = {
    customerId: [{ required: true, message: '请选择下单用户', trigger: 'change' }], productId: [{ required: true, message: '请选择商品', trigger: 'change' }], skuId: [{ required: true, message: '请选择销售规格', trigger: 'change' }], quantity: [{ required: true, message: '请输入购买数量', trigger: 'change' }], contactName: [{ required: true, message: '请填写联系人', trigger: 'blur' }], contactPhone: [{ required: true, pattern: /^1\d{10}$/, message: '请输入正确的11位手机号', trigger: 'blur' }]
  }
  const enabledSkus = computed<any[]>(() => productDetail.value?.skus?.filter((x:any) => x.enabled) || [])
  const selectedSku = computed(() => enabledSkus.value.find(x => x.id === form.skuId))
  const selectedPlayer = computed(() => players.value.find(x => x.id === form.requestedPlayerId))
  const filteredPlayers = computed(() => form.playerLevelId ? players.value.filter(x => Number(x.price_level_id) === Number(form.playerLevelId)) : players.value)
  const effectiveUnitPrice = computed(() => selectedSku.value?.levelPrices?.find((x:any) => Number(x.playerLevelId) === Number(form.playerLevelId) && x.enabled)?.price ?? selectedSku.value?.price ?? 0)
  const estimatedTotal = computed(() => Number(effectiveUnitPrice.value) * Number(form.quantity || 1) * (selectedSku.value?.priceType === 'FIXED_TOTAL' || productDetail.value?.productType === 'PACKAGE' ? 1 : Number(selectedSku.value?.playerCount || 1)))
  const priceTypeText = computed(() => selectedSku.value?.priceType === 'FIXED_TOTAL' || productDetail.value?.productType === 'PACKAGE' ? '整单总价' : '按陪玩人数')

  watch(() => props.modelValue, async value => { if (value) await initialize() })
  async function initialize() {
    loading.value = true
    try {
      const [customerRows, productPage] = await Promise.all([fetchOrderCustomers(), fetchProducts({ current: 1, size: 200, status: 'ON_SALE' })])
      customers.value = customerRows; products.value = productPage.records
      Object.assign(form, { customerId: undefined, productId: undefined, skuId: undefined, quantity: 1, contactName: '', contactPhone: '', customerRemark: '', gameAccount: '', gameNickname: '', customerGameProfileId: undefined, serverId: undefined, currentRankId: undefined, targetRankId: undefined, extraRequirement: '', playerLevelId: undefined, requestedPlayerId: undefined, paymentStatus: 'UNPAID', paymentChannel: 'MANUAL_WECHAT' })
      productDetail.value = undefined; clearGameOptions()
    } finally { loading.value = false }
  }
  function clearGameOptions() { gameProfiles.value = []; servers.value = []; rankSystems.value = []; playerLevels.value = []; players.value = [] }
  function customerChanged(id:number) { const row = customers.value.find(x => x.id === id); form.contactName = row?.label || ''; form.contactPhone = row?.phone || ''; resetGameProfile(); loadCreateOptions() }
  async function productChanged(id:number) { productDetail.value = await fetchProduct(id); form.skuId = enabledSkus.value[0]?.id; form.quantity = selectedSku.value?.minQuantity || 1; resetGameProfile(); await loadCreateOptions() }
  function skuChanged() { form.quantity = Math.max(Number(form.quantity || 1), Number(selectedSku.value?.minQuantity || 1)) }
  async function loadCreateOptions() { if (!form.customerId || !productDetail.value?.gameId) return clearGameOptions(); const data = await fetchOrderCreateOptions(form.customerId, productDetail.value.gameId); gameProfiles.value = data.gameProfiles || []; servers.value = data.gameConfig?.servers || []; rankSystems.value = data.gameConfig?.rankSystems || []; playerLevels.value = data.playerLevels || []; players.value = data.players || [] }
  function resetGameProfile() { Object.assign(form, { customerGameProfileId: undefined, serverId: undefined, currentRankId: undefined, targetRankId: undefined, gameAccount: '', gameNickname: '', playerLevelId: undefined, requestedPlayerId: undefined }) }
  function profileChanged(id?:number) { const row = gameProfiles.value.find(x => x.id === id); if (!row) return; form.gameAccount = row.gameAccount; form.gameNickname = row.gameNickname; form.serverId = row.serverId; form.currentRankId = row.ranks?.[0]?.rankId }
  function levelChanged() { if (form.requestedPlayerId && !filteredPlayers.value.some(x => x.id === form.requestedPlayerId)) form.requestedPlayerId = undefined }
  function playerChanged(id?:number) { const row = players.value.find(x => x.id === id); if (row?.price_level_id) form.playerLevelId = row.price_level_id }
  async function submit() {
    await formRef.value?.validate()
    if (!form.customerGameProfileId && (!form.gameAccount?.trim() || !form.gameNickname?.trim())) return ElMessage.warning('请选择保存的游戏账号，或完整填写游戏账号和昵称')
    if (form.currentRankId && form.targetRankId && rankIndex(form.targetRankId) < rankIndex(form.currentRankId)) return ElMessage.warning('目标段位不能低于当前段位')
    saving.value = true
    try {
      const result = await createOrder({ ...form, serverName: undefined, rankName: undefined })
      if (form.paymentStatus === 'PAID') {
        try { await confirmOrderPayment(result.id, form.paymentChannel) } catch { ElMessage.warning('订单已创建，但确认收款失败，请在订单列表中重新确认') }
      }
      ElMessage.success('订单创建成功'); visible.value = false; emit('saved')
    } finally { saving.value = false }
  }
  function rankIndex(id:number) { const ranks = rankSystems.value.flatMap(x => x.ranks || []); return ranks.findIndex((x:any) => x.id === id) }
  function money(value:any) { return Number(value || 0).toFixed(2) }
  function workStatusText(value:string) { return ({ AVAILABLE: '可接单', BUSY: '服务中', OFFLINE: '休息中' } as any)[value] || value || '-' }
</script>

<style scoped>
  :global(.order-create-page .el-dialog__header){padding:0;margin:0}.page-header{height:78px;padding:0 30px;border-bottom:1px solid var(--el-border-color-lighter);display:flex;align-items:center;justify-content:space-between;background:var(--el-bg-color)}.page-header h2{margin:0;font-size:22px}.page-header p{margin:6px 0 0;color:var(--el-text-color-secondary);font-size:13px}.page-body{min-height:calc(100vh - 78px);padding:22px 28px 40px;box-sizing:border-box;background:var(--el-fill-color-lighter)}.content-grid{max-width:1500px;margin:0 auto;display:grid;grid-template-columns:minmax(0,1fr) 320px;gap:20px}.form-column{min-width:0}.section-card{margin-bottom:18px;border:0}.section-title{display:flex;align-items:center;gap:12px}.section-title>span{width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;background:var(--el-color-primary);font-weight:700}.section-title strong,.section-title small{display:block}.section-title small{margin-top:3px;color:var(--el-text-color-secondary);font-weight:400}.summary-column{position:relative}.summary-card{position:sticky;top:0;border:0}.summary-product{padding:4px 0 18px}.summary-product span,.summary-product small{display:block}.summary-product span{font-size:17px;font-weight:700}.summary-product small{margin-top:7px;color:var(--el-text-color-secondary)}.summary-line{padding:8px 0;display:flex;justify-content:space-between;color:var(--el-text-color-regular)}.total-line{display:flex;align-items:flex-end;justify-content:space-between}.total-line strong{color:var(--el-color-danger);font-size:27px}.create-button,.cancel-button{width:100%;margin:18px 0 0}.cancel-button{margin:10px 0 0}@media(max-width:1100px){.content-grid{grid-template-columns:1fr}.summary-card{position:static}}
</style>
