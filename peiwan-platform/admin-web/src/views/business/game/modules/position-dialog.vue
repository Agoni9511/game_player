<template>
  <ElDialog
    v-model="visible"
    :title="`${game?.gameName || ''} · 位置维护`"
    width="680px"
    @open="load"
    ><div class="flex justify-end mb-3"
      ><ElButton v-if="has('business:game-position:create')" @click="openEdit()"
        >新增位置</ElButton
      ></div
    ><ElTable v-loading="loading" :data="rows"
      ><ElTableColumn prop="positionCode" label="位置编码" /><ElTableColumn
        prop="positionName"
        label="位置名称"
      /><ElTableColumn prop="sortNo" label="排序" width="80" /><ElTableColumn
        label="状态"
        width="90"
        ><template #default="{ row }"
          ><ElTag :type="row.enabled ? 'success' : 'info'">{{
            row.enabled ? '启用' : '禁用'
          }}</ElTag></template
        ></ElTableColumn
      ><ElTableColumn label="操作" width="150"
        ><template #default="{ row }"
          ><ElButton
            v-if="has('business:game-position:update')"
            link
            type="primary"
            @click="openEdit(row)"
            >编辑</ElButton
          ><ElButton
            v-if="has('business:game-position:delete')"
            link
            type="danger"
            @click="remove(row)"
            >删除</ElButton
          ></template
        ></ElTableColumn
      ></ElTable
    ><ElDialog
      v-model="editor"
      append-to-body
      :title="form.id ? '编辑位置' : '新增位置'"
      width="440px"
      ><ElForm label-width="90px"
        ><ElFormItem label="位置编码" required
          ><ElInput v-model="form.positionCode"><template #append><ElButton @click="form.positionCode = generateBusinessCode('position')">重新生成</ElButton></template></ElInput></ElFormItem
        ><ElFormItem label="位置名称" required
          ><ElInput v-model="form.positionName" placeholder="如 打野" /></ElFormItem
        ><ElFormItem label="位置图标"><LocalFileUpload v-model="form.iconUrl" /></ElFormItem
        ><ElFormItem label="排序"><ElInputNumber v-model="form.sortNo" :min="0" /></ElFormItem
        ><ElFormItem label="启用"><ElSwitch v-model="form.enabled" /></ElFormItem></ElForm
      ><template #footer
        ><ElButton @click="editor = false">取消</ElButton
        ><ElButton type="primary" @click="save">保存</ElButton></template
      ></ElDialog
    ></ElDialog
  >
</template>
<script setup lang="ts">
  import {
    fetchGamePositions,
    createGamePosition,
    updateGamePosition,
    deleteGamePosition
  } from '@/api/business-manage'
  import { useUserStore } from '@/store/modules/user'
  import LocalFileUpload from '@/components/business/local-file-upload.vue'
  import { generateBusinessCode } from '@/utils/business-code'
  const props = defineProps<{ modelValue: boolean; game?: Api.Business.Game }>(),
    emit = defineEmits(['update:modelValue'])
  const visible = computed({
      get: () => props.modelValue,
      set: (v) => emit('update:modelValue', v)
    }),
    store = useUserStore(),
    has = (c: string) => store.info.roles?.includes('admin') || store.info.buttons?.includes(c),
    loading = ref(false),
    rows = ref<Api.Business.GamePosition[]>([]),
    editor = ref(false),
    form = reactive<any>({})
  async function load() {
    if (!props.game) return
    loading.value = true
    try {
      rows.value = await fetchGamePositions(props.game.id)
    } finally {
      loading.value = false
    }
  }
  function openEdit(r?: any) {
    Object.assign(
      form,
      r || { id: null, positionCode: generateBusinessCode('position'), positionName: '', iconUrl: '', sortNo: 0, enabled: true }
    )
    editor.value = true
  }
  async function save() {
    if (!form.positionCode || !form.positionName) return ElMessage.warning('请填写位置编码和名称')
    form.id
      ? await updateGamePosition(props.game!.id, form.id, form)
      : await createGamePosition(props.game!.id, form)
    editor.value = false
    ElMessage.success('保存成功')
    load()
  }
  async function remove(r: any) {
    await ElMessageBox.confirm(`确定删除位置“${r.positionName}”吗？`, '删除确认', {
      type: 'warning'
    })
    await deleteGamePosition(r.id)
    load()
  }
</script>
