<template>
  <ElDialog v-model="visible" title="批量新增陪玩师" width="640px" destroy-on-close @open="resetForm">
    <ElAlert
      title="每个手机号会同时创建登录用户和陪玩师档案，并授予普通用户、陪玩师两个身份。档案默认为草稿，游戏、资料及审核状态可稍后逐个完善。"
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
      <ElButton type="primary" :loading="submitting" @click="submit">创建用户和陪玩师</ElButton>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import type { FormInstance, FormRules } from 'element-plus'
  import { ElMessageBox } from 'element-plus'
  import { batchCreatePlayers } from '@/api/business-manage'

  const props=defineProps<{visible:boolean}>()
  const emit=defineEmits<{(e:'update:visible',value:boolean):void;(e:'submit'):void}>()
  const visible=computed({get:()=>props.visible,set:value=>emit('update:visible',value)})
  const formRef=ref<FormInstance>()
  const submitting=ref(false)
  const form=reactive({phoneText:'',password:'12345678'})
  const phones=()=>form.phoneText.split(/[\s,，;；]+/).map(value=>value.trim()).filter(Boolean)
  const rules:FormRules={
    phoneText:[{validator:(_rule,_value,callback)=>{const values=phones();if(!values.length)return callback(new Error('请至少输入一个手机号'));if(values.length>200)return callback(new Error('单次最多创建200个陪玩师'));const invalid=values.filter(phone=>!/^1[3-9]\d{9}$/.test(phone));return invalid.length?callback(new Error(`手机号格式不正确：${invalid.slice(0,3).join('、')}${invalid.length>3?' 等':''}`)):callback()},trigger:'blur'}],
    password:[{required:true,message:'请输入初始密码'},{min:8,max:64,message:'初始密码需为8-64位'}]
  }
  function resetForm(){form.phoneText='';form.password='12345678';nextTick(()=>formRef.value?.clearValidate())}
  async function submit(){
    if(!formRef.value)return
    await formRef.value.validate()
    submitting.value=true
    try{
      const result=await batchCreatePlayers({phones:phones(),password:form.password})
      visible.value=false
      emit('submit')
      const details=[h('p',`成功创建 ${result.createdCount} 个用户和陪玩师档案。`),result.existingPhones.length?h('p',`账号或陪玩师已存在并跳过：${result.existingPhones.join('、')}`):null,result.duplicatePhones.length?h('p',`输入重复并跳过：${result.duplicatePhones.join('、')}`):null].filter(Boolean)
      await ElMessageBox.alert(h('div',{class:'leading-7 break-all'},details),'批量新增完成',{confirmButtonText:'知道了'})
    }finally{submitting.value=false}
  }
</script>
