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
        ><ElTableColumn prop="gameCode" label="游戏编码" min-width="140" /><ElTableColumn
          prop="gameName"
          label="游戏名称"
          min-width="140" /><ElTableColumn
          prop="platformType"
          label="平台"
          width="100" /><ElTableColumn
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
        ><ElFormItem label="游戏编码" required><ElInput v-model="editing.gameCode"><template #append><ElButton @click="editing.gameCode = generateBusinessCode('game')">重新生成</ElButton></template></ElInput></ElFormItem
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
    ><PositionDialog v-model="positionVisible" :game="positionGame"
  /><ConfigDialog v-model="configVisible" :game="configGame" /></div>
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
    ...(has('business:game:update') ? [{ key: 'config', label: '区服与段位', icon: 'ri:medal-line' }] : []),
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
    editing.id ? await updateGame(editing.id, editing) : await createGame(editing)
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
  async function action(k: any, r: any) {
    if (k === 'edit') open(r)
    else if(k==='config'){configGame.value=r;configVisible.value=true}
    else if (k === 'positions') {
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
