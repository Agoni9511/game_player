<template>
  <view class="submit-page">
    <view class="form-card">
      <view class="quantity-row"><view><text>实际服务数量</text><label>按订单服务单位填写</label></view><input v-model="actualQuantity" type="digit" /></view>
      <view class="note-field"><view><text>完成说明</text><label>{{ completionNote.length }}/300</label></view><textarea v-model="completionNote" maxlength="300" placeholder="简要说明本次服务完成情况" /></view>
    </view>
    <view class="proof-card">
      <view class="card-head"><view><text>完成凭证</text><label>至少 1 张，最多 9 张</label></view><text>{{ proofUrls.length }}/9</text></view>
      <view class="proof-grid">
        <view v-for="(url,index) in proofUrls" :key="url" class="proof-item"><image :src="assetUrl(url)" mode="aspectFill"/><text @click="removeProof(index)">×</text></view>
        <view v-if="proofUrls.length<9" class="add-proof" @click="chooseProofs"><text>＋</text><label>{{ uploading?'上传中':'添加凭证' }}</label></view>
      </view>
    </view>
    <view class="bottom-action"><button :disabled="submitting||uploading" @click="submit">{{ submitting?'提交中…':'提交完成' }}</button></view>
  </view>
</template>
<script setup lang="ts">
import{ref}from'vue';import{onLoad}from'@dcloudio/uni-app';import{submitOrder}from'@/api/player';import{assetUrl,uploadFile}from'@/services/http'
const id=ref(0),actualQuantity=ref('1'),completionNote=ref(''),proofUrls=ref<string[]>([]),uploading=ref(false),submitting=ref(false)
onLoad(q=>id.value=Number(q?.id))
async function chooseProofs(){if(uploading.value||proofUrls.value.length>=9)return;const picked=await uni.chooseImage({count:9-proofUrls.value.length});uploading.value=true;uni.showLoading({title:'上传中'});try{for(const path of picked.tempFilePaths)proofUrls.value.push(await uploadFile(path))}finally{uploading.value=false;uni.hideLoading()}}
function removeProof(index:number){proofUrls.value.splice(index,1)}
async function submit(){if(submitting.value)return;if(!completionNote.value.trim())return uni.showToast({title:'请填写完成说明',icon:'none'});if(!proofUrls.value.length)return uni.showToast({title:'请至少上传一项凭证',icon:'none'});submitting.value=true;try{await submitOrder(id.value,{actualQuantity:Number(actualQuantity.value),completionNote:completionNote.value.trim(),proofUrls:proofUrls.value});uni.showToast({title:'提交成功'});setTimeout(()=>uni.navigateBack(),500)}finally{submitting.value=false}}
</script>
<style scoped>
.submit-page{min-height:100vh;padding:24rpx 24rpx 170rpx;box-sizing:border-box;background:#eee9da}.form-card,.proof-card{padding:0 24rpx;border:1rpx solid rgba(49,92,80,.15);border-radius:24rpx;background:#fffaf0}.quantity-row{min-height:104rpx;border-bottom:1rpx solid rgba(49,92,80,.11);display:flex;align-items:center}.quantity-row>view{min-width:0;flex:1}.quantity-row text,.quantity-row label{display:block}.quantity-row text{font-size:24rpx;font-weight:700}.quantity-row label{margin-top:6rpx;color:#89928c;font-size:18rpx}.quantity-row input{width:110rpx;height:58rpx;border-radius:17rpx;text-align:center;background:#e7e9df;font-size:27rpx;font-weight:800}.note-field{padding:23rpx 0}.note-field>view,.card-head{display:flex;align-items:center;justify-content:space-between}.note-field>view text,.card-head>view text{font-size:24rpx;font-weight:700}.note-field>view label,.card-head>view label{display:block;margin-top:5rpx;color:#8a938d;font-size:18rpx}.note-field>view>label,.card-head>text{color:#969d97;font-size:18rpx}.note-field textarea{width:100%;height:210rpx;margin-top:17rpx;padding:19rpx;border-radius:18rpx;box-sizing:border-box;background:#f0eee3;font-size:23rpx;line-height:1.55}.proof-card{margin-top:20rpx;padding-top:23rpx;padding-bottom:24rpx}.proof-grid{margin-top:20rpx;display:grid;grid-template-columns:repeat(3,1fr);gap:13rpx}.proof-item,.add-proof{position:relative;height:176rpx;overflow:hidden;border-radius:18rpx}.proof-item image{width:100%;height:100%}.proof-item>text{position:absolute;right:7rpx;top:7rpx;width:38rpx;height:38rpx;border-radius:50%;color:#fff;background:rgba(35,48,41,.72);line-height:35rpx;text-align:center;font-size:29rpx}.add-proof{border:2rpx dashed #abb5ad;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#6e7d75;background:#efeee5}.add-proof text{font-size:45rpx;font-weight:300}.add-proof label{margin-top:7rpx;font-size:18rpx}.bottom-action{position:fixed;z-index:10;left:0;right:0;bottom:0;padding:16rpx 24rpx calc(16rpx + env(safe-area-inset-bottom));background:rgba(255,250,240,.97);box-shadow:0 -8rpx 25rpx rgba(39,55,46,.1)}.bottom-action button{height:82rpx;border-radius:41rpx;color:#fffaf0;background:#315c50;line-height:82rpx;font-size:25rpx}
</style>
