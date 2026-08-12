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
      <view v-for="order in filteredOrders" :key="String(order.id)" class="order-ticket" :class="statusClass(String(order.orderStatus))" @click="open(Number(order.id))">
        <view class="ticket-status"><text />{{ statusText(String(order.orderStatus)) }}</view>
        <view class="ticket-game"><view class="game-mark"><image src="/static/icons/gamepad.png" /></view><view><text>{{ order.gameName || '游戏陪玩服务' }}</text><label>{{ order.productName || '服务商品' }}</label></view></view>
        <view class="ticket-spec">{{ order.skuName || '默认规格' }}</view>
        <view class="ticket-meta"><text>{{ [order.serverName,order.rankName].filter(Boolean).join(' · ') || '区服段位待确认' }}</text><label>{{ order.memberCount || 0 }}/{{ order.requiredPlayerCount || 1 }} 位陪玩</label></view>
        <view class="appointment"><image src="/static/icons/hourglass.png"/><text>{{ appointmentText(order) }}</text></view>
        <view v-if="reviewHint(order)" class="review-hint">{{ reviewHint(order) }}</view>
        <view class="ticket-foot">
          <view class="amount"><text>¥</text>{{ money(order.payableAmount) }}</view>
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
import { computed, onMounted, ref, watch } from 'vue'
import { getPlayerOrder, getPlayerOrders, startOrder } from '@/api/player'
import EmptyState from '@/components/EmptyState.vue'
import type { RecordData } from '@/types/api'

const tabs=[{key:'ALL',label:'全部'},{key:'ASSIGNED',label:'待开始'},{key:'IN_SERVICE',label:'服务中'},{key:'REVIEW',label:'待审核'},{key:'COMPLETED',label:'已完成'}]
const props=withDefaults(defineProps<{initialTab?:string}>(),{initialTab:'ALL'})
const activeTab=ref('ALL'),orders=ref<RecordData[]>([]),loading=ref(false)
watch(()=>props.initialTab,value=>{if(tabs.some(tab=>tab.key===value))activeTab.value=value},{immediate:true})
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
.orders-page{min-height:0;padding-bottom:40rpx;background:#f8f5ec}.tabs{position:sticky;z-index:10;top:0;white-space:nowrap;border-top:1rpx solid #e7e0d2;border-bottom:1rpx solid #e7e0d2;background:rgba(248,245,236,.97)}.tabs-inner{height:88rpx;padding:0 28rpx;display:flex;align-items:center;gap:6rpx}.tab{position:relative;min-width:114rpx;padding:28rpx 5rpx;color:#7c817e;text-align:center;font-size:23rpx}.tab text{margin-left:5rpx;color:#b42e28;font-size:19rpx}.tab.active{color:#174737;font-weight:800}.tab.active:after{content:'';position:absolute;left:34%;right:34%;bottom:6rpx;height:5rpx;border-radius:4rpx;background:#174737}.content{padding:28rpx 38rpx}.order-ticket{position:relative;margin-bottom:24rpx;padding:28rpx 28rpx 24rpx 36rpx;border:1rpx solid #dfd5c3;background:#fffdf8;box-shadow:0 8rpx 24rpx rgba(57,48,33,.045)}.order-ticket:before{content:'';position:absolute;left:0;top:0;bottom:0;width:8rpx;background:#315c50}.order-ticket.review:before{background:#b6873e}.order-ticket.done:before{background:#a4a7a1}.order-ticket.abnormal:before{background:#963d31}.ticket-status{display:flex;align-items:center;gap:10rpx;color:#963d31;font-size:22rpx;font-weight:800}.ticket-status>text{width:10rpx;height:10rpx;border-radius:50%;background:currentColor}.working .ticket-status{color:#197459}.review .ticket-status{color:#a87328}.done .ticket-status{color:#777d79}.ticket-game{margin-top:24rpx;display:flex;align-items:center}.game-mark{width:64rpx;height:64rpx;flex:none;border-radius:13rpx;display:flex;align-items:center;justify-content:center;background:#e3ece5}.game-mark image{width:39rpx;height:39rpx}.ticket-game>view:last-child{min-width:0;flex:1;margin-left:17rpx}.ticket-game text,.ticket-game label{display:block;overflow:hidden;white-space:nowrap;text-overflow:ellipsis}.ticket-game text{color:#193b30;font-size:28rpx;font-weight:800}.ticket-game label{margin-top:6rpx;color:#838985;font-size:19rpx}.ticket-spec{margin-top:27rpx;color:#202a26;font-family:STKaiti,KaiTi,serif;font-size:37rpx;font-weight:800}.ticket-meta{margin-top:13rpx;display:flex;align-items:center;color:#747a76;font-size:21rpx}.ticket-meta label{margin-left:auto}.appointment{margin-top:24rpx;padding:21rpx 0;border-top:1rpx dashed #d9d1c4;border-bottom:1rpx solid #e5ded2;display:flex;align-items:center;color:#50615a;font-size:21rpx}.appointment image{width:30rpx;height:30rpx;margin-right:11rpx}.review-hint{margin-top:16rpx;padding:13rpx 16rpx;border-left:4rpx solid #b6873e;color:#80643a;background:#f5edda;font-size:19rpx}.ticket-foot{min-height:82rpx;padding-top:20rpx;display:flex;align-items:center;justify-content:space-between}.amount{color:#af2923;font-size:35rpx;font-weight:900}.amount text{margin-right:4rpx;font-size:21rpx}.actions button{height:64rpx;margin:0;padding:0 28rpx;border-radius:6rpx;line-height:64rpx;font-size:21rpx}.actions .primary{color:#fff;background:#174737}.outline{border:1rpx solid #9caf9f;color:#315c50;background:#fffdf8}.loading{padding:80rpx;color:#878d88;text-align:center}
</style>
