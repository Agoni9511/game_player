<template>
  <div class="menu-page art-full-height">
    <ElCard class="art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load">
        <template #left><ElButton v-auth="'system:menu:create'" @click="openCreate(null,'DIRECTORY')">新增根目录</ElButton></template>
      </ArtTableHeader>
      <ElTable v-loading="loading" :data="rows" row-key="id" default-expand-all :tree-props="{children:'children'}">
        <ElTableColumn prop="title" label="名称" min-width="180" />
        <ElTableColumn prop="type" label="类型" width="90"><template #default="{row}"><ElTag :type="row.type==='BUTTON'?'danger':row.type==='DIRECTORY'?'info':'primary'">{{ typeText(row.type) }}</ElTag></template></ElTableColumn>
        <ElTableColumn prop="path" label="路由" min-width="180" />
        <ElTableColumn prop="authMark" label="权限编码" min-width="220" />
        <ElTableColumn prop="enabled" label="状态" width="90"><template #default="{row}"><ElTag :type="row.enabled?'success':'info'">{{ row.enabled?'启用':'禁用' }}</ElTag></template></ElTableColumn>
        <ElTableColumn label="操作" width="80" fixed="right"><template #default="{row}">
          <ArtButtonMore :list="actions(row)" @click="item => handleAction(item,row)" />
        </template></ElTableColumn>
      </ElTable>
      <MenuDialog v-model:visible="dialogVisible" :edit-data="editing" :parent-id="parentId" :options="options" @submit="save" />
    </ElCard>
  </div>
</template>

<script setup lang="ts">
  import MenuDialog from './modules/menu-dialog.vue'
  import { fetchCreateMenu,fetchDeleteMenu,fetchGetMenuTree,fetchUpdateMenu } from '@/api/system-manage'
  import { useUserStore } from '@/store/modules/user'
  import ArtButtonMore,{ type ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  const loading=ref(false);const rows=ref<any[]>([]);const dialogVisible=ref(false);const editing=ref<any>();const parentId=ref<number|null>(null);const options=ref<any[]>([]);const userStore=useUserStore()
  const has=(code:string)=>userStore.info.roles?.includes('admin')||userStore.info.buttons?.includes(code)
  function normalize(nodes:any[]):any[]{return nodes.map(node=>{const children=normalize(node.children||[]);const buttons=(node.meta?.authList||[]).map((a:any)=>({id:a.id,parentId:node.id,type:'BUTTON',name:a.name,title:a.title,path:'',authMark:a.authMark,sortNo:a.sortNo,enabled:a.enabled,children:[]}));return{...node,title:node.meta?.title,type:node.type||'MENU',authMark:'',children:[...children,...buttons]}})}
  function toOptions(nodes:any[]):any[]{return nodes.filter(n=>n.type!=='BUTTON').map(n=>({id:n.id,label:n.title,children:toOptions(n.children||[])}))}
  async function load(){loading.value=true;try{rows.value=normalize(await fetchGetMenuTree());options.value=toOptions(rows.value)}finally{loading.value=false}}
  function typeText(type:string){return type==='DIRECTORY'?'目录':type==='MENU'?'菜单':'按钮'}
  function actions(row:any):ButtonMoreItem[]{return[
    ...(row.type!=='BUTTON'&&has('system:menu:create')?[{key:'create-menu',label:'新增菜单',icon:'ri:menu-add-line'}]:[]),
    ...(row.type==='MENU'&&has('system:menu:create')?[{key:'create-button',label:'新增按钮',icon:'ri:add-box-line'}]:[]),
    ...(has('system:menu:update')?[{key:'edit',label:'编辑',icon:'ri:edit-2-line'}]:[]),
    ...(has('system:menu:delete')?[{key:'delete',label:'删除',icon:'ri:delete-bin-4-line',color:'#f56c6c'}]:[])
  ]}
  function handleAction(item:ButtonMoreItem,row:any){
    if(item.key==='create-menu')openCreate(row.id,'MENU')
    if(item.key==='create-button')openCreate(row.id,'BUTTON')
    if(item.key==='edit')openEdit(row)
    if(item.key==='delete')remove(row)
  }
  function openCreate(parent:number|null,type:'DIRECTORY'|'MENU'|'BUTTON'){editing.value={initialType:type};parentId.value=parent;dialogVisible.value=true}
  function openEdit(row:any){editing.value=row;parentId.value=row.parentId??null;dialogVisible.value=true}
  async function save(data:Api.SystemManage.MenuSaveParams&{id?:number}){const {id,...body}=data;if(id)await fetchUpdateMenu(id,body);else await fetchCreateMenu(body);ElMessage.success(id?'更新成功':'创建成功');load()}
  async function remove(row:any){await ElMessageBox.confirm(`确定删除“${row.title}”吗？`,'删除确认',{type:'warning'});await fetchDeleteMenu(row.id);ElMessage.success('删除成功');load()}
  onMounted(load)
</script>

<style scoped>
  /* 菜单树会一次性展开全部目录、菜单和按钮，不能套用分页表格的固定高度裁剪。 */
  .menu-page {
    display: block;
    height: auto;
    min-height: var(--art-full-height);
  }

  .menu-page .art-table-card {
    display: block;
    min-height: var(--art-full-height);
  }

  .menu-page .art-table-card :deep(.el-card__body) {
    height: auto;
    overflow: visible;
  }
</style>
