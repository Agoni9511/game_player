<template>
  <div class="rule-page">
    <ElCard shadow="never" class="hero-card">
      <div class="hero">
        <div>
          <div class="eyebrow">DISPATCH STRATEGY</div>
          <h2>派单规则</h2>
          <p>统一控制候选人筛选、响应时限和陪玩师接单容量，保存后对新发起和重试的派单立即生效。</p>
        </div>
        <ElTag type="success" size="large" effect="dark">当前规则已启用</ElTag>
      </div>
    </ElCard>

    <div class="content-grid">
      <ElCard v-loading="loading" shadow="never" class="form-card">
        <template #header><div class="card-title"><strong>规则参数</strong><span>修改后无需重启服务</span></div></template>
        <ElForm ref="formRef" :model="form" :rules="rules" label-position="top">
          <ElFormItem label="规则名称" prop="ruleName">
            <ElInput v-model.trim="form.ruleName" maxlength="64" show-word-limit placeholder="例如：平台默认派单规则" />
          </ElFormItem>
          <ElRow :gutter="20">
            <ElCol :xs="24" :md="12">
              <ElFormItem label="接单响应时限" prop="grabMinutes">
                <ElInputNumber v-model="form.grabMinutes" :min="1" :max="1440" :precision="0" class="!w-full" />
                <div class="field-help">候选陪玩师需要在此时间内接受或拒绝，单位：分钟。</div>
              </ElFormItem>
            </ElCol>
            <ElCol :xs="24" :md="12">
              <ElFormItem label="单次最大候选人数" prop="maxCandidates">
                <ElInputNumber v-model="form.maxCandidates" :min="1" :max="100" :precision="0" class="!w-full" />
                <div class="field-help">每轮公开抢单最多推送给多少名符合条件的陪玩师。</div>
              </ElFormItem>
            </ElCol>
            <ElCol :xs="24" :md="12">
              <ElFormItem label="平台同时接单上限" prop="maxActiveOrders">
                <ElInputNumber v-model="form.maxActiveOrders" :min="1" :max="20" :precision="0" class="!w-full" />
                <div class="field-help">实际容量取“平台上限”和陪玩师个人上限中的较小值。</div>
              </ElFormItem>
            </ElCol>
            <ElCol :xs="24" :md="12">
              <ElFormItem label="允许忙碌陪玩师进入候选">
                <div class="switch-line"><ElSwitch v-model="form.allowBusy" /><span>{{ form.allowBusy ? '允许，仍会校验接单容量' : '不允许，仅匹配可接单状态' }}</span></div>
              </ElFormItem>
            </ElCol>
          </ElRow>
          <ElFormItem label="派单失败后自动再次发布">
            <div class="switch-line"><ElSwitch v-model="form.allowReofferAfterReject" /><span>{{ form.allowReofferAfterReject ? '允许自动重新派单' : '停止自动重试，需后台手动发起' }}</span></div>
            <div class="field-help">适用于公开抢单被全部拒绝、超时、部分接单后仍缺人或后台取消的情况。</div>
          </ElFormItem>
          <ElDivider />
          <div class="actions">
            <span v-if="updatedAt">最近更新：{{ formatDateTime(updatedAt) }}</span>
            <ElButton @click="load">恢复当前配置</ElButton>
            <ElButton v-auth="'business:dispatch-rule:update'" type="primary" :loading="saving" @click="save">保存规则</ElButton>
          </div>
        </ElForm>
      </ElCard>

      <div class="side-column">
        <ElCard shadow="never" class="preview-card">
          <template #header><strong>当前策略预览</strong></template>
          <div class="preview-item"><span>响应窗口</span><b>{{ form.grabMinutes || 0 }} 分钟</b></div>
          <div class="preview-item"><span>每轮推送</span><b>最多 {{ form.maxCandidates || 0 }} 人</b></div>
          <div class="preview-item"><span>同时接单</span><b>最多 {{ form.maxActiveOrders || 0 }} 单</b></div>
          <div class="preview-item"><span>忙碌候选</span><b>{{ form.allowBusy ? '允许' : '排除' }}</b></div>
          <div class="preview-item"><span>失败重试</span><b>{{ form.allowReofferAfterReject ? '自动重试' : '人工处理' }}</b></div>
        </ElCard>
        <ElAlert title="影响范围" type="warning" :closable="false" show-icon description="规则只影响保存后新发起或后续重试的派单；已经创建的派单任务，其截止时间和候选名单不会被追溯修改。" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import type { FormInstance, FormRules } from 'element-plus'
  import { fetchDispatchRule, updateDispatchRule } from '@/api/business-manage'
  import { formatDateTime } from '@/utils/date'

  const loading = ref(false), saving = ref(false), updatedAt = ref('')
  const formRef = ref<FormInstance>()
  const form = reactive({ ruleName: '', grabMinutes: 10, maxCandidates: 10, allowBusy: false, maxActiveOrders: 3, allowReofferAfterReject: false })
  const rules: FormRules = {
    ruleName: [{ required: true, message: '请填写规则名称', trigger: 'blur' }],
    grabMinutes: [{ required: true, message: '请设置接单时限', trigger: 'change' }],
    maxCandidates: [{ required: true, message: '请设置候选人数', trigger: 'change' }],
    maxActiveOrders: [{ required: true, message: '请设置同时接单上限', trigger: 'change' }]
  }

  async function load() {
    loading.value = true
    try {
      const data = await fetchDispatchRule()
      Object.assign(form, { ruleName: data.ruleName, grabMinutes: Number(data.grabMinutes), maxCandidates: Number(data.maxCandidates), allowBusy: Boolean(data.allowBusy), maxActiveOrders: Number(data.maxActiveOrders), allowReofferAfterReject: Boolean(data.allowReofferAfterReject) })
      updatedAt.value = data.updatedAt || '-'
    } finally { loading.value = false }
  }
  async function save() {
    await formRef.value?.validate()
    saving.value = true
    try { await updateDispatchRule({ ...form }); ElMessage.success('派单规则已更新'); await load() }
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
