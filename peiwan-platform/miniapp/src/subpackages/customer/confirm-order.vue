<template>
  <view class="confirm-page">
    <view class="page-title"><text>确认服务帖</text><label>核对资料后生成待支付订单</label><view class="seal">确认</view></view>

    <view class="card product-card">
      <view class="game-mark">{{ shortName(product.gameName) }}</view>
      <view class="product-main"><view class="product-name">{{ product.productName }}</view><view class="sku-name">{{ selectedSku.skuName || '服务规格' }} · {{ playerCount }} 位陪玩</view><view class="unit-price">¥{{ money(effectivePrice) }}{{ selectedSku.priceType === 'PER_PLAYER' ? '/人' : '/单' }} · {{ skuUnitLabel(selectedSku.unitType, selectedSku.unitCount) }}</view></view>
    </view>

    <view class="card assignment-card"><view class="section-title">接单方式</view><view class="assignment"><view class="assignment-mark">{{ requestedPlayerId ? '定' : '厅' }}</view><view><strong>{{ requestedPlayerId ? `指定 ${requestedPlayerName}` : `${selectedLevel.levelName || '平台'}陪玩大厅` }}</strong><text>{{ requestedPlayerId ? '订单仅推送给该陪玩师' : '付款后发布抢单，由符合等级的陪玩师响应' }}</text></view></view></view>

    <view class="card">
      <view class="section-title">游戏资料</view>
      <view v-if="profiles.length" class="field"><label>常用账号</label><picker :range="profileLabels" @change="selectProfile"><view class="picker-value">{{ selectedProfile.gameNickname || '请选择常用账号' }} ›</view></picker></view>
      <view class="field required"><label>游戏账号</label><input v-model.trim="form.gameAccount" placeholder="请输入用于服务的游戏账号" /></view>
      <view class="field required"><label>游戏昵称</label><input v-model.trim="form.gameNickname" placeholder="请输入游戏内昵称" /></view>
      <view class="field"><label>所在区服</label><picker :range="servers" range-key="serverName" @change="selectServer"><view class="picker-value">{{ selectedServer.serverName || '请选择区服' }} ›</view></picker></view>
      <view v-if="primaryRankSystem.id" class="field"><label>{{ primaryRankSystem.systemName }}</label><picker :range="ranks" range-key="rankName" @change="selectRank"><view class="picker-value">{{ selectedRank.rankName || '请选择当前段位' }} ›</view></picker></view>
      <view v-if="primaryRankSystem.id" class="field"><label>目标段位</label><picker :range="ranks" range-key="rankName" @change="selectTargetRank"><view class="picker-value">{{ selectedTargetRank.rankName || '不指定' }} ›</view></picker></view>
      <view v-if="!selectedProfile.id" class="field"><label>保存账号</label><switch :checked="saveProfile" color="#315c50" @change="toggleSaveProfile" /></view>
      <view class="textarea-field"><label>服务要求</label><textarea v-model.trim="form.extraRequirement" maxlength="500" placeholder="目标、时间偏好和其他需要陪玩师注意的事项" /><text>{{ form.extraRequirement.length }}/500</text></view>
    </view>

    <view class="card">
      <view class="section-title">联系信息</view>
      <view class="field required"><label>联系人</label><input v-model.trim="form.contactName" placeholder="请输入联系人称呼" /></view>
      <view class="field required"><label>联系电话</label><input v-model.trim="form.contactPhone" type="number" maxlength="11" placeholder="用于订单履约联系" /></view>
      <view class="textarea-field small"><label>订单备注</label><textarea v-model.trim="form.customerRemark" maxlength="200" placeholder="其他备注（选填）" /><text>{{ form.customerRemark.length }}/200</text></view>
    </view>

    <view class="card quantity-card"><view><view class="section-title">购买数量</view><text>范围 {{ minQuantity }}{{ maxQuantity ? ` - ${maxQuantity}` : ' 起' }}</text></view><view class="stepper"><button @click="changeQuantity(-1)">−</button><text>{{ form.quantity }}</text><button @click="changeQuantity(1)">＋</button></view></view>

    <view class="card amount-card"><view><text>商品金额</text><strong>¥{{ totalAmount }}</strong></view><view><text>会员优惠</text><label>支付页计算</label></view><view class="payable"><text>预计应付</text><strong>¥{{ totalAmount }}</strong></view></view>

    <view class="agreement">提交订单即代表同意《凌竞电竞服务规则》，订单创建后进入待支付状态。</view>
    <view class="bottom-bar"><view class="total"><text>应付</text><text class="total-price">¥{{ totalAmount }}</text></view><button class="submit" :disabled="submitting" @click="submit">{{ submitting ? '正在提交...' : '提交订单' }}</button></view>
  </view>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { createCustomerOrder, getCatalogProduct, getGameConfig, getCustomerGameProfiles, createCustomerGameProfile } from '@/api/customer'
import { useAuthStore } from '@/stores/auth'
import { requireLogin } from '@/utils/auth-guard'
import type { RecordData } from '@/types/api'

const auth = useAuthStore()
const product = ref<RecordData>({})
const selectedSku = ref<RecordData>({})
const selectedLevel = ref<RecordData>({})
const playerLevelId = ref(0)
const requestedPlayerId = ref(0)
const requestedPlayerName = ref('')
const submitting = ref(false)
const config=ref<RecordData>({}),profiles=ref<RecordData[]>([]),selectedProfile=ref<RecordData>({}),selectedServer=ref<RecordData>({}),selectedRank=ref<RecordData>({}),selectedTargetRank=ref<RecordData>({}),saveProfile=ref(true)
const servers=computed(()=>((config.value.servers||[]) as RecordData[])),primaryRankSystem=computed(()=>((config.value.rankSystems||[]) as RecordData[])[0]||{}),ranks=computed(()=>((primaryRankSystem.value.ranks||[]) as RecordData[])),profileLabels=computed(()=>profiles.value.map(x=>`${x.gameNickname} · ${x.serverName||'未选区服'}${x.history?'（最近使用）':''}`))
const form = reactive({ quantity: 1, contactName: '', contactPhone: '', customerRemark: '', gameAccount: '', gameNickname: '', extraRequirement: '' })
const minQuantity = computed(() => Number(selectedSku.value.minQuantity || 1))
const maxQuantity = computed(() => selectedSku.value.maxQuantity ? Number(selectedSku.value.maxQuantity) : 0)
const effectivePrice = computed(() => Number(selectedLevel.value.price ?? selectedSku.value.price ?? 0))
const playerCount = computed(() => Number(selectedSku.value.playerCount || 1))
const totalAmount = computed(() => (effectivePrice.value * form.quantity * (selectedSku.value.priceType === 'FIXED_TOTAL' ? 1 : playerCount.value)).toFixed(2))

onLoad(async query => {
  if (!requireLogin('登录后才能确认并提交订单')) return
  const productId = Number(query?.productId || 0)
  const skuId = Number(query?.skuId || 0)
  playerLevelId.value = Number(query?.playerLevelId || 0)
  requestedPlayerId.value = Number(query?.requestedPlayerId || 0)
  requestedPlayerName.value = decodeURIComponent(String(query?.requestedPlayerName || '所选陪玩师'))
  if (!productId || !skuId) return uni.showToast({ title: '商品参数不完整', icon: 'none' })
  product.value = await getCatalogProduct(productId)
  ;[config.value,profiles.value]=await Promise.all([getGameConfig(Number(product.value.gameId)),getCustomerGameProfiles(Number(product.value.gameId))])
  selectedSku.value = ((product.value.skus || []) as RecordData[]).find(item => Number(item.id) === skuId) || {}
  selectedLevel.value = ((selectedSku.value.levelPrices || []) as RecordData[]).find(item => Number(item.playerLevelId) === playerLevelId.value) || {}
  if (!selectedSku.value.id) return uni.showToast({ title: '服务规格已失效', icon: 'none' })
  form.quantity = minQuantity.value
  form.contactName = auth.user?.nickName || auth.user?.userName || ''
  form.contactPhone = auth.user?.phone || ''
  const preferred=profiles.value.find(x=>x.isDefault)||profiles.value[0];if(preferred)applyProfile(preferred)
})

function applyProfile(profile:RecordData){selectedProfile.value=profile;form.gameAccount=String(profile.gameAccount||'');form.gameNickname=String(profile.gameNickname||'');selectedServer.value=servers.value.find(x=>Number(x.id)===Number(profile.serverId)||(profile.serverName&&String(x.serverName)===String(profile.serverName)))||{};const saved=((profile.ranks||[]) as RecordData[]).find(x=>Number(x.rankSystemId)===Number(primaryRankSystem.value.id));selectedRank.value=ranks.value.find(x=>Number(x.id)===Number(saved?.rankId||profile.currentRankId)||(profile.currentRankName&&String(x.rankName)===String(profile.currentRankName)))||{};if(!form.contactName&&profile.contactName)form.contactName=String(profile.contactName);if(!form.contactPhone&&profile.contactPhone)form.contactPhone=String(profile.contactPhone)}
function selectProfile(event:any){applyProfile(profiles.value[Number(event.detail.value)])}
function selectServer(event:any){selectedServer.value=servers.value[Number(event.detail.value)]||{}}
function selectRank(event:any){selectedRank.value=ranks.value[Number(event.detail.value)]||{}}
function selectTargetRank(event:any){selectedTargetRank.value=ranks.value[Number(event.detail.value)]||{}}
function toggleSaveProfile(event:any){saveProfile.value=Boolean(event.detail.value)}

function changeQuantity(step: number) { const next = form.quantity + step; if (next < minQuantity.value) return; if (maxQuantity.value && next > maxQuantity.value) return; form.quantity = next }
function validate() {
  if (!form.gameAccount) return '请输入游戏账号'
  if (!form.gameNickname) return '请输入游戏昵称'
  if (!form.contactName) return '请输入联系人'
  if (!/^1\d{10}$/.test(form.contactPhone)) return '请输入正确的11位手机号'
  return ''
}
async function submit() {
  const message = validate(); if (message) return uni.showToast({ title: message, icon: 'none' })
  if (submitting.value) return
  submitting.value = true
  try {
    let profileId=Number(selectedProfile.value.id||0)
    if(!profileId&&saveProfile.value){const saved=await createCustomerGameProfile({gameId:Number(product.value.gameId),serverId:selectedServer.value.id,gameAccount:form.gameAccount,gameNickname:form.gameNickname,isDefault:profiles.value.length===0,ranks:selectedRank.value.id?[{rankSystemId:primaryRankSystem.value.id,rankId:selectedRank.value.id}]:[]});profileId=Number(saved.id)}
    const result = await createCustomerOrder({ skuId: Number(selectedSku.value.id), quantity: form.quantity, requestedPlayerId:requestedPlayerId.value||undefined, playerLevelId: playerLevelId.value || undefined, customerGameProfileId:profileId||undefined,serverId:Number(selectedServer.value.id)||undefined,currentRankId:Number(selectedRank.value.id)||undefined,targetRankId:Number(selectedTargetRank.value.id)||undefined, contactName: form.contactName, contactPhone: form.contactPhone, customerRemark: form.customerRemark || undefined, gameAccount: form.gameAccount, gameNickname: form.gameNickname, extraRequirement: form.extraRequirement || undefined })
    uni.showToast({ title: '订单创建成功', icon: 'success' })
    setTimeout(() => uni.redirectTo({ url: `/subpackages/customer/order-detail?id=${result.id}` }), 400)
  } finally { submitting.value = false }
}
function money(value: unknown) { return Number(value || 0).toFixed(2) }
function shortName(value: unknown) { return String(value || '游戏').slice(0, 4) }
function unitLabel(value: unknown) { return ({ HOUR: '小时', GAME: '局', ORDER: '单' } as Record<string, string>)[String(value || '')] || '份' }
function skuUnitLabel(value: unknown, count: unknown) { const amount = Number(count || 1); return `${amount > 1 ? amount : ''}${unitLabel(value)}` }
</script>

<style scoped lang="scss">
.confirm-page{min-height:100vh;padding:30rpx 24rpx 170rpx;box-sizing:border-box;background-color:#eee9da;background-image:radial-gradient(circle at 88% 2%,rgba(91,126,108,.15),transparent 34%),linear-gradient(180deg,rgba(244,240,225,.86),rgba(244,240,225,.96))}.page-title{position:relative;padding:25rpx 8rpx 34rpx}.page-title>text{display:block;font-family:STKaiti,KaiTi,serif;font-size:43rpx;font-weight:800}.page-title>label{display:block;margin-top:10rpx;color:#718078;font-size:21rpx}.seal{position:absolute;right:10rpx;top:20rpx;padding:8rpx;border:3rpx double #963d31;color:#963d31;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.product-card{display:flex;align-items:center}.game-mark{width:115rpx;height:115rpx;flex:none;border-radius:7rpx 25rpx 7rpx 25rpx;display:flex;align-items:center;justify-content:center;color:#fff6e7;background:#315c50;font-family:STKaiti,KaiTi,serif;font-weight:800}.product-main{min-width:0;flex:1;margin-left:22rpx}.product-name{overflow:hidden;white-space:nowrap;text-overflow:ellipsis;font-size:28rpx;font-weight:800}.sku-name{margin-top:9rpx;color:#76827b;font-size:21rpx}.unit-price{margin-top:10rpx;color:#963d31;font-weight:700}.section-title{font-family:STKaiti,KaiTi,serif;font-size:31rpx;font-weight:800}.field{min-height:88rpx;border-bottom:1rpx solid rgba(49,92,80,.13);display:flex;align-items:center}.field label{width:155rpx;color:#46584f;font-size:24rpx}.field.required label:after{content:'*';margin-left:5rpx;color:#963d31}.field input,.field picker{flex:1;font-size:24rpx;text-align:right}.picker-value{color:#26372f}.textarea-field{position:relative;padding-top:23rpx}.textarea-field label{display:block;color:#46584f;font-size:24rpx}.textarea-field textarea{width:100%;height:160rpx;margin-top:15rpx;padding:18rpx;box-sizing:border-box;border-radius:6rpx 18rpx 6rpx 18rpx;background:#ecebdd;font-size:23rpx}.textarea-field>text{position:absolute;right:15rpx;bottom:13rpx;color:#8d958f;font-size:18rpx}.textarea-field.small textarea{height:110rpx}.quantity-card,.amount-card>view{display:flex;align-items:center;justify-content:space-between}.quantity-card>view:first-child>text{color:#89928c;font-size:19rpx}.stepper{display:flex;align-items:center;gap:22rpx}.stepper button{width:58rpx;height:58rpx;padding:0;line-height:58rpx;color:#315c50;background:#e2e8dd}.stepper>text{min-width:40rpx;text-align:center;font-weight:800}.amount-card>view{min-height:60rpx;color:#69766f}.amount-card strong{color:#263a31}.amount-card label{color:#9a7540}.amount-card .payable{margin-top:12rpx;padding-top:16rpx;border-top:1rpx solid rgba(49,92,80,.16)}.amount-card .payable strong{color:#963d31;font-size:33rpx}.agreement{padding:4rpx 15rpx;color:#7d877f;font-size:19rpx;line-height:1.6}.bottom-bar{position:fixed;z-index:20;left:0;right:0;bottom:0;padding:14rpx 24rpx calc(14rpx + env(safe-area-inset-bottom));display:flex;align-items:center;background:rgba(255,252,241,.98);box-shadow:0 -8rpx 28rpx rgba(40,55,46,.12)}.total{flex:1;display:flex;align-items:baseline;white-space:nowrap}.total>text:first-child{color:#65736b;font-size:21rpx}.total-price{margin-left:10rpx;color:#963d31;font-size:36rpx;font-weight:800}.submit{width:300rpx;height:82rpx;margin:0;border-radius:7rpx 23rpx 7rpx 23rpx;line-height:82rpx;color:#fff8e9;background:#315c50;font-size:27rpx;font-weight:800}.submit[disabled]{opacity:.65}
.assignment{margin-top:20rpx;display:flex;align-items:center}.assignment-mark{width:58rpx;height:58rpx;margin-right:16rpx;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fffaf0;background:#315c50;font-family:STKaiti,KaiTi,serif;font-weight:800}.assignment strong,.assignment text{display:block}.assignment text{margin-top:7rpx;color:#7b877f;font-size:19rpx}
</style>
