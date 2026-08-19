<template>
  <div class="art-full-height"
    ><ElCard class="art-table-card"
      ><ElAlert
        class="mb-4"
        type="info"
        :closable="false"
        title="商品分类用于前台按游戏模式或消费场景找商品；基础服务用于定义具体交付内容和等级价格。一个分类可包含多种基础服务。" />
      ><ArtTableHeader :loading="loading" @refresh="load"
        ><template #left
          ><ElButton v-auth="'business:product-category:create'" @click="open()"
            >新增根分类</ElButton
          ></template
        ></ArtTableHeader
      ><ElTable v-loading="loading" :data="rows" row-key="id" default-expand-all
        ><ElTableColumn prop="categoryName" label="分类名称" min-width="180" /><ElTableColumn
          prop="categoryCode"
          label="分类编码"
          min-width="160" /><ElTableColumn prop="gameName" label="所属游戏" min-width="140"
          ><template #default="{ row }">{{ row.gameName || '通用分类' }}</template></ElTableColumn
        ><ElTableColumn prop="sortNo" label="排序" width="80" /><ElTableColumn
          label="状态"
          width="90"
          ><template #default="{ row }"
            ><ElSwitch
              v-model="row.enabled"
              :disabled="!has('business:product-category:status')"
              @change="(v) => status(row, Boolean(v))" /></template></ElTableColumn
        ><ElTableColumn label="操作" width="80" fixed="right"
          ><template #default="{ row }"
            ><ArtButtonMore
              :list="actions"
              @click="(i) => action(i.key, row)" /></template></ElTableColumn></ElTable
      ><ElDialog v-model="visible" :title="form.id ? '编辑商品分类' : '新增商品分类'" width="520px"
        ><ElForm label-width="90px"
          ><ElFormItem label="所属游戏"
            ><ElSelect
              v-model="form.gameId"
              clearable
              class="w-full"
              @change="form.parentId = undefined"
              ><ElOption
                v-for="g in games"
                :key="g.id"
                :label="g.gameName"
                :value="g.id" /></ElSelect></ElFormItem
          ><ElFormItem label="父分类"
            ><ElTreeSelect
              v-model="form.parentId"
              :data="parentOptions"
              node-key="id"
              check-strictly
              clearable
              :props="{ label: 'categoryName', children: 'children' }"
              class="w-full" /></ElFormItem
          ><ElFormItem label="分类编码" required><ElInput v-model="form.categoryCode"><template #append><ElButton @click="form.categoryCode = generateBusinessCode('category')">重新生成</ElButton></template></ElInput></ElFormItem
          ><ElFormItem label="分类名称" required><ElInput v-model="form.categoryName" /></ElFormItem
          ><ElFormItem label="分类图标"><LocalFileUpload v-model="form.iconUrl" /></ElFormItem
          ><ElFormItem label="排序"><ElInputNumber v-model="form.sortNo" :min="0" /></ElFormItem
          ><ElFormItem label="启用"><ElSwitch v-model="form.enabled" /></ElFormItem></ElForm
        ><template #footer
          ><ElButton @click="visible = false">取消</ElButton
          ><ElButton type="primary" @click="save">保存</ElButton></template
        ></ElDialog
      ></ElCard
    ></div
  >
</template>
<script setup lang="ts">
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import {
    fetchProductCategories,
    createProductCategory,
    updateProductCategory,
    setProductCategoryStatus,
    deleteProductCategory,
    fetchGameOptions
  } from '@/api/business-manage'
  import { useUserStore } from '@/store/modules/user'
  import LocalFileUpload from '@/components/business/local-file-upload.vue'
  import { generateBusinessCode } from '@/utils/business-code'
  const store = useUserStore(),
    has = (c: string) => store.info.roles?.includes('admin') || store.info.buttons?.includes(c),
    loading = ref(false),
    rows = ref<Api.Business.ProductCategory[]>([]),
    games = ref<Api.Business.Game[]>([]),
    visible = ref(false),
    form = reactive<any>({})
  const actions = computed(() => [
      ...(has('business:product-category:create')
        ? [{ key: 'child', label: '新增子分类', icon: 'ri:add-line' }]
        : []),
      ...(has('business:product-category:update')
        ? [{ key: 'edit', label: '编辑', icon: 'ri:edit-line' }]
        : []),
      ...(has('business:product-category:delete')
        ? [{ key: 'delete', label: '删除', icon: 'ri:delete-bin-line', color: '#f56c6c' }]
        : [])
    ]),
    parentOptions = computed(() =>
      filterTree(rows.value, (n) => n.gameId === form.gameId && n.id !== form.id)
    )
  function filterTree(list: any[], fn: (x: any) => boolean): any[] {
    return list.filter(fn).map((x) => ({ ...x, children: filterTree(x.children || [], fn) }))
  }
  async function load() {
    loading.value = true
    try {
      ;[rows.value, games.value] = await Promise.all([fetchProductCategories(), fetchGameOptions()])
    } finally {
      loading.value = false
    }
  }
  function open(row?: any, parent?: any) {
    Object.assign(
      form,
      row
        ? { ...row, children: undefined }
        : {
            id: null,
            gameId: parent?.gameId,
            parentId: parent?.id,
            categoryCode: generateBusinessCode('category'),
            categoryName: '',
            iconUrl: '',
            sortNo: 0,
            enabled: true
          }
    )
    visible.value = true
  }
  async function save() {
    if (!form.categoryCode || !form.categoryName) return ElMessage.warning('请填写分类编码和名称')
    form.id ? await updateProductCategory(form.id, form) : await createProductCategory(form)
    visible.value = false
    load()
  }
  async function status(r: any, v: boolean) {
    try {
      await setProductCategoryStatus(r.id, v)
    } catch {
      load()
    }
  }
  async function action(k: any, r: any) {
    if (k === 'child') open(undefined, r)
    else if (k === 'edit') open(r)
    else {
      await ElMessageBox.confirm(`确定删除“${r.categoryName}”吗？`, '删除确认', { type: 'warning' })
      await deleteProductCategory(r.id)
      load()
    }
  }
  onMounted(load)
</script>
