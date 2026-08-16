<template>
  <ProductEditor
    v-if="editorAction"
    :key="route.fullPath"
    :product-id="editorProductId"
    :copy="editorAction === 'copy'"
    @cancel="leaveEditor"
    @saved="leaveEditor"
  />
  <div v-else class="art-full-height">
    <ElCard class="mb-3">
      <ElForm inline>
        <ElFormItem label="所属游戏"><ElSelect v-model="query.gameId" clearable class="!w-40" @change="query.categoryId = undefined"><ElOption v-for="g in games" :key="g.id" :label="g.gameName" :value="g.id" /></ElSelect></ElFormItem>
        <ElFormItem label="商品分类"><ElSelect v-model="query.categoryId" clearable class="!w-40"><ElOption v-for="c in leafCategories(query.gameId)" :key="c.id" :label="c.categoryName" :value="c.id" /></ElSelect></ElFormItem>
        <ElFormItem label="商品名称"><ElInput v-model="query.productName" clearable /></ElFormItem>
        <ElFormItem label="商品类型"><ElSelect v-model="query.productType" clearable class="!w-32"><ElOption label="单项服务" value="SERVICE" /><ElOption label="平台套餐" value="PACKAGE" /></ElSelect></ElFormItem>
        <ElFormItem label="状态"><ElSelect v-model="query.status" clearable class="!w-32"><ElOption label="草稿" value="DRAFT" /><ElOption label="已上架" value="ON_SALE" /><ElOption label="已下架" value="OFF_SHELF" /></ElSelect></ElFormItem>
        <ElFormItem><ElButton @click="reset">重置</ElButton><ElButton type="primary" @click="search">查询</ElButton></ElFormItem>
      </ElForm>
    </ElCard>
    <ElCard class="art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load"><template #left><ElButton v-auth="'business:product:create'" type="primary" @click="openEditor('create')">新增商品</ElButton></template></ArtTableHeader>
      <ElTable v-loading="loading" :data="rows">
        <ElTableColumn prop="productCode" label="商品编码" min-width="180" />
        <ElTableColumn prop="productName" label="商品名称" min-width="180" show-overflow-tooltip />
        <ElTableColumn prop="gameName" label="游戏" min-width="120" />
        <ElTableColumn prop="categoryName" label="分类" min-width="120" />
        <ElTableColumn label="类型" width="95"><template #default="{ row }"><ElTag :type="row.productType === 'PACKAGE' ? 'warning' : 'info'">{{ row.productType === 'PACKAGE' ? '平台套餐' : '单项服务' }}</ElTag></template></ElTableColumn>
        <ElTableColumn label="起售价" width="110"><template #default="{ row }"><span v-if="row.minPrice != null" class="text-red-500">¥ {{ Number(row.minPrice).toFixed(2) }}</span><span v-else>-</span></template></ElTableColumn>
        <ElTableColumn label="SKU规格" width="120"><template #default="{ row }"><ElButton link type="primary" @click="openSku(row)">{{ row.skuCount || 0 }} 个 · 查看</ElButton></template></ElTableColumn>
        <ElTableColumn label="状态" width="90"><template #default="{ row }"><ElTag :type="statusMeta[row.status]?.type">{{ statusMeta[row.status]?.text || row.status }}</ElTag></template></ElTableColumn>
        <ElTableColumn prop="sortNo" label="排序" width="70" />
        <ElTableColumn label="操作" width="80" fixed="right"><template #default="{ row }"><ArtButtonMore :list="actions(row)" @click="(item) => action(item.key, row)" /></template></ElTableColumn>
      </ElTable>
      <div class="flex justify-end mt-4"><ElPagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total" layout="total, sizes, prev, pager, next" @change="load" /></div>
    </ElCard>

    <ElDialog v-model="skuVisible" :title="`${skuProduct.productName || '商品'} · SKU明细`" width="980px">
      <ElTable :data="skuProduct.skus || []" border max-height="520">
        <ElTableColumn prop="skuCode" label="SKU编码" min-width="180" />
        <ElTableColumn prop="skuName" label="规格名称" min-width="150" />
        <ElTableColumn label="服务规格" width="120"><template #default="{ row }">{{ row.unitCount }} {{ unitText[row.unitType] || row.unitType }}</template></ElTableColumn>
        <ElTableColumn label="陪玩人数" width="90"><template #default="{ row }">{{ row.playerCount || 1 }} 人</template></ElTableColumn>
        <ElTableColumn label="计价方式" width="100"><template #default="{ row }"><ElTag :type="row.priceType === 'FIXED_TOTAL' ? 'warning' : 'info'">{{ row.priceType === 'FIXED_TOTAL' ? '整单总价' : '每人单价' }}</ElTag></template></ElTableColumn>
        <ElTableColumn label="基础价格" width="100"><template #default="{ row }">¥ {{ Number(row.price || 0).toFixed(2) }}</template></ElTableColumn>
        <ElTableColumn label="价格来源" min-width="170"><template #default="{ row }">{{ skuProduct.productType === 'SERVICE' ? '基础服务等级单价' : 'SKU 固定总价' }}<span v-if="skuProduct.productType === 'SERVICE'" class="text-gray-400">（缺失时用兜底价）</span></template></ElTableColumn>
        <ElTableColumn label="承诺规则" width="95"><template #default="{ row }">{{ row.commitments?.length || 0 }} 条</template></ElTableColumn>
        <ElTableColumn label="状态" width="75"><template #default="{ row }"><ElTag :type="row.enabled ? 'success' : 'info'">{{ row.enabled ? '启用' : '停用' }}</ElTag></template></ElTableColumn>
      </ElTable>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import ProductEditor from './editor.vue'
  import { deleteProduct, fetchGameOptions, fetchProduct, fetchProductCategories, fetchProducts, setProductStatus } from '@/api/business-manage'
  import { useUserStore } from '@/store/modules/user'

  const route = useRoute()
  const router = useRouter()
  const store = useUserStore()
  const has = (code: string) => store.info.roles?.includes('admin') || store.info.buttons?.includes(code)
  const editorAction = computed(() => {
    const action = String(route.query.productAction || '')
    return ['create', 'edit', 'copy'].includes(action) ? action : ''
  })
  const editorProductId = computed(() => {
    const id = Number(route.query.id)
    return Number.isFinite(id) && id > 0 ? id : undefined
  })
  const loading = ref(false)
  const skuVisible = ref(false)
  const skuProduct = ref<any>({})
  const rows = ref<Api.Business.Product[]>([])
  const games = ref<Api.Business.Game[]>([])
  const categories = ref<Api.Business.ProductCategory[]>([])
  const total = ref(0)
  const query = reactive<any>({ current: 1, size: 20, gameId: undefined, categoryId: undefined, productName: '', status: '', productType: '' })
  const statusMeta: any = { DRAFT: { text: '草稿', type: 'info' }, ON_SALE: { text: '已上架', type: 'success' }, OFF_SHELF: { text: '已下架', type: 'warning' } }
  const unitText: any = { HOUR: '小时', GAME: '局', ORDER: '单' }

  function flatten(list: any[], gameId?: number, out: any[] = []) {
    for (const item of list) {
      if ((!gameId || item.gameId === gameId) && (!item.children || !item.children.length)) out.push(item)
      flatten(item.children || [], gameId, out)
    }
    return out
  }
  const leafCategories = (gameId?: number) => flatten(categories.value, gameId, [])
  async function initOptions() {
    const [categoryList, gameList] = await Promise.all([fetchProductCategories(), fetchGameOptions()])
    categories.value = categoryList
    games.value = gameList
  }
  async function load() {
    loading.value = true
    try {
      const data = await fetchProducts(query)
      rows.value = data.records
      total.value = data.total
    } finally {
      loading.value = false
    }
  }
  function search() { query.current = 1; load() }
  function reset() { Object.assign(query, { current: 1, gameId: undefined, categoryId: undefined, productName: '', status: '', productType: '' }); load() }
  function openEditor(productAction: 'create' | 'edit' | 'copy', row?: Api.Business.Product) {
    router.push({ path: route.path, query: { productAction, ...(row?.id ? { id: row.id } : {}) } })
  }
  async function leaveEditor() {
    await router.push({ path: route.path })
  }
  async function openSku(row: any) { skuProduct.value = await fetchProduct(row.id); skuVisible.value = true }
  function actions(row: any) {
    return [
      ...(has('business:product:update') && row.status !== 'ON_SALE' ? [{ key: 'edit', label: '编辑', icon: 'ri:edit-line' }] : []),
      ...(has('business:product:create') ? [{ key: 'copy', label: '复制商品', icon: 'ri:file-copy-line' }] : []),
      ...(has('business:product:status') ? [{ key: row.status === 'ON_SALE' ? 'off' : 'on', label: row.status === 'ON_SALE' ? '下架' : '上架', icon: row.status === 'ON_SALE' ? 'ri:arrow-down-circle-line' : 'ri:arrow-up-circle-line' }] : []),
      ...(has('business:product:delete') && row.status !== 'ON_SALE' ? [{ key: 'delete', label: '删除', icon: 'ri:delete-bin-line', color: '#f56c6c' }] : [])
    ]
  }
  async function action(key: string | number, row: any) {
    if (key === 'edit' || key === 'copy') return openEditor(key, row)
    if (key === 'delete') {
      await ElMessageBox.confirm(`确定删除“${row.productName}”吗？`, '删除确认', { type: 'warning' })
      await deleteProduct(row.id)
    } else {
      await ElMessageBox.confirm(`确定${key === 'on' ? '上架' : '下架'}“${row.productName}”吗？`, '状态确认')
      await setProductStatus(row.id, key === 'on' ? 'ON_SALE' : 'OFF_SHELF')
    }
    await load()
  }
  watch(editorAction, (next, previous) => { if (!next && previous) load() })
  onMounted(async () => { await initOptions(); if (!editorAction.value) await load() })
</script>
