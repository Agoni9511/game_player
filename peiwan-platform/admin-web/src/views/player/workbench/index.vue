<template>
  <div class="art-full-height" v-loading="loading">
    <ElCard v-if="identityProblem" shadow="never" class="empty-card">
      <ElResult icon="info" :title="identityTitle" :sub-title="identityProblem">
        <template #extra>
          <ElButton v-if="canManagePlayer" type="primary" @click="router.push('/business/player')">去绑定陪玩师</ElButton>
          <ElButton @click="load">重新检查</ElButton>
        </template>
      </ElResult>
    </ElCard>
    <template v-else-if="dashboard">
      <ElRow :gutter="16" class="mb-4">
        <ElCol :span="10"><ElCard shadow="never"><div class="profile"><ElAvatar :size="58" :src="dashboard.player?.avatarUrl"/><div><h3>{{dashboard.player?.nickname||'-'}}</h3><div class="muted">{{dashboard.player?.playerNo}}</div></div><ElTag :type="dashboard.player?.workStatus==='AVAILABLE'?'success':dashboard.player?.workStatus==='BUSY'?'warning':'info'">{{workText(dashboard.player?.workStatus)}}</ElTag></div><div class="mt-4"><ElButton v-auth="'player:work-status:update'" type="primary" :disabled="dashboard.player?.workStatus==='BUSY'" @click="status('AVAILABLE')">开始接单</ElButton><ElButton v-auth="'player:work-status:update'" :disabled="dashboard.player?.workStatus==='BUSY'" @click="status('OFFLINE')">休息</ElButton></div></ElCard></ElCol>
        <ElCol :span="14"><ElRow :gutter="12"><ElCol v-for="x in stats" :key="x.label" :span="8"><ElCard shadow="never"><div class="stat-value">{{x.value}}</div><div class="muted">{{x.label}}</div></ElCard></ElCol></ElRow></ElCol>
      </ElRow>
      <ElCard shadow="never"><ElTabs v-model="tab"><ElTabPane label="待响应派单" name="dispatch"><ElTable :data="dispatches" empty-text="暂无待响应派单"><ElTableColumn prop="taskNo" label="任务号" min-width="180"/><ElTableColumn prop="gameName" label="游戏" width="120"/><ElTableColumn prop="productName" label="商品" min-width="150"/><ElTableColumn prop="skuName" label="规格" min-width="120"/><ElTableColumn label="接单进度" width="105"><template #default="{row}">{{row.memberCount || 0}}/{{row.requiredPlayerCount || 1}} 人</template></ElTableColumn><ElTableColumn prop="serverName" label="区服" width="110"/><ElTableColumn prop="rankName" label="段位" width="100"/><ElTableColumn prop="deadlineAt" label="响应截止" width="180"/><ElTableColumn label="操作" width="150" fixed="right"><template #default="{row}"><ElButton v-auth="'player:dispatch:accept'" link type="primary" @click="accept(row)">接受</ElButton><ElButton v-auth="'player:dispatch:reject'" link type="danger" @click="reject(row)">拒绝</ElButton></template></ElTableColumn></ElTable></ElTabPane><ElTabPane label="我的订单" name="orders"><ElTable :data="orders"><ElTableColumn prop="orderNo" label="订单号" min-width="190"/><ElTableColumn prop="gameName" label="游戏" width="120"/><ElTableColumn prop="productName" label="商品" min-width="160"/><ElTableColumn prop="skuName" label="规格" min-width="130"/><ElTableColumn label="成员" width="90"><template #default="{row}">{{row.memberCount || 0}}/{{row.requiredPlayerCount || 1}} 人</template></ElTableColumn><ElTableColumn label="状态" width="110"><template #default="{row}"><ElTag>{{orderText(row.orderStatus)}}</ElTag></template></ElTableColumn><ElTableColumn prop="assignedAt" label="接单时间" width="180"/><ElTableColumn label="操作" width="150"><template #default="{row}"><ElButton v-if="row.orderStatus==='ASSIGNED'" link type="primary" @click="start(row)">开始服务</ElButton><ElButton v-if="row.orderStatus==='IN_SERVICE'" link type="success" @click="submit(row)">提交完成</ElButton></template></ElTableColumn></ElTable><div class="flex justify-end mt-4"><ElPagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total" @change="loadOrders" layout="total, prev, pager, next"/></div></ElTabPane></ElTabs></ElCard>
    </template>
    <ElDialog v-model="submitVisible" title="提交完成凭证" width="600px"><ElForm label-width="90px"><ElFormItem label="完成说明" required><ElInput v-model="submitForm.note" type="textarea" :rows="4"/></ElFormItem><ElFormItem label="完成数量"><ElInputNumber v-model="submitForm.quantity" :min="0.01" :precision="2"/></ElFormItem><ElFormItem label="完成凭证" required><LocalFileUpload v-model="submitForm.proofUrl" kind="PROOF" accept="image/jpeg,image/png,image/webp,video/mp4"/></ElFormItem></ElForm><template #footer><ElButton @click="submitVisible=false">取消</ElButton><ElButton type="primary" @click="saveSubmit">提交审核</ElButton></template></ElDialog>
  </div>
</template>
<script setup lang="ts">
import{fetchPlayerWorkbench,updateOwnWorkStatus,fetchOwnPendingDispatches,acceptOwnDispatch,rejectOwnDispatch,fetchOwnOrders,startOwnOrder,submitOwnOrder}from'@/api/business-manage'
import{HttpError}from'@/utils/http/error'
import{useUserStore}from'@/store/modules/user'
import LocalFileUpload from '@/components/business/local-file-upload.vue'
const router=useRouter(),store=useUserStore(),loading=ref(false),dashboard=ref<any>(),identityProblem=ref(''),dispatches=ref<any[]>([]),orders=ref<any[]>([]),total=ref(0),tab=ref('dispatch'),query=reactive({current:1,size:20}),submitVisible=ref(false),submitOrder=ref<any>(),submitForm=reactive({note:'',quantity:1,proofUrl:''})
const stats=computed(()=>[{label:'待响应派单',value:dashboard.value?.pendingDispatchCount||0},{label:'进行中订单',value:dashboard.value?.activeOrderCount||0},{label:'已完成订单',value:dashboard.value?.completedOrderCount||0}])
const canManagePlayer=computed(()=>store.info.roles?.includes('admin')||store.info.buttons?.includes('business:player:update'))
const identityTitle=computed(()=>identityProblem.value.includes('审核')?'陪玩师资料尚未通过审核':identityProblem.value.includes('停用')?'陪玩师账号不可用':'尚未绑定陪玩师')
async function loadOrders(){const d=await fetchOwnOrders(query);orders.value=d.records;total.value=d.total}
async function load(){loading.value=true;identityProblem.value='';dashboard.value=undefined;try{dashboard.value=await fetchPlayerWorkbench();dispatches.value=await fetchOwnPendingDispatches();await loadOrders()}catch(e){if(e instanceof HttpError&&['当前账号尚未绑定陪玩师资料','陪玩师账号已停用','陪玩师资料尚未审核通过'].includes(e.message)){identityProblem.value=canManagePlayer.value?`${e.message}，请先在陪玩师管理中完成账号绑定和资料配置。`:`${e.message}，请联系平台管理员完成绑定和资料配置。`;return}throw e}finally{loading.value=false}}
async function status(v:string){await updateOwnWorkStatus(v);ElMessage.success(v==='AVAILABLE'?'已开始接单':'已切换为休息');load()}
async function accept(r:any){await ElMessageBox.confirm(`确定接受订单 ${r.orderNo} 吗？`,'接受派单');await acceptOwnDispatch(r.taskId);ElMessage.success('接单成功');load()}
async function reject(r:any){const x=await ElMessageBox.prompt('请输入拒绝原因','拒绝派单',{inputValidator:v=>Boolean(v)||'请输入拒绝原因'});await rejectOwnDispatch(r.taskId,x.value);ElMessage.success('已拒绝');load()}
async function start(r:any){await ElMessageBox.confirm(`确定开始服务订单 ${r.orderNo} 吗？`,'开始服务');await startOwnOrder(r.id);ElMessage.success('已开始服务');load()}
function submit(r:any){submitOrder.value=r;Object.assign(submitForm,{note:'',quantity:1,proofUrl:''});submitVisible.value=true}
async function saveSubmit(){if(!submitForm.note.trim())return ElMessage.warning('请填写完成说明');if(!submitForm.proofUrl)return ElMessage.warning('请上传完成凭证');await submitOwnOrder(submitOrder.value.id,{completionNote:submitForm.note,actualQuantity:submitForm.quantity,proofUrls:[submitForm.proofUrl]});ElMessage.success('已提交审核');submitVisible.value=false;load()}
const workText=(s:string)=>({AVAILABLE:'可接单',OFFLINE:'休息',BUSY:'已达接单上限',SUSPENDED:'暂停'}[s]||s),orderText=(s:string)=>({ASSIGNED:'已接单',IN_SERVICE:'服务中',PENDING_CONFIRM:'待确认完成',COMPLETED:'已完成',CANCELLED:'已取消'}[s]||s)
onMounted(load)
</script>
<style scoped>.empty-card{min-height:420px;display:flex;align-items:center;justify-content:center}.profile{display:flex;align-items:center;gap:14px}.profile h3{margin:0 0 5px}.profile .el-tag{margin-left:auto}.muted{color:var(--el-text-color-secondary);font-size:13px}.stat-value{font-size:30px;font-weight:600;margin-bottom:8px}</style>
