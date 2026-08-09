<template>
  <div class="art-full-height">
    <ElCard class="mb-3">
      <ElForm inline>
        <ElFormItem label="标签名称"><ElInput v-model="query.tagName" clearable /></ElFormItem>
        <ElFormItem
          ><ElButton @click="reset">重置</ElButton
          ><ElButton type="primary" @click="search">查询</ElButton></ElFormItem
        >
      </ElForm>
    </ElCard>
    <ElCard class="art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load"
        ><template #left
          ><ElButton v-auth="'business:player-tag:create'" @click="open()"
            >新增标签</ElButton
          ></template
        ></ArtTableHeader
      >
      <ElTable v-loading="loading" :data="rows">
        <ElTableColumn prop="tagCode" label="标签编码" />
        <ElTableColumn label="标签名称"
          ><template #default="{ row }"
            ><ElTag effect="plain" :style="tagStyle(row.tagColor)">{{
              row.tagName
            }}</ElTag></template
          ></ElTableColumn
        >
        <ElTableColumn prop="tagGroup" label="分组" />
        <ElTableColumn prop="sortNo" label="排序" width="80" />
        <ElTableColumn label="状态" width="90"
          ><template #default="{ row }"
            ><ElTag :type="row.enabled ? 'success' : 'info'">{{
              row.enabled ? '启用' : '禁用'
            }}</ElTag></template
          ></ElTableColumn
        >
        <ElTableColumn label="操作" width="80"
          ><template #default="{ row }"
            ><ArtButtonMore :list="actions" @click="(i) => action(i.key, row)" /></template
        ></ElTableColumn>
      </ElTable>
      <div class="flex justify-end mt-4"
        ><ElPagination
          v-model:current-page="query.current"
          v-model:page-size="query.size"
          :total="total"
          @change="load"
          layout="total, sizes, prev, pager, next"
      /></div>
    </ElCard>
    <ElDialog v-model="visible" :title="editing.id ? '编辑标签' : '新增标签'" width="480px">
      <ElForm label-width="90px">
        <ElFormItem label="标签编码" required><ElInput v-model="editing.tagCode"><template #append><ElButton @click="editing.tagCode = generateBusinessCode('tag')">重新生成</ElButton></template></ElInput></ElFormItem>
        <ElFormItem label="标签名称" required><ElInput v-model="editing.tagName" /></ElFormItem>
        <ElFormItem label="标签分组"
          ><ElSelect v-model="editing.tagGroup" class="w-full"
            ><ElOption label="服务风格" value="STYLE" /><ElOption
              label="技术特点"
              value="SKILL" /><ElOption label="声音特点" value="VOICE" /><ElOption
              label="在线时段"
              value="TIME" /><ElOption label="其他" value="OTHER" /></ElSelect
        ></ElFormItem>
        <ElFormItem label="标签颜色"
          ><div class="flex items-center gap-3"
            ><ElColorPicker v-model="editing.tagColor" /><ElTag
              effect="plain"
              :style="tagStyle(editing.tagColor)"
              >{{ editing.tagName || '标签预览' }}</ElTag
            ></div
          ></ElFormItem
        >
        <ElFormItem label="排序"><ElInputNumber v-model="editing.sortNo" /></ElFormItem>
        <ElFormItem label="启用"><ElSwitch v-model="editing.enabled" /></ElFormItem>
      </ElForm>
      <template #footer
        ><ElButton @click="visible = false">取消</ElButton
        ><ElButton type="primary" @click="save">保存</ElButton></template
      >
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { fetchTags, createTag, updateTag, deleteTag } from '@/api/business-manage'
  import { useUserStore } from '@/store/modules/user'
  import { generateBusinessCode } from '@/utils/business-code'
  const store = useUserStore()
  const has = (code: string) =>
    store.info.roles?.includes('admin') || store.info.buttons?.includes(code)
  const loading = ref(false),
    rows = ref<Api.Business.PlayerTag[]>([]),
    total = ref(0),
    visible = ref(false)
  const query = reactive({ current: 1, size: 20, tagName: '' })
  const editing = reactive<any>({})
  const actions = computed(() => [
    ...(has('business:player-tag:update')
      ? [{ key: 'edit', label: '编辑', icon: 'ri:edit-line' }]
      : []),
    ...(has('business:player-tag:delete')
      ? [{ key: 'delete', label: '删除', icon: 'ri:delete-bin-line', color: '#f56c6c' }]
      : [])
  ])
  function tagStyle(color?: string) {
    const value = /^#[0-9a-fA-F]{6}$/.test(color || '') ? color! : '#909399'
    return { color: value, borderColor: `${value}99`, backgroundColor: `${value}18` }
  }
  async function load() {
    loading.value = true
    try {
      const data = await fetchTags(query)
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
    query.tagName = ''
    search()
  }
  function open(row?: any) {
    Object.assign(
      editing,
      row || {
        id: null,
        tagCode: generateBusinessCode('tag'),
        tagName: '',
        tagColor: '#409EFF',
        tagGroup: 'OTHER',
        sortNo: 0,
        enabled: true
      }
    )
    visible.value = true
  }
  async function save() {
    if (!editing.tagCode || !editing.tagName) return ElMessage.warning('请填写标签编码和名称')
    editing.id ? await updateTag(editing.id, editing) : await createTag(editing)
    visible.value = false
    ElMessage.success('保存成功')
    load()
  }
  async function action(key: any, row: any) {
    if (key === 'edit') open(row)
    else {
      await ElMessageBox.confirm(`确定删除“${row.tagName}”吗？`, '删除确认', { type: 'warning' })
      await deleteTag(row.id)
      load()
    }
  }
  onMounted(load)
</script>
