<template>
  <div class="rule-page">
    <ElCard shadow="never" class="hero-card">
      <div class="hero">
        <div>
          <div class="eyebrow">SERVICE LIABILITY</div>
          <h2>服务责任规则</h2>
          <p>统一控制转单和炸单产生的责任扣款比例，保存后只影响后续产生的责任记录。</p>
        </div>
        <ElTag type="success" size="large" effect="dark">当前规则已启用</ElTag>
      </div>
    </ElCard>

    <div class="content-grid">
      <ElCard v-loading="loading" shadow="never" class="form-card">
        <template #header><div class="card-title"><strong>规则参数</strong><span>修改后无需重启服务</span></div></template>
        <ElForm ref="formRef" :model="form" :rules="rules" label-position="top">
          <ElRow :gutter="20">
            <ElCol :xs="24" :md="12">
              <ElFormItem label="转单责任比例" prop="transferRatePercent">
                <ElInputNumber v-model="form.transferRatePercent" :min="0" :max="99.99" :precision="2" class="!w-full" />
                <div class="field-help">转单成功后，转出成员按订单基础单价承担责任，默认 16%。</div>
              </ElFormItem>
            </ElCol>
            <ElCol :xs="24" :md="12">
              <ElFormItem label="炸单责任比例" prop="abortRatePercent">
                <ElInputNumber v-model="form.abortRatePercent" :min="0" :max="99.99" :precision="2" class="!w-full" />
                <div class="field-help">炸单审核通过后，每位最终在役成员按订单基础单价承担责任，默认 20%。</div>
              </ElFormItem>
            </ElCol>
          </ElRow>
          <ElAlert title="计算口径" type="info" :closable="false" show-icon description="责任金额 = 订单基础单价 × 对应比例；炸单还会执行用户退款，责任比例只影响陪玩师责任扣款和平台责任流水。" />
          <ElDivider />
          <div class="actions">
            <span v-if="updatedAt">最近更新：{{ formatDateTime(updatedAt) }}</span>
            <ElButton @click="load">恢复当前配置</ElButton>
            <ElButton v-auth="'business:service-liability-rule:update'" type="primary" :loading="saving" @click="save">保存规则</ElButton>
          </div>
        </ElForm>
      </ElCard>

      <div class="side-column">
        <ElCard shadow="never" class="preview-card">
          <template #header><strong>当前策略预览</strong></template>
          <div class="preview-item"><span>转单扣款</span><b>{{ form.transferRatePercent.toFixed(2) }}%</b></div>
          <div class="preview-item"><span>炸单扣款</span><b>{{ form.abortRatePercent.toFixed(2) }}%</b></div>
          <div class="preview-item"><span>计算基础</span><b>订单基础单价</b></div>
        </ElCard>
        <ElAlert title="生效范围" type="warning" :closable="false" show-icon description="已经生成的责任记录不会重新计算；修改后新审核通过的转单或炸单申请使用新比例。" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import type { FormInstance, FormRules } from 'element-plus'
  import { fetchServiceLiabilityRule, updateServiceLiabilityRule } from '@/api/business-manage'
  import { formatDateTime } from '@/utils/date'

  const loading = ref(false), saving = ref(false), updatedAt = ref('')
  const formRef = ref<FormInstance>()
  const form = reactive({ transferRatePercent: 16, abortRatePercent: 20 })
  const rules: FormRules = {
    transferRatePercent: [{ required: true, message: '请设置转单责任比例', trigger: 'change' }],
    abortRatePercent: [{ required: true, message: '请设置炸单责任比例', trigger: 'change' }]
  }

  async function load() {
    loading.value = true
    try {
      const data = await fetchServiceLiabilityRule()
      Object.assign(form, { transferRatePercent: Number(data.transferRate) * 100, abortRatePercent: Number(data.abortRate) * 100 })
      updatedAt.value = data.updatedAt || '-'
    } finally { loading.value = false }
  }

  async function save() {
    await formRef.value?.validate()
    saving.value = true
    try {
      await updateServiceLiabilityRule({ transferRate: form.transferRatePercent / 100, abortRate: form.abortRatePercent / 100 })
      ElMessage.success('服务责任规则已更新')
      await load()
    } finally { saving.value = false }
  }

  onMounted(load)
</script>

<style scoped>
  .rule-page { min-height: 100%; padding-bottom: 20px; }
  .hero-card { margin-bottom: 18px; background: linear-gradient(135deg, #fff7f0, #fff 58%, #f3f8ff); }
  .hero { padding: 8px 4px; display: flex; align-items: center; justify-content: space-between; gap: 24px; }
  .hero h2 { margin: 5px 0 8px; font-size: 25px; }
  .hero p { margin: 0; color: var(--el-text-color-secondary); }
  .eyebrow { color: var(--el-color-primary); font-size: 11px; font-weight: 700; letter-spacing: 2px; }
  .content-grid { display: grid; grid-template-columns: minmax(0, 1fr) 330px; gap: 18px; }
  .card-title { display: flex; align-items: baseline; justify-content: space-between; }
  .card-title span { color: var(--el-text-color-secondary); font-size: 12px; }
  .field-help { width: 100%; margin-top: 6px; color: var(--el-text-color-secondary); font-size: 12px; line-height: 1.5; }
  .actions { display: flex; align-items: center; justify-content: flex-end; gap: 10px; }
  .actions > span { margin-right: auto; color: var(--el-text-color-secondary); font-size: 12px; }
  .side-column { display: flex; flex-direction: column; gap: 18px; }
  .preview-item { min-height: 50px; border-bottom: 1px solid var(--el-border-color-lighter); display: flex; align-items: center; justify-content: space-between; }
  .preview-item:last-child { border-bottom: 0; }
  .preview-item span { color: var(--el-text-color-secondary); }
  .preview-item b { color: var(--el-text-color-primary); }
  @media (max-width: 1000px) { .content-grid { grid-template-columns: 1fr; } }
</style>
