<template>
  <div class="art-full-height"
    ><ElCard class="mb-3"
      ><ElForm inline
        ><ElFormItem label="游戏名称"><ElInput v-model="query.gameName" clearable /></ElFormItem
        ><ElFormItem label="状态"
          ><ElSelect v-model="query.enabled" clearable class="!w-32"
            ><ElOption label="启用" :value="true" /><ElOption
              label="禁用"
              :value="false" /></ElSelect></ElFormItem
        ><ElFormItem
          ><ElButton @click="reset">重置</ElButton
          ><ElButton type="primary" @click="search">查询</ElButton></ElFormItem
        ></ElForm
      ></ElCard
    ><ElCard class="art-table-card"
      ><ArtTableHeader :loading="loading" @refresh="load"
        ><template #left
          ><ElButton v-auth="'business:game:create'" @click="open()">新增游戏</ElButton></template
        ></ArtTableHeader
      ><ElTable v-loading="loading" :data="rows"
        ><ElTableColumn label="序号" width="76" align="center"
          ><template #default="{ $index }"
            ><span class="row-index">{{
              (query.current - 1) * query.size + $index + 1
            }}</span></template
          ></ElTableColumn
        ><ElTableColumn label="图标" width="88" align="center"
          ><template #default="{ row }"
            ><ElImage
              v-if="row.iconUrl"
              :src="row.iconUrl"
              :preview-src-list="[row.iconUrl]"
              preview-teleported
              fit="cover"
              class="game-icon"
              ><template #error
                ><div class="image-fallback"
                  ><ArtSvgIcon icon="ri:gamepad-line" /></div></template></ElImage
            ><div v-else class="game-icon image-fallback"
              ><ArtSvgIcon icon="ri:gamepad-line" /></div></template></ElTableColumn
        ><ElTableColumn prop="gameName" label="游戏名称" min-width="150" />
        <ElTableColumn prop="gameCode" label="游戏编码" min-width="150" />
        ><ElTableColumn label="游戏封面" width="168"
          ><template #default="{ row }"
            ><ElImage
              v-if="row.coverUrl"
              :src="row.coverUrl"
              :preview-src-list="[row.coverUrl]"
              preview-teleported
              fit="cover"
              class="game-cover"
              ><template #error
                ><div class="cover-fallback"
                  ><ArtSvgIcon icon="ri:image-line" /></div></template></ElImage
            ><div v-else class="game-cover cover-fallback"
              ><ArtSvgIcon icon="ri:image-line" /></div></template></ElTableColumn
        ><ElTableColumn label="平台" width="110"
          ><template #default="{ row }"
            ><ElTag effect="plain" round
              ><ArtSvgIcon :icon="platformIcon(row.platformType)" class="mr-1" />{{
                platformText(row.platformType)
              }}</ElTag
            ></template
          ></ElTableColumn
        ><ElTableColumn
          prop="description"
          label="说明"
          min-width="180"
          show-overflow-tooltip /><ElTableColumn label="状态" width="90"
          ><template #default="{ row }"
            ><ElSwitch
              v-model="row.enabled"
              :disabled="!has('business:game:status')"
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
    ><ElDialog v-model="visible" :title="editing.id ? '编辑游戏' : '新增游戏'" width="520px"
      ><ElForm label-width="90px"
        ><ElFormItem label="游戏编码" required
          ><ElInput v-model="editing.gameCode"
            ><template #append
              ><ElButton @click="editing.gameCode = generateBusinessCode('game')"
                >重新生成</ElButton
              ></template
            ></ElInput
          ></ElFormItem
        ><ElFormItem label="游戏名称" required><ElInput v-model="editing.gameName" /></ElFormItem
        ><ElFormItem label="平台"
          ><ElSelect v-model="editing.platformType" class="w-full"
            ><ElOption label="手游" value="MOBILE" /><ElOption label="电脑" value="PC" /><ElOption
              label="主机"
              value="CONSOLE" /><ElOption label="其他" value="OTHER" /></ElSelect></ElFormItem
        ><ElFormItem label="游戏图标"><LocalFileUpload v-model="editing.iconUrl" /></ElFormItem
        ><ElFormItem label="游戏封面"><LocalFileUpload v-model="editing.coverUrl" /></ElFormItem
        ><ElFormItem label="说明"
          ><ElInput v-model="editing.description" type="textarea" /></ElFormItem
        ><ElFormItem label="排序"><ElInputNumber v-model="editing.sortNo" :min="0" /></ElFormItem
        ><ElFormItem label="启用"><ElSwitch v-model="editing.enabled" /></ElFormItem></ElForm
      ><template #footer
        ><ElButton @click="visible = false">取消</ElButton
        ><ElButton type="primary" @click="save">保存</ElButton></template
      ></ElDialog
    ><PositionDialog v-model="positionVisible" :game="positionGame" /><ConfigDialog
      v-model="configVisible"
      :game="configGame"
  /></div>
</template>
<script setup lang="ts">
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import PositionDialog from './modules/position-dialog.vue'
  import ConfigDialog from './modules/config-dialog.vue'
  import LocalFileUpload from '@/components/business/local-file-upload.vue'
  import {
    fetchGames,
    createGame,
    updateGame,
    setGameStatus,
    deleteGame
  } from '@/api/business-manage'
  import { useUserStore } from '@/store/modules/user'
  import { generateBusinessCode } from '@/utils/business-code'
  const store = useUserStore(),
    has = (c: string) => store.info.roles?.includes('admin') || store.info.buttons?.includes(c),
    loading = ref(false),
    rows = ref<Api.Business.Game[]>([]),
    total = ref(0),
    visible = ref(false),
    positionVisible = ref(false),
    configVisible = ref(false),
    positionGame = ref<Api.Business.Game>(),
    configGame = ref<Api.Business.Game>(),
    query = reactive<any>({ current: 1, size: 20, gameName: '', enabled: undefined }),
    editing = reactive<any>({})
  const actions = computed(() => [
    ...(has('business:game-position:list')
      ? [{ key: 'positions', label: '位置维护', icon: 'ri:map-pin-line' }]
      : []),
    ...(has('business:game:update')
      ? [{ key: 'config', label: '区服与段位', icon: 'ri:medal-line' }]
      : []),
    ...(has('business:game:update') ? [{ key: 'edit', label: '编辑', icon: 'ri:edit-line' }] : []),
    ...(has('business:game:delete')
      ? [{ key: 'delete', label: '删除', icon: 'ri:delete-bin-line', color: '#f56c6c' }]
      : [])
  ])
  async function load() {
    loading.value = true
    try {
      const d = await fetchGames(query)
      rows.value = d.records
      total.value = d.total
    } finally {
      loading.value = false
    }
  }
  function search() {
    query.current = 1
    load()
  }
  function reset() {
    query.gameName = ''
    query.enabled = undefined
    search()
  }
  function open(row?: any) {
    Object.assign(
      editing,
      row || {
        id: null,
        gameCode: generateBusinessCode('game'),
        gameName: '',
        platformType: 'MOBILE',
        iconUrl: '',
        coverUrl: '',
        description: '',
        sortNo: 0,
        enabled: true
      }
    )
    visible.value = true
  }
  async function save() {
    if (!editing.gameCode || !editing.gameName) return ElMessage.warning('请填写游戏编码和名称')
    if (editing.id) await updateGame(editing.id, editing)
    else await createGame(editing)
    visible.value = false
    ElMessage.success('保存成功')
    load()
  }
  async function status(r: any, v: boolean) {
    try {
      await setGameStatus(r.id, v)
    } catch {
      load()
    }
  }
  function platformText(platform: string) {
    return { MOBILE: '手游', PC: '电脑', CONSOLE: '主机', OTHER: '其他' }[platform] || platform
  }
  function platformIcon(platform: string) {
    return (
      { MOBILE: 'ri:smartphone-line', PC: 'ri:computer-line', CONSOLE: 'ri:gamepad-line' }[
        platform
      ] || 'ri:apps-line'
    )
  }
  async function action(k: any, r: any) {
    if (k === 'edit') open(r)
    else if (k === 'config') {
      configGame.value = r
      configVisible.value = true
    } else if (k === 'positions') {
      positionGame.value = r
      positionVisible.value = true
    } else {
      await ElMessageBox.confirm(`确定删除“${r.gameName}”吗？`, '删除确认', { type: 'warning' })
      await deleteGame(r.id)
      load()
    }
  }
  onMounted(load)
</script>
<style scoped>
  .row-index {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 30px;
    height: 30px;
    font-size: 13px;
    font-weight: 600;
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-9);
    border-radius: 9px;
  }

  .game-icon {
    display: block;
    width: 48px;
    height: 48px;
    margin: 0 auto;
    overflow: hidden;
    background: var(--el-fill-color-light);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 12px;
  }

  .game-cover {
    display: block;
    width: 128px;
    height: 58px;
    overflow: hidden;
    background: var(--el-fill-color-light);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 9px;
  }

  .image-fallback,
  .cover-fallback {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    font-size: 22px;
    color: var(--el-text-color-placeholder);
  }
</style>
