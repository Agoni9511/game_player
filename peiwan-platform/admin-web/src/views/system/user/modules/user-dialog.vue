<template>
  <ElDialog v-model="visible" :title="type === 'add' ? '新增用户' : '编辑用户'" width="520px" @open="init">
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="90px">
      <ElFormItem label="用户名" prop="userName"><ElInput v-model="form.userName" /></ElFormItem>
      <ElFormItem v-if="type === 'add'" label="初始密码" prop="password"><ElInput v-model="form.password" type="password" show-password /></ElFormItem>
      <ElFormItem label="昵称" prop="nickName"><ElInput v-model="form.nickName" /></ElFormItem>
      <ElFormItem label="手机号" prop="userPhone"><ElInput v-model="form.userPhone" /></ElFormItem>
      <ElFormItem label="邮箱" prop="userEmail"><ElInput v-model="form.userEmail" /></ElFormItem>
      <ElFormItem label="性别"><ElSelect v-model="form.userGender"><ElOption label="男" value="男" /><ElOption label="女" value="女" /><ElOption label="未知" value="未知" /></ElSelect></ElFormItem>
      <ElFormItem label="角色"><ElSelect v-model="form.roleIds" multiple class="w-full"><ElOption v-for="role in roles" :key="role.roleId" :label="role.roleName" :value="role.roleId" :disabled="!role.enabled" /></ElSelect></ElFormItem>
      <ElFormItem label="启用"><ElSwitch v-model="form.enabled" /></ElFormItem>
    </ElForm>
    <template #footer><ElButton @click="visible=false">取消</ElButton><ElButton type="primary" :loading="submitting" @click="submit">保存</ElButton></template>
  </ElDialog>
</template>

<script setup lang="ts">
  import type { FormInstance, FormRules } from 'element-plus'
  import { fetchCreateUser, fetchGetRoleOptions, fetchUpdateUser } from '@/api/system-manage'

  const props = defineProps<{ visible: boolean; type: string; userData?: Partial<Api.SystemManage.UserListItem> }>()
  const emit = defineEmits<{ (e:'update:visible',value:boolean):void; (e:'submit'):void }>()
  const visible = computed({ get:()=>props.visible, set:(value)=>emit('update:visible',value) })
  const formRef=ref<FormInstance>(); const roles=ref<Api.SystemManage.RoleOption[]>([]); const submitting=ref(false)
  const form=reactive<Api.SystemManage.UserSaveParams>({userName:'',password:'',nickName:'',userPhone:'',userEmail:'',userGender:'未知',enabled:true,roleIds:[]})
  const rules:FormRules={userName:[{required:true,message:'请输入用户名'},{pattern:/^[A-Za-z0-9_.-]{3,64}$/,message:'3-64位字母、数字或_.-'}],password:[{validator:(_r,v,cb)=>props.type==='add'&&(!v||v.length<8)?cb(new Error('初始密码至少8位')):cb()}],userPhone:[{pattern:/^$|^1[3-9]\d{9}$/,message:'手机号格式不正确'}],userEmail:[{type:'email',message:'邮箱格式不正确'}]}
  async function init(){roles.value=await fetchGetRoleOptions();const row=props.userData;Object.assign(form,{userName:row?.userName||'',password:'',nickName:row?.nickName||'',userPhone:row?.userPhone||'',userEmail:row?.userEmail||'',userGender:row?.userGender||'未知',enabled:row?.enabled??true,roleIds:row?.roleIds||[]});nextTick(()=>formRef.value?.clearValidate())}
  async function submit(){if(!formRef.value)return;await formRef.value.validate();submitting.value=true;try{if(props.type==='add')await fetchCreateUser(form);else await fetchUpdateUser(props.userData!.id!,form);ElMessage.success(props.type==='add'?'用户创建成功':'用户更新成功');visible.value=false;emit('submit')}finally{submitting.value=false}}
</script>
