<template>
  <div class="log-page art-full-height">
    <ElCard class="mb-3">
      <ElForm :inline="true" :model="query" class="!mb-[-18px]">
        <ElFormItem label="操作人"><ElInput v-model="query.operator" clearable placeholder="请输入账号" /></ElFormItem>
        <ElFormItem label="权限编码"><ElInput v-model="query.operation" clearable placeholder="system:user:update" /></ElFormItem>
        <ElFormItem label="对象类型"><ElInput v-model="query.targetType" clearable placeholder="USER / ROLE / MENU" /></ElFormItem>
        <ElFormItem><ElButton @click="reset">重置</ElButton><ElButton type="primary" @click="search">查询</ElButton></ElFormItem>
      </ElForm>
    </ElCard>
    <ElCard class="log-table-card art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load" />
      <ElTable class="log-table" height="100%" v-loading="loading" :data="records">
        <ElTableColumn prop="operatorName" label="操作人" min-width="120" />
        <ElTableColumn prop="operation" label="权限编码" min-width="210" show-overflow-tooltip />
        <ElTableColumn prop="targetType" label="对象类型" width="110" />
        <ElTableColumn prop="targetId" label="对象 ID" width="100" />
        <ElTableColumn prop="detail" label="操作内容" min-width="220" show-overflow-tooltip />
        <ElTableColumn prop="ipAddress" label="IP 地址" min-width="140" />
        <ElTableColumn label="操作时间" width="180"><template #default="{row}">{{ formatDateTime(row.createTime) }}</template></ElTableColumn>
      </ElTable>
      <div class="log-pagination"><ElPagination v-model:current-page="query.current" v-model:page-size="query.size" :page-sizes="[10,20,50,100]" :total="total" layout="total, sizes, prev, pager, next, jumper" @change="load" /></div>
    </ElCard>
  </div>
</template>
<script setup lang="ts">
  import { fetchGetOperationLogs } from '@/api/system-manage'
  import { formatDateTime } from '@/utils/date'
  defineOptions({name:'OperationLog'})
  const loading=ref(false);const records=ref<Api.SystemManage.OperationLogItem[]>([]);const total=ref(0)
  const query=reactive({current:1,size:20,operator:'',operation:'',targetType:''})
  async function load(){loading.value=true;try{const data=await fetchGetOperationLogs(query);records.value=data.records;total.value=data.total}finally{loading.value=false}}
  function search(){query.current=1;load()} function reset(){query.operator='';query.operation='';query.targetType='';search()} onMounted(load)
</script>
<style scoped>
  .log-table-card :deep(.el-card__body) { display:flex; flex-direction:column; min-height:0; }
  .log-table { flex:1; min-height:0; }
  .log-pagination { display:flex; flex-shrink:0; justify-content:flex-end; padding-top:16px; }
</style>
