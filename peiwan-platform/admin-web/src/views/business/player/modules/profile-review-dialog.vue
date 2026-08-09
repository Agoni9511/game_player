<template>
  <ElDialog v-model="visible" title="陪玩师资料变更审核" width="900px" top="5vh" @open="load">
    <ElTable v-loading="loading" :data="rows" empty-text="暂无待审核资料">
      <ElTableColumn prop="playerNo" label="陪玩师编号" min-width="150" />
      <ElTableColumn prop="nickname" label="当前昵称" min-width="130" />
      <ElTableColumn prop="submittedAt" label="提交时间" min-width="180" />
      <ElTableColumn label="状态" width="100"><template #default="{ row }"><ElTag type="warning">{{ statusText(row.draftStatus) }}</ElTag></template></ElTableColumn>
      <ElTableColumn label="操作" width="90"><template #default="{ row }"><ElButton link type="primary" @click="openDetail(row.id)">审核</ElButton></template></ElTableColumn>
    </ElTable>

    <ElDrawer v-model="drawer" title="资料变更详情" size="680px" append-to-body>
      <template v-if="detail">
        <ElAlert type="warning" :closable="false" title="审核通过后，以下资料将覆盖当前正式资料。" class="mb-4" />
        <ElDescriptions :column="2" border>
          <ElDescriptionsItem label="展示昵称">{{ detail.draft.nickname }}</ElDescriptionsItem>
          <ElDescriptionsItem label="真实姓名">{{ detail.draft.realName || '-' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="手机号">{{ detail.draft.phone || '-' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="邮箱">{{ detail.draft.email || '-' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="性别">{{ genderText(detail.draft.gender) }}</ElDescriptionsItem>
          <ElDescriptionsItem label="提交时间">{{ detail.submittedAt || '-' }}</ElDescriptionsItem>
          <ElDescriptionsItem label="个人介绍" :span="2">{{ detail.draft.introduction || '-' }}</ElDescriptionsItem>
        </ElDescriptions>

        <h4>标签</h4>
        <ElSpace wrap><ElTag v-for="id in detail.draft.tagIds || []" :key="id" effect="plain">{{ tagName(id) }}</ElTag><span v-if="!detail.draft.tagIds?.length">未选择</span></ElSpace>

        <h4>游戏资料</h4>
        <ElCard v-for="game in detail.draft.games || []" :key="game.gameId" shadow="never" class="mb-3">
          <div class="game-title">{{ gameName(game.gameId) }}<ElTag v-if="game.primary" type="success" class="ml-2">主游戏</ElTag></div>
          <div class="muted mt-2">游戏昵称：{{ game.gameNickname || '-' }}　区服：{{ game.serverName || '-' }}　段位：{{ game.rankName || '-' }}</div>
          <div class="muted mt-2">擅长位置：{{ positionNames(game.gameId, game.positionIds).join('、') || '未选择' }}</div>
          <ElLink v-if="game.proofUrl" :href="game.proofUrl" target="_blank" type="primary" class="mt-2">查看游戏证明</ElLink>
        </ElCard>
        <ElEmpty v-if="!detail.draft.games?.length" description="未填写游戏资料" :image-size="70" />

        <h4>展示媒体</h4>
        <ElSpace wrap>
          <template v-for="media in detail.draft.media || []" :key="media.mediaUrl">
            <ElImage v-if="['PHOTO','GAME_PROOF'].includes(media.mediaType)" :src="media.mediaUrl" :preview-src-list="imageUrls" class="media" fit="cover" />
            <ElLink v-else :href="media.mediaUrl" target="_blank" type="primary">{{ media.mediaType === 'VIDEO' ? '查看视频' : '播放语音' }}</ElLink>
          </template>
          <span v-if="!detail.draft.media?.length">未上传</span>
        </ElSpace>

        <div class="review-actions"><ElButton type="danger" @click="reject">驳回</ElButton><ElButton type="success" @click="approve">审核通过</ElButton></div>
      </template>
    </ElDrawer>
  </ElDialog>
</template>

<script setup lang="ts">
import { auditPlayerProfileDraft, fetchGameOptions, fetchGamePositions, fetchPlayerProfileDraft, fetchPlayerProfileDrafts, fetchTagOptions } from '@/api/business-manage'

const props = defineProps<{ modelValue: boolean }>()
const emit = defineEmits(['update:modelValue'])
const visible = computed({ get: () => props.modelValue, set: value => emit('update:modelValue', value) })
const loading = ref(false), rows = ref<any[]>([]), drawer = ref(false), detail = ref<any>()
const games = ref<any[]>([]), tags = ref<any[]>([]), positions = reactive<Record<number, any[]>>({})
const imageUrls = computed(() => (detail.value?.draft?.media || []).filter((item:any) => ['PHOTO','GAME_PROOF'].includes(item.mediaType)).map((item:any) => item.mediaUrl))

async function load() { loading.value = true; try { [rows.value, games.value, tags.value] = await Promise.all([fetchPlayerProfileDrafts(), fetchGameOptions(), fetchTagOptions()]) } finally { loading.value = false } }
async function openDetail(id:number) { detail.value = await fetchPlayerProfileDraft(id); await Promise.all((detail.value.draft.games || []).map(async (game:any) => { positions[game.gameId] = await fetchGamePositions(game.gameId) })); drawer.value = true }
async function approve() { await ElMessageBox.confirm('确认通过本次资料变更吗？','审核确认'); await auditPlayerProfileDraft(detail.value.id,'APPROVE','资料变更审核通过'); ElMessage.success('审核已通过'); drawer.value = false; await load() }
async function reject() { const result = await ElMessageBox.prompt('请输入驳回原因','驳回资料',{ inputValidator:value => Boolean(value) || '必须填写驳回原因' }); await auditPlayerProfileDraft(detail.value.id,'REJECT',result.value); ElMessage.success('资料已驳回'); drawer.value = false; await load() }
const statusText = (status:string) => ({ PENDING:'待审核',APPROVED:'已通过',REJECTED:'已驳回',DRAFT:'草稿' }[status] || status)
const genderText = (gender:string) => ({ MALE:'男',FEMALE:'女',UNKNOWN:'未知' }[gender] || '未知')
const gameName = (id:number) => games.value.find(item => item.id === id)?.gameName || `游戏 ${id}`
const tagName = (id:number) => tags.value.find(item => item.id === id)?.tagName || `标签 ${id}`
const positionNames = (gameId:number, ids:number[] = []) => (positions[gameId] || []).filter(item => ids.includes(item.id)).map(item => item.positionName)
</script>

<style scoped>
.game-title{font-weight:700}.muted{color:#858b91}.media{width:100px;height:100px;border-radius:8px}.review-actions{position:sticky;bottom:0;margin-top:28px;padding:18px 0;display:flex;justify-content:flex-end;background:#fff}
</style>
