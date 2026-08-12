<template>
  <div class="art-full-height">
    <ElCard shadow="never" class="overview-card mb-4">
      <div class="overview">
        <div>
          <div class="eyebrow">MEMBERSHIP BENEFITS</div>
          <h2>会员等级</h2>
          <p>配置平台会员身份及累计充值门槛，会员身份不参与商品折扣。</p>
        </div>
        <ElButton
          v-auth="'business:member-level:create'"
          type="primary"
          size="large"
          @click="open()"
        >
          新增等级
        </ElButton>
      </div>
    </ElCard>

    <ElCard shadow="never" class="mb-4">
      <ElForm inline>
        <ElFormItem label="关键词">
          <ElInput v-model="query.keyword" clearable placeholder="会员编码或名称" />
        </ElFormItem>
        <ElFormItem label="状态">
          <ElSelect v-model="query.enabled" clearable class="!w-28">
            <ElOption label="启用" :value="true" />
            <ElOption label="停用" :value="false" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem>
          <ElButton @click="reset">重置</ElButton>
          <ElButton type="primary" @click="search">查询</ElButton>
        </ElFormItem>
      </ElForm>
    </ElCard>

    <ElCard shadow="never" class="art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load">
        <template #left>
          <div class="table-title">
            等级列表
            <span>共 {{ total }} 个</span>
          </div>
        </template>
      </ArtTableHeader>

      <ElAlert
        class="mb-4"
        type="info"
        :closable="false"
        title="会员等级仅代表身份，不参与商品折扣；用户累计充值本金达到门槛后自动升级。"
      />

      <ElTable v-loading="loading" :data="rows" row-key="id">
        <ElTableColumn prop="levelNo" label="等级序号" width="96" align="center" />
        <ElTableColumn prop="levelCode" label="会员编码" min-width="130" />
        <ElTableColumn label="会员名称" min-width="140">
          <template #default="{ row }">
            <ElTag effect="plain" :type="tagType(row.levelNo)">{{ row.levelName }}</ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn label="累计充值门槛" min-width="140" align="right">
          <template #default="{ row }">¥ {{ money(row.minRechargeAmount) }}</template>
        </ElTableColumn>
        <ElTableColumn prop="memberCount" label="已绑用户" width="100" align="center" />
        <ElTableColumn prop="benefitDescription" label="权益说明" min-width="260" show-overflow-tooltip />
        <ElTableColumn prop="sortNo" label="排序" width="80" align="center" />
        <ElTableColumn label="状态" width="100" align="center">
          <template #default="{ row }">
            <ElSwitch
              v-model="row.enabled"
              :disabled="!has('business:member-level:status')"
              @change="(value) => changeStatus(row, Boolean(value))"
            />
          </template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="100" fixed="right" align="center">
          <template #default="{ row }">
            <ArtButtonMore :list="actions" @click="(item) => action(String(item.key), row)" />
          </template>
        </ElTableColumn>
      </ElTable>

      <div class="pagination">
        <ElPagination
          v-model:current-page="query.current"
          v-model:page-size="query.size"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next"
          @change="load"
        />
      </div>
    </ElCard>

    <ElDialog
      v-model="visible"
      :title="form.id ? '编辑会员等级' : '新增会员等级'"
      width="620px"
      destroy-on-close
    >
      <ElForm label-width="100px">
        <ElFormItem label="会员编码" required>
          <ElInput
            v-model="form.levelCode"
            maxlength="32"
            placeholder="例如 SILVER"
            @input="normalizeCode"
          />
        </ElFormItem>
        <ElFormItem label="会员名称" required>
          <ElInput v-model.trim="form.levelName" maxlength="64" placeholder="例如 银卡会员" />
        </ElFormItem>
        <ElFormItem label="等级序号" required>
          <ElInputNumber v-model="form.levelNo" :min="0" :max="99" controls-position="right" />
        </ElFormItem>
        <ElFormItem label="累充门槛" required>
          <ElInputNumber
            v-model="form.minRechargeAmount"
            :min="0"
            :max="99999999"
            :precision="2"
            :step="100"
            controls-position="right"
            class="!w-full"
          />
          <div class="form-hint">仅累计实际充值本金，赠送金额和消费不会降低会员身份。</div>
        </ElFormItem>
        <ElFormItem label="权益说明">
          <ElInput
            v-model.trim="form.benefitDescription"
            type="textarea"
            :rows="3"
            maxlength="1000"
            show-word-limit
            placeholder="例如 专属客服、充值赠送、优先派单"
          />
        </ElFormItem>
        <ElFormItem label="排序">
          <ElInputNumber v-model="form.sortNo" :min="0" :max="9999" controls-position="right" />
        </ElFormItem>
        <ElFormItem label="立即启用">
          <ElSwitch v-model="form.enabled" />
        </ElFormItem>
      </ElForm>
      <template #footer>
        <ElButton @click="visible = false">取消</ElButton>
        <ElButton type="primary" :loading="saving" @click="save">保存等级</ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import {
    createMemberLevel,
    deleteMemberLevel,
    fetchMemberLevelList,
    setMemberLevelStatus,
    updateMemberLevel
  } from '@/api/business-manage'
  import { useUserStore } from '@/store/modules/user'

  const userStore = useUserStore()
  const has = (code: string) =>
    userStore.info.roles?.includes('admin') || userStore.info.buttons?.includes(code)

  const loading = ref(false)
  const saving = ref(false)
  const visible = ref(false)
  const rows = ref<any[]>([])
  const total = ref(0)
  const query = reactive<any>({ current: 1, size: 20, keyword: '', enabled: undefined })
  const form = reactive<any>(emptyForm())

  const actions = computed(() => [
    ...(has('business:member-level:update')
      ? [{ key: 'edit', label: '编辑', icon: 'ri:edit-line' }]
      : []),
    ...(has('business:member-level:delete')
      ? [{ key: 'delete', label: '删除', icon: 'ri:delete-bin-line', color: '#f56c6c' }]
      : [])
  ])

  function emptyForm() {
    return {
      id: null,
      levelCode: '',
      levelName: '',
      levelNo: 0,
      minRechargeAmount: 0,
      benefitDescription: '',
      sortNo: 0,
      enabled: true
    }
  }

  async function load() {
    loading.value = true
    try {
      const data = await fetchMemberLevelList(query)
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
    Object.assign(query, { current: 1, size: 20, keyword: '', enabled: undefined })
    load()
  }

  function open(row?: any) {
    Object.assign(form, emptyForm(), row || {})
    visible.value = true
  }

  function normalizeCode(value: string) {
    form.levelCode = value.toUpperCase().replace(/[^A-Z0-9_]/g, '')
  }

  async function save() {
    if (!form.levelCode || !form.levelName) return ElMessage.warning('请填写会员编码和会员名称')
    if (Number(form.levelNo) < 0) return ElMessage.warning('等级序号不能小于 0')
    if (Number(form.minRechargeAmount) < 0) return ElMessage.warning('累计充值门槛不能小于 0')

    const payload = {
      levelCode: form.levelCode.trim(),
      levelName: form.levelName.trim(),
      levelNo: Number(form.levelNo),
      minRechargeAmount: Number(form.minRechargeAmount),
      benefitDescription: form.benefitDescription?.trim() || '',
      sortNo: Number(form.sortNo || 0),
      enabled: Boolean(form.enabled)
    }

    saving.value = true
    try {
      if (form.id) await updateMemberLevel(form.id, payload)
      else await createMemberLevel(payload)
      visible.value = false
      ElMessage.success('会员等级已保存')
      await load()
    } finally {
      saving.value = false
    }
  }

  async function changeStatus(row: any, enabled: boolean) {
    try {
      await setMemberLevelStatus(row.id, enabled)
      ElMessage.success(enabled ? '会员等级已启用' : '会员等级已停用')
      await load()
    } catch {
      await load()
    }
  }

  async function action(key: string, row: any) {
    if (key === 'edit') return open(row)
    await ElMessageBox.confirm(
      `确定删除“${row.levelName}”吗？已授予用户的身份无法删除。`,
      '删除确认',
      { type: 'warning' }
    )
    await deleteMemberLevel(row.id)
    ElMessage.success('会员等级已删除')
    await load()
  }

  const money = (value: number) => Number(value || 0).toFixed(2)
  const tagType = (levelNo: number) =>
    ['info', 'success', 'warning', 'danger', 'primary'][Math.min(Number(levelNo || 0), 4)] as
      | 'info'
      | 'success'
      | 'warning'
      | 'danger'
      | 'primary'

  onMounted(load)
</script>

<style scoped>
  .overview-card {
    overflow: hidden;
    border: 0;
    background:
      radial-gradient(circle at 86% 18%, rgb(255 255 255 / 24%) 0 92px, transparent 93px),
      linear-gradient(120deg, #0d1734, #29104a 55%, #4b1674);
  }

  .overview {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
    min-height: 118px;
    padding: 8px 10px;
    color: #fff;
  }

  .eyebrow {
    margin-bottom: 6px;
    color: rgb(255 255 255 / 65%);
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.18em;
  }

  h2 {
    margin: 0;
    font-size: 26px;
  }

  .overview p {
    margin: 8px 0 0;
    color: rgb(255 255 255 / 78%);
  }

  .table-title {
    color: var(--art-text-gray-900);
    font-size: 16px;
    font-weight: 600;
  }

  .table-title span {
    margin-left: 8px;
    color: var(--art-text-gray-500);
    font-size: 12px;
    font-weight: 400;
  }

  .form-hint {
    margin-top: 5px;
    color: var(--art-text-gray-500);
    font-size: 12px;
    line-height: 1.5;
  }

  .pagination {
    display: flex;
    justify-content: flex-end;
    margin-top: 20px;
  }

  @media (width <= 680px) {
    .overview {
      align-items: flex-start;
      flex-direction: column;
    }
  }
</style>
