<template><PlayerDispatchList ref="board" /></template>
<script setup lang="ts">
import { ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import PlayerDispatchList from '@/components/PlayerDispatchList.vue'
const board = ref<InstanceType<typeof PlayerDispatchList>>()
onShow(() => board.value?.load())
</script>

<style>
page { min-height: 100%; }
</style>
