<template>
  <view class="profile-page page">
    <view class="intro">
      <view class="avatar" @click="chooseAvatar">
        <image v-if="form.avatar" :src="assetUrl(form.avatar)" mode="aspectFill" />
        <text v-else>{{ avatarText }}</text>
        <view>更换头像</view>
      </view>
      <view><view class="heading">完善个人资料</view><text>这些信息用于订单联系和个人展示</text></view>
    </view>

    <view class="form-card">
      <view class="field readonly"><text>登录账号</text><input :value="auth.user?.userName" disabled /></view>
      <view class="field"><text>昵称</text><input v-model.trim="form.nickName" maxlength="64" placeholder="请输入昵称" /></view>
      <view class="field gender"><text>性别</text><view><view v-for="item in genders" :key="item.value" :class="{ active: form.gender===item.value }" @click="form.gender=item.value">{{ item.label }}</view></view></view>
      <view class="field"><text>手机号</text><input v-model.trim="form.phone" type="number" maxlength="20" placeholder="用于订单联系" /></view>
      <view class="field"><text>邮箱</text><input v-model.trim="form.email" maxlength="128" placeholder="请输入常用邮箱" /></view>
    </view>

    <view class="safe-tip"><view>隐私保护</view><text>登录账号不可修改，联系方式仅用于平台服务与订单履约。</text></view>
    <button class="save" :disabled="saving || uploading" @click="save">{{ saving ? '保存中' : '保存个人资料' }}</button>
  </view>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { updateUserProfile } from '@/api/auth'
import { assetUrl, uploadFile } from '@/services/http'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const saving = ref(false)
const uploading = ref(false)
const form = reactive({ nickName:'', gender:'UNKNOWN', phone:'', email:'', avatar:'' })
const genders = [{label:'保密',value:'UNKNOWN'},{label:'男',value:'MALE'},{label:'女',value:'FEMALE'}]
const avatarText = computed(() => (form.nickName || auth.user?.userName || '游').slice(0,1))

onLoad(async () => {
  if (!auth.user) await auth.loadUser()
  form.nickName = auth.user?.nickName || ''
  form.gender = auth.user?.gender || 'UNKNOWN'
  form.phone = auth.user?.phone || ''
  form.email = auth.user?.email || ''
  form.avatar = auth.user?.avatar || ''
})

async function chooseAvatar() {
  const result = await uni.chooseImage({ count:1, sourceType:['album','camera'] })
  if (!result.tempFilePaths[0]) return
  uploading.value = true
  uni.showLoading({ title:'上传头像' })
  try { form.avatar = await uploadFile(result.tempFilePaths[0], 'IMAGE') }
  finally { uploading.value = false; uni.hideLoading() }
}
async function save() {
  if (!form.nickName) return uni.showToast({ title:'请输入昵称', icon:'none' })
  saving.value = true
  try {
    await updateUserProfile({ ...form })
    await auth.loadUser()
    uni.showToast({ title:'资料已更新', icon:'success' })
    setTimeout(() => uni.navigateBack(), 450)
  } finally { saving.value = false }
}
</script>

<style scoped lang="scss">
.profile-page{padding-bottom:60rpx}.intro{min-height:220rpx;padding:28rpx 18rpx 36rpx;display:flex;align-items:center;gap:28rpx}.avatar{position:relative;width:142rpx;height:142rpx;flex:none;overflow:hidden;border:6rpx solid rgba(49,92,80,.18);border-radius:18rpx 42rpx 18rpx 42rpx;display:flex;align-items:center;justify-content:center;color:#fffaf0;background:#963d31;font-family:STKaiti,KaiTi,serif;font-size:50rpx;font-weight:800}.avatar image{width:100%;height:100%}.avatar>view{position:absolute;left:0;right:0;bottom:0;padding:8rpx 0;color:#fff;background:rgba(24,46,38,.7);font-family:sans-serif;font-size:18rpx;text-align:center}.heading{color:#1d3027;font-family:STKaiti,KaiTi,serif;font-size:38rpx;font-weight:800}.intro>view>text{display:block;margin-top:12rpx;color:#79867f;font-size:21rpx}.form-card{padding:10rpx 28rpx;border:1rpx solid rgba(54,79,68,.16);border-radius:12rpx 30rpx 12rpx 30rpx;background:rgba(255,252,241,.96);box-shadow:0 12rpx 32rpx rgba(38,54,45,.08)}.field{min-height:104rpx;border-bottom:1rpx solid rgba(49,92,80,.12);display:flex;align-items:center}.field:last-child{border-bottom:0}.field>text{width:150rpx;color:#42574d;font-size:25rpx}.field input{flex:1;color:#26372f;text-align:right;font-size:25rpx}.readonly input{color:#99a29c}.gender>view{flex:1;display:flex;justify-content:flex-end;gap:12rpx}.gender>view>view{padding:11rpx 22rpx;border:1rpx solid rgba(49,92,80,.2);border-radius:24rpx;color:#748078;background:#f0eee3;font-size:21rpx}.gender .active{border-color:#315c50;color:#fffaf0;background:#315c50}.safe-tip{margin:24rpx 8rpx;padding:22rpx 24rpx;border-left:6rpx solid #557869;border-radius:6rpx 20rpx 20rpx 6rpx;background:rgba(218,228,213,.64)}.safe-tip view{color:#315c50;font-weight:700}.safe-tip text{display:block;margin-top:8rpx;color:#77837c;font-size:20rpx;line-height:1.6}.save{height:90rpx;margin-top:32rpx;border-radius:12rpx 26rpx 12rpx 26rpx;color:#fffaf0;background:#315c50;font-size:27rpx;font-weight:700}
</style>
