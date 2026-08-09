<template>
  <div class="art-full-height">
    <ElCard class="mb-3">
      <ElForm inline>
        <ElFormItem label="关键词"><ElInput v-model="query.keyword" clearable placeholder="编号/昵称/手机号" /></ElFormItem>
        <ElFormItem label="审核状态"><ElSelect v-model="query.auditStatus" clearable class="!w-32"><ElOption label="草稿" value="DRAFT" /><ElOption label="待审核" value="PENDING" /><ElOption label="已通过" value="APPROVED" /><ElOption label="已拒绝" value="REJECTED" /></ElSelect></ElFormItem>
        <ElFormItem label="接单状态"><ElSelect v-model="query.workStatus" clearable class="!w-32"><ElOption label="离线" value="OFFLINE" /><ElOption label="可接单" value="AVAILABLE" /><ElOption label="忙碌" value="BUSY" /><ElOption label="暂停" value="SUSPENDED" /></ElSelect></ElFormItem>
        <ElFormItem><ElButton @click="reset">重置</ElButton><ElButton type="primary" @click="search">查询</ElButton></ElFormItem>
      </ElForm>
    </ElCard>
    <ElCard class="art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load">
        <template #left><ElButton v-auth="'business:player:create'" @click="open()">新增陪玩师</ElButton><ElButton v-auth="'business:player:audit'" type="warning" plain @click="profileReview=true">资料变更审核</ElButton></template>
      </ArtTableHeader>
      <ElTable v-loading="loading" :data="rows">
        <ElTableColumn prop="playerNo" label="陪玩师编号" min-width="150" /><ElTableColumn prop="nickname" label="昵称" min-width="120" /><ElTableColumn prop="phone" label="手机号" min-width="130" />
        <ElTableColumn prop="primaryGame" label="主游戏" min-width="120"><template #default="{row}">{{row.primaryGame||'-'}}</template></ElTableColumn>
        <ElTableColumn label="审核状态" width="100"><template #default="{row}"><ElTag :type="auditType(row.auditStatus)">{{auditText(row.auditStatus)}}</ElTag></template></ElTableColumn>
        <ElTableColumn label="接单状态" width="110"><template #default="{row}"><ElTag>{{workText(row.workStatus)}}</ElTag></template></ElTableColumn>
        <ElTableColumn label="启用" width="80"><template #default="{row}"><ElSwitch v-model="row.enabled" :disabled="!has('business:player:status')" @change="value=>toggle(row,Boolean(value))" /></template></ElTableColumn>
        <ElTableColumn prop="ratingScore" label="评分" width="80" /><ElTableColumn prop="orderCount" label="订单数" width="80" />
        <ElTableColumn label="操作" width="80" fixed="right"><template #default="{row}"><ArtButtonMore :list="actions(row)" @click="item=>action(String(item.key),row)" /></template></ElTableColumn>
      </ElTable>
      <div class="flex justify-end mt-4"><ElPagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total" @change="load" layout="total, sizes, prev, pager, next" /></div>
    </ElCard>
    <PlayerDialog v-model="dialog" :id="currentId" @success="load" />
    <ProfileReviewDialog v-model="profileReview" />
  </div>
</template>

<script setup lang="ts">
import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
import PlayerDialog from './modules/player-dialog.vue'
import ProfileReviewDialog from './modules/profile-review-dialog.vue'
import { auditPlayer, fetchPlayers, setPlayerStatus } from '@/api/business-manage'
import { useUserStore } from '@/store/modules/user'

const store = useUserStore()
const has = (code:string) => store.info.roles?.includes('admin') || store.info.buttons?.includes(code)
const loading = ref(false), rows = ref<Api.Business.Player[]>([]), total = ref(0)
const dialog = ref(false), profileReview = ref(false), currentId = ref<number>()
const query = reactive<any>({ current:1, size:20, keyword:'', auditStatus:'', workStatus:'' })

async function load() { loading.value = true; try { const data = await fetchPlayers(query); rows.value = data.records; total.value = data.total } finally { loading.value = false } }
function search() { query.current = 1; load() }
function reset() { query.keyword=''; query.auditStatus=''; query.workStatus=''; search() }
function open(row?:any) { currentId.value = row?.id; dialog.value = true }
function actions(row:any) { return [...(has('business:player:detail')||has('business:player:update')?[{key:'edit',label:'资料管理',icon:'ri:edit-line'}]:[]),...(has('business:player:audit')&&row.auditStatus!=='APPROVED'?[{key:'approve',label:'审核通过',icon:'ri:checkbox-circle-line'},{key:'reject',label:'审核拒绝',icon:'ri:close-circle-line',color:'#f56c6c'}]:[]),...(has('business:player:status')&&row.auditStatus==='APPROVED'?[{key:'available',label:'设为可接单',icon:'ri:play-circle-line'},{key:'offline',label:'设为休息',icon:'ri:pause-circle-line'}]:[])] }
async function action(key:string,row:any) { if(key==='edit')return open(row); if(key==='approve'){await ElMessageBox.confirm(`确认通过“${row.nickname}”的审核吗？`,'审核确认');await auditPlayer(row.id,'APPROVED','审核通过')} if(key==='reject'){const result=await ElMessageBox.prompt('请输入拒绝原因','审核拒绝',{inputValidator:value=>!!value||'必须填写拒绝原因'});await auditPlayer(row.id,'REJECTED',result.value)} if(key==='available')await setPlayerStatus(row.id,{workStatus:'AVAILABLE',reason:'后台设置'}); if(key==='offline')await setPlayerStatus(row.id,{workStatus:'OFFLINE',reason:'后台设置'}); load() }
async function toggle(row:any,value:boolean) { try { await setPlayerStatus(row.id,{enabled:value,reason:'后台设置'}) } catch { load() } }
const auditText=(status:string)=>({DRAFT:'草稿',PENDING:'待审核',APPROVED:'已通过',REJECTED:'已拒绝'}[status]||status)
const auditType=(status:string)=>(status==='APPROVED'?'success':status==='REJECTED'?'danger':status==='PENDING'?'warning':'info') as any
const workText=(status:string)=>({OFFLINE:'休息',AVAILABLE:'可接单',BUSY:'忙碌',SUSPENDED:'暂停'}[status]||status)
onMounted(load)
</script>
