<template>
  <view class="orders-page">
    <scroll-view scroll-x class="tabs" :show-scrollbar="false">
      <view class="tabs-inner">
        <view v-for="tab in tabs" :key="tab.key" class="tab" :class="{ active: activeTab===tab.key }" @click="activeTab=tab.key">
          {{ tab.label }}<text v-if="countFor(tab.key)">{{ countFor(tab.key) }}</text>
        </view>
      </view>
    </scroll-view>

    <view class="content">
      <view v-for="order in filteredOrders" :key="String(order.id)" class="order-card" @click="open(Number(order.id))">
        <view class="card-head"><view class="order-no">{{ order.orderNo }}</view><view class="status" :class="statusClass(String(order.orderStatus))">{{ statusText(String(order.orderStatus)) }}</view></view>
        <view class="game-row">
          <view class="game-icon"><image src="/static/icons/gamepad.svg" /></view>
          <view class="game-main"><view class="game-name">{{ order.gameName || '游戏陪玩服务' }}</view><view class="product">{{ order.productName || '服务商品' }}</view></view>
          <view class="amount"><text>订单金额</text><view>¥{{ money(order.payableAmount) }}</view></view>
        </view>
        <view class="info-grid">
          <view><text>服务规格</text><label>{{ order.skuName || '默认规格' }}</label></view>
          <view><text>区服 / 段位</text><label>{{ [order.serverName,order.rankName].filter(Boolean).join(' · ') || '未填写' }}</label></view>
          <view class="wide"><text>预约信息</text><label>{{ appointmentText(order) }}</label></view>
        </view>
        <view v-if="reviewHint(order)" class="review-hint"><image src="/static/icons/hourglass.svg"/><text>{{ reviewHint(order) }}</text></view>
        <view class="card-foot">
          <text>接单于 {{ formatTime(order.assignedAt) }}</text>
          <view class="actions" @click.stop>
            <button v-if="order.orderStatus==='ASSIGNED'" size="mini" class="primary small" @click="start(order)">开始服务</button>
            <button v-else-if="order.orderStatus==='IN_SERVICE'" size="mini" class="primary small" @click="submit(order)">提交完成</button>
            <button v-else-if="isAbnormal(String(order.orderStatus))" size="mini" class="outline small" @click="contact(order)">联系客服</button>
            <button v-else size="mini" class="outline small" @click="open(Number(order.id))">查看详情</button>
          </view>
        </view>
      </view>
      <EmptyState v-if="!loading&&!filteredOrders.length" :text="`暂无${activeLabel}服务单`" />
      <view v-if="loading" class="loading">服务单加载中...</view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { getPlayerOrder, getPlayerOrders, startOrder } from '@/api/player'
import EmptyState from '@/components/EmptyState.vue'
import type { RecordData } from '@/types/api'

const tabs=[{key:'ALL',label:'全部'},{key:'ASSIGNED',label:'待开始'},{key:'IN_SERVICE',label:'服务中'},{key:'REVIEW',label:'待审核'},{key:'COMPLETED',label:'已完成'}]
const activeTab=ref('ALL'),orders=ref<RecordData[]>([]),loading=ref(false)
const filteredOrders=computed(()=>activeTab.value==='ALL'?orders.value:orders.value.filter(item=>activeTab.value==='REVIEW'?['PENDING_CONFIRM','WAIT_CUSTOMER_CONFIRM'].includes(String(item.orderStatus)):item.orderStatus===activeTab.value))
const activeLabel=computed(()=>tabs.find(tab=>tab.key===activeTab.value)?.label||'')
onMounted(load)
defineExpose({ load })
async function load(){loading.value=true;try{const records=(await getPlayerOrders()).records||[];orders.value=await Promise.all(records.map(async item=>{try{return{...item,...await getPlayerOrder(Number(item.id))}}catch{return item}}))}finally{loading.value=false}}
function countFor(key:string){if(key==='ALL')return orders.value.length;if(key==='REVIEW')return orders.value.filter(x=>['PENDING_CONFIRM','WAIT_CUSTOMER_CONFIRM'].includes(String(x.orderStatus))).length;return orders.value.filter(x=>x.orderStatus===key).length}
function statusText(status:string){return({ASSIGNED:'待开始',IN_SERVICE:'服务中',PENDING_CONFIRM:'平台审核中',WAIT_CUSTOMER_CONFIRM:'待顾客确认',COMPLETED:'已完成',CANCELLED:'已取消',AFTER_SALE:'售后处理中'}as Record<string,string>)[status]||status}
function statusClass(status:string){if(status==='IN_SERVICE')return'working';if(['PENDING_CONFIRM','WAIT_CUSTOMER_CONFIRM'].includes(status))return'review';if(status==='COMPLETED')return'done';if(isAbnormal(status))return'abnormal';return'waiting'}
function money(value:unknown){const amount=Number(value||0);return amount.toFixed(2)}
function formatTime(value:unknown){if(!value)return'--';return String(value).replace('T',' ').slice(0,16)}
function appointmentText(order:RecordData){return order.serviceStartedAt?`已于 ${formatTime(order.serviceStartedAt)} 开始`:order.assignedAt?`接单时间 ${formatTime(order.assignedAt)}`:'未设置预约时间'}
function reviewHint(order:RecordData){if(order.orderStatus==='PENDING_CONFIRM')return'完成凭证已提交，等待平台审核';if(order.orderStatus==='WAIT_CUSTOMER_CONFIRM')return'平台审核已通过，等待顾客确认完成';return''}
function isAbnormal(status:string){return['CANCELLED','AFTER_SALE'].includes(status)}
function open(id:number){uni.navigateTo({url:`/subpackages/player/order-detail?id=${id}`})}
function submit(order:RecordData){uni.navigateTo({url:`/subpackages/player/submit?id=${order.id}`})}
function start(order:RecordData){uni.showModal({title:'开始服务',content:'请确认已与顾客核对游戏账号、区服和服务要求。开始后订单将进入服务中。',confirmText:'确认开始',success:async result=>{if(result.confirm){await startOrder(Number(order.id));uni.showToast({title:'服务已开始'});await load()}}})}
function contact(order:RecordData){uni.showModal({title:'联系平台客服',content:`订单 ${order.orderNo} 当前存在异常，请保留相关凭证并联系平台管理员处理。`,confirmText:'我知道了',showCancel:false})}
</script>

<style scoped lang="scss">
.orders-page{min-height:100vh;padding-bottom:180rpx;background:#f5f6fa}.tabs{position:sticky;z-index:10;top:0;white-space:nowrap;background:#fff}.tabs-inner{height:94rpx;padding:0 22rpx;display:flex;align-items:center;gap:8rpx}.tab{position:relative;min-width:105rpx;padding:26rpx 7rpx;text-align:center;color:#858a99;font-size:25rpx}.tab text{margin-left:6rpx;color:#b0b4bf;font-size:18rpx}.tab.active{color:#7357ef;font-weight:800}.tab.active:after{content:'';position:absolute;left:35%;right:35%;bottom:8rpx;height:6rpx;border-radius:6rpx;background:#7357ef}.content{padding:22rpx}.order-card{margin-bottom:22rpx;padding:26rpx;border-radius:25rpx;background:#fff;box-shadow:0 8rpx 28rpx rgba(35,40,55,.045)}.card-head,.game-row,.card-foot{display:flex;align-items:center}.card-head{justify-content:space-between;padding-bottom:20rpx;border-bottom:1rpx solid #f0f1f4}.order-no{color:#777c8b;font-size:21rpx}.status{font-size:22rpx;font-weight:700}.status.waiting{color:#7a5eef}.status.working{color:#1ca49f}.status.review{color:#e18a34}.status.done{color:#7e8492}.status.abnormal{color:#dc596e}.game-row{padding:24rpx 0}.game-icon{width:78rpx;height:78rpx;flex:none;border-radius:22rpx;display:flex;align-items:center;justify-content:center;background:#f0edff}.game-icon image{width:50rpx;height:50rpx}.game-main{min-width:0;flex:1;margin-left:18rpx}.game-name{font-size:28rpx;font-weight:800}.product{margin-top:9rpx;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;color:#9297a5;font-size:21rpx}.amount{text-align:right}.amount text{color:#a2a6b1;font-size:18rpx}.amount view{margin-top:6rpx;color:#ec5e85;font-size:29rpx;font-weight:800}.info-grid{padding:20rpx;border-radius:17rpx;display:grid;grid-template-columns:1fr 1fr;gap:18rpx;background:#f8f8fb}.info-grid view{min-width:0}.info-grid .wide{grid-column:1/3}.info-grid text,.info-grid label{display:block}.info-grid text{color:#a0a4b0;font-size:18rpx}.info-grid label{margin-top:7rpx;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;color:#515563;font-size:21rpx}.review-hint{margin-top:18rpx;padding:17rpx;border-radius:15rpx;display:flex;align-items:center;gap:12rpx;color:#9a743d;background:#fff7e9;font-size:20rpx}.review-hint image{width:31rpx;height:31rpx}.card-foot{min-height:78rpx;padding-top:16rpx;justify-content:space-between}.card-foot>text{color:#a5a9b4;font-size:18rpx}.actions button{margin:0}.small{padding:0 24rpx;border-radius:100rpx;font-size:21rpx}.outline{color:#6e7280;background:#fff;border:1rpx solid #dfe1e7}.loading{padding:80rpx;color:#999eaa;text-align:center}
</style>
<style scoped lang="scss">
.orders-page{background:#eee9da url('/static/ink-tactical-bg.jpg') center top/100% auto no-repeat}.tabs{background:rgba(250,247,235,.96);border-bottom:1rpx solid rgba(52,80,66,.16)}.tab.active{color:#315c50}.tab.active:after{background:#963d31}.order-card{border:1rpx solid rgba(54,79,68,.18);border-radius:9rpx 25rpx 9rpx 25rpx;background:rgba(255,252,241,.93);box-shadow:0 9rpx 26rpx rgba(36,54,44,.07)}.status.waiting{color:#315c50}.game-icon{background:#dce7dc}.info-grid{background:rgba(226,229,215,.62)}.amount view{color:#963d31}.review-hint{color:#725b38;background:#f1e8cf}.outline{color:#315c50;background:#fffaf0;border-color:#aab9ad}
</style>
