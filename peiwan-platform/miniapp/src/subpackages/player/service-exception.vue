<template>
  <view class="exception-page">
    <view class="type-switch"><view v-for="(item,index) in types" :key="item.value" :class="{active:typeIndex===index}" @click="selectType(index)">{{ item.shortLabel }}</view></view>
    <view class="form-card">
      <picker v-if="type==='TRANSFER'" :range="targets" range-key="player_name" @change="targetIndex=Number($event.detail.value)">
        <view class="select-row"><view><text>接替陪玩</text><label>{{ targetName }}</label></view><text>›</text></view>
      </picker>
      <view class="reason-field"><view><text>申请原因</text><label>{{ reason.length }}/200</label></view><textarea v-model="reason" maxlength="200" :placeholder="type==='TRANSFER'?'简要说明转单原因':'简要说明无法继续服务的原因'"/></view>
    </view>
    <view class="notice"><text>审</text><view>{{ type==='TRANSFER'?'平台审核通过后，接替成员确认即可完成转单':'提交后由平台审核并核算相关责任' }}</view></view>
    <view class="bottom-action"><button :disabled="submitting" @click="submit">{{ submitting?'提交中…':'提交审核' }}</button></view>
  </view>
</template>
<script setup lang="ts">
import{computed,ref}from'vue';import{onLoad}from'@dcloudio/uni-app';import{createPlayerServiceException,getPlayerTransferTargets}from'@/api/player';import type{RecordData}from'@/types/api'
const id=ref(0),targets=ref<RecordData[]>([]),targetIndex=ref(-1),typeIndex=ref(0),reason=ref(''),submitting=ref(false)
const types=[{label:'申请转单',shortLabel:'转单',value:'TRANSFER'},{label:'申请炸单',shortLabel:'终止服务',value:'ABORT'}]as const
const type=computed(()=>types[typeIndex.value].value)
const targetName=computed(()=>String(targets.value[targetIndex.value]?.player_name||targets.value[targetIndex.value]?.playerName||'请选择接替成员'))
onLoad(async q=>{id.value=Number(q?.id);targets.value=await getPlayerTransferTargets(id.value)})
function selectType(index:number){typeIndex.value=index;targetIndex.value=-1}
async function submit(){if(submitting.value)return;if(type.value==='TRANSFER'&&!targets.value[targetIndex.value])return uni.showToast({title:'请选择接替陪玩',icon:'none'});if(!reason.value.trim())return uni.showToast({title:'请填写申请原因',icon:'none'});submitting.value=true;try{await createPlayerServiceException(id.value,{requestType:type.value,targetPlayerId:type.value==='TRANSFER'?Number(targets.value[targetIndex.value].player_id||targets.value[targetIndex.value].playerId):undefined,reason:reason.value.trim()});uni.showToast({title:'已提交审核'});setTimeout(()=>uni.navigateBack(),500)}finally{submitting.value=false}}
</script>
<style scoped>
.exception-page{min-height:100vh;padding:24rpx 24rpx 170rpx;box-sizing:border-box;background:#eee9da}.type-switch{padding:7rpx;border-radius:25rpx;display:grid;grid-template-columns:1fr 1fr;background:#dedfd5}.type-switch view{height:68rpx;border-radius:20rpx;color:#758078;line-height:68rpx;text-align:center;font-size:23rpx}.type-switch .active{color:#fffaf0;background:#315c50;font-weight:700;box-shadow:0 6rpx 16rpx rgba(49,92,80,.18)}.form-card{margin-top:20rpx;padding:0 24rpx;border:1rpx solid rgba(49,92,80,.15);border-radius:24rpx;background:#fffaf0}.select-row{min-height:100rpx;border-bottom:1rpx solid rgba(49,92,80,.11);display:flex;align-items:center;justify-content:space-between}.select-row>view text,.select-row>view label{display:block}.select-row>view text{color:#263a31;font-size:24rpx;font-weight:700}.select-row>view label{margin-top:6rpx;color:#879088;font-size:19rpx}.select-row>text{color:#8c958f;font-size:38rpx}.reason-field{padding:23rpx 0}.reason-field>view{display:flex;align-items:center;justify-content:space-between}.reason-field>view text{font-size:24rpx;font-weight:700}.reason-field>view label{color:#969d97;font-size:18rpx}.reason-field textarea{width:100%;height:230rpx;margin-top:17rpx;padding:19rpx;border-radius:18rpx;box-sizing:border-box;background:#f0eee3;font-size:23rpx;line-height:1.6}.notice{margin-top:20rpx;padding:20rpx 22rpx;border-radius:20rpx;display:flex;align-items:center;color:#7d684c;background:#eee4d2;font-size:19rpx}.notice>text{width:44rpx;height:44rpx;flex:none;margin-right:14rpx;border-radius:50%;color:#fffaf0;background:#963d31;line-height:44rpx;text-align:center;font-family:STKaiti,KaiTi,serif}.bottom-action{position:fixed;z-index:10;left:0;right:0;bottom:0;padding:16rpx 24rpx calc(16rpx + env(safe-area-inset-bottom));background:rgba(255,250,240,.97);box-shadow:0 -8rpx 25rpx rgba(39,55,46,.1)}.bottom-action button{height:82rpx;border-radius:41rpx;color:#fffaf0;background:#315c50;line-height:82rpx;font-size:25rpx}
</style>
