<template>
  <div class="art-full-height">
    <ElCard shadow="never" class="overview-card mb-4">
      <div class="overview">
        <div>
          <div class="eyebrow">WALLET BENEFITS</div>
          <h2>充值套餐</h2>
          <p>配置充值面额和赠送余额；充值本金计入累计充值金额并用于会员身份升级。</p>
        </div>
        <ElButton
          v-auth="'business:recharge-plan:create'"
          type="primary"
          size="large"
          @click="open()"
        >
          新增套餐
        </ElButton>
      </div>
    </ElCard>

    <ElCard shadow="never" class="art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load">
        <template #left>
          <div class="table-title">
            套餐列表
            <span>共 {{ total }} 个</span>
          </div>
        </template>
      </ArtTableHeader>

      <ElAlert
        class="mb-4"
        type="warning"
        :closable="false"
        title="当前充值为测试环境模拟入账；正式运营前需接入支付渠道和支付回调。"
      />

      <ElTable v-loading="loading" :data="rows" row-key="id">
        <ElTableColumn prop="planCode" label="套餐编码" min-width="130" />
        <ElTableColumn label="套餐名称" min-width="180">
          <template #default="{ row }">
            <div class="plan-name">{{ row.planName }}</div>
          </template>
        </ElTableColumn>
        <ElTableColumn label="充值金额" min-width="130" align="right">
          <template #default="{ row }">
            <strong class="amount">¥ {{ money(row.rechargeAmount) }}</strong>
          </template>
        </ElTableColumn>
        <ElTableColumn label="赠送金额" min-width="120" align="right">
          <template #default="{ row }">
            <span :class="{ bonus: Number(row.bonusAmount) > 0 }">
              {{ Number(row.bonusAmount) > 0 ? `+ ¥ ${money(row.bonusAmount)}` : '-' }}
            </span>
          </template>
        </ElTableColumn>
        <ElTableColumn label="到账合计" min-width="130" align="right">
          <template #default="{ row }">
            ¥ {{ money(Number(row.rechargeAmount) + Number(row.bonusAmount)) }}
          </template>
        </ElTableColumn>
        <ElTableColumn prop="sortNo" label="排序" width="80" align="center" />
        <ElTableColumn label="状态" width="100" align="center">
          <template #default="{ row }">
            <ElSwitch
              v-model="row.enabled"
              :disabled="!has('business:recharge-plan:status')"
              @change="(value) => changeStatus(row, Boolean(value))"
            />
          </template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="90" fixed="right" align="center">
          <template #default="{ row }">
            <ElButton
              v-if="has('business:recharge-plan:update')"
              link
              type="primary"
              @click="open(row)"
            >
              编辑
            </ElButton>
            <span v-else class="muted">-</span>
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
      :title="form.id ? '编辑充值套餐' : '新增充值套餐'"
      width="560px"
      destroy-on-close
    >
      <ElForm label-width="100px">
        <ElFormItem label="套餐编码" required>
          <ElInput
            v-model="form.planCode"
            maxlength="40"
            placeholder="例如 R500"
            @input="normalizeCode"
          >
            <template #append>
              <ElButton @click="form.planCode = generatePlanCode()">重新生成</ElButton>
            </template>
          </ElInput>
        </ElFormItem>
        <ElFormItem label="套餐名称" required>
          <ElInput v-model.trim="form.planName" maxlength="80" placeholder="例如 充值500元" />
        </ElFormItem>
        <ElFormItem label="充值金额" required>
          <ElInputNumber
            v-model="form.rechargeAmount"
            :min="0.01"
            :max="99999999"
            :precision="2"
            :step="100"
            controls-position="right"
            class="!w-full"
          />
        </ElFormItem>
        <ElFormItem label="赠送金额" required>
          <ElInputNumber
            v-model="form.bonusAmount"
            :min="0"
            :max="99999999"
            :precision="2"
            :step="10"
            controls-position="right"
            class="!w-full"
          />
        </ElFormItem>
        <ElFormItem label="到账合计">
          <div class="total-preview">
            ¥ {{ money(Number(form.rechargeAmount || 0) + Number(form.bonusAmount || 0)) }}
          </div>
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
        <ElButton type="primary" :loading="saving" @click="save">保存套餐</ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import {
    createRechargePlan,
    fetchRechargePlanList,
    setRechargePlanStatus,
    updateRechargePlan,
    type RechargePlan,
    type RechargePlanSave
  } from '@/api/recharge-plan'
  import { useUserStore } from '@/store/modules/user'

  interface RechargePlanForm extends RechargePlanSave {
    id?: number
  }

  const userStore = useUserStore()
  const has = (code: string) =>
    userStore.info.roles?.includes('admin') || userStore.info.buttons?.includes(code)

  const loading = ref(false)
  const saving = ref(false)
  const visible = ref(false)
  const rows = ref<RechargePlan[]>([])
  const total = ref(0)
  const query = reactive({ current: 1, size: 20 })
  const form = reactive<RechargePlanForm>(emptyForm())

  function emptyForm(): RechargePlanForm {
    return {
      planCode: generatePlanCode(),
      planName: '',
      rechargeAmount: 100,
      bonusAmount: 0,
      sortNo: 0,
      enabled: true
    }
  }

  async function load() {
    loading.value = true
    try {
      const data = await fetchRechargePlanList(query)
      rows.value = data.records
      total.value = data.total
    } finally {
      loading.value = false
    }
  }

  function open(row?: any) {
    Object.assign(form, emptyForm(), row || {})
    if (!row) delete form.id
    visible.value = true
  }

  function normalizeCode(value: string) {
    form.planCode = value.toUpperCase().replace(/[^A-Z0-9_-]/g, '')
  }

  function generatePlanCode() {
    const randomPart = Math.random().toString(36).slice(2, 6).toUpperCase()
    const timePart = Date.now().toString().slice(-4)
    return `R${timePart}${randomPart}`
  }

  async function save() {
    if (!form.planCode.trim() || !form.planName.trim()) {
      return ElMessage.warning('请填写套餐编码和套餐名称')
    }
    if (Number(form.rechargeAmount) <= 0 || Number(form.bonusAmount) < 0) {
      return ElMessage.warning('充值金额必须大于 0，赠送金额不能小于 0')
    }

    const payload: RechargePlanSave = {
      planCode: form.planCode.trim(),
      planName: form.planName.trim(),
      rechargeAmount: Number(form.rechargeAmount),
      bonusAmount: Number(form.bonusAmount),
      sortNo: Number(form.sortNo || 0),
      enabled: Boolean(form.enabled)
    }

    saving.value = true
    try {
      if (form.id) await updateRechargePlan(form.id, payload)
      else await createRechargePlan(payload)
      visible.value = false
      ElMessage.success('套餐已保存')
      await load()
    } finally {
      saving.value = false
    }
  }

  async function changeStatus(row: any, enabled: boolean) {
    try {
      await setRechargePlanStatus(row.id, enabled)
      ElMessage.success(enabled ? '套餐已启用' : '套餐已停用')
    } catch {
      await load()
    }
  }

  const money = (value: number) => Number(value || 0).toFixed(2)

  onMounted(load)
</script>

<style scoped>
  .overview-card {
    overflow: hidden;
    border: 0;
    background:
      radial-gradient(circle at 88% 20%, rgb(255 255 255 / 42%) 0 70px, transparent 71px),
      linear-gradient(120deg, #e8f1ec, #f7ecd4);
  }

  .overview {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
    min-height: 112px;
    padding: 8px 10px;
  }

  .eyebrow {
    margin-bottom: 6px;
    color: #6b7d73;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.18em;
  }

  h2 {
    margin: 0;
    color: #263b31;
    font-size: 25px;
  }

  .overview p {
    margin: 8px 0 0;
    color: #64746b;
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

  .plan-name {
    font-weight: 600;
  }

  .amount {
    color: #a04432;
  }

  .bonus {
    color: #25805f;
    font-weight: 600;
  }

  .muted,
  .form-hint {
    color: var(--art-text-gray-500);
  }

  .form-hint {
    margin-top: 5px;
    font-size: 12px;
    line-height: 1.5;
  }

  .total-preview {
    color: #a04432;
    font-size: 18px;
    font-weight: 700;
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
