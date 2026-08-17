<template>
  <div class="player-editor-page">
    <div class="editor-heading">
      <div class="heading-main">
        <ElButton text class="back-button" @click="emit('cancel')">
          <ElIcon><ArrowLeft /></ElIcon>
          返回列表
        </ElButton>
        <div>
          <h2>{{ id ? '编辑陪玩师' : '新增陪玩师' }}</h2>
          <p>{{ id ? '维护陪玩师的基本资料、游戏能力和展示内容' : '创建陪玩师并配置完整资料' }}</p>
        </div>
      </div>
      <div class="heading-actions">
        <ElButton @click="emit('cancel')">取消</ElButton>
        <ElButton type="primary" :loading="saving" @click="save">保存</ElButton>
      </div>
    </div>
    <ElCard v-loading="loading" shadow="never" class="editor-card">
      <ElTabs v-model="tab"
      ><ElTabPane label="基本资料" name="base"
        ><ElForm label-width="90px"
          ><ElRow :gutter="16"
            ><ElCol :span="12"
              ><ElFormItem label="展示昵称" required
                ><ElInput v-model="form.nickname" /></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="绑定账号"
                ><ElSelect
                  v-model="form.userId"
                  clearable
                  filterable
                  class="w-full"
                  placeholder="选择尚未绑定的启用账号"
                  ><ElOption
                    v-for="u in users"
                    :key="u.id"
                    :value="u.id"
                    :label="`${u.label}（${u.username}）`" /></ElSelect></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="真实姓名"><ElInput v-model="form.realName" /></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="性别"
                ><ElSelect v-model="form.gender" class="w-full"
                  ><ElOption label="未知" value="UNKNOWN" /><ElOption
                    label="男"
                    value="MALE" /><ElOption
                    label="女"
                    value="FEMALE" /></ElSelect></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="手机号"><ElInput v-model="form.phone" /></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="邮箱"><ElInput v-model="form.email" /></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="陪玩师头像"
                ><LocalFileUpload
                  v-model="form.avatarUrl"
                  display="picture-card" /></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="主页封面"
                ><LocalFileUpload
                  v-model="form.coverUrl"
                  display="picture-card" /></ElFormItem></ElCol
            ><ElCol :span="24"
              ><ElFormItem label="个人介绍"
                ><ElInput
                  v-model="form.introduction"
                  type="textarea"
                  :rows="3" /></ElFormItem></ElCol
            ><ElCol :span="24"
              ><ElFormItem label="标签"
                ><ElSelect v-model="form.tagIds" multiple class="w-full"
                  ><ElOption
                    v-for="t in tags"
                    :key="t.id"
                    :label="t.tagName"
                    :value="t.id" /></ElSelect></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="同时接单"
                ><ElInputNumber
                  v-model="form.maxActiveOrders"
                  :min="1"
                  :max="20"
                  class="!w-full" /></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="排序"
                ><ElInputNumber v-model="form.sortNo" :min="0" /></ElFormItem></ElCol
            ><ElCol :span="12"
              ><ElFormItem label="启用"><ElSwitch v-model="form.enabled" /></ElFormItem></ElCol
            ><ElCol :span="24"
              ><ElFormItem label="后台备注"
                ><ElInput
                  v-model="form.remark"
                  type="textarea" /></ElFormItem></ElCol></ElRow></ElForm></ElTabPane
      ><ElTabPane label="游戏资料" name="games"
        ><div class="flex justify-end mb-3"><ElButton @click="addGame">添加游戏</ElButton></div
        ><ElCard v-for="(g, i) in form.games" :key="i" shadow="never" class="mb-3"
          ><div class="flex justify-between mb-3"
            ><span>游戏资料 {{ i + 1 }}</span
            ><ElButton link type="danger" @click="form.games.splice(i, 1)">移除</ElButton></div
          ><ElRow :gutter="12"
            ><ElCol :span="8"
              ><ElSelect
                v-model="g.gameId"
                placeholder="选择游戏"
                class="w-full"
                @change="changeGame(g)"
                ><ElOption
                  v-for="x in games"
                  :key="x.id"
                  :label="x.gameName"
                  :value="x.id" /></ElSelect></ElCol
            ><ElCol :span="8"><ElInput v-model="g.gameNickname" placeholder="游戏昵称" /></ElCol
            ><ElCol :span="8"
              ><ElSelect v-model="g.priceLevelId" class="w-full" placeholder="陪玩等级"
                ><ElOption
                  v-for="level in levelsForGame(g.gameId)"
                  :key="level.id"
                  :label="level.levelName"
                  :value="level.id" /></ElSelect></ElCol
            ><ElCol :span="8" class="mt-3"
              ><ElSelect v-model="g.serverId" clearable class="w-full" placeholder="选择区服"
                ><ElOption
                  v-for="server in gameConfigMap[g.gameId]?.servers || []"
                  :key="server.id"
                  :label="server.serverName"
                  :value="server.id" /></ElSelect></ElCol
            ><ElCol :span="8" class="mt-3"
              ><ElSelect v-model="g.rankId" clearable class="w-full" placeholder="选择段位"
                ><ElOption
                  v-for="rank in gameRanks(g.gameId)"
                  :key="rank.id"
                  :label="rank.rankName"
                  :value="rank.id" /></ElSelect></ElCol
            ><ElCol :span="16" class="mt-3"
              ><LocalFileUpload
                v-model="g.proofUrl"
                kind="PROOF"
                accept="image/jpeg,image/png,image/webp,application/pdf" /></ElCol
            ><ElCol :span="8" class="mt-3"
              ><ElCheckbox v-model="g.primary">设为主游戏</ElCheckbox
              ><ElCheckbox v-model="g.enabled">启用</ElCheckbox></ElCol
            ><ElCol :span="16" class="mt-3"
              ><ElSelect
                v-model="g.positionIds"
                multiple
                clearable
                placeholder="选择擅长位置"
                class="w-full"
                @change="validatePrimary(g)"
                ><ElOption
                  v-for="p in positionMap[g.gameId] || []"
                  :key="p.id"
                  :label="p.positionName"
                  :value="p.id"
                  :disabled="!p.enabled" /></ElSelect></ElCol
            ><ElCol :span="8" class="mt-3"
              ><ElSelect
                v-model="g.primaryPositionId"
                clearable
                placeholder="选择主位置"
                class="w-full"
                ><ElOption
                  v-for="p in selectedPositions(g)"
                  :key="p.id"
                  :label="p.positionName"
                  :value="p.id" /></ElSelect></ElCol></ElRow></ElCard
        ><ElEmpty v-if="!form.games.length" description="暂未添加游戏资料" /></ElTabPane
      ><ElTabPane label="展示媒体" name="media"
        ><div class="flex justify-end mb-3"><ElButton @click="addMedia">添加媒体</ElButton></div
        ><ElRow v-for="(m, i) in form.media" :key="i" :gutter="12" class="mb-3"
          ><ElCol :span="5"
            ><ElSelect v-model="m.mediaType"
              ><ElOption label="照片" value="PHOTO" /><ElOption
                label="视频"
                value="VIDEO" /><ElOption label="语音" value="VOICE" /><ElOption
                label="游戏证明"
                value="GAME_PROOF" /></ElSelect></ElCol
          ><ElCol :span="13"
            ><LocalFileUpload
              v-model="m.mediaUrl"
              kind="MEDIA"
              :accept="mediaAccept(m.mediaType)" /></ElCol
          ><ElCol :span="4"><ElInputNumber v-model="m.sortNo" :min="0" /></ElCol
          ><ElCol :span="2"
            ><ElButton link type="danger" @click="form.media.splice(i, 1)">删除</ElButton></ElCol
          ></ElRow
        ><ElEmpty v-if="!form.media.length" description="暂未添加展示媒体" /></ElTabPane></ElTabs>
    </ElCard>
    <div class="editor-footer">
      <ElButton @click="emit('cancel')">取消</ElButton>
      <ElButton type="primary" :loading="saving" @click="save">保存</ElButton>
    </div>
  </div>
</template>
<script setup lang="ts">
  import { ArrowLeft } from '@element-plus/icons-vue'
  import {
    fetchPlayer,
    fetchGameOptions,
    fetchTagOptions,
    fetchGamePositions,
    createPlayer,
    updatePlayer,
    fetchPlayerUserOptions,
    setPlayerCapacity,
    fetchPlayerLevels,
    fetchGameConfig
  } from '@/api/business-manage'
  import LocalFileUpload from '@/components/business/local-file-upload.vue'
  const props = defineProps<{ id?: number }>(),
    emit = defineEmits(['cancel', 'success'])
  const tab = ref('base'),
    loading = ref(false),
    saving = ref(false),
    games = ref<Api.Business.Game[]>([]),
    tags = ref<Api.Business.PlayerTag[]>([]),
    users = ref<any[]>([]),
    playerLevels = ref<any[]>([]),
    positionMap = reactive<Record<number, Api.Business.GamePosition[]>>({}),
    gameConfigMap = reactive<Record<number, any>>({})
  const empty = (): Api.Business.PlayerSave => ({
    nickname: '',
    realName: '',
    gender: 'UNKNOWN',
    phone: '',
    email: '',
    avatarUrl: '',
    coverUrl: '',
    introduction: '',
    voiceUrl: '',
    maxActiveOrders: 1,
    enabled: true,
    sortNo: 0,
    remark: '',
    tagIds: [],
    games: [],
    media: []
  })
  const form = reactive<Api.Business.PlayerSave>(empty())
  async function loadPositions(gameId: number) {
    if (gameId && !positionMap[gameId]) positionMap[gameId] = await fetchGamePositions(gameId)
    if (gameId && !gameConfigMap[gameId]) gameConfigMap[gameId] = await fetchGameConfig(gameId)
  }
  async function init() {
    loading.value = true
    tab.value = 'base'
    try {
      ;[games.value, tags.value, users.value, playerLevels.value] = await Promise.all([
        fetchGameOptions(),
        fetchTagOptions(),
        fetchPlayerUserOptions(props.id),
        fetchPlayerLevels()
      ])
      Object.assign(form, empty(), props.id ? await fetchPlayer(props.id) : {})
      await Promise.all(form.games.map((g) => loadPositions(g.gameId)))
    } finally {
      loading.value = false
    }
  }
  async function changeGame(g: Api.Business.PlayerGame) {
    g.positionIds = []
    g.primaryPositionId = undefined
    g.priceLevelId = levelsForGame(g.gameId)[0]?.id
    g.serverId = undefined
    g.rankId = undefined
    await loadPositions(g.gameId)
  }
  function addGame() {
    const gameId = games.value[0]?.id || 0
    form.games.push({
      gameId,
      priceLevelId: levelsForGame(gameId)[0]?.id,
      gameNickname: '',
      serverName: '',
      rankName: '',
      serverId: undefined,
      rankId: undefined,
      proofUrl: '',
      primary: form.games.length === 0,
      enabled: true,
      positionIds: []
    })
    loadPositions(gameId)
  }
  function selectedPositions(g: Api.Business.PlayerGame) {
    return (positionMap[g.gameId] || []).filter((p) => g.positionIds?.includes(p.id))
  }
  function levelsForGame(gameId: number) {
    return playerLevels.value.filter((level) => Number(level.gameId) === Number(gameId))
  }
  function gameRanks(gameId: number) {
    return (gameConfigMap[gameId]?.rankSystems || []).flatMap((system: any) => system.ranks || [])
  }
  function validatePrimary(g: Api.Business.PlayerGame) {
    if (g.primaryPositionId && !g.positionIds?.includes(g.primaryPositionId))
      g.primaryPositionId = undefined
  }
  function addMedia() {
    form.media.push({
      mediaType: 'PHOTO',
      mediaUrl: '',
      title: '',
      sortNo: form.media.length,
      enabled: true
    })
  }
  function mediaAccept(type: string) {
    if (type === 'VIDEO') return 'video/mp4,video/webm'
    if (type === 'VOICE') return 'audio/mpeg,audio/wav,audio/ogg,audio/mp4'
    return 'image/jpeg,image/png,image/gif,image/webp'
  }
  async function save() {
    if (!form.nickname) return ElMessage.warning('请输入展示昵称')
    if (form.games.filter((x) => x.primary).length > 1)
      return ElMessage.warning('只能设置一个主游戏')
    saving.value = true
    try {
      if (props.id) {
        await updatePlayer(props.id, form)
        await setPlayerCapacity(props.id, form.maxActiveOrders || 1)
      } else await createPlayer(form)
      ElMessage.success('保存成功')
      emit('success')
    } finally {
      saving.value = false
    }
  }
  onMounted(init)
</script>
<style scoped>
  .player-editor-page {
    min-height: 100%;
    padding-bottom: 76px;
  }

  .editor-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 24px;
    margin-bottom: 16px;
    padding: 20px 24px;
    border: 1px solid var(--el-border-color-light);
    border-radius: 12px;
    background: var(--el-bg-color);
  }

  .heading-main {
    display: flex;
    align-items: center;
    gap: 18px;
  }

  .back-button {
    padding: 8px 4px;
  }

  .heading-main h2 {
    margin: 0 0 6px;
    font-size: 22px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  .heading-main p {
    margin: 0;
    color: var(--el-text-color-secondary);
  }

  .heading-actions {
    flex: none;
  }

  .editor-card {
    min-height: calc(100vh - 250px);
  }

  .editor-card :deep(.el-card__body) {
    padding: 0 28px 32px;
  }

  .editor-card :deep(.el-tabs__header) {
    margin-bottom: 28px;
  }

  .editor-card :deep(.el-tabs__item) {
    height: 58px;
    padding: 0 26px;
    font-size: 16px;
  }

  .editor-footer {
    position: fixed;
    right: 24px;
    bottom: 20px;
    z-index: 20;
    display: flex;
    gap: 10px;
    padding: 12px 16px;
    border: 1px solid var(--el-border-color-light);
    border-radius: 12px;
    background: color-mix(in srgb, var(--el-bg-color) 94%, transparent);
    box-shadow: var(--el-box-shadow-light);
    backdrop-filter: blur(10px);
  }

  @media (max-width: 768px) {
    .editor-heading {
      align-items: flex-start;
      padding: 16px;
    }

    .heading-actions {
      display: none;
    }

    .editor-card :deep(.el-card__body) {
      padding: 0 16px 24px;
    }
  }
</style>
