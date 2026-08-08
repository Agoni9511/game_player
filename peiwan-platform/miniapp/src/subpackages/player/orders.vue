<template><PlayerOrderList ref="list" /></template>
<script setup lang="ts">import{ref}from'vue';import{onShow}from'@dcloudio/uni-app';import PlayerOrderList from '@/components/PlayerOrderList.vue';const list=ref<InstanceType<typeof PlayerOrderList>>();onShow(()=>list.value?.load())</script>
