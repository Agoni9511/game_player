<template>
  <div class="art-full-height">
    <ElCard class="mb-3">
      <ElForm inline>
        <ElFormItem label="所属游戏"><ElSelect v-model="query.gameId" clearable filterable class="!w-44" placeholder="全部游戏"><ElOption v-for="game in games" :key="game.id" :label="game.gameName" :value="game.id" /></ElSelect></ElFormItem>
        <ElFormItem label="等级名称"><ElInput v-model="query.levelName" clearable placeholder="输入名称查询" /></ElFormItem>
        <ElFormItem label="状态"><ElSelect v-model="query.enabled" clearable class="!w-28"><ElOption label="启用" :value="true" /><ElOption label="停用" :value="false" /></ElSelect></ElFormItem>
        <ElFormItem><ElButton @click="reset">重置</ElButton><ElButton type="primary" @click="search">查询</ElButton></ElFormItem>
      </ElForm>
    </ElCard>
    <ElCard class="art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load"><template #left><ElButton v-auth="'business:player-level:create'" type="primary" @click="open()">新增等级</ElButton></template></ArtTableHeader>
      <ElAlert class="mb-4" type="info" :closable="false" title="等级是平台统一定价层级。删除等级会同步清理其商品价格；已分配给陪玩师的等级不可停用或删除。" />
      <ElTable v-loading="loading" :data="rows">
        <ElTableColumn prop="gameName" label="所属游戏" min-width="140" />
        <ElTableColumn prop="levelCode" label="等级编码" min-width="150" />
        <ElTableColumn label="等级名称" min-width="130"><template #default="{row}"><ElTag effect="plain">{{row.levelName}}</ElTag></template></ElTableColumn>
        <ElTableColumn prop="description" label="等级说明" min-width="240" show-overflow-tooltip />
        <ElTableColumn prop="sortNo" label="排序" width="80" />
        <ElTableColumn label="状态" width="100"><template #default="{row}"><ElSwitch v-model="row.enabled" :disabled="!has('business:player-level:status')" @change="v=>changeStatus(row,Boolean(v))" /></template></ElTableColumn>
        <ElTableColumn label="操作" width="90" fixed="right"><template #default="{row}"><ArtButtonMore :list="actions" @click="i=>action(i.key,row)" /></template></ElTableColumn>
      </ElTable>
      <div class="flex justify-end mt-4"><ElPagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total" layout="total, sizes, prev, pager, next" @change="load" /></div>
    </ElCard>
    <ElDialog v-model="visible" :title="form.id?'编辑陪玩等级':'新增陪玩等级'" width="520px">
      <ElForm label-width="90px">
        <ElFormItem label="所属游戏" required><ElSelect v-model="form.gameId" class="w-full" filterable placeholder="请选择游戏"><ElOption v-for="game in games" :key="game.id" :label="game.gameName" :value="game.id" /></ElSelect></ElFormItem>
        <ElFormItem label="等级编码" required><ElInput v-model="form.levelCode" maxlength="32" placeholder="例如 ELITE" @input="form.levelCode=String(form.levelCode).toUpperCase().replace(/[^A-Z0-9_]/g,'')" /></ElFormItem>
        <ElFormItem label="等级名称" required><ElInput v-model="form.levelName" maxlength="64" placeholder="例如 精英" /></ElFormItem>
        <ElFormItem label="等级说明"><ElInput v-model="form.description" type="textarea" :rows="3" maxlength="255" show-word-limit /></ElFormItem>
        <ElFormItem label="排序"><ElInputNumber v-model="form.sortNo" :min="0" /></ElFormItem>
        <ElFormItem label="启用"><ElSwitch v-model="form.enabled" /></ElFormItem>
      </ElForm>
      <template #footer><ElButton @click="visible=false">取消</ElButton><ElButton type="primary" :loading="saving" @click="save">保存</ElButton></template>
    </ElDialog>
  </div>
</template>
<script setup lang="ts">
import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
import { fetchPlayerLevelList, createPlayerLevel, updatePlayerLevel, setPlayerLevelStatus, deletePlayerLevel, fetchGameOptions } from '@/api/business-manage'
import { useUserStore } from '@/store/modules/user'
const store=useUserStore(),has=(code:string)=>store.info.roles?.includes('admin')||store.info.buttons?.includes(code)
const loading=ref(false),saving=ref(false),visible=ref(false),rows=ref<any[]>([]),games=ref<any[]>([]),total=ref(0)
const query=reactive<any>({current:1,size:20,gameId:undefined,levelName:'',enabled:undefined}),form=reactive<any>({})
const actions=computed(()=>[...(has('business:player-level:update')?[{key:'edit',label:'编辑',icon:'ri:edit-line'}]:[]),...(has('business:player-level:delete')?[{key:'delete',label:'删除',icon:'ri:delete-bin-line',color:'#f56c6c'}]:[])])
async function load(){loading.value=true;try{const data=await fetchPlayerLevelList(query);rows.value=data.records;total.value=data.total}finally{loading.value=false}}
function search(){query.current=1;load()}
function reset(){Object.assign(query,{current:1,gameId:undefined,levelName:'',enabled:undefined});load()}
function open(row?:any){Object.assign(form,row?{...row}:{id:null,gameId:query.gameId||games.value[0]?.id,levelCode:'',levelName:'',description:'',sortNo:0,enabled:true});visible.value=true}
async function save(){if(!form.gameId||!form.levelCode||!form.levelName)return ElMessage.warning('请选择游戏并填写等级编码和名称');saving.value=true;try{form.id?await updatePlayerLevel(form.id,form):await createPlayerLevel(form);visible.value=false;await load();ElMessage.success('保存成功')}finally{saving.value=false}}
async function changeStatus(row:any,enabled:boolean){try{await setPlayerLevelStatus(row.id,enabled);ElMessage.success('状态已更新')}catch{await load()}}
async function action(key:any,row:any){if(key==='edit')return open(row);await ElMessageBox.confirm(`删除“${row.levelName}”后，其商品等级价格也会删除，确定继续吗？`,'删除确认',{type:'warning'});await deletePlayerLevel(row.id);await load();ElMessage.success('删除成功')}
onMounted(async()=>{games.value=await fetchGameOptions();await load()})
</script>
