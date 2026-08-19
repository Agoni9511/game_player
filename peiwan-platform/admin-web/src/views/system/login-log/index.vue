<template>
  <div class="log-page art-full-height">
    <ElCard class="mb-3">
      <ElForm :inline="true" :model="query" class="!mb-[-18px]">
        <ElFormItem label="登录账号"><ElInput v-model="query.username" clearable placeholder="请输入账号" @keyup.enter="search" /></ElFormItem>
        <ElFormItem label="登录结果"><ElSelect v-model="query.success" clearable placeholder="全部" class="!w-36"><ElOption label="成功" :value="true" /><ElOption label="失败" :value="false" /></ElSelect></ElFormItem>
        <ElFormItem><ElButton @click="reset">重置</ElButton><ElButton type="primary" @click="search">查询</ElButton></ElFormItem>
      </ElForm>
    </ElCard>
    <ElCard class="log-table-card art-table-card">
      <ArtTableHeader :loading="loading" @refresh="load" />
      <ElTable class="log-table" height="100%" v-loading="loading" :data="records">
        <ElTableColumn prop="username" label="登录账号" min-width="140" />
        <ElTableColumn label="登录结果" width="100"><template #default="{row}"><ElTag :type="row.success?'success':'danger'">{{ row.success?'成功':'失败' }}</ElTag></template></ElTableColumn>
        <ElTableColumn prop="ipAddress" label="IP 地址" min-width="140" />
        <ElTableColumn prop="message" label="结果说明" min-width="180" show-overflow-tooltip />
        <ElTableColumn prop="userAgent" label="客户端" min-width="260" show-overflow-tooltip />
        <ElTableColumn label="登录时间" width="180"><template #default="{row}">{{ formatDateTime(row.createTime) }}</template></ElTableColumn>
      </ElTable>
      <div class="log-pagination"><ElPagination v-model:current-page="query.current" v-model:page-size="query.size" :page-sizes="[10,20,50,100]" :total="total" layout="total, sizes, prev, pager, next, jumper" @change="load" /></div>
    </ElCard>
  </div>
</template>
<script setup lang="ts">
  import { fetchGetLoginLogs } from '@/api/system-manage'
  import { formatDateTime } from '@/utils/date'
  defineOptions({name:'LoginLog'})
  const loading=ref(false);const records=ref<Api.SystemManage.LoginLogItem[]>([]);const total=ref(0)
  const query=reactive<{current:number;size:number;username:string;success?:boolean}>({current:1,size:20,username:''})
  async function load(){loading.value=true;try{const data=await fetchGetLoginLogs(query);records.value=data.records;total.value=data.total}finally{loading.value=false}}
  function search(){query.current=1;load()} function reset(){query.username='';query.success=undefined;search()} onMounted(load)
</script>
<style scoped>
  .log-table-card :deep(.el-card__body) { display:flex; flex-direction:column; min-height:0; }
  .log-table { flex:1; min-height:0; }
  .log-pagination { display:flex; flex-shrink:0; justify-content:flex-end; padding-top:16px; }
</style>
