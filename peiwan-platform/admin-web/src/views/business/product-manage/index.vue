<template>
  <div class="art-full-height">
    <ElCard class="mb-3"
      ><ElForm inline>
        <ElFormItem label="所属游戏"
          ><ElSelect
            v-model="query.gameId"
            clearable
            class="!w-40"
            @change="query.categoryId = undefined"
            ><ElOption v-for="g in games" :key="g.id" :label="g.gameName" :value="g.id" /></ElSelect
        ></ElFormItem>
        <ElFormItem label="商品分类"
          ><ElSelect v-model="query.categoryId" clearable class="!w-40"
            ><ElOption
              v-for="c in leafCategories(query.gameId)"
              :key="c.id"
              :label="c.categoryName"
              :value="c.id" /></ElSelect
        ></ElFormItem>
        <ElFormItem label="商品名称"><ElInput v-model="query.productName" clearable /></ElFormItem>
        <ElFormItem label="商品类型"><ElSelect v-model="query.productType" clearable class="!w-32"><ElOption label="单项服务" value="SERVICE"/><ElOption label="平台套餐" value="PACKAGE"/></ElSelect></ElFormItem>
        <ElFormItem label="状态"
          ><ElSelect v-model="query.status" clearable class="!w-32"
            ><ElOption label="草稿" value="DRAFT" /><ElOption
              label="已上架"
              value="ON_SALE" /><ElOption label="已下架" value="OFF_SHELF" /></ElSelect
        ></ElFormItem>
        <ElFormItem
          ><ElButton @click="reset">重置</ElButton
          ><ElButton type="primary" @click="search">查询</ElButton></ElFormItem
        >
      </ElForm></ElCard
    >
    <ElCard class="art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load"
        ><template #left
          ><ElButton v-auth="'business:product:create'" @click="open()"
            >新增商品</ElButton
          ></template
        ></ArtTableHeader
      >
      <ElTable v-loading="loading" :data="rows">
        <ElTableColumn prop="productCode" label="商品编码" min-width="180" /><ElTableColumn
          prop="productName"
          label="商品名称"
          min-width="180"
          show-overflow-tooltip
        /><ElTableColumn prop="gameName" label="游戏" min-width="120" /><ElTableColumn
          prop="categoryName"
          label="分类"
          min-width="120"
        />
        <ElTableColumn label="类型" width="95"><template #default="{row}"><ElTag :type="row.productType==='PACKAGE'?'warning':'info'">{{row.productType==='PACKAGE'?'平台套餐':'单项服务'}}</ElTag></template></ElTableColumn>
        <ElTableColumn label="起售价" width="110"
          ><template #default="{ row }"
            ><span v-if="row.minPrice != null" class="text-red-500"
              >¥ {{ Number(row.minPrice).toFixed(2) }}</span
            ><span v-else>-</span></template
          ></ElTableColumn
        >
        <ElTableColumn prop="skuCount" label="规格数" width="80" /><ElTableColumn
          label="状态"
          width="90"
          ><template #default="{ row }"
            ><ElTag :type="statusMeta[row.status].type">{{
              statusMeta[row.status].text
            }}</ElTag></template
          ></ElTableColumn
        ><ElTableColumn prop="sortNo" label="排序" width="70" />
        <ElTableColumn label="操作" width="80" fixed="right"
          ><template #default="{ row }"
            ><ArtButtonMore :list="actions(row)" @click="(i) => action(i.key, row)" /></template
        ></ElTableColumn>
      </ElTable>
      <div class="flex justify-end mt-4"
        ><ElPagination
          v-model:current-page="query.current"
          v-model:page-size="query.size"
          :total="total"
          layout="total, sizes, prev, pager, next"
          @change="load"
      /></div>
    </ElCard>

    <ElDialog
      v-model="visible"
      :title="form.id ? '编辑商品' : '新增商品'"
      width="920px"
      top="5vh"
      destroy-on-close
    >
      <ElForm label-width="90px">
        <ElRow :gutter="16"
          ><ElCol :span="12"
            ><ElFormItem label="所属游戏" required
              ><ElSelect v-model="form.gameId" class="w-full" @change="gameChanged"
                ><ElOption
                  v-for="g in games"
                  :key="g.id"
                  :label="g.gameName"
                  :value="g.id" /></ElSelect></ElFormItem></ElCol
          ><ElCol :span="12"
            ><ElFormItem label="商品分类" required
              ><ElSelect v-model="form.categoryId" class="w-full"
                ><ElOption
                  v-for="c in leafCategories(form.gameId)"
                  :key="c.id"
                  :label="c.categoryName"
                  :value="c.id" /></ElSelect></ElFormItem></ElCol
        ></ElRow>
        <ElRow :gutter="16"
          ><ElCol :span="12"
            ><ElFormItem label="商品编码" required
              ><ElInput v-model="form.productCode"><template #append><ElButton @click="form.productCode = generateBusinessCode('product')">重新生成</ElButton></template></ElInput></ElFormItem></ElCol
          ><ElCol :span="12"
            ><ElFormItem label="商品名称" required
              ><ElInput v-model="form.productName" /></ElFormItem></ElCol
        ></ElRow>
        <ElRow :gutter="16"><ElCol :span="8"><ElFormItem label="商品类型" required><ElSelect v-model="form.productType" class="w-full" @change="typeChanged"><ElOption label="单项服务" value="SERVICE"/><ElOption label="平台套餐" value="PACKAGE"/></ElSelect></ElFormItem></ElCol><ElCol :span="8"><ElFormItem label="有效天数"><ElInputNumber v-model="form.validityDays" :min="1" class="!w-full"/></ElFormItem></ElCol><ElCol :span="8"><ElFormItem label="每人限购"><ElInputNumber v-model="form.purchaseLimit" :min="1" class="!w-full"/></ElFormItem></ElCol></ElRow>
        <div class="flex items-center justify-between mb-3"><span class="font-medium">{{form.productType==='PACKAGE'?'套餐组成':'基础服务'}}</span><ElButton v-if="form.productType==='PACKAGE'||!form.components.length" plain @click="addComponent">添加服务</ElButton></div>
        <ElTable :data="form.components" border class="mb-4"><ElTableColumn label="基础服务" min-width="260"><template #default="{row}"><ElSelect v-model="row.serviceId" class="w-full"><ElOption v-for="s in availableServices" :key="s.id" :label="`${s.serviceName}（${s.serviceCode}）`" :value="s.id" :disabled="form.components.some((x:any)=>x!==row&&x.serviceId===s.id)"/></ElSelect></template></ElTableColumn><ElTableColumn label="服务数量" width="130"><template #default="{row}"><ElInputNumber v-model="row.quantity" :min="0.01" :precision="2" class="!w-full"/></template></ElTableColumn><ElTableColumn label="计量单位" width="130"><template #default="{row}"><ElSelect v-model="row.unitType"><ElOption label="小时" value="HOUR"/><ElOption label="局" value="GAME"/><ElOption label="单" value="ORDER"/></ElSelect></template></ElTableColumn><ElTableColumn label="操作" width="70"><template #default="{$index}"><ElButton link type="danger" @click="form.components.splice($index,1)">移除</ElButton></template></ElTableColumn></ElTable>
        <ElFormItem label="商品副标题"
          ><ElInput v-model="form.subtitle" maxlength="255" show-word-limit /></ElFormItem
        ><ElFormItem label="商品说明"
          ><ElInput v-model="form.description" type="textarea" :rows="3"
        /></ElFormItem>
        <ElRow :gutter="16"
          ><ElCol :span="18"
            ><ElFormItem label="商品封面"><LocalFileUpload v-model="form.coverUrl" /></ElFormItem></ElCol
          ><ElCol :span="6"
            ><ElFormItem label="排序"
              ><ElInputNumber v-model="form.sortNo" :min="0" /></ElFormItem></ElCol
        ></ElRow>
      </ElForm>
      <div class="flex items-center justify-between mb-3"
        ><span class="font-medium">销售规格（SKU）</span
        ><ElButton type="primary" plain @click="addSku">新增规格</ElButton></div
      >
      <ElTable ref="skuTable" :data="form.skus" border max-height="300">
        <ElTableColumn label="规格编码" width="205" fixed="left"
          ><template #default="{ row }"><div class="flex gap-1"><ElInput v-model="row.skuCode" /><ElTooltip content="重新生成编码"><ElButton class="!px-2" @click="row.skuCode = generateBusinessCode('sku')"><ArtSvgIcon icon="ri:refresh-line" /></ElButton></ElTooltip></div></template></ElTableColumn
        ><ElTableColumn label="规格名称" min-width="135"
          ><template #default="{ row }"><ElInput v-model="row.skuName" /></template
        ></ElTableColumn>
        <ElTableColumn label="售价" width="100"
          ><template #default="{ row }"
            ><ElInputNumber
              v-model="row.price"
              :min="0"
              :precision="2"
              :controls="false"
              class="!w-full" /></template></ElTableColumn
        ><ElTableColumn label="划线价" width="100"><template #default="{row}"><ElInputNumber v-model="row.marketPrice" :min="0" :precision="2" :controls="false" class="!w-full"/></template></ElTableColumn><ElTableColumn label="计价单位" width="105"
          ><template #default="{ row }"
            ><ElSelect v-model="row.unitType"
              ><ElOption label="小时" value="HOUR" /><ElOption label="局" value="GAME" /><ElOption
                label="单"
                value="ORDER" /></ElSelect></template
        ></ElTableColumn>
        <ElTableColumn label="单位数量" width="95"
          ><template #default="{ row }"
            ><ElInputNumber
              v-model="row.unitCount"
              :min="0.01"
              :precision="2"
              :controls="false"
              class="!w-full" /></template></ElTableColumn
        ><ElTableColumn label="最少购买" width="90"
          ><template #default="{ row }"
            ><ElInputNumber
              v-model="row.minQuantity"
              :min="1"
              :controls="false"
              class="!w-full" /></template
        ></ElTableColumn>
        <ElTableColumn label="服务分钟" width="90"
          ><template #default="{ row }"
            ><ElInputNumber
              v-model="row.serviceMinutes"
              :min="1"
              :controls="false"
              class="!w-full" /></template></ElTableColumn
        ><ElTableColumn label="启用" width="65"
          ><template #default="{ row }"><ElSwitch v-model="row.enabled" /></template></ElTableColumn
        ><ElTableColumn label="操作" width="65" fixed="right"
          ><template #default="{ $index }"
            ><ElTooltip content="删除规格"><ElButton link type="danger" @click="form.skus.splice($index, 1)"><ArtSvgIcon icon="ri:delete-bin-line" /></ElButton></ElTooltip></template
          ></ElTableColumn
        >
      </ElTable>
      <template #footer
        ><ElButton @click="visible = false">取消</ElButton
        ><ElButton type="primary" :loading="saving" @click="save">保存为草稿</ElButton></template
      >
    </ElDialog>
  </div>
</template>
<script setup lang="ts">
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import LocalFileUpload from '@/components/business/local-file-upload.vue'
  import {
    fetchProducts,
    fetchProduct,
    createProduct,
    updateProduct,
    setProductStatus,
    deleteProduct,
    fetchGameOptions,
    fetchProductCategories,
    fetchServices
  } from '@/api/business-manage'
  import { useUserStore } from '@/store/modules/user'
  import { generateBusinessCode } from '@/utils/business-code'
  const store = useUserStore(),
    has = (c: string) => store.info.roles?.includes('admin') || store.info.buttons?.includes(c)
  const loading = ref(false),
    saving = ref(false),
    skuTable = ref(),
    visible = ref(false),
    rows = ref<Api.Business.Product[]>([]),
    games = ref<Api.Business.Game[]>([]),
    categories = ref<Api.Business.ProductCategory[]>([]),
    services = ref<Api.Business.ServiceItem[]>([]),
    total = ref(0)
  const query = reactive<any>({
      current: 1,
      size: 20,
      gameId: undefined,
      categoryId: undefined,
      productName: '',
      status: '',
      productType: ''
    }),
    form = reactive<any>({})
  const statusMeta: any = {
    DRAFT: { text: '草稿', type: 'info' },
    ON_SALE: { text: '已上架', type: 'success' },
    OFF_SHELF: { text: '已下架', type: 'warning' }
  }
  const availableServices = computed(() =>
    services.value.filter((x) => x.gameId === form.gameId && x.enabled)
  )
  function flatten(list: any[], gameId?: number, out: any[] = []) {
    for (const x of list) {
      if ((!gameId || x.gameId === gameId) && (!x.children || !x.children.length)) out.push(x)
      flatten(x.children || [], gameId, out)
    }
    return out
  }
  const leafCategories = (gameId?: number) => flatten(categories.value, gameId, [])
  async function initOptions() {
    const [c, g, s] = await Promise.all([
      fetchProductCategories(),
      fetchGameOptions(),
      fetchServices({ current: 1, size: 200, enabled: true })
    ])
    categories.value = c
    games.value = g
    services.value = s.records
  }
  async function load() {
    loading.value = true
    try {
      const d = await fetchProducts(query)
      rows.value = d.records
      total.value = d.total
    } finally {
      loading.value = false
    }
  }
  function search() {
    query.current = 1
    load()
  }
  function reset() {
    Object.assign(query, {
      current: 1,
      gameId: undefined,
      categoryId: undefined,
      productName: '',
      status: '',
      productType: ''
    })
    load()
  }
  function blank() {
    return {
      id: null,
      gameId: games.value[0]?.id,
      categoryId: undefined,
      productCode: generateBusinessCode('product'),
      productName: '',
      subtitle: '',
      description: '',
      coverUrl: '',
      productType: 'SERVICE',
      sortNo: 0,
      validityDays: undefined,
      purchaseLimit: undefined,
      serviceIds: [],
      components: [],
      skus: []
    }
  }
  async function open(row?: Api.Business.Product) {
    Object.assign(form, blank())
    if (row) Object.assign(form, await fetchProduct(row.id))
    if (!form.components.length) addComponent()
    if (!form.skus.length) addSku()
    visible.value = true
    await nextTick()
    skuTable.value?.setScrollLeft?.(0)
  }
  function gameChanged() {
    form.categoryId = undefined
    form.serviceIds = []
    form.components = []
  }
  function typeChanged(){form.components=[];addComponent()}
  function addComponent(){if(form.productType==='SERVICE'&&form.components.length)return;form.components.push({serviceId:undefined,quantity:1,unitType:form.productType==='PACKAGE'?'HOUR':'ORDER',sortNo:form.components.length+1})}
  function addSku() {
    form.skus.push({
      skuCode: generateBusinessCode('sku'),
      skuName: '',
      price: 0,
      marketPrice: undefined,
      unitType: 'HOUR',
      unitCount: 1,
      minQuantity: 1,
      maxQuantity: undefined,
      stockMode: 'UNLIMITED',
      stockQuantity: undefined,
      serviceMinutes: 60,
      enabled: true,
      sortNo: form.skus.length
    })
  }
  async function save() {
    if (
      !form.gameId ||
      !form.categoryId ||
      !form.productCode ||
      !form.productName
    )
      return ElMessage.warning('请填写商品必填信息')
    const requiredComponents=form.productType==='PACKAGE'?2:1
    if(form.components.length<requiredComponents||form.components.some((x:any)=>!x.serviceId))return ElMessage.warning(form.productType==='PACKAGE'?'套餐至少添加两个基础服务':'请选择基础服务')
    if (!form.skus.length || form.skus.some((x: any) => !x.skuCode || !x.skuName))
      return ElMessage.warning('请完整填写销售规格')
    saving.value = true
    try {
      form.id ? await updateProduct(form.id, form) : await createProduct(form)
      visible.value = false
      await load()
      ElMessage.success('保存成功')
    } finally {
      saving.value = false
    }
  }
  function actions(row: any) {
    return [
      ...(has('business:product:update') && row.status !== 'ON_SALE'
        ? [{ key: 'edit', label: '编辑', icon: 'ri:edit-line' }]
        : []),
      ...(has('business:product:create')
        ? [{ key: 'copy', label: '复制商品', icon: 'ri:file-copy-line' }]
        : []),
      ...(has('business:product:status')
        ? [
            {
              key: row.status === 'ON_SALE' ? 'off' : 'on',
              label: row.status === 'ON_SALE' ? '下架' : '上架',
              icon:
                row.status === 'ON_SALE' ? 'ri:arrow-down-circle-line' : 'ri:arrow-up-circle-line'
            }
          ]
        : []),
      ...(has('business:product:delete') && row.status !== 'ON_SALE'
        ? [{ key: 'delete', label: '删除', icon: 'ri:delete-bin-line', color: '#f56c6c' }]
        : [])
    ]
  }
  async function action(key: string | number, row: any) {
    if (key === 'edit') return open(row)
    if (key === 'copy') {
      const source:any=await fetchProduct(row.id)
      Object.assign(form,source,{id:null,status:'DRAFT',productCode:generateBusinessCode('product'),productName:`${source.productName} 副本`,skus:(source.skus||[]).map((x:any)=>({...x,id:undefined,skuCode:generateBusinessCode('sku')}))})
      visible.value=true
      await nextTick();skuTable.value?.setScrollLeft?.(0)
      return
    }
    if (key === 'delete') {
      await ElMessageBox.confirm(`确定删除“${row.productName}”吗？`, '删除确认', {
        type: 'warning'
      })
      await deleteProduct(row.id)
    } else {
      const target = key === 'on' ? 'ON_SALE' : 'OFF_SHELF'
      await ElMessageBox.confirm(
        `确定${key === 'on' ? '上架' : '下架'}“${row.productName}”吗？`,
        '状态确认'
      )
      await setProductStatus(row.id, target)
    }
    await load()
  }
  onMounted(async () => {
    await initOptions()
    await load()
  })
</script>
