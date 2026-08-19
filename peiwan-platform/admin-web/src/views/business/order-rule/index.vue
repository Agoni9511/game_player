<template>
  <div class="rule-page">
    <ElCard shadow="never" class="hero-card">
      <div class="hero">
        <div>
          <div class="eyebrow">ORDER CONFIRMATION</div>
          <h2>订单确认规则</h2>
          <p>控制履约凭证审核通过后，用户确认订单的等待时限和超时处理方式。</p>
        </div>
        <ElTag type="success" size="large" effect="dark">当前规则已启用</ElTag>
      </div>
    </ElCard>

    <div class="content-grid">
      <ElCard v-loading="loading" shadow="never" class="form-card">
        <template #header><div class="card-title"><strong>规则参数</strong><span>修改后无需重启服务</span></div></template>
        <ElForm ref="formRef" :model="form" :rules="rules" label-position="top">
          <ElFormItem label="用户确认时限" prop="customerConfirmHours">
            <ElInputNumber v-model="form.customerConfirmHours" :min="1" :max="720" :precision="0" class="!w-full" />
            <div class="field-help">履约凭证审核全部通过后，用户可在此时间内确认服务完成，单位：小时。</div>
          </ElFormItem>
          <ElFormItem label="确认超时后自动完成订单">
            <div class="switch-line"><ElSwitch v-model="form.autoCompleteEnabled" /><span>{{ form.autoCompleteEnabled ? '开启，超时后系统自动完成订单' : '关闭，超时后保留待确认状态' }}</span></div>
            <div class="field-help">关闭后不会自动结算完成，需由业务人员按实际情况处理。</div>
          </ElFormItem>
          <ElDivider />
          <div class="actions">
            <span v-if="updatedAt">最近更新：{{ formatDateTime(updatedAt) }}</span>
            <ElButton @click="load">恢复当前配置</ElButton>
            <ElButton v-auth="'business:order-rule:update'" type="primary" :loading="saving" @click="save">保存规则</ElButton>
          </div>
        </ElForm>
      </ElCard>

      <div class="side-column">
        <ElCard shadow="never" class="preview-card">
          <template #header><strong>当前策略预览</strong></template>
          <div class="preview-item"><span>用户确认窗口</span><b>{{ form.customerConfirmHours || 0 }} 小时</b></div>
          <div class="preview-item"><span>确认超时处理</span><b>{{ form.autoCompleteEnabled ? '自动完成' : '人工处理' }}</b></div>
        </ElCard>
        <ElAlert title="生效范围" type="warning" :closable="false" show-icon description="规则只影响保存后进入用户确认阶段的订单；已经生成确认截止时间的订单不会被追溯修改。" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import type { FormInstance, FormRules } from 'element-plus'
  import { fetchOrderRule, updateOrderRule } from '@/api/business-manage'
  import { formatDateTime } from '@/utils/date'

  const loading = ref(false), saving = ref(false), updatedAt = ref('')
  const formRef = ref<FormInstance>()
  const form = reactive({ customerConfirmHours: 24, autoCompleteEnabled: true })
  const rules: FormRules = {
    customerConfirmHours: [{ required: true, message: '请设置用户确认时限', trigger: 'change' }]
  }

  async function load() {
    loading.value = true
    try {
      const data = await fetchOrderRule()
      Object.assign(form, { customerConfirmHours: Number(data.customerConfirmHours), autoCompleteEnabled: Boolean(data.autoCompleteEnabled) })
      updatedAt.value = data.updatedAt || '-'
    } finally { loading.value = false }
  }

  async function save() {
    await formRef.value?.validate()
    saving.value = true
    try { await updateOrderRule({ ...form }); ElMessage.success('订单确认规则已更新'); await load() }
    finally { saving.value = false }
  }

  onMounted(load)
</script>

<style scoped>
  .rule-page { min-height: 100%; padding-bottom: 20px; }
  .hero-card { margin-bottom: 18px; background: linear-gradient(135deg, #f3f8ff, #fff 58%, #eef8f4); }
  .hero { padding: 8px 4px; display: flex; align-items: center; justify-content: space-between; gap: 24px; }
  .hero h2 { margin: 5px 0 8px; font-size: 25px; }
  .hero p { margin: 0; color: var(--el-text-color-secondary); }
  .eyebrow { color: var(--el-color-primary); font-size: 11px; font-weight: 700; letter-spacing: 2px; }
  .content-grid { display: grid; grid-template-columns: minmax(0, 1fr) 330px; gap: 18px; }
  .card-title { display: flex; align-items: baseline; justify-content: space-between; }
  .card-title span { color: var(--el-text-color-secondary); font-size: 12px; }
  .field-help { width: 100%; margin-top: 6px; color: var(--el-text-color-secondary); font-size: 12px; line-height: 1.5; }
  .switch-line { min-height: 32px; display: flex; align-items: center; gap: 12px; color: var(--el-text-color-regular); }
  .actions { display: flex; align-items: center; justify-content: flex-end; gap: 10px; }
  .actions > span { margin-right: auto; color: var(--el-text-color-secondary); font-size: 12px; }
  .side-column { display: flex; flex-direction: column; gap: 18px; }
  .preview-item { min-height: 50px; border-bottom: 1px solid var(--el-border-color-lighter); display: flex; align-items: center; justify-content: space-between; }
  .preview-item:last-child { border-bottom: 0; }
  .preview-item span { color: var(--el-text-color-secondary); }
  .preview-item b { color: var(--el-text-color-primary); }
  @media (max-width: 1000px) { .content-grid { grid-template-columns: 1fr; } }
</style>
