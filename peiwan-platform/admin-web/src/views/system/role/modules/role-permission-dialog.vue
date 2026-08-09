<template>
  <ElDialog v-model="visible" title="角色权限" width="560px" @open="load">
    <ElAlert v-if="roleData?.builtIn" title="内置超级管理员默认拥有全部权限，无需单独授权" type="info" :closable="false" class="mb-3" />
    <ElTree ref="treeRef" v-loading="loading" :data="tree" node-key="id" show-checkbox default-expand-all :props="{children:'children',label:'label'}" />
    <template #footer><ElButton @click="visible=false">取消</ElButton><ElButton type="primary" :disabled="roleData?.builtIn" :loading="saving" @click="save">保存权限</ElButton></template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { fetchAssignRoleMenus,fetchGetMenuTree,fetchGetRoleMenus } from '@/api/system-manage'
  const props=defineProps<{modelValue:boolean;roleData?:Api.SystemManage.RoleListItem}>();const emit=defineEmits<{(e:'update:modelValue',v:boolean):void;(e:'success'):void}>()
  const visible=computed({get:()=>props.modelValue,set:v=>emit('update:modelValue',v)});const treeRef=ref();const tree=ref<any[]>([]);const loading=ref(false);const saving=ref(false)
  function convert(nodes:any[]):any[]{return nodes.map(node=>({id:node.id,label:node.meta?.title||node.name,children:[...(node.children?convert(node.children):[]),...(node.meta?.authList||[]).map((auth:any)=>({id:auth.id,label:auth.title,children:[]}))]}))}
  async function load(){if(!props.roleData)return;loading.value=true;try{const [menus,checked]=await Promise.all([fetchGetMenuTree(),fetchGetRoleMenus(props.roleData.roleId)]);tree.value=convert(menus);nextTick(()=>treeRef.value?.setCheckedKeys(checked.filter((id:number)=>!hasChildren(tree.value,id))))}finally{loading.value=false}}
  function hasChildren(nodes:any[],id:number):boolean{for(const node of nodes){if(node.id===id)return node.children?.length>0;if(node.children&&hasChildren(node.children,id))return true}return false}
  async function save(){if(!props.roleData)return;saving.value=true;try{const ids=[...treeRef.value.getCheckedKeys(),...treeRef.value.getHalfCheckedKeys()].map(Number);await fetchAssignRoleMenus(props.roleData.roleId,[...new Set(ids)]);ElMessage.success('角色权限保存成功');visible.value=false;emit('success')}finally{saving.value=false}}
</script>
