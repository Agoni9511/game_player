<template>
  <view class="login-page">
    <view class="glow glow-one" />
    <view class="glow glow-two" />

    <view class="hero">
      <view class="brand-row">
        <image class="logo" src="/static/logo.png" mode="aspectFit" />
        <view>
          <view class="brand-name">凌竞电竞</view>
          <view class="brand-en">LINGJING ESPORTS</view>
        </view>
      </view>
      <view class="slogan">不止是上分，<text>更是遇见同频的人</text></view>
      <view class="feature-row">
        <view><text class="dot purple" />严选陪玩</view>
        <view><text class="dot cyan" />透明履约</view>
        <view><text class="dot pink" />平台保障</view>
      </view>
    </view>

    <view class="login-panel">
      <view class="panel-head">
        <view>
          <view class="panel-title">账号登录</view>
          <view class="panel-subtitle">输入账号密码，进入凌竞电竞</view>
        </view>
        <view class="badge">安全登录</view>
      </view>

      <view class="field" :class="{ focused: focusField === 'account' }">
        <view class="field-icon">账号</view>
        <input v-model.trim="userName" placeholder="请输入账号" confirm-type="next" @focus="focusField='account'" @blur="focusField=''" />
        <view v-if="userName" class="clear" @click="userName=''">×</view>
      </view>

      <view class="field" :class="{ focused: focusField === 'password' }">
        <view class="field-icon">密码</view>
        <input v-model="password" :password="!showPassword" placeholder="请输入密码" confirm-type="done" @focus="focusField='password'" @blur="focusField=''" @confirm="submit" />
        <view class="visibility" @click="showPassword=!showPassword">{{ showPassword ? '隐藏' : '显示' }}</view>
      </view>

      <view class="options">
        <view class="remember" @click="rememberAccount=!rememberAccount">
          <view class="checkbox" :class="{ checked: rememberAccount }">{{ rememberAccount ? '✓' : '' }}</view>
          <text>记住账号</text>
        </view>
        <view class="forgot" @click="forgotPassword">忘记密码？</view>
      </view>

      <view class="login-button" :class="{ disabled: loading }" @click="submit">
        <view v-if="loading" class="spinner" />
        <text>{{ loading ? '正在登录...' : '进入凌竞电竞' }}</text>
      </view>

      <view class="login-divider">
        <view />
        <text>其他登录方式</text>
        <view />
      </view>

      <view class="wechat-button" :class="{ disabled: wechatLoading }" @click="wechatSignIn">
        <view class="wechat-mark">微</view>
        <text>{{ wechatLoading ? '正在唤起微信...' : '微信快捷登录' }}</text>
      </view>

      <view class="agreement">
        登录即代表你已阅读并同意
        <text @click="showPending('用户协议')">《用户协议》</text>
        和
        <text @click="showPending('隐私政策')">《隐私政策》</text>
      </view>
    </view>

    <view class="version">安全连接 · 凌竞电竞陪玩服务</view>
  </view>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { useAuthStore } from '@/stores/auth'
import { useAppModeStore } from '@/stores/app-mode'

const ACCOUNT_KEY = 'peiwan_remembered_account'
const auth = useAuthStore()
const mode = useAppModeStore()
const userName = ref('')
const password = ref('')
const loading = ref(false)
const wechatLoading = ref(false)
const showPassword = ref(false)
const rememberAccount = ref(true)
const focusField = ref('')

onLoad(() => {
  if (auth.loggedIn && auth.user) { uni.switchTab({ url: '/pages/home/index' }); return }
  userName.value = String(uni.getStorageSync(ACCOUNT_KEY) || '')
})

async function submit() {
  if (!userName.value) return uni.showToast({ title: '请输入登录账号', icon: 'none' })
  if (!password.value) return uni.showToast({ title: '请输入登录密码', icon: 'none' })
  loading.value = true
  try {
    await auth.signIn(userName.value, password.value)
    mode.ensureAllowed()
    if (rememberAccount.value) uni.setStorageSync(ACCOUNT_KEY, userName.value)
    else uni.removeStorageSync(ACCOUNT_KEY)
    uni.showToast({ title: '登录成功', icon: 'success' })
    setTimeout(() => uni.switchTab({ url: '/pages/home/index' }), 350)
  } finally {
    loading.value = false
  }
}

function wechatSignIn() {
  if (wechatLoading.value) return
  wechatLoading.value = true
  uni.login({
    provider: 'weixin',
    success: ({ code }) => {
      if (!code) {
        uni.showToast({ title: '未获取到微信授权信息', icon: 'none' })
        return
      }
      uni.showModal({
        title: '微信快捷登录',
        content: '微信授权已完成。请配置小程序 AppID、AppSecret 和后台微信登录接口后启用正式登录。',
        confirmText: '我知道了',
        showCancel: false,
      })
    },
    fail: () => uni.showToast({ title: '请先配置微信小程序 AppID', icon: 'none' }),
    complete: () => { wechatLoading.value = false },
  })
}

function forgotPassword() {
  uni.showModal({
    title: '忘记密码',
    content: '当前账号由平台统一管理，暂未开放短信自助找回。请联系平台管理员核验身份并重置密码。',
    confirmText: '我知道了',
    showCancel: false,
  })
}

function showPending(name: string) {
  uni.showToast({ title: `${name}内容待平台配置`, icon: 'none' })
}
</script>

<style scoped lang="scss">
.login-page { position: relative; min-height: 100vh; padding: 92rpx 36rpx 40rpx; overflow: hidden; box-sizing: border-box; background: linear-gradient(155deg, #17152c 0%, #27214b 38%, #f5f6fb 38.2%, #f5f6fb 100%); }
.glow { position: absolute; border-radius: 50%; filter: blur(10rpx); opacity: .45; pointer-events: none; }
.glow-one { width: 300rpx; height: 300rpx; right: -100rpx; top: -80rpx; background: #7458ff; }
.glow-two { width: 180rpx; height: 180rpx; left: -90rpx; top: 300rpx; background: #18d7db; opacity: .2; }
.hero { position: relative; z-index: 1; color: #fff; padding: 0 20rpx 58rpx; }
.brand-row { display: flex; align-items: center; gap: 20rpx; }
.logo { width: 118rpx; height: 96rpx; flex: none; border-radius: 20rpx; background: #fff; box-shadow: 0 12rpx 32rpx rgba(26, 214, 255, .2); }
.brand-name { font-size: 38rpx; line-height: 1.1; font-weight: 800; letter-spacing: 3rpx; }
.brand-en { margin-top: 8rpx; color: rgba(255,255,255,.5); font-size: 18rpx; letter-spacing: 4rpx; }
.slogan { margin-top: 40rpx; font-size: 34rpx; font-weight: 700; }
.slogan text { color: #a999ff; }
.feature-row { display: flex; gap: 28rpx; margin-top: 24rpx; color: rgba(255,255,255,.65); font-size: 22rpx; }
.feature-row view { display: flex; align-items: center; gap: 9rpx; }
.dot { width: 10rpx; height: 10rpx; border-radius: 50%; box-shadow: 0 0 14rpx currentColor; }
.purple { background: #a999ff; color: #a999ff; }.cyan { background: #36e4dc; color: #36e4dc; }.pink { background: #ff7db3; color: #ff7db3; }
.login-panel { position: relative; z-index: 2; padding: 38rpx 34rpx 34rpx; border-radius: 34rpx; background: rgba(255,255,255,.98); box-shadow: 0 24rpx 70rpx rgba(28, 25, 58, .16); }
.panel-head { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 34rpx; }
.panel-title { color: #202033; font-size: 38rpx; font-weight: 800; }
.panel-subtitle { margin-top: 10rpx; color: #9297a8; font-size: 24rpx; }
.badge { padding: 8rpx 16rpx; border-radius: 100rpx; color: #7357ff; background: #f0edff; font-size: 20rpx; }
.field { height: 98rpx; margin-bottom: 22rpx; padding: 0 24rpx; display: flex; align-items: center; border: 2rpx solid transparent; border-radius: 20rpx; background: #f5f6fa; transition: .2s; }
.field.focused { border-color: #8067ff; background: #fff; box-shadow: 0 0 0 7rpx rgba(115,87,255,.08); }
.field-icon { width: 44rpx; color: #8a72ff; font-size: 20rpx; }.field-icon.key { font-size: 18rpx; }
.field input { flex: 1; height: 100%; color: #252535; font-size: 28rpx; }
.clear { width: 44rpx; color: #afb4c1; text-align: right; font-size: 36rpx; }
.visibility { color: #7357ff; font-size: 24rpx; }
.options { margin: 4rpx 2rpx 30rpx; display: flex; align-items: center; justify-content: space-between; font-size: 24rpx; }
.remember { display: flex; align-items: center; gap: 12rpx; color: #73798a; }
.checkbox { width: 30rpx; height: 30rpx; border: 2rpx solid #c9cdd7; border-radius: 8rpx; text-align: center; line-height: 30rpx; color: #fff; font-size: 22rpx; }
.checkbox.checked { border-color: #7357ff; background: #7357ff; }.forgot { color: #7357ff; }
.login-button { position: relative; height: 96rpx; border-radius: 20rpx; display: flex; align-items: center; justify-content: center; gap: 14rpx; color: #fff; font-size: 30rpx; font-weight: 700; letter-spacing: 2rpx; background: linear-gradient(100deg, #8067ff, #6547ed); box-shadow: 0 16rpx 32rpx rgba(104,73,238,.28); }
.login-button.disabled { opacity: .75; }.arrow { position: absolute; right: 32rpx; font-size: 36rpx; font-weight: 400; }.spinner { width: 26rpx; height: 26rpx; border: 4rpx solid rgba(255,255,255,.35); border-top-color: #fff; border-radius: 50%; animation: spin .8s linear infinite; }
@keyframes spin { to { transform: rotate(360deg); } }
.role-tip { margin-top: 32rpx; padding: 22rpx; display: flex; align-items: center; gap: 18rpx; border-radius: 18rpx; background: linear-gradient(100deg, #f5f2ff, #f9f8ff); }
.role-icon { width: 54rpx; height: 54rpx; display: flex; align-items: center; justify-content: center; border-radius: 16rpx; color: #fff; background: #7357ff; }
.role-title { color: #38344d; font-size: 24rpx; font-weight: 700; }.role-text { margin-top: 6rpx; color: #9692a5; font-size: 20rpx; }
.agreement { margin-top: 28rpx; color: #a4a8b4; font-size: 20rpx; text-align: center; line-height: 1.7; }.agreement text { color: #7560db; }
.version { position: relative; z-index: 1; margin-top: 32rpx; color: #a0a4b0; font-size: 20rpx; text-align: center; }
</style>
<style scoped lang="scss">
.login-page {
  padding: 88rpx 34rpx 40rpx;
  background-color: #eee8d7;
  background-image: radial-gradient(circle at 88% 2%, rgba(91, 126, 108, .17), transparent 34%), linear-gradient(180deg, rgba(243, 238, 221, .82), rgba(243, 238, 221, .96));
}

.glow { display: none; }
.hero { padding: 0 18rpx 52rpx; color: #17251f; text-shadow: 0 1rpx rgba(255, 255, 255, .65); }
.logo { border: 1rpx solid rgba(43, 72, 60, .22); border-radius: 24rpx; box-shadow: 0 10rpx 26rpx rgba(45, 70, 59, .14); }
.brand-name, .panel-title { font-family: STKaiti, KaiTi, serif; color: #17251f; }
.brand-en, .feature-row { color: #66756d; }
.slogan text { color: #315c50; }

.login-panel {
  padding: 40rpx 32rpx 34rpx;
  border: 1rpx solid rgba(54, 79, 68, .18);
  border-radius: 34rpx;
  background: rgba(255, 252, 241, .94);
  box-shadow: 0 24rpx 60rpx rgba(44, 60, 50, .14);
}
.panel-head { align-items: center; margin-bottom: 34rpx; }
.panel-title { font-size: 36rpx; }
.panel-subtitle { margin-top: 8rpx; color: #7c8982; }
.badge { padding: 9rpx 17rpx; border: 1rpx solid rgba(150, 61, 49, .12); border-radius: 24rpx; color: #963d31; background: #f1e3d9; }

.field {
  height: 96rpx;
  margin-bottom: 20rpx;
  padding: 0 22rpx;
  border-radius: 24rpx;
  background: rgba(233, 233, 220, .82);
}
.field.focused { border-color: #557869; background: rgba(255, 255, 250, .96); box-shadow: 0 0 0 7rpx rgba(63, 101, 86, .08); }
.field-icon {
  width: 72rpx;
  margin-right: 20rpx;
  border-right: 1rpx solid rgba(49, 92, 80, .18);
  color: #315c50;
  font-size: 22rpx;
  font-weight: 700;
  line-height: 34rpx;
}
.field input { font-size: 27rpx; }
.clear { width: 44rpx; height: 44rpx; border-radius: 50%; color: #89958e; line-height: 40rpx; text-align: center; }
.visibility { padding: 10rpx 16rpx; border-radius: 20rpx; color: #315c50; background: rgba(49, 92, 80, .08); font-size: 22rpx; }

.options { margin: 6rpx 4rpx 30rpx; }
.checkbox { border-radius: 9rpx; }
.checkbox.checked { border-color: #315c50; background: #315c50; }
.forgot, .agreement text { color: #315c50; }

.login-button {
  height: 98rpx;
  border-radius: 50rpx;
  background: linear-gradient(105deg, #416b5c, #274c42);
  box-shadow: 0 15rpx 30rpx rgba(39, 76, 66, .25);
  transition: transform .15s, box-shadow .15s;
}
.login-button:active { transform: scale(.985); box-shadow: 0 9rpx 20rpx rgba(39, 76, 66, .22); }

.login-divider { margin: 30rpx 8rpx 24rpx; display: flex; align-items: center; gap: 20rpx; color: #929d97; font-size: 20rpx; }
.login-divider view { flex: 1; height: 1rpx; background: rgba(49, 92, 80, .15); }
.wechat-button {
  height: 90rpx;
  border: 2rpx solid rgba(49, 92, 80, .3);
  border-radius: 46rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16rpx;
  color: #315c50;
  background: rgba(255, 255, 250, .72);
  font-size: 28rpx;
  font-weight: 700;
  transition: transform .15s, background-color .15s;
}
.wechat-button:active { transform: scale(.985); background: rgba(224, 234, 220, .8); }
.wechat-button.disabled { opacity: .65; }
.wechat-mark { width: 46rpx; height: 46rpx; border-radius: 50%; color: #fffaf0; background: #315c50; font-size: 22rpx; line-height: 46rpx; text-align: center; font-weight: 700; }
.agreement { margin-top: 26rpx; }
.version { color: #68776f; }
</style>
