<template>
  <div class="user-page art-full-height">
    <UserSearch v-model="searchForm" @search="handleSearch" @reset="resetSearchParams" />
    <ElCard class="art-table-card">
      <ArtTableHeader v-model:columns="columnChecks" :loading="loading" @refresh="refreshData">
        <template #left>
          <ElSpace>
            <ElButton v-auth="'system:user:create'" @click="showDialog('add')" v-ripple>新增用户</ElButton>
            <ElButton v-auth="'system:user:create'" type="primary" @click="batchDialogVisible=true" v-ripple>批量生成用户</ElButton>
          </ElSpace>
        </template>
      </ArtTableHeader>
      <ArtTable :loading="loading" :data="data" :columns="columns" :pagination="pagination" @pagination:size-change="handleSizeChange" @pagination:current-change="handleCurrentChange" />
      <UserDialog v-model:visible="dialogVisible" :type="dialogType" :user-data="currentUser" @submit="refreshData" />
      <BatchUserDialog v-model:visible="batchDialogVisible" @submit="refreshData" />
    </ElCard>
  </div>
</template>

<script setup lang="ts">
  import { useTable } from '@/hooks/core/useTable'
  import { fetchDeleteUser,fetchGetUserList,fetchResetUserPassword,fetchSetUserStatus } from '@/api/system-manage'
  import UserSearch from './modules/user-search.vue'
  import UserDialog from './modules/user-dialog.vue'
  import BatchUserDialog from './modules/batch-user-dialog.vue'
  import ArtButtonMore,{ type ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import { ElMessageBox,ElSwitch,ElTag } from 'element-plus'
  import type { DialogType } from '@/types'
  import { useUserStore } from '@/store/modules/user'
  import { formatDateTime } from '@/utils/date'

  defineOptions({name:'User'})
  type User=Api.SystemManage.UserListItem
  const dialogType=ref<DialogType>('add');const dialogVisible=ref(false);const batchDialogVisible=ref(false);const currentUser=ref<Partial<User>>({})
  const searchForm=ref<Api.SystemManage.UserSearchParams>({userName:undefined,userPhone:undefined,userEmail:undefined,status:undefined})
  const {columns,columnChecks,data,loading,pagination,getData,replaceSearchParams,resetSearchParams,handleSizeChange,handleCurrentChange,refreshData}=useTable({core:{apiFn:fetchGetUserList,apiParams:{current:1,size:20},columnsFactory:()=>[
    {type:'index',width:70,label:'序号'},
    {prop:'userName',label:'用户名',minWidth:130},
    {prop:'nickName',label:'昵称',minWidth:120},
    {prop:'userPhone',label:'手机号',minWidth:130},
    {prop:'userEmail',label:'邮箱',minWidth:180},
    {prop:'userRoles',label:'角色',minWidth:160,formatter:(row:User)=>h('div',{class:'flex gap-1'},row.userRoles.map(role=>h(ElTag,{size:'small'},()=>role)))},
    {prop:'status',label:'状态',width:100,formatter:(row:User)=>h(ElSwitch,{modelValue:row.enabled,disabled:!hasPermission('system:user:status'),onChange:(value:string|number|boolean)=>changeStatus(row,Boolean(value))})},
    {prop:'createTime',label:'创建时间',minWidth:170,formatter:(row:User)=>formatDateTime(row.createTime)},
    {prop:'operation',label:'操作',width:80,fixed:'right',formatter:(row:User)=>h(ArtButtonMore,{list:actions(row),onClick:(item:ButtonMoreItem)=>handleAction(item,row)})}
  ]}})
  const userStore=useUserStore();const hasPermission=(code:string)=>userStore.info.roles?.includes('admin')||userStore.info.buttons?.includes(code)
  function actions(row:User){return[
    ...(hasPermission('system:user:update')?[{key:'edit',label:'编辑/分配角色',icon:'ri:edit-line'}]:[]),
    ...(hasPermission('system:user:reset-password')?[{key:'password',label:'重置密码',icon:'ri:lock-password-line'}]:[]),
    ...(hasPermission('system:user:delete')?[{key:'delete',label:'删除用户',icon:'ri:delete-bin-line',color:'#f56c6c'}]:[])
  ]}
  function showDialog(type:DialogType,row?:User){dialogType.value=type;currentUser.value=row||{};dialogVisible.value=true}
  function handleSearch(params:Api.SystemManage.UserSearchParams){replaceSearchParams(params);getData()}
  async function changeStatus(row:User,enabled:boolean){try{await ElMessageBox.confirm(`确定${enabled?'启用':'禁用'}用户“${row.userName}”吗？`,'状态确认');await fetchSetUserStatus(row.id,enabled);ElMessage.success('状态更新成功');refreshData()}catch{refreshData()}}
  async function handleAction(item:ButtonMoreItem,row:User){if(item.key==='edit')showDialog('edit',row);if(item.key==='password'){const result=await ElMessageBox.prompt('请输入至少8位的新密码',`重置 ${row.userName} 的密码`,{inputType:'password',inputValidator:(v)=>v.length>=8||'密码至少8位'});await fetchResetUserPassword(row.id,result.value);ElMessage.success('密码重置成功')}if(item.key==='delete'){await ElMessageBox.confirm(`确定删除用户“${row.userName}”吗？`,'删除确认',{type:'warning'});await fetchDeleteUser(row.id);ElMessage.success('删除成功');refreshData()}}
</script>
