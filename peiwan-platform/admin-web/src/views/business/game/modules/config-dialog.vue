<template>
  <ElDialog v-model="visible" :title="`${game?.gameName || ''} · 区服与段位`" width="900px" destroy-on-close @open="load">
    <ElTabs>
      <ElTabPane label="区服配置">
        <div class="toolbar"><ElButton type="primary" @click="servers.push(blankServer())">新增区服</ElButton></div>
        <ElTable :data="servers" border>
          <ElTableColumn label="编码"><template #default="{row}"><ElInput v-model="row.serverCode" /></template></ElTableColumn>
          <ElTableColumn label="区服名称"><template #default="{row}"><ElInput v-model="row.serverName" /></template></ElTableColumn>
          <ElTableColumn label="排序" width="110"><template #default="{row}"><ElInputNumber v-model="row.sortNo" :min="0" controls-position="right" /></template></ElTableColumn>
          <ElTableColumn label="启用" width="80"><template #default="{row}"><ElSwitch v-model="row.enabled" /></template></ElTableColumn>
          <ElTableColumn label="操作" width="130"><template #default="{row}"><ElButton link type="primary" @click="saveServer(row)">保存</ElButton><ElButton link type="danger" @click="removeServer(row)">删除</ElButton></template></ElTableColumn>
        </ElTable>
      </ElTabPane>
      <ElTabPane label="段位配置">
        <div class="toolbar"><ElButton type="primary" @click="systems.push(blankSystem())">新增段位体系</ElButton></div>
        <ElCollapse accordion>
          <ElCollapseItem v-for="system in systems" :key="system.id || system._key" :name="system.id || system._key">
            <template #title><strong>{{ system.systemName || '新段位体系' }}</strong><span class="summary">{{ system.ranks?.length || 0 }} 个段位</span></template>
            <ElForm inline>
              <ElFormItem label="体系编码"><ElInput v-model="system.systemCode" /></ElFormItem><ElFormItem label="体系名称"><ElInput v-model="system.systemName" /></ElFormItem><ElFormItem label="说明"><ElInput v-model="system.description" /></ElFormItem><ElFormItem><ElSwitch v-model="system.enabled" active-text="启用" /></ElFormItem><ElFormItem><ElButton type="primary" @click="saveSystem(system)">保存体系</ElButton><ElButton type="danger" plain @click="removeSystem(system)">删除体系</ElButton></ElFormItem>
            </ElForm>
            <div class="toolbar"><ElButton size="small" @click="system.ranks.push(blankRank())">新增段位</ElButton></div>
            <ElTable :data="system.ranks" size="small" border>
              <ElTableColumn label="编码"><template #default="{row}"><ElInput v-model="row.rankCode" /></template></ElTableColumn><ElTableColumn label="段位名称"><template #default="{row}"><ElInput v-model="row.rankName" /></template></ElTableColumn><ElTableColumn label="层级" width="100"><template #default="{row}"><ElInputNumber v-model="row.tierNo" :min="0" controls-position="right" /></template></ElTableColumn><ElTableColumn label="排序" width="100"><template #default="{row}"><ElInputNumber v-model="row.sortNo" :min="0" controls-position="right" /></template></ElTableColumn><ElTableColumn label="启用" width="70"><template #default="{row}"><ElSwitch v-model="row.enabled" /></template></ElTableColumn><ElTableColumn label="操作" width="120"><template #default="{row}"><ElButton link type="primary" :disabled="!system.id" @click="saveRank(system,row)">保存</ElButton><ElButton link type="danger" @click="removeRank(system,row)">删除</ElButton></template></ElTableColumn>
            </ElTable>
          </ElCollapseItem>
        </ElCollapse>
      </ElTabPane>
    </ElTabs>
    <template #footer><ElButton @click="visible=false">关闭</ElButton></template>
  </ElDialog>
</template>
<script setup lang="ts">
import{fetchGameConfig,createGameServer,updateGameServer,deleteGameServer,createRankSystem,updateRankSystem,deleteRankSystem,createGameRank,updateGameRank,deleteGameRank}from '@/api/business-manage'
const props=defineProps<{modelValue:boolean;game?:any}>(),emit=defineEmits(['update:modelValue']),visible=computed({get:()=>props.modelValue,set:v=>emit('update:modelValue',v)}),servers=ref<any[]>([]),systems=ref<any[]>([])
const blankServer=()=>({serverCode:'',serverName:'',sortNo:servers.value.length+1,enabled:true}),blankSystem=()=>({_key:Date.now()+Math.random(),systemCode:'',systemName:'',description:'',sortNo:systems.value.length+1,enabled:true,ranks:[]}),blankRank=()=>({rankCode:'',rankName:'',tierNo:0,sortNo:0,enabled:true})
async function load(){if(!props.game?.id)return;const data=await fetchGameConfig(props.game.id);servers.value=data.servers;systems.value=data.rankSystems}
async function saveServer(row:any){if(!row.serverCode||!row.serverName)return ElMessage.warning('请填写区服编码和名称');row.id?await updateGameServer(props.game.id,row.id,row):await createGameServer(props.game.id,row);ElMessage.success('区服已保存');await load()}
async function removeServer(row:any){if(row.id){await ElMessageBox.confirm('确定删除该区服吗？','删除确认');await deleteGameServer(row.id)}else servers.value.splice(servers.value.indexOf(row),1);await load()}
async function saveSystem(row:any){if(!row.systemCode||!row.systemName)return ElMessage.warning('请填写体系编码和名称');row.id?await updateRankSystem(props.game.id,row.id,row):await createRankSystem(props.game.id,row);ElMessage.success('段位体系已保存');await load()}
async function removeSystem(row:any){if(row.id){await ElMessageBox.confirm('将同时删除该体系下未使用的段位，确定继续吗？','删除确认');await deleteRankSystem(row.id)}else systems.value.splice(systems.value.indexOf(row),1);await load()}
async function saveRank(system:any,row:any){if(!row.rankCode||!row.rankName)return ElMessage.warning('请填写段位编码和名称');row.id?await updateGameRank(system.id,row.id,row):await createGameRank(system.id,row);ElMessage.success('段位已保存');await load()}
async function removeRank(system:any,row:any){if(row.id){await ElMessageBox.confirm('确定删除该段位吗？','删除确认');await deleteGameRank(row.id)}else system.ranks.splice(system.ranks.indexOf(row),1);await load()}
</script>
<style scoped>.toolbar{display:flex;justify-content:flex-end;margin-bottom:12px}.summary{margin-left:12px;color:#909399;font-weight:400}</style>
