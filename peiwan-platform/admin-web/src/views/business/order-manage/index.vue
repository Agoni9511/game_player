<template>
  <div class="art-full-height">
    <ElCard class="mb-3">
      <ElForm inline>
        <ElFormItem label="订单号"><ElInput v-model="query.orderNo" clearable /></ElFormItem>
        <ElFormItem label="下单用户"><ElInput v-model="query.customerName" clearable /></ElFormItem>
        <ElFormItem label="订单状态">
          <ElSelect v-model="query.orderStatus" clearable class="!w-36">
            <ElOption v-for="(x, k) in statusMeta" :key="k" :label="x.text" :value="k" />
          </ElSelect>
        </ElFormItem>
        <ElFormItem><ElButton @click="reset">重置</ElButton><ElButton type="primary" @click="search">查询</ElButton></ElFormItem>
      </ElForm>
    </ElCard>
    <ElCard class="art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load"><template #left><ElButton v-auth="'business:order:create'" @click="openCreate">创建订单</ElButton></template></ArtTableHeader>
      <ElTable v-loading="loading" :data="rows">
        <ElTableColumn prop="orderNo" label="订单号" min-width="190" />
        <ElTableColumn prop="productName" label="商品" min-width="170" show-overflow-tooltip />
        <ElTableColumn label="下单用户" min-width="130"><template #default="{ row }">{{ row.customerNickname || row.customerUsername }}</template></ElTableColumn>
        <ElTableColumn label="应付金额" width="110"><template #default="{ row }"><span class="text-red-500">¥ {{ money(row.payableAmount) }}</span></template></ElTableColumn>
        <ElTableColumn label="接单成员" min-width="120"><template #default="{ row }"><ElTag v-if="row.memberCount" type="success" effect="plain">{{ row.memberCount }}/{{ row.requiredPlayerCount || 1 }} 人</ElTag><span v-else>-</span></template></ElTableColumn>
        <ElTableColumn label="状态" width="100"><template #default="{ row }"><ElTag :type="statusMeta[row.orderStatus]?.type">{{ statusMeta[row.orderStatus]?.text || row.orderStatus }}</ElTag></template></ElTableColumn>
        <ElTableColumn prop="createTime" label="创建时间" min-width="165" />
        <ElTableColumn label="操作" width="80" fixed="right"><template #default="{ row }"><ArtButtonMore :list="actions(row)" @click="(i) => action(i.key, row)" /></template></ElTableColumn>
      </ElTable>
      <div class="flex justify-end mt-4"><ElPagination v-model:current-page="query.current" v-model:page-size="query.size" :total="total" layout="total, sizes, prev, pager, next" @change="load" /></div>
    </ElCard>

    <CreateOrderPage v-model="createVisible" @saved="load" />

    <ElDrawer v-model="detailVisible" title="订单详情" size="620px">
      <template v-if="detail">
        <ElDescriptions :column="2" border>
          <ElDescriptionsItem label="订单号" :span="2">{{ detail.orderNo }}</ElDescriptionsItem>
          <ElDescriptionsItem label="用户">{{ detail.customerNickname || detail.customerUsername }}</ElDescriptionsItem>
          <ElDescriptionsItem label="状态">{{ statusMeta[detail.orderStatus]?.text }}</ElDescriptionsItem>
          <ElDescriptionsItem label="联系人">{{ detail.contactName || '-' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="电话">{{ detail.contactPhone || '-' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="应付金额">¥ {{ money(detail.payableAmount) }}</ElDescriptionsItem>
          <ElDescriptionsItem label="实付金额">¥ {{ money(detail.paidAmount) }}</ElDescriptionsItem>
          <ElDescriptionsItem label="计价方式">{{ detail.pricingMode==='PLAYER_LEVEL'?'陪玩等级价':'SKU 固定价' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="要求等级">{{ detail.playerLevelName || '未指定（SKU 兜底）' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="接单进度" :span="2">{{ detail.memberCount || 0 }}/{{ detail.requiredPlayerCount || 1 }} 人</ElDescriptionsItem>
        </ElDescriptions>
        <h4 class="my-4">订单成员</h4>
        <ElTable :data="detail.members || []" border empty-text="暂无陪玩师接单"><ElTableColumn label="陪玩师" min-width="150"><template #default="{row}"><div class="flex items-center gap-2"><ElAvatar :size="28" :src="row.avatarUrl"/>{{row.playerName}}（{{row.playerNo}}）</div></template></ElTableColumn><ElTableColumn label="成员状态" width="105"><template #default="{row}">{{memberText[row.memberStatus] || row.memberStatus}}</template></ElTableColumn><ElTableColumn label="接单来源" width="95"><template #default="{row}">{{sourceText[row.joinSource] || row.joinSource}}</template></ElTableColumn><ElTableColumn prop="joinedAt" label="接单时间" min-width="165"/></ElTable>
        <h4 class="my-4">商品快照</h4>
        <ElTable :data="detail.items" border><ElTableColumn prop="productName" label="商品" /><ElTableColumn prop="skuName" label="规格" /><ElTableColumn label="单价" width="90"><template #default="{ row }">¥ {{ money(row.unitPrice) }}</template></ElTableColumn><ElTableColumn label="价格来源" width="105"><template #default="{row}">{{row.pricingRuleId?'等级规则':'SKU 兜底'}}</template></ElTableColumn><ElTableColumn prop="quantity" label="数量" width="65" /></ElTable>
        <ElDivider content-position="left">订单承诺</ElDivider>
        <ElTable :data="detail.commitments || []" border empty-text="本单无承诺规则"><ElTableColumn prop="title" label="承诺" min-width="130"/><ElTableColumn label="目标" width="100"><template #default="{row}">{{row.targetValue==null?'-':`${row.targetValue}${row.targetUnit||''}`}}</template></ElTableColumn><ElTableColumn prop="description" label="规则说明" min-width="160"/><ElTableColumn prop="failureAction" label="未达标处理" min-width="150"/></ElTable>
        <h4 class="my-4">用户游戏资料</h4>
        <ElDescriptions v-if="detail.gameProfile" :column="2" border><ElDescriptionsItem label="游戏">{{ detail.gameProfile.gameName }}</ElDescriptionsItem><ElDescriptionsItem label="区服">{{ detail.gameProfile.serverName || '-' }}</ElDescriptionsItem><ElDescriptionsItem label="账号">{{ detail.gameProfile.gameAccount || '-' }}</ElDescriptionsItem><ElDescriptionsItem label="昵称">{{ detail.gameProfile.gameNickname || '-' }}</ElDescriptionsItem><ElDescriptionsItem label="服务要求" :span="2">{{ detail.gameProfile.extraRequirement || '-' }}</ElDescriptionsItem></ElDescriptions>
        <h4 class="my-4">状态记录</h4>
        <ElTimeline><ElTimelineItem v-for="x in detail.statusLogs" :key="x.id" :timestamp="x.createTime" placement="top"><div>{{ statusMeta[x.toStatus]?.text || x.toStatus }}</div><small>{{ x.operatorName || '系统' }}{{ x.reason ? ` · ${x.reason}` : '' }}</small></ElTimelineItem></ElTimeline>
      </template>
    </ElDrawer>

    <ElDialog v-model="assignVisible" title="发起派单" width="720px">
      <ElForm label-width="90px"><ElFormItem label="派单模式"><ElRadioGroup v-model="assignForm.dispatchMode"><ElRadioButton value="DIRECT">指定派单</ElRadioButton><ElRadioButton value="GRAB">发布抢单</ElRadioButton></ElRadioGroup></ElFormItem></ElForm>
      <ElTable :data="players" border highlight-current-row @current-change="x=>assignForm.targetPlayerId=x?.playerId"><ElTableColumn label="陪玩师"><template #default="{row}">{{row.playerName}}（{{row.playerNo}}）</template></ElTableColumn><ElTableColumn prop="ratingScore" label="评分" width="80"/><ElTableColumn prop="activeOrderCount" label="进行中" width="80"/><ElTableColumn prop="matchScore" label="匹配分" width="90"/><ElTableColumn v-if="assignForm.dispatchMode==='DIRECT'" label="选择" width="65"><template #default="{row}"><ElRadio v-model="assignForm.targetPlayerId" :value="row.playerId"><span></span></ElRadio></template></ElTableColumn></ElTable>
      <template #footer><ElButton @click="assignVisible = false">取消</ElButton><ElButton type="primary" @click="saveAssign">{{assignForm.dispatchMode==='DIRECT'?'发送指定邀请':'发布抢单'}}</ElButton></template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import CreateOrderPage from './modules/create-order-page.vue'
  import { fetchOrders, fetchOrder, setOrderStatus, confirmOrderPayment, fetchEligiblePlayers, createDispatch } from '@/api/business-manage'
  import { useUserStore } from '@/store/modules/user'
  const store = useUserStore(), has = (c: string) => store.info.roles?.includes('admin') || store.info.buttons?.includes(c)
  const loading = ref(false), rows = ref<Api.Business.Order[]>([]), total = ref(0), createVisible = ref(false), detailVisible = ref(false), assignVisible = ref(false), detail = ref<Api.Business.Order>(), players = ref<any[]>([]), currentOrder = ref<any>()
  const query = reactive<any>({ current: 1, size: 20, orderNo: '', customerName: '', orderStatus: '' }), assignForm = reactive<any>({})
  const statusMeta: any = { PENDING_PAYMENT: { text: '待支付', type: 'warning' }, WAIT_ASSIGN: { text: '待接单', type: 'primary' }, ASSIGNED: { text: '成员已满', type: 'primary' }, IN_SERVICE: { text: '服务中', type: 'success' }, PAUSED: { text: '已暂停', type: 'warning' }, PENDING_CONFIRM: { text: '待履约审核', type: 'warning' }, WAIT_CUSTOMER_CONFIRM: { text: '待顾客确认', type: 'warning' }, COMPLETED: { text: '已完成', type: 'success' }, CANCELLED: { text: '已取消', type: 'info' } }
  const memberText: Record<string, string> = { ACCEPTED: '已接单', IN_SERVICE: '服务中', COMPLETED: '已完成', CANCELLED: '已取消' }
  const sourceText: Record<string, string> = { ADMIN: '后台分配', DIRECT: '指定邀请', GRAB: '公开抢单', MIGRATION: '历史迁移' }
  const money = (v: any) => Number(v || 0).toFixed(2)
  async function load() { loading.value = true; try { const d = await fetchOrders(query); rows.value = d.records; total.value = d.total } finally { loading.value = false } }
  function search() { query.current = 1; load() }
  function reset() { Object.assign(query, { current: 1, orderNo: '', customerName: '', orderStatus: '' }); load() }
  function openCreate() { createVisible.value = true }
  function actions(row: any) { const a: any[] = [{ key: 'detail', label: '查看详情', icon: 'ri:eye-line' }]; if (has('business:order:status') && row.orderStatus === 'PENDING_PAYMENT') a.push({ key: 'pay', label: '确认收款', icon: 'ri:bank-card-line' }); if (has('business:order:assign') && row.orderStatus === 'WAIT_ASSIGN') a.push({ key: 'assign', label: '分配陪玩师', icon: 'ri:user-add-line' }); if (has('business:order:status') && row.orderStatus === 'ASSIGNED') a.push({ key: 'start', label: '开始服务', icon: 'ri:play-circle-line' }); if (has('business:order:status') && row.orderStatus === 'IN_SERVICE') a.push({ key: 'complete', label: '完成服务', icon: 'ri:checkbox-circle-line' }); if (has('business:order:status') && ['PENDING_PAYMENT', 'WAIT_ASSIGN', 'ASSIGNED'].includes(row.orderStatus)) a.push({ key: 'cancel', label: '取消订单', icon: 'ri:close-circle-line', color: '#f56c6c' }); return a }
  async function action(key: string | number, row: any) { if (key === 'detail') { detail.value = await fetchOrder(row.id); detailVisible.value = true; return } if (key === 'assign') { currentOrder.value = row; players.value = await fetchEligiblePlayers(row.id); Object.assign(assignForm, { dispatchMode: 'DIRECT', targetPlayerId: undefined }); assignVisible.value = true; return } if(key==='pay'){await ElMessageBox.confirm('确认已通过微信或线下方式收到本订单款项吗？','确认收款');await confirmOrderPayment(row.id,'MANUAL_WECHAT');ElMessage.success('已确认收款');load();return} const target: any = { start: 'IN_SERVICE', complete: 'COMPLETED', cancel: 'CANCELLED' }[key]; let reason = ''; if (key === 'cancel') reason = await ElMessageBox.prompt('请输入取消原因', '取消订单', { inputValidator: (v) => Boolean(v) || '请输入取消原因' }).then((x) => x.value); else await ElMessageBox.confirm(`确定执行“${{ start: '开始服务', complete: '完成服务' }[key as string]}”吗？`, '订单操作'); await setOrderStatus(row.id, target, reason); load() }
  async function saveAssign() { if(assignForm.dispatchMode==='DIRECT'&&!assignForm.targetPlayerId)return ElMessage.warning('请选择陪玩师');await createDispatch({orderId:currentOrder.value.id,dispatchMode:assignForm.dispatchMode,targetPlayerId:assignForm.dispatchMode==='DIRECT'?assignForm.targetPlayerId:null});assignVisible.value=false;ElMessage.success(assignForm.dispatchMode==='DIRECT'?'指定邀请已发送':'抢单任务已发布');load() }
  onMounted(load)
</script>
