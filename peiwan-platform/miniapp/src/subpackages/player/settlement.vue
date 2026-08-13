<template>
  <view class="settlement-page">
    <view class="balance-card">
      <view class="balance-head"><view><text>可提现余额</text><label>订单完成并结算后自动到账</label></view><view class="seal">收益</view></view>
      <view class="amount"><text>¥</text>{{ money(account.availableBalance) }}</view>
      <view class="balance-grid"><view><text>¥{{ money(account.frozenBalance) }}</text><label>提现中</label></view><view><text>¥{{ money(account.totalIncome) }}</text><label>累计收入</label></view><view><text>¥{{ money(account.totalWithdrawn) }}</text><label>累计提现</label></view></view>
    </view>
    <view class="rule-card"><view><text>当前分成</text><label>{{ percent(summary.playerRate) }}% 到手</label></view><view><text>平台服务费</text><label>{{ percent(summary.commissionRate) }}%</label></view><view><text>提现规则</text><label>每周{{ weekday(summary.withdrawWeekday) }} · 最低 ¥{{ money(summary.minWithdrawAmount) }}</label></view></view>
    <view class="section-head"><view><text>收入明细</text><label>每笔订单结算记录</label></view><text>{{ earnings.length }} 笔</text></view>
    <view v-for="item in earnings" :key="String(item.id)" class="earning-card" @click="openOrder(item)">
      <view class="earning-head">
        <view><text>{{ item.productName || item.title || '陪玩服务订单' }}</text><label>{{ item.gameName || '平台服务' }}<template v-if="item.skuName"> · {{ item.skuName }}</template></label></view>
        <view><text>+¥{{ money(item.playerAmount) }}</text><label>{{ earningStatusText(item.earningStatus) }}</label></view>
      </view>
      <view class="order-line"><text>订单 {{ item.orderNo || item.earningNo }}</text><label>查看订单 ›</label></view>
      <view class="service-meta">
        <text v-if="item.serverName">{{ item.serverName }}</text><text v-if="item.rankName">{{ item.rankName }}</text>
        <text>{{ Number(item.quantity || 1) }} 份</text><text v-if="Number(item.completedMemberCount || 0) > 1">{{ item.completedMemberCount }} 人完成</text>
      </view>
      <view class="calculation">
        <view><text>订单实付</text><label>¥{{ money(item.orderAmount) }}</label></view>
        <view><text>平台服务费（{{ percent(item.commissionRate) }}%）</text><label>-¥{{ money(platformFee(item)) }}</label></view>
        <view><text>订单可分配</text><label>¥{{ money(distributable(item)) }}</label></view>
        <view v-if="Number(item.completedMemberCount || 0) > 1"><text>我的分配比例</text><label>{{ distributionPercent(item) }}%</label></view>
        <view class="income-row"><text>本笔实际到账</text><label>+¥{{ money(item.playerAmount) }}</label></view>
      </view>
      <view class="earning-foot"><text>{{ item.settlementRemark || '订单完成后自动结算' }}</text><label>结算于 {{ formatTime(item.settledAt || item.createdAt) }}</label></view>
    </view>
    <EmptyState v-if="!loading && !earnings.length" text="暂无已结算收入" />
    <view v-if="loading" class="loading">收益数据加载中...</view>
  </view>
</template>
<script setup lang="ts">
import { computed, ref } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { getPlayerEarnings, getPlayerSettlement } from '@/api/player'
import EmptyState from '@/components/EmptyState.vue'
import type { RecordData } from '@/types/api'
const summary = ref<RecordData>({}), earnings = ref<RecordData[]>([]), loading = ref(false)
const account = computed(() => (summary.value.account || {}) as RecordData)
onShow(async()=>{loading.value=true;try{const [data,page]=await Promise.all([getPlayerSettlement(),getPlayerEarnings()]);summary.value=data;earnings.value=page.records||[]}finally{loading.value=false}})
function money(value:unknown){return Number(value||0).toFixed(2)}
function percent(value:unknown){return (Number(value||0)*100).toFixed(0)}
function weekday(value:unknown){return ['','一','二','三','四','五','六','日'][Number(value)||1]}
function formatTime(value:unknown){return value?String(value).replace('T',' ').slice(0,16):'--'}
function platformFee(item:RecordData){return item.platformAmount ?? item.commissionAmount}
function distributable(item:RecordData){return item.distributableAmount ?? Number(item.orderAmount||0)-Number(platformFee(item)||0)}
function distributionPercent(item:RecordData){const rate=Number(item.distributionRate||0);if(rate>0&&rate<=1)return percent(rate);const total=Number(distributable(item)||0);return total>0?(Number(item.playerAmount||0)/total*100).toFixed(0):'0'}
function earningStatusText(value:unknown){return ({AVAILABLE:'已入账',FROZEN:'提现中',WITHDRAWN:'已提现'} as Record<string,string>)[String(value)]||'已结算'}
function openOrder(item:RecordData){if(item.orderId)uni.navigateTo({url:`/subpackages/player/order-detail?id=${item.orderId}`})}
</script>
<style scoped>
.settlement-page{min-height:100vh;padding:28rpx 25rpx 90rpx;box-sizing:border-box;background:#eee9da}.balance-card{padding:31rpx 27rpx;border-radius:12rpx 34rpx 12rpx 34rpx;color:#fff5df;background:linear-gradient(135deg,#1d3d32,#416b5b);box-shadow:0 15rpx 34rpx rgba(27,55,45,.2)}.balance-head{display:flex;justify-content:space-between}.balance-head text,.balance-head label{display:block}.balance-head text{font-size:25rpx;font-weight:800}.balance-head label{margin-top:7rpx;color:rgba(255,245,223,.62);font-size:18rpx}.seal{padding:7rpx;border:3rpx double #e7c98c;color:#f0d79e;font-family:STKaiti,KaiTi,serif;transform:rotate(5deg)}.amount{margin:32rpx 0;font-size:62rpx;font-weight:800}.amount text{margin-right:8rpx;font-size:29rpx}.balance-grid{padding-top:23rpx;border-top:1rpx solid rgba(255,255,255,.14);display:grid;grid-template-columns:repeat(3,1fr)}.balance-grid view{text-align:center}.balance-grid text,.balance-grid label{display:block}.balance-grid text{font-size:24rpx;font-weight:700}.balance-grid label{margin-top:8rpx;color:rgba(255,245,223,.57);font-size:17rpx}.rule-card{margin-top:22rpx;padding:8rpx 24rpx;border:1rpx solid rgba(49,92,80,.15);border-radius:24rpx;background:#fffaf0}.rule-card>view{min-height:78rpx;border-bottom:1rpx solid rgba(49,92,80,.1);display:flex;align-items:center;justify-content:space-between}.rule-card>view:last-child{border:0}.rule-card text{color:#6d7b73;font-size:21rpx}.rule-card label{color:#315c50;font-size:22rpx;font-weight:700}.section-head{margin:36rpx 7rpx 18rpx;display:flex;align-items:flex-end;justify-content:space-between}.section-head view text,.section-head view label{display:block}.section-head view text{font-family:STKaiti,KaiTi,serif;font-size:33rpx;font-weight:800}.section-head view label,.section-head>text{margin-top:6rpx;color:#818c85;font-size:18rpx}.earning-card{margin-bottom:19rpx;padding:25rpx 24rpx 22rpx;border:1rpx solid rgba(49,92,80,.14);border-radius:21rpx;background:#fffaf0;box-shadow:0 7rpx 20rpx rgba(57,48,33,.035)}.earning-card text,.earning-card label{display:block}.earning-head{display:flex;align-items:flex-start;justify-content:space-between;gap:20rpx}.earning-head>view:first-child{min-width:0;flex:1}.earning-head>view:first-child text{overflow:hidden;color:#203e34;font-size:24rpx;font-weight:800;white-space:nowrap;text-overflow:ellipsis}.earning-head label{margin-top:8rpx;color:#8c958f;font-size:18rpx}.earning-head>view:last-child{flex:none;text-align:right}.earning-head>view:last-child text{color:#963d31;font-size:28rpx;font-weight:900}.earning-head>view:last-child label{color:#4f7a68}.order-line{margin-top:20rpx;padding:16rpx 0;border-top:1rpx solid rgba(49,92,80,.1);border-bottom:1rpx solid rgba(49,92,80,.1);display:flex;justify-content:space-between;color:#77837c;font-size:18rpx}.order-line label{color:#315c50}.service-meta{padding:15rpx 0;display:flex;flex-wrap:wrap;gap:10rpx}.service-meta text{padding:6rpx 11rpx;border-radius:16rpx;color:#5c7167;background:#edf0e8;font-size:17rpx}.calculation{padding:7rpx 18rpx;border-radius:14rpx;background:#f5f1e6}.calculation>view{min-height:51rpx;display:flex;align-items:center;justify-content:space-between;color:#69766f;font-size:19rpx}.calculation label{color:#334b41;font-weight:700}.calculation .income-row{margin-top:4rpx;border-top:1rpx dashed #d8d0c2;color:#263d34;font-weight:800}.calculation .income-row label{color:#963d31;font-size:22rpx}.earning-foot{margin-top:16rpx;display:flex;align-items:flex-start;justify-content:space-between;gap:15rpx;color:#919991;font-size:16rpx}.earning-foot text{min-width:0;flex:1}.earning-foot label{flex:none;text-align:right}.loading{padding:70rpx;text-align:center;color:#7c8881}
</style>
