<template>
  <div class="art-full-height"
    ><ElCard class="mb-3"
      ><ElForm inline
        ><ElFormItem label="所属游戏"
          ><ElSelect v-model="query.gameId" clearable class="!w-40"
            ><ElOption
              v-for="g in games"
              :key="g.id"
              :label="g.gameName"
              :value="g.id" /></ElSelect></ElFormItem
        ><ElFormItem label="服务名称"><ElInput v-model="query.serviceName" clearable /></ElFormItem
        ><ElFormItem label="服务类型"
          ><ElSelect v-model="query.serviceType" clearable class="!w-36"
            ><ElOption
              v-for="x in types"
              :key="x.value"
              :label="x.label"
              :value="x.value" /></ElSelect></ElFormItem
        ><ElFormItem
          ><ElButton @click="reset">重置</ElButton
          ><ElButton type="primary" @click="search">查询</ElButton></ElFormItem
        ></ElForm
      ></ElCard
    ><ElCard class="art-table-card"
      ><ArtTableHeader :loading="loading" @refresh="load"
        ><template #left
          ><ElButton v-auth="'business:service:create'" @click="open()"
            >新增服务</ElButton
          ></template
        ></ArtTableHeader
      ><ElTable v-loading="loading" :data="rows"
        ><ElTableColumn prop="gameName" label="游戏" min-width="130" /><ElTableColumn
          prop="serviceCode"
          label="服务编码"
          min-width="160" /><ElTableColumn
          prop="serviceName"
          label="服务名称"
          min-width="150" /><ElTableColumn label="服务类型" width="110"
          ><template #default="{ row }"
            ><ElTag>{{ typeText(row.serviceType) }}</ElTag></template
          ></ElTableColumn
        ><ElTableColumn
          prop="description"
          label="说明"
          min-width="220"
          show-overflow-tooltip /><ElTableColumn
          prop="sortNo"
          label="排序"
          width="70" /><ElTableColumn label="状态" width="90"
          ><template #default="{ row }"
            ><ElSwitch
              v-model="row.enabled"
              :disabled="!has('business:service:status')"
              @change="(v) => status(row, Boolean(v))" /></template></ElTableColumn
        ><ElTableColumn label="操作" width="80" fixed="right"
          ><template #default="{ row }"
            ><ArtButtonMore
              :list="actions"
              @click="(i) => action(i.key, row)" /></template></ElTableColumn></ElTable
      ><div class="flex justify-end mt-4"
        ><ElPagination
          v-model:current-page="query.current"
          v-model:page-size="query.size"
          :total="total"
          @change="load"
          layout="total, sizes, prev, pager, next" /></div></ElCard
    ><ElDialog v-model="visible" :title="form.id ? '编辑基础服务' : '新增基础服务'" width="900px"
      ><ElForm label-width="90px"
        ><ElFormItem label="所属游戏" required
          ><ElSelect v-model="form.gameId" class="w-full" @change="gameChanged"
            ><ElOption
              v-for="g in games"
              :key="g.id"
              :label="g.gameName"
              :value="g.id" /></ElSelect></ElFormItem
        ><ElFormItem label="服务编码" required><ElInput v-model="form.serviceCode"><template #append><ElButton @click="form.serviceCode = generateBusinessCode('service')">重新生成</ElButton></template></ElInput></ElFormItem
        ><ElFormItem label="服务名称" required><ElInput v-model="form.serviceName" /></ElFormItem
        ><ElFormItem label="服务类型" required
          ><ElSelect v-model="form.serviceType" class="w-full"
            ><ElOption
              v-for="x in types"
              :key="x.value"
              :label="x.label"
              :value="x.value" /></ElSelect></ElFormItem
        ><ElFormItem label="服务说明"
          ><ElInput v-model="form.description" type="textarea" :rows="3" /></ElFormItem
        ><ElFormItem label="排序"><ElInputNumber v-model="form.sortNo" :min="0" /></ElFormItem
        ><ElFormItem label="启用"><ElSwitch v-model="form.enabled" /></ElFormItem></ElForm
      ><div class="flex items-center justify-between mb-3"><div><span class="font-medium">陪玩等级单价</span><span class="ml-2 text-xs text-gray-400">这里配置每人每小时 / 每局 / 每单的基础价格</span></div><ElButton plain type="primary" @click="addPricingUnit">新增计价单位</ElButton></div>
      <ElTable :data="pricingUnits" border>
        <ElTableColumn label="计价单位" width="130"><template #default="{row}"><ElSelect v-model="row.unitType"><ElOption v-for="u in unusedUnits(row.unitType)" :key="u.value" :label="u.label" :value="u.value" /></ElSelect></template></ElTableColumn>
        <ElTableColumn v-for="level in playerLevels" :key="level.id" :label="`${level.levelName}单价`" min-width="145"><template #default="{row}"><ElInputNumber v-model="priceEntry(row.unitType,level.id).price" :min="0" :precision="2" :controls="false" placeholder="未配置" class="!w-full" /></template></ElTableColumn>
        <ElTableColumn label="操作" width="70"><template #default="{$index}"><ElButton link type="danger" @click="pricingUnits.splice($index,1)">删除</ElButton></template></ElTableColumn>
      </ElTable>
      <ElEmpty v-if="!playerLevels.length" :image-size="50" description="该游戏暂无陪玩等级，请先在陪玩等级中新增" />
      ><template #footer
        ><ElButton @click="visible = false">取消</ElButton
        ><ElButton type="primary" @click="save">保存</ElButton></template
      ></ElDialog
    ></div
  >
</template>
<script setup lang="ts">
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import {
    fetchServices,
    createService,
    updateService,
    setServiceStatus,
    deleteService,
    fetchGameOptions,
    fetchPlayerLevels
  } from '@/api/business-manage'
  import { useUserStore } from '@/store/modules/user'
  import { generateBusinessCode } from '@/utils/business-code'
  const store = useUserStore(),
    has = (c: string) => store.info.roles?.includes('admin') || store.info.buttons?.includes(c),
    loading = ref(false),
    rows = ref<Api.Business.ServiceItem[]>([]),
    games = ref<Api.Business.Game[]>([]),
    playerLevels = ref<any[]>([]),
    pricingUnits = ref<any[]>([]),
    total = ref(0),
    visible = ref(false),
    query = reactive<any>({
      current: 1,
      size: 20,
      gameId: undefined,
      serviceName: '',
      serviceType: ''
    }),
    form = reactive<any>({}),
    types = [
      { value: 'COMPANION', label: '普通陪玩' },
      { value: 'RANKING', label: '排位上分' },
      { value: 'TEACHING', label: '教学' },
      { value: 'ESCORT', label: '护航' },
      { value: 'MAP_CLEAR', label: '清图' },
      { value: 'CUSTOM', label: '专项服务' }
    ],
    typeText = (v: string) => types.find((x) => x.value === v)?.label || v
  const actions = computed(() => [
    ...(has('business:service:update')
      ? [{ key: 'edit', label: '编辑', icon: 'ri:edit-line' }]
      : []),
    ...(has('business:service:delete')
      ? [{ key: 'delete', label: '删除', icon: 'ri:delete-bin-line', color: '#f56c6c' }]
      : [])
  ])
  async function load() {
    loading.value = true
    try {
      const [d, g] = await Promise.all([fetchServices(query), fetchGameOptions()])
      rows.value = d.records
      total.value = d.total
      games.value = g
    } finally {
      loading.value = false
    }
  }
  function search() {
    query.current = 1
    load()
  }
  function reset() {
    query.gameId = undefined
    query.serviceName = ''
    query.serviceType = ''
    search()
  }
  const units = [{value:'HOUR',label:'小时'},{value:'GAME',label:'局'},{value:'ORDER',label:'单'}]
  function unusedUnits(current:string){return units.filter((u)=>u.value===current||!pricingUnits.value.some((x)=>x.unitType===u.value))}
  function addPricingUnit(){const next=units.find((u)=>!pricingUnits.value.some((x)=>x.unitType===u.value));if(next)pricingUnits.value.push({unitType:next.value});else ElMessage.info('小时、局、单均已添加')}
  function priceEntry(unitType:string,playerLevelId:number){let row=(form.levelPrices||[]).find((x:any)=>x.unitType===unitType&&Number(x.playerLevelId)===Number(playerLevelId));if(!row){row={unitType,playerLevelId,price:undefined,marketPrice:undefined,enabled:true};(form.levelPrices||(form.levelPrices=[])).push(row)}return row}
  async function gameChanged(){form.levelPrices=[];pricingUnits.value=[];playerLevels.value=form.gameId?await fetchPlayerLevels(form.gameId):[];addPricingUnit()}
  async function open(r?: any) {
    Object.assign(
      form,
      r || {
        id: null,
        gameId: games.value[0]?.id,
        serviceCode: generateBusinessCode('service'),
        serviceName: '',
        serviceType: 'COMPANION',
        description: '',
        sortNo: 0,
        enabled: true,
        levelPrices: []
      }
    )
    playerLevels.value = form.gameId ? await fetchPlayerLevels(form.gameId) : []
    pricingUnits.value = [...new Set((form.levelPrices || []).map((x:any)=>x.unitType))].map((unitType)=>({unitType}))
    if (!pricingUnits.value.length) addPricingUnit()
    visible.value = true
  }
  async function save() {
    if (!form.gameId || !form.serviceCode || !form.serviceName)
      return ElMessage.warning('请填写必填项')
    const activeUnits=new Set(pricingUnits.value.map((x)=>x.unitType))
    form.levelPrices=(form.levelPrices||[]).filter((x:any)=>activeUnits.has(x.unitType)&&x.price!=null)
    form.id ? await updateService(form.id, form) : await createService(form)
    visible.value = false
    load()
  }
  async function status(r: any, v: boolean) {
    try {
      await setServiceStatus(r.id, v)
    } catch {
      load()
    }
  }
  async function action(k: any, r: any) {
    if (k === 'edit') open(r)
    else {
      await ElMessageBox.confirm(`确定删除“${r.serviceName}”吗？`, '删除确认', { type: 'warning' })
      await deleteService(r.id)
      load()
    }
  }
  onMounted(load)
</script>
