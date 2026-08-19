<template>
  <ElDialog v-model="visible" title="批量生成用户" width="620px" destroy-on-close @open="resetForm">
    <ElAlert
      title="账号将使用手机号，昵称自动生成为“用户+手机号后四位”，默认启用并授予普通用户角色。其他资料可稍后编辑。"
      type="info"
      :closable="false"
      show-icon
      class="mb-5"
    />
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="90px">
      <ElFormItem label="手机号" prop="phoneText">
        <ElInput
          v-model="form.phoneText"
          type="textarea"
          :rows="10"
          maxlength="2600"
          show-word-limit
          placeholder="每行一个手机号，也可使用逗号、空格分隔；单次最多200个"
        />
      </ElFormItem>
      <ElFormItem label="初始密码" prop="password">
        <ElInput v-model="form.password" type="password" maxlength="64" show-password />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <ElButton @click="visible=false">取消</ElButton>
      <ElButton type="primary" :loading="submitting" @click="submit">生成用户</ElButton>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import type { FormInstance, FormRules } from 'element-plus'
  import { ElMessageBox } from 'element-plus'
  import { fetchBatchCreateUsers } from '@/api/system-manage'

  const props = defineProps<{ visible: boolean }>()
  const emit = defineEmits<{ (e:'update:visible',value:boolean):void; (e:'submit'):void }>()
  const visible = computed({ get:()=>props.visible, set:(value)=>emit('update:visible',value) })
  const formRef = ref<FormInstance>()
  const submitting = ref(false)
  const form = reactive({ phoneText:'', password:'12345678' })

  function phones() {
    return form.phoneText.split(/[\s,，;；]+/).map(value=>value.trim()).filter(Boolean)
  }

  const rules:FormRules = {
    phoneText: [{ validator:(_rule,_value,callback)=>{
      const values=phones()
      if(!values.length)return callback(new Error('请至少输入一个手机号'))
      if(values.length>200)return callback(new Error('单次最多生成200个用户'))
      const invalid=values.filter(phone=>!/^1[3-9]\d{9}$/.test(phone))
      return invalid.length?callback(new Error(`手机号格式不正确：${invalid.slice(0,3).join('、')}${invalid.length>3?' 等':''}`)):callback()
    },trigger:'blur' }],
    password: [{ required:true,message:'请输入初始密码' },{ min:8,max:64,message:'初始密码需为8-64位' }]
  }

  function resetForm(){form.phoneText='';form.password='12345678';nextTick(()=>formRef.value?.clearValidate())}

  async function submit(){
    if(!formRef.value)return
    await formRef.value.validate()
    submitting.value=true
    try{
      const result=await fetchBatchCreateUsers({phones:phones(),password:form.password})
      visible.value=false
      emit('submit')
      const details=[
        h('p',`成功创建 ${result.createdCount} 个用户。`),
        result.existingPhones.length?h('p',`已存在并跳过：${result.existingPhones.join('、')}`):null,
        result.duplicatePhones.length?h('p',`输入重复并跳过：${result.duplicatePhones.join('、')}`):null
      ].filter(Boolean)
      await ElMessageBox.alert(h('div',{class:'leading-7 break-all'},details),'批量生成完成',{confirmButtonText:'知道了'})
    }finally{submitting.value=false}
  }
</script>
