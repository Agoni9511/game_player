<template>
  <div class="art-full-height finance-page">
    <ElAlert class="mb-4" type="info" :closable="false">
      <template #title>支付、余额与结算是不同会计层次；总览按业务口径汇总，明细保留各原始账本，不做重复相加。</template>
    </ElAlert>

    <ElCard shadow="never" class="mb-4 filter-card">
      <div class="page-head">
        <div><div class="page-title">财务流水</div><div class="page-subtitle">全平台支付、账户、平台损益与订单分账记录</div></div>
        <div class="date-actions">
          <ElDatePicker v-model="dateRange" type="daterange" value-format="YYYY-MM-DD" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" :clearable="true" />
          <ElButton type="primary" @click="search">查询</ElButton><ElButton @click="reset">重置</ElButton>
        </div>
      </div>
    </ElCard>

    <ElRow :gutter="14" class="mb-4">
      <ElCol v-for="card in summaryCards" :key="card.label" :xs="12" :sm="8" :lg="4">
        <ElCard shadow="never" class="summary-card">
          <div class="summary-label">{{ card.label }}</div>
          <div class="summary-value" :class="card.tone">¥ {{ money(card.value) }}</div>
          <div class="summary-note">{{ card.note }}</div>
        </ElCard>
      </ElCol>
    </ElRow>

    <ElCard shadow="never" class="art-table-card">
      <ElTabs v-model="activeTab" @tab-change="tabChanged">
        <ElTabPane label="交易支付" name="payments" />
        <ElTabPane label="平台账本" name="platform" />
        <ElTabPane label="用户钱包" name="wallet" />
        <ElTabPane label="陪玩师账户" name="player" />
        <ElTabPane label="订单结算" name="settlement" />
      </ElTabs>

      <ElForm inline class="table-filter">
        <ElFormItem label="关键词"><ElInput v-model="query.keyword" clearable :placeholder="keywordPlaceholder" class="!w-64" @keyup.enter="searchRows" /></ElFormItem>
        <template v-if="activeTab==='payments'">
          <ElFormItem label="交易类型"><ElSelect v-model="query.businessType" clearable class="!w-36"><ElOption label="陪玩服务" value="PLAYER_SERVICE"/><ElOption label="钱包充值" value="WALLET_RECHARGE"/></ElSelect></ElFormItem>
          <ElFormItem label="支付状态"><ElSelect v-model="query.status" clearable class="!w-32"><ElOption label="已支付" value="PAID"/><ElOption label="已退款" value="REFUNDED"/></ElSelect></ElFormItem>
          <ElFormItem label="支付渠道"><ElSelect v-model="query.channel" clearable class="!w-36"><ElOption label="钱包" value="WALLET"/><ElOption label="模拟微信" value="MOCK_WECHAT"/><ElOption label="模拟充值" value="MOCK_RECHARGE"/></ElSelect></ElFormItem>
        </template>
        <template v-else-if="activeTab==='platform'">
          <ElFormItem label="业务类型"><ElSelect v-model="query.businessType" clearable class="!w-48"><ElOption v-for="x in platformTypes" :key="x.value" :label="x.label" :value="x.value"/></ElSelect></ElFormItem>
          <ElFormItem label="方向"><DirectionSelect v-model="query.direction" /></ElFormItem>
        </template>
        <template v-else-if="activeTab==='wallet' || activeTab==='player'">
          <ElFormItem label="业务类型"><ElInput v-model="query.businessType" clearable placeholder="如 ORDER_PAYMENT" class="!w-44" /></ElFormItem>
          <ElFormItem label="余额类型"><ElSelect v-model="query.balanceType" clearable class="!w-32"><ElOption v-if="activeTab==='wallet'" label="现金" value="CASH"/><ElOption v-if="activeTab==='wallet'" label="赠送金" value="BONUS"/><ElOption v-if="activeTab==='wallet'" label="冻结" value="FROZEN"/><ElOption v-if="activeTab==='player'" label="可用余额" value="AVAILABLE"/><ElOption v-if="activeTab==='player'" label="冻结余额" value="FROZEN"/></ElSelect></ElFormItem>
          <ElFormItem label="方向"><DirectionSelect v-model="query.direction" /></ElFormItem>
        </template>
        <template v-else>
          <ElFormItem label="结算状态"><ElSelect v-model="query.status" clearable class="!w-32"><ElOption label="已结算" value="SETTLED"/></ElSelect></ElFormItem>
        </template>
        <ElFormItem><ElButton type="primary" @click="searchRows">筛选</ElButton><ElButton @click="resetRows">清空</ElButton></ElFormItem>
      </ElForm>

      <ElTable v-if="activeTab==='payments'" v-loading="loading" :data="rows" empty-text="暂无交易支付记录">
        <ElTableColumn prop="payment_no" label="支付流水号" min-width="205"/><ElTableColumn prop="order_no" label="业务单号" min-width="190"/>
        <ElTableColumn label="用户" min-width="130"><template #default="{row}">{{row.nickname || row.username}}</template></ElTableColumn>
        <ElTableColumn label="业务" width="105"><template #default="{row}">{{tradeTypeText(row.business_type)}}</template></ElTableColumn>
        <ElTableColumn label="渠道" width="105"><template #default="{row}">{{channelText(row.payment_channel)}}</template></ElTableColumn>
        <ElTableColumn label="应付" width="105"><template #default="{row}">¥ {{money(row.payable_amount)}}</template></ElTableColumn>
        <ElTableColumn label="实付构成" min-width="155"><template #default="{row}">现金 {{money(row.cash_amount)}} / 赠送 {{money(row.bonus_amount)}}</template></ElTableColumn>
        <ElTableColumn label="退款" width="105"><template #default="{row}">¥ {{money(Number(row.refunded_cash_amount||0)+Number(row.refunded_bonus_amount||0))}}</template></ElTableColumn>
        <ElTableColumn label="状态" width="90"><template #default="{row}"><ElTag :type="row.payment_status==='REFUNDED'?'warning':'success'">{{row.payment_status==='REFUNDED'?'已退款':'已支付'}}</ElTag></template></ElTableColumn>
        <ElTableColumn label="支付时间" min-width="165"><template #default="{row}">{{formatDateTime(row.paid_at)}}</template></ElTableColumn>
      </ElTable>

      <ElTable v-else-if="activeTab==='platform'" v-loading="loading" :data="rows" empty-text="暂无平台账本记录">
        <ElTableColumn prop="ledger_no" label="平台流水号" min-width="205"/><ElTableColumn prop="order_no" label="订单号" min-width="185"/>
        <ElTableColumn label="业务类型" min-width="155"><template #default="{row}">{{platformTypeText(row.business_type)}}</template></ElTableColumn>
        <ElTableColumn label="方向" width="85"><template #default="{row}"><DirectionTag :direction="row.direction"/></template></ElTableColumn>
        <ElTableColumn label="金额" width="125"><template #default="{row}"><AmountText :row="row"/></template></ElTableColumn>
        <ElTableColumn prop="remark" label="说明" min-width="200" show-overflow-tooltip/><ElTableColumn label="入账时间" min-width="165"><template #default="{row}">{{formatDateTime(row.created_at)}}</template></ElTableColumn>
      </ElTable>

      <ElTable v-else-if="activeTab==='wallet'" v-loading="loading" :data="rows" empty-text="暂无用户钱包流水">
        <ElTableColumn prop="transaction_no" label="流水号" min-width="205"/><ElTableColumn label="用户" min-width="130"><template #default="{row}">{{row.nickname || row.username || row.owner_id}}</template></ElTableColumn>
        <ElTableColumn prop="business_no" label="业务单号" min-width="175"/><ElTableColumn prop="business_type" label="业务类型" min-width="145"/>
        <ElTableColumn label="余额账户" width="95"><template #default="{row}">{{balanceText(row.balance_type)}}</template></ElTableColumn><ElTableColumn label="变动" width="120"><template #default="{row}"><AmountText :row="row"/></template></ElTableColumn>
        <ElTableColumn label="余额前后" min-width="155"><template #default="{row}">{{money(row.balance_before)}} → {{money(row.balance_after)}}</template></ElTableColumn><ElTableColumn prop="remark" label="说明" min-width="180" show-overflow-tooltip/><ElTableColumn label="时间" min-width="165"><template #default="{row}">{{formatDateTime(row.created_at)}}</template></ElTableColumn>
      </ElTable>

      <ElTable v-else-if="activeTab==='player'" v-loading="loading" :data="rows" empty-text="暂无陪玩师账户流水">
        <ElTableColumn prop="transaction_no" label="流水号" min-width="205"/><ElTableColumn label="陪玩师" min-width="150"><template #default="{row}">{{row.nickname}}（{{row.player_no}}）</template></ElTableColumn>
        <ElTableColumn prop="business_no" label="业务单号" min-width="175"/><ElTableColumn prop="business_type" label="业务类型" min-width="155"/>
        <ElTableColumn label="余额账户" width="100"><template #default="{row}">{{balanceText(row.balance_type)}}</template></ElTableColumn><ElTableColumn label="变动" width="120"><template #default="{row}"><AmountText :row="row"/></template></ElTableColumn>
        <ElTableColumn label="余额前后" min-width="155"><template #default="{row}">{{money(row.balance_before)}} → {{money(row.balance_after)}}</template></ElTableColumn><ElTableColumn prop="remark" label="说明" min-width="190" show-overflow-tooltip/><ElTableColumn label="时间" min-width="165"><template #default="{row}">{{formatDateTime(row.created_at)}}</template></ElTableColumn>
      </ElTable>

      <ElTable v-else v-loading="loading" :data="rows" empty-text="暂无订单结算记录">
        <ElTableColumn prop="settlement_no" label="结算单号" min-width="205"/><ElTableColumn prop="order_no" label="订单号" min-width="190"/>
        <ElTableColumn label="用户" min-width="130"><template #default="{row}">{{row.nickname || row.username}}</template></ElTableColumn><ElTableColumn label="订单金额" width="110"><template #default="{row}">¥ {{money(row.order_amount)}}</template></ElTableColumn>
        <ElTableColumn label="平台所得" width="110"><template #default="{row}"><span class="income">¥ {{money(row.platform_amount)}}</span></template></ElTableColumn><ElTableColumn label="陪玩分配" width="110"><template #default="{row}">¥ {{money(row.distributable_amount)}}</template></ElTableColumn>
        <ElTableColumn prop="player_count" label="分配人数" width="90"/><ElTableColumn label="状态" width="90"><template #default><ElTag type="success">已结算</ElTag></template></ElTableColumn><ElTableColumn label="结算时间" min-width="165"><template #default="{row}">{{formatDateTime(row.settled_at)}}</template></ElTableColumn>
      </ElTable>

      <div class="pagination"><ElPagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total" layout="total, sizes, prev, pager, next" @change="loadRows"/></div>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
import { defineComponent, h } from 'vue'
import { ElOption, ElSelect, ElTag } from 'element-plus'
import { fetchFinancePayments,fetchFinancePlatformLedger,fetchFinancePlayerTransactions,fetchFinanceSettlements,fetchFinanceSummary,fetchFinanceWalletTransactions } from '@/api/business-manage'
import { formatDateTime } from '@/utils/date'

const DirectionSelect=defineComponent({props:{modelValue:String},emits:['update:modelValue'],setup(props,{emit}){return()=>h(ElSelect,{modelValue:props.modelValue,clearable:true,class:'!w-28','onUpdate:modelValue':(v:string)=>emit('update:modelValue',v)},()=>[h(ElOption,{label:'收入',value:'IN'}),h(ElOption,{label:'支出',value:'OUT'})])}})
const DirectionTag=defineComponent({props:{direction:String},setup:p=>()=>h(ElTag,{type:p.direction==='IN'?'success':'danger',effect:'plain'},()=>p.direction==='IN'?'收入':'支出')})
const AmountText=defineComponent({props:{row:{type:Object,required:true}},setup:p=>()=>h('span',{class:p.row.direction==='IN'?'income':'expense'},`${p.row.direction==='IN'?'+':'-'} ¥ ${money(p.row.amount)}`)})

const loading=ref(false),activeTab=ref('payments'),rows=ref<any[]>([]),total=ref(0),summary=ref<any>({}),dateRange=ref<string[]>([])
const query=reactive<any>({current:1,size:20,keyword:'',businessType:'',status:'',channel:'',direction:'',balanceType:''})
const platformTypes=[{label:'服务订单佣金',value:'SERVICE_COMMISSION'},{label:'转单责任扣款',value:'SERVICE_TRANSFER_PENALTY'},{label:'炸单责任扣款',value:'SERVICE_ABORT_PENALTY'}]
const summaryCards=computed(()=>[
  {label:'实际支付',value:summary.value.gross_paid_amount,note:`${summary.value.payment_count||0} 笔支付`,tone:'primary'},
  {label:'已退款',value:summary.value.refund_amount,note:'现金与赠送金退款',tone:'danger'},
  {label:'陪玩分成',value:summary.value.player_income_amount,note:`${summary.value.settlement_count||0} 笔已结算`,tone:'warning'},
  {label:'平台入账',value:summary.value.platform_income_amount,note:'佣金与责任扣款',tone:'success'},
  {label:'已提现',value:summary.value.withdrawn_amount,note:'审核通过并打款',tone:'neutral'},
  {label:'支付净额',value:Number(summary.value.gross_paid_amount||0)-Number(summary.value.refund_amount||0),note:'支付减退款，不代表利润',tone:'primary'}
])
const keywordPlaceholder=computed(()=>activeTab.value==='payments'?'支付号、订单号或用户':activeTab.value==='platform'?'平台流水号、订单号或说明':activeTab.value==='wallet'?'流水号、业务号或用户':activeTab.value==='player'?'流水号、业务号或陪玩师':'结算单号、订单号或用户')
const dateParams=()=>({dateFrom:dateRange.value?.[0]||undefined,dateTo:dateRange.value?.[1]||undefined})
const requestMap:any={payments:fetchFinancePayments,platform:fetchFinancePlatformLedger,wallet:fetchFinanceWalletTransactions,player:fetchFinancePlayerTransactions,settlement:fetchFinanceSettlements}
async function loadSummary(){summary.value=await fetchFinanceSummary(dateParams())}
async function loadRows(){loading.value=true;try{const d=await requestMap[activeTab.value]({...query,...dateParams()});rows.value=d.records||[];total.value=d.total||0}finally{loading.value=false}}
async function load(){await Promise.all([loadSummary(),loadRows()])}
function search(){query.current=1;load()}
function reset(){dateRange.value=[];query.current=1;load()}
function searchRows(){query.current=1;loadRows()}
function resetRows(){Object.assign(query,{current:1,keyword:'',businessType:'',status:'',channel:'',direction:'',balanceType:''});loadRows()}
function tabChanged(){resetRows()}
const money=(v:any)=>Number(v||0).toFixed(2)
const tradeTypeText=(v:string)=>({PLAYER_SERVICE:'陪玩服务',WALLET_RECHARGE:'钱包充值'}[v]||v)
const channelText=(v:string)=>({WALLET:'钱包',MOCK_WECHAT:'模拟微信',MOCK_RECHARGE:'模拟充值'}[v]||v)
const platformTypeText=(v:string)=>Object.fromEntries(platformTypes.map(x=>[x.value,x.label]))[v]||v
const balanceText=(v:string)=>({CASH:'现金',BONUS:'赠送金',FROZEN:'冻结余额',AVAILABLE:'可用余额'}[v]||v)
onMounted(load)
</script>

<style scoped>
.page-head{display:flex;align-items:center;justify-content:space-between;gap:20px}.page-title{font-size:22px;font-weight:700}.page-subtitle,.summary-label,.summary-note{color:var(--el-text-color-secondary)}.page-subtitle{margin-top:6px;font-size:13px}.date-actions{display:flex;align-items:center;gap:10px}.summary-card{min-height:128px}.summary-value{margin:14px 0 10px;font-size:25px;font-weight:700;white-space:nowrap}.summary-value.primary{color:var(--el-color-primary)}.summary-value.success,.income{color:var(--el-color-success);font-weight:600}.summary-value.danger,.expense{color:var(--el-color-danger);font-weight:600}.summary-value.warning{color:var(--el-color-warning)}.summary-value.neutral{color:var(--el-text-color-primary)}.summary-note{font-size:12px}.table-filter{margin-top:4px}.pagination{display:flex;justify-content:flex-end;margin-top:18px}@media(max-width:900px){.page-head{align-items:flex-start;flex-direction:column}.date-actions{width:100%;flex-wrap:wrap}.summary-card{margin-bottom:12px}}
</style>
