<template>
  <view class="application-page">
    <view class="hero">
      <view class="seal">陪</view>
      <view><text>申请成为陪玩师</text><label>提交联系方式后，由平台工作人员与您联系</label></view>
    </view>

    <view v-if="activeApplication" class="status-card">
      <view class="status-mark">{{ statusIcon }}</view>
      <view class="status-copy"><text>{{ statusTitle }}</text><label>{{ statusDescription }}</label></view>
    </view>

    <view class="form-card">
      <view class="section-title">联系资料</view>
      <view class="field"><text>姓名</text><input v-model="form.realName" maxlength="64" placeholder="请输入真实姓名" /></view>
      <view class="field"><text>电话</text><input v-model="form.phone" type="number" maxlength="11" placeholder="请输入11位手机号" /></view>
      <view class="field textarea-field"><text>所在地址</text><textarea v-model="form.address" maxlength="500" auto-height placeholder="请输入省、市、区及详细地址" /></view>
      <view class="notice"><text>说明</text><label>本申请仅用于平台人工联系和资质沟通。提交后不会自动开通陪玩师身份，也不能立即接单。</label></view>
      <button class="submit" :disabled="submitting || activeApplication" @click="submit">{{ activeApplication ? '申请已提交' : submitting ? '提交中…' : '提交入驻申请' }}</button>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { createPlayerApplication, getPlayerApplication } from '@/api/customer'
import { useAuthStore } from '@/stores/auth'
import type { RecordData } from '@/types/api'

const auth = useAuthStore()
const application = ref<RecordData>({})
const submitting = ref(false)
const form = reactive({ realName: '', phone: '', address: '' })
const activeApplication = computed(() => ['PENDING', 'PROCESSING'].includes(String(application.value.status || '')))
const statusIcon = computed(() => application.value.status === 'PROCESSING' ? '联' : '审')
const statusTitle = computed(() => application.value.status === 'PROCESSING' ? '工作人员正在跟进' : '申请已提交，等待联系')
const statusDescription = computed(() => application.value.status === 'PROCESSING' ? '平台工作人员已开始处理，请保持电话畅通。' : '我们已收到您的资料，将由工作人员人工联系。')

onLoad(async () => {
  if (!auth.user) await auth.loadUser().catch(() => undefined)
  form.realName = String(auth.user?.nickName || '')
  form.phone = String(auth.user?.phone || '')
  application.value = await getPlayerApplication().catch(() => ({}))
  if (activeApplication.value) {
    form.realName = String(application.value.realName || form.realName)
    form.phone = String(application.value.phone || form.phone)
    form.address = String(application.value.address || '')
  }
})

async function submit() {
  if (!form.realName.trim()) return uni.showToast({ title: '请填写姓名', icon: 'none' })
  if (!/^1\d{10}$/.test(form.phone.trim())) return uni.showToast({ title: '请填写正确的手机号', icon: 'none' })
  if (!form.address.trim()) return uni.showToast({ title: '请填写所在地址', icon: 'none' })
  submitting.value = true
  try {
    const result = await createPlayerApplication({ realName: form.realName.trim(), phone: form.phone.trim(), address: form.address.trim() })
    application.value = { id: result.id, ...form, status: 'PENDING' }
    uni.showModal({ title: '提交成功', content: '申请已发送至平台后台，请保持电话畅通，等待工作人员联系。', showCancel: false })
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped lang="scss">
.application-page{min-height:100vh;padding:28rpx 24rpx 70rpx;box-sizing:border-box;background:#eee9da}.hero{padding:35rpx 29rpx;border-radius:12rpx 34rpx 12rpx 34rpx;display:flex;align-items:center;color:#fff7e6;background:linear-gradient(135deg,#204538,#4f7766);box-shadow:0 14rpx 35rpx rgba(31,68,55,.18)}.seal{width:82rpx;height:82rpx;flex:none;margin-right:22rpx;border:4rpx double #ead39f;display:flex;align-items:center;justify-content:center;color:#f0d89f;font-family:STKaiti,KaiTi,serif;font-size:40rpx;transform:rotate(-4deg)}.hero text,.hero label{display:block}.hero text{font-family:STKaiti,KaiTi,serif;font-size:38rpx;font-weight:800}.hero label{margin-top:9rpx;color:rgba(255,247,230,.72);font-size:20rpx}.status-card{margin-top:22rpx;padding:24rpx;border:1rpx solid rgba(150,109,48,.22);border-radius:20rpx;display:flex;align-items:center;background:#fff3d8}.status-mark{width:62rpx;height:62rpx;flex:none;margin-right:17rpx;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;background:#a37430;font-family:STKaiti,KaiTi,serif;font-size:29rpx;font-weight:800}.status-copy text,.status-copy label{display:block}.status-copy text{color:#604719;font-size:25rpx;font-weight:800}.status-copy label{margin-top:7rpx;color:#8b744d;font-size:20rpx;line-height:1.5}.form-card{margin-top:22rpx;padding:29rpx 25rpx;border:1rpx solid rgba(49,92,80,.13);border-radius:22rpx;background:#fffaf0;box-shadow:0 8rpx 24rpx rgba(51,46,35,.04)}.section-title{margin-bottom:12rpx;color:#203d33;font-family:STKaiti,KaiTi,serif;font-size:32rpx;font-weight:800}.field{padding:24rpx 0;border-bottom:1rpx solid rgba(49,92,80,.11);display:flex;align-items:center}.field>text{width:145rpx;flex:none;color:#40554b;font-size:23rpx}.field input,.field textarea{min-width:0;flex:1;color:#263a31;font-size:23rpx}.textarea-field{align-items:flex-start}.textarea-field textarea{min-height:120rpx;line-height:1.6}.notice{margin-top:24rpx;padding:20rpx;border-radius:15rpx;display:flex;gap:14rpx;background:#f3eee0}.notice text{flex:none;color:#966d30;font-weight:800}.notice label{color:#7d7567;font-size:20rpx;line-height:1.6}.submit{margin-top:30rpx;height:84rpx;border:0;border-radius:8rpx 24rpx 8rpx 24rpx;color:#fff8e9;background:#315c50;font-size:25rpx;font-weight:800;line-height:84rpx}.submit[disabled]{color:#8a928c;background:#d9ddd6}
</style>

