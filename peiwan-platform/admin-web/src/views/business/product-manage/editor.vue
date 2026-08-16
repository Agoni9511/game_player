<template>
  <div v-loading="loading" class="product-editor">
    <ElCard class="mb-3 editor-header">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <ElButton :icon="ArrowLeft" @click="emit('cancel')">返回商品列表</ElButton>
          <div>
            <div class="text-lg font-medium">{{ pageTitle }}</div>
            <div class="text-xs text-gray-400 mt-1">集中配置商品信息、套餐内容、SKU 档位和承诺规则</div>
          </div>
        </div>
        <ElButton type="primary" :loading="saving" @click="save">保存为草稿</ElButton>
      </div>
    </ElCard>

    <ElForm label-width="96px">
      <ElCard class="mb-3" header="基础信息">
        <ElRow :gutter="20">
          <ElCol :xs="24" :lg="12">
            <ElFormItem label="所属游戏" required>
              <ElSelect v-model="form.gameId" class="w-full" @change="gameChanged">
                <ElOption v-for="g in games" :key="g.id" :label="g.gameName" :value="g.id" />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :xs="24" :lg="12">
            <ElFormItem label="商品分类" required>
              <ElSelect v-model="form.categoryId" class="w-full">
                <ElOption v-for="c in leafCategories(form.gameId)" :key="c.id" :label="c.categoryName" :value="c.id" />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :xs="24" :lg="12">
            <ElFormItem label="商品编码" required>
              <ElInput v-model="form.productCode">
                <template #append><ElButton @click="form.productCode = generateBusinessCode('product')">重新生成</ElButton></template>
              </ElInput>
            </ElFormItem>
          </ElCol>
          <ElCol :xs="24" :lg="12">
            <ElFormItem label="商品名称" required><ElInput v-model="form.productName" /></ElFormItem>
          </ElCol>
          <ElCol :xs="24" :md="8">
            <ElFormItem label="商品类型" required>
              <ElSelect v-model="form.productType" class="w-full" @change="typeChanged">
                <ElOption label="单项服务" value="SERVICE" />
                <ElOption label="平台套餐" value="PACKAGE" />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :xs="24" :md="8"><ElFormItem label="有效天数"><ElInputNumber v-model="form.validityDays" :min="1" class="!w-full" /></ElFormItem></ElCol>
          <ElCol :xs="24" :md="8"><ElFormItem label="每人限购"><ElInputNumber v-model="form.purchaseLimit" :min="1" class="!w-full" /></ElFormItem></ElCol>
        </ElRow>
      </ElCard>

      <ElCard class="mb-3">
        <template #header>
          <div class="flex items-center justify-between">
            <span>{{ form.productType === 'PACKAGE' ? '套餐组成' : '基础服务' }}</span>
            <ElButton v-if="form.productType === 'PACKAGE' || !form.components.length" type="primary" plain @click="addComponent">添加服务</ElButton>
          </div>
        </template>
        <ElAlert
          class="mb-3"
          type="info"
          :closable="false"
          :title="form.productType === 'PACKAGE' ? '这里仅说明套餐包含哪些服务，不参与价格累加；成交价格始终取下面的 SKU 套餐整单售价。' : '基础服务用于定义交付内容；服务可无价格，商品成交价由 SKU 或基础服务等级报价规则确定。'"
        />
        <ElTable :data="form.components" border>
          <ElTableColumn label="基础服务" min-width="320">
            <template #default="{ row }">
              <ElSelect v-model="row.serviceId" class="w-full" @change="serviceChanged(row)">
                <ElOption
                  v-for="s in availableServices"
                  :key="s.id"
                  :label="`${s.serviceName}（${s.serviceCode}）${s.usageType === 'PACKAGE_ONLY' ? ' · 仅套餐' : ''}`"
                  :value="s.id"
                  :disabled="form.components.some((x: any) => x !== row && x.serviceId === s.id)"
                />
              </ElSelect>
            </template>
          </ElTableColumn>
          <ElTableColumn label="服务数量" width="160"><template #default="{ row }"><ElInputNumber v-model="row.quantity" :min="0.01" :precision="2" class="!w-full" /></template></ElTableColumn>
          <ElTableColumn label="计量单位" width="160"><template #default="{ row }"><ElSelect v-model="row.unitType" class="w-full"><ElOption label="小时" value="HOUR" /><ElOption label="局" value="GAME" /><ElOption label="单" value="ORDER" /></ElSelect></template></ElTableColumn>
          <ElTableColumn label="操作" width="90"><template #default="{ $index }"><ElButton link type="danger" @click="form.components.splice($index, 1)">移除</ElButton></template></ElTableColumn>
        </ElTable>
      </ElCard>

      <ElCard class="mb-3" header="商品介绍">
        <ElFormItem label="商品副标题"><ElInput v-model="form.subtitle" maxlength="255" show-word-limit /></ElFormItem>
        <ElFormItem label="商品说明"><ElInput v-model="form.description" type="textarea" :rows="4" /></ElFormItem>
        <ElRow :gutter="20">
          <ElCol :xs="24" :lg="18"><ElFormItem label="商品封面"><LocalFileUpload v-model="form.coverUrl" /></ElFormItem></ElCol>
          <ElCol :xs="24" :lg="6"><ElFormItem label="排序"><ElInputNumber v-model="form.sortNo" :min="0" class="!w-full" /></ElFormItem></ElCol>
        </ElRow>
      </ElCard>

      <ElCard>
        <template #header>
          <div class="flex items-center justify-between">
            <div>
              <span>销售规格（SKU）</span>
              <span class="ml-2 text-xs text-gray-400">价格、人数、服务时长及承诺均按规格配置</span>
            </div>
            <div class="flex gap-2">
              <ElButton v-if="form.productType === 'SERVICE'" plain :disabled="!selectedService" @click="generateServiceSkus">按基础服务生成规格</ElButton>
              <ElButton type="primary" plain @click="addSku()">新增规格</ElButton>
            </div>
          </div>
        </template>
        <ElAlert
          class="mb-4"
          :type="form.productType === 'PACKAGE' ? 'warning' : 'info'"
          :closable="false"
          :title="form.productType === 'PACKAGE' ? '平台套餐按整单计价：计价单位固定为“单”、单位数量固定为 1，套餐售价不会再乘陪玩人数。' : '单项服务的 SKU 定义售卖档位；兜底价仅在缺少基础服务等级报价时使用。'"
        />
        <ElEmpty v-if="!form.skus.length" description="暂无销售规格"><ElButton type="primary" @click="addSku()">新增第一个规格</ElButton></ElEmpty>
        <ElCard v-for="(sku, skuIndex) in form.skus" :key="sku.__key || sku.id || skuIndex" shadow="never" class="mb-4 sku-card">
          <template #header>
            <div class="flex items-center justify-between">
              <div class="font-medium">规格 {{ skuIndex + 1 }}<span v-if="sku.skuName" class="ml-2 text-gray-400">{{ sku.skuName }}</span></div>
              <div class="flex items-center gap-3"><ElSwitch v-model="sku.enabled" active-text="启用" /><ElButton link type="danger" @click="form.skus.splice(skuIndex, 1)">删除规格</ElButton></div>
            </div>
          </template>
          <ElRow :gutter="16">
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem label="规格编码" required><ElInput v-model="sku.skuCode"><template #append><ElButton @click="sku.skuCode = generateBusinessCode('sku')">重新生成</ElButton></template></ElInput></ElFormItem></ElCol>
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem label="规格名称" required><ElInput v-model="sku.skuName" /></ElFormItem></ElCol>
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem :label="form.productType === 'PACKAGE' ? '套餐售价' : '兜底价'"><ElInputNumber v-model="sku.price" :min="0" :precision="2" :controls="false" class="!w-full" /></ElFormItem></ElCol>
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem label="划线价"><ElInputNumber v-model="sku.marketPrice" :min="0" :precision="2" :controls="false" class="!w-full" /></ElFormItem></ElCol>
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem label="计价单位"><ElInput v-if="form.productType === 'PACKAGE'" model-value="单" disabled /><ElSelect v-else v-model="sku.unitType" class="w-full"><ElOption v-for="unit in unitOptions" :key="unit.value" :label="`${unit.label}${configuredServiceUnits.includes(unit.value) ? '（有等级价）' : '（使用兜底价）'}`" :value="unit.value" /></ElSelect></ElFormItem></ElCol>
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem label="单位数量"><ElInputNumber v-model="sku.unitCount" :disabled="form.productType === 'PACKAGE'" :min="0.01" :precision="2" :controls="false" class="!w-full" /></ElFormItem></ElCol>
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem label="陪玩人数"><ElInputNumber v-model="sku.playerCount" :min="1" :max="20" :controls="false" class="!w-full" /></ElFormItem></ElCol>
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem label="价格类型"><ElInput v-if="form.productType === 'PACKAGE'" model-value="整单总价" disabled /><ElSelect v-else v-model="sku.priceType" class="w-full"><ElOption label="每人单价" value="PER_PLAYER" /><ElOption label="整单总价" value="FIXED_TOTAL" /></ElSelect></ElFormItem></ElCol>
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem label="最少购买"><ElInputNumber v-model="sku.minQuantity" :min="1" :controls="false" class="!w-full" /></ElFormItem></ElCol>
            <ElCol :xs="24" :md="12" :xl="8"><ElFormItem label="服务分钟"><ElInputNumber v-model="sku.serviceMinutes" :min="1" :controls="false" class="!w-full" /></ElFormItem></ElCol>
          </ElRow>

          <template v-if="form.productType === 'SERVICE'">
            <ElAlert v-if="!skuLevelPricePreview(sku).length" class="mb-4" type="warning" :closable="false" :title="`基础服务未配置“${unitName(sku.unitType)}”等级价格，下单将使用 SKU 兜底价 ¥${money(sku.price)}。`" />
            <div v-else class="level-price-preview mb-4">
              <div class="preview-title">等级成交价预览 <span>基础服务单价 × {{ sku.unitCount || 1 }} {{ unitName(sku.unitType) }}</span></div>
              <div class="preview-list">
                <div v-for="price in skuLevelPricePreview(sku)" :key="price.playerLevelId" class="preview-item">
                  <span>{{ playerLevelName(price.playerLevelId) }}</span>
                  <strong>¥{{ money(price.totalPrice) }}</strong>
                  <small>¥{{ money(price.price) }} × {{ sku.unitCount || 1 }}</small>
                </div>
              </div>
            </div>
          </template>

          <ElDivider content-position="left">SKU 承诺规则</ElDivider>
          <div class="flex items-center justify-between mb-3">
            <span class="text-xs text-gray-400">承诺不参与价格计算；下单时会生成订单快照。</span>
            <ElButton plain @click="addCommitment(sku)">新增规则</ElButton>
          </div>
          <ElEmpty v-if="!sku.commitments?.length" :image-size="56" description="暂无承诺规则" />
          <ElTable v-else :data="sku.commitments" border>
            <ElTableColumn label="规则类型" min-width="145"><template #default="{ row }"><ElSelect v-model="row.ruleType" class="w-full"><ElOption v-for="item in commitmentTypes" :key="item.value" :label="item.label" :value="item.value" /></ElSelect></template></ElTableColumn>
            <ElTableColumn label="展示标题" min-width="150"><template #default="{ row }"><ElInput v-model="row.title" placeholder="如：基础保底" /></template></ElTableColumn>
            <ElTableColumn label="目标值" width="115"><template #default="{ row }"><ElInputNumber v-model="row.targetValue" :min="0" :precision="2" :controls="false" class="!w-full" /></template></ElTableColumn>
            <ElTableColumn label="单位" width="100"><template #default="{ row }"><ElInput v-model="row.targetUnit" placeholder="万/个" /></template></ElTableColumn>
            <ElTableColumn label="规则说明" min-width="180"><template #default="{ row }"><ElInput v-model="row.description" placeholder="如：成功撤离才计入" /></template></ElTableColumn>
            <ElTableColumn label="未达标处理" min-width="180"><template #default="{ row }"><ElInput v-model="row.failureAction" placeholder="如：未出继续服务" /></template></ElTableColumn>
            <ElTableColumn label="启用" width="70"><template #default="{ row }"><ElSwitch v-model="row.enabled" /></template></ElTableColumn>
            <ElTableColumn label="操作" width="70"><template #default="{ $index }"><ElButton link type="danger" @click="sku.commitments.splice($index, 1)">删除</ElButton></template></ElTableColumn>
          </ElTable>
        </ElCard>
      </ElCard>
    </ElForm>

    <div class="editor-footer">
      <ElButton @click="emit('cancel')">取消</ElButton>
      <ElButton type="primary" :loading="saving" @click="save">保存为草稿</ElButton>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ArrowLeft } from '@element-plus/icons-vue'
  import LocalFileUpload from '@/components/business/local-file-upload.vue'
  import { createProduct, fetchGameOptions, fetchPlayerLevels, fetchProduct, fetchProductCategories, fetchServices, updateProduct } from '@/api/business-manage'
  import { generateBusinessCode } from '@/utils/business-code'

  const props = defineProps<{ productId?: number; copy?: boolean }>()
  const emit = defineEmits<{ cancel: []; saved: [] }>()
  const loading = ref(true)
  const saving = ref(false)
  type UnitType = 'HOUR' | 'GAME' | 'ORDER'
  const games = ref<Api.Business.Game[]>([])
  const categories = ref<Api.Business.ProductCategory[]>([])
  const services = ref<Api.Business.ServiceItem[]>([])
  const playerLevels = ref<any[]>([])
  const form = reactive<any>({})
  const pageTitle = computed(() => (props.copy ? '复制商品' : props.productId ? '编辑商品' : '新增商品'))
  const commitmentTypes = [
    { value: 'GUARANTEE_VALUE', label: '保底承诺' },
    { value: 'TARGET_COUNT', label: '目标数量' },
    { value: 'SUCCESS_CONDITION', label: '有效条件' },
    { value: 'KEEP_PLAYING', label: '未达继续服务' },
    { value: 'DESIGNATED_ITEM', label: '指定物品' },
    { value: 'DESIGNATED_MAP', label: '指定地图' },
    { value: 'COMPENSATION', label: '补偿规则' },
    { value: 'OTHER', label: '其他规则' }
  ]
  const availableServices = computed(() => services.value.filter((x) => x.gameId === form.gameId && x.enabled && (form.productType === 'PACKAGE' || x.usageType !== 'PACKAGE_ONLY')))
  const selectedService = computed(() => services.value.find((x) => Number(x.id) === Number(form.components?.[0]?.serviceId)))
  const unitOptions: Array<{ value: UnitType; label: string }> = [
    { value: 'HOUR', label: '小时' },
    { value: 'GAME', label: '局' },
    { value: 'ORDER', label: '单' }
  ]
  const configuredServiceUnits = computed<UnitType[]>(() => [...new Set((selectedService.value?.levelPrices || []).filter((x) => x.enabled !== false && x.price != null).map((x) => x.unitType))])

  function flatten(list: any[], gameId?: number, out: any[] = []) {
    for (const item of list) {
      if ((!gameId || item.gameId === gameId) && (!item.children || !item.children.length)) out.push(item)
      flatten(item.children || [], gameId, out)
    }
    return out
  }
  const leafCategories = (gameId?: number) => flatten(categories.value, gameId, [])
  function blank() {
    return { id: null, gameId: games.value[0]?.id, categoryId: undefined, productCode: generateBusinessCode('product'), productName: '', subtitle: '', description: '', coverUrl: '', productType: 'SERVICE', sortNo: 0, validityDays: undefined, purchaseLimit: undefined, serviceIds: [], components: [], skus: [] }
  }
  function normalizePackageSkus() {
    if (form.productType !== 'PACKAGE') return
    for (const sku of form.skus || []) Object.assign(sku, { unitType: 'ORDER', unitCount: 1, priceType: 'FIXED_TOTAL' })
  }
  function addComponent() {
    if (form.productType === 'SERVICE' && form.components.length) return
    form.components.push({ serviceId: undefined, quantity: 1, unitType: form.productType === 'PACKAGE' ? 'HOUR' : 'ORDER', sortNo: form.components.length + 1 })
  }
  function createSku(unitType: UnitType = form.productType === 'PACKAGE' ? 'ORDER' : configuredServiceUnits.value[0] || 'HOUR') {
    const unit = unitName(unitType)
    const basePrices = (selectedService.value?.levelPrices || []).filter((x) => x.unitType === unitType && x.enabled !== false && x.price != null).map((x) => Number(x.price))
    return { __key: generateBusinessCode('sku'), skuCode: generateBusinessCode('sku'), skuName: form.productType === 'PACKAGE' ? '' : `1${unit}`, price: basePrices.length ? Math.min(...basePrices) : 0, marketPrice: undefined, unitType, unitCount: 1, playerCount: 1, priceType: form.productType === 'PACKAGE' ? 'FIXED_TOTAL' : 'PER_PLAYER', minQuantity: 1, maxQuantity: undefined, stockMode: 'UNLIMITED', stockQuantity: undefined, serviceMinutes: unitType === 'HOUR' ? 60 : undefined, enabled: true, sortNo: form.skus.length, commitments: [] }
  }
  function addSku(unitType?: UnitType) {
    form.skus.push(createSku(unitType))
  }
  function generateServiceSkus() {
    if (!selectedService.value) return ElMessage.warning('请先选择基础服务')
    if (!configuredServiceUnits.value.length) return ElMessage.warning('该基础服务尚未配置任何等级计价单位，请手动创建 SKU 并填写兜底价')
    const placeholderOnly = form.skus.length === 1 && !form.skus[0].skuName
    if (placeholderOnly) form.skus = []
    let added = 0
    for (const unitType of configuredServiceUnits.value) {
      if (form.skus.some((sku: any) => sku.unitType === unitType && Number(sku.unitCount) === 1)) continue
      addSku(unitType)
      added++
    }
    if (!added) return ElMessage.info('已存在所有可用计价单位的 1 单位规格')
    ElMessage.success(`已生成 ${added} 个标准规格，可继续修改数量或新增档位`)
  }
  function serviceChanged(row: any) {
    if (form.productType !== 'SERVICE') return
    const service = services.value.find((x) => Number(x.id) === Number(row.serviceId))
    const units: UnitType[] = [...new Set((service?.levelPrices || []).filter((x) => x.enabled !== false && x.price != null).map((x) => x.unitType))]
    if (units.length) row.unitType = units[0]
    if (form.skus.length === 1 && !form.skus[0].skuName) generateServiceSkus()
  }
  function addCommitment(sku: any) {
    const rows = sku.commitments || (sku.commitments = [])
    rows.push({ ruleType: 'GUARANTEE_VALUE', title: '', targetValue: undefined, targetUnit: '', description: '', failureAction: '', enabled: true, sortNo: rows.length })
  }
  async function gameChanged() {
    form.categoryId = undefined
    form.serviceIds = []
    form.components = []
    playerLevels.value = form.gameId ? await fetchPlayerLevels(form.gameId) : []
    addComponent()
  }
  function typeChanged() {
    form.components = []
    addComponent()
    normalizePackageSkus()
  }
  async function initialize() {
    loading.value = true
    try {
      const [categoryList, gameList, servicePage] = await Promise.all([fetchProductCategories(), fetchGameOptions(), fetchServices({ current: 1, size: 200, enabled: true })])
      categories.value = categoryList
      games.value = gameList
      services.value = servicePage.records
      Object.assign(form, blank())
      if (props.productId) {
        const source: any = await fetchProduct(props.productId)
        Object.assign(form, source)
        if (props.copy) {
          Object.assign(form, { id: null, status: 'DRAFT', productCode: generateBusinessCode('product'), productName: `${source.productName} 副本` })
          form.components = (source.components || []).map((component: any) => ({ ...component, id: undefined }))
          form.skus = (source.skus || []).map((sku: any) => ({ ...sku, id: undefined, __key: generateBusinessCode('sku'), skuCode: generateBusinessCode('sku'), commitments: (sku.commitments || []).map((rule: any) => ({ ...rule, id: undefined })) }))
        }
      }
      playerLevels.value = form.gameId ? await fetchPlayerLevels(form.gameId) : []
      for (const sku of form.skus || []) {
        sku.commitments ||= []
        sku.__key ||= sku.id || generateBusinessCode('sku')
      }
      normalizePackageSkus()
      if (!form.components.length) addComponent()
      if (!form.skus.length) addSku()
    } finally {
      loading.value = false
    }
  }
  async function save() {
    normalizePackageSkus()
    if (!form.gameId || !form.categoryId || !form.productCode || !form.productName) return ElMessage.warning('请填写商品必填信息')
    const requiredComponents = form.productType === 'PACKAGE' ? 2 : 1
    if (form.components.length < requiredComponents || form.components.some((x: any) => !x.serviceId)) return ElMessage.warning(form.productType === 'PACKAGE' ? '套餐至少添加两个基础服务' : '请选择基础服务')
    if (!form.skus.length || form.skus.some((x: any) => !x.skuCode || !x.skuName)) return ElMessage.warning('请完整填写销售规格')
    if (form.productType === 'SERVICE' && form.skus.some((x: any) => !skuLevelPricePreview(x).length && Number(x.price) <= 0)) return ElMessage.warning('存在没有等级报价且兜底价为 0 的规格，请补充基础服务价格或 SKU 兜底价')
    if (form.skus.some((x: any) => (x.commitments || []).some((rule: any) => !rule.ruleType || !rule.title))) return ElMessage.warning('请完整填写 SKU 承诺规则的类型和标题')
    saving.value = true
    try {
      const payload = { ...form, skus: form.skus.map(({ __key, ...sku }: any) => sku) }
      form.id ? await updateProduct(form.id, payload) : await createProduct(payload)
      ElMessage.success('保存成功')
      emit('saved')
    } finally {
      saving.value = false
    }
  }
  function unitName(value: UnitType) {
    return unitOptions.find((x) => x.value === value)?.label || '单位'
  }
  function money(value: unknown) {
    return Number(value || 0).toFixed(2)
  }
  function playerLevelName(id: number) {
    const level = playerLevels.value.find((x) => Number(x.id) === Number(id))
    return level?.levelName || level?.name || `等级 ${id}`
  }
  function skuLevelPricePreview(sku: any) {
    const count = Number(sku.unitCount || 0)
    return (selectedService.value?.levelPrices || [])
      .filter((x) => x.unitType === sku.unitType && x.enabled !== false && x.price != null)
      .map((x) => ({ ...x, totalPrice: Number(x.price) * count }))
  }
  onMounted(initialize)
</script>

<style scoped>
  .product-editor { padding-bottom: 76px; }
  .editor-header { position: sticky; top: 0; z-index: 8; }
  .sku-card:last-child { margin-bottom: 0; }
  .level-price-preview { padding: 14px 16px; border: 1px solid var(--el-border-color-light); border-radius: 6px; background: var(--el-fill-color-lighter); }
  .preview-title { margin-bottom: 10px; font-weight: 500; }
  .preview-title span { margin-left: 8px; color: var(--el-text-color-secondary); font-size: 12px; font-weight: 400; }
  .preview-list { display: flex; flex-wrap: wrap; gap: 10px; }
  .preview-item { min-width: 150px; padding: 9px 12px; border-radius: 5px; background: var(--el-bg-color); }
  .preview-item span, .preview-item small { display: block; color: var(--el-text-color-secondary); }
  .preview-item strong { display: block; margin: 3px 0; color: var(--el-color-danger); }
  .editor-footer { position: fixed; right: 24px; bottom: 20px; z-index: 20; padding: 12px 18px; border: 1px solid var(--el-border-color-light); border-radius: 8px; background: var(--el-bg-color); box-shadow: var(--el-box-shadow-light); }
</style>
