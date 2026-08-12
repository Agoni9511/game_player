<template>
  <PlayerOrderList ref="list" :initial-tab="initialTab" />
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'
import PlayerOrderList from '@/components/PlayerOrderList.vue'

const list = ref<InstanceType<typeof PlayerOrderList>>()
const initialTab = ref('ALL')

onLoad(query => { initialTab.value = String(query?.status || 'ALL') })
onShow(() => list.value?.load())
</script>
