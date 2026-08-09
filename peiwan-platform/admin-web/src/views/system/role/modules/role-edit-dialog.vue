<template>
  <ElDialog v-model="visible" :title="dialogType==='add'?'新增角色':'编辑角色'" width="500px" @open="init">
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="90px">
      <ElFormItem label="角色名称" prop="roleName"><ElInput v-model="form.roleName" /></ElFormItem>
      <ElFormItem label="角色编码" prop="roleCode"><ElInput v-model="form.roleCode" :disabled="roleData?.builtIn" /></ElFormItem>
      <ElFormItem label="描述" prop="description"><ElInput v-model="form.description" type="textarea" :rows="3" /></ElFormItem>
      <ElFormItem label="启用"><ElSwitch v-model="form.enabled" :disabled="roleData?.builtIn" /></ElFormItem>
    </ElForm>
    <template #footer><ElButton @click="visible=false">取消</ElButton><ElButton type="primary" :loading="submitting" @click="submit">保存</ElButton></template>
  </ElDialog>
</template>

<script setup lang="ts">
  import type { FormInstance,FormRules } from 'element-plus'
  import { fetchCreateRole,fetchUpdateRole } from '@/api/system-manage'
  const props=defineProps<{modelValue:boolean;dialogType:'add'|'edit';roleData?:Api.SystemManage.RoleListItem}>()
  const emit=defineEmits<{(e:'update:modelValue',value:boolean):void;(e:'success'):void}>()
  const visible=computed({get:()=>props.modelValue,set:v=>emit('update:modelValue',v)});const formRef=ref<FormInstance>();const submitting=ref(false)
  const form=reactive<Api.SystemManage.RoleListItem>({roleId:0,roleName:'',roleCode:'',description:'',enabled:true,createTime:''})
  const rules:FormRules={roleName:[{required:true,message:'请输入角色名称'},{min:2,max:64,message:'长度2-64位'}],roleCode:[{required:true,message:'请输入角色编码'},{pattern:/^[a-z][a-z0-9_-]{1,63}$/,message:'小写字母开头，可包含数字、_、-'}]}
  function init(){Object.assign(form,props.dialogType==='edit'&&props.roleData?props.roleData:{roleId:0,roleName:'',roleCode:'',description:'',enabled:true,createTime:''});nextTick(()=>formRef.value?.clearValidate())}
  async function submit(){if(!formRef.value)return;await formRef.value.validate();submitting.value=true;try{if(props.dialogType==='add')await fetchCreateRole(form);else await fetchUpdateRole(form.roleId,form);ElMessage.success(props.dialogType==='add'?'角色创建成功':'角色更新成功');visible.value=false;emit('success')}finally{submitting.value=false}}
</script>
