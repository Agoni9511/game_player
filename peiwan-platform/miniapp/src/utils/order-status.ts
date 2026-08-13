import type { RecordData } from '@/types/api'

export const customerOrderStatusLabels: Record<string, string> = {
  ACTIVE_SERVICE: '服务中',
  PENDING_CONFIRMATION: '待确认',
  PENDING_PAYMENT: '待付款',
  WAIT_ASSIGN: '待接单',
  ASSIGNED: '已派单',
  IN_SERVICE: '服务中',
  PENDING_CONFIRM: '待平台审核',
  WAIT_CUSTOMER_CONFIRM: '待顾客确认',
  COMPLETED: '已完成',
  CANCELLED: '已取消',
  AFTER_SALE: '售后中',
  CLOSED: '已关闭'
}

export function customerOrderStatusText(status: unknown) {
  const key = String(status || '')
  return customerOrderStatusLabels[key] || '状态更新中'
}

export function customerOrderStatusTone(status: unknown) {
  const key = String(status || '')
  if (['COMPLETED'].includes(key)) return 'success'
  if (['CANCELLED', 'CLOSED'].includes(key)) return 'muted-status'
  if (['PENDING_PAYMENT', 'PENDING_CONFIRM', 'WAIT_CUSTOMER_CONFIRM'].includes(key)) return 'warning'
  if (key === 'AFTER_SALE') return 'danger'
  return 'active'
}

export type PlayerOrderCategory = 'ASSIGNED' | 'IN_SERVICE' | 'REVIEW' | 'COMPLETED'

type SeenPlayerOrders = Partial<Record<PlayerOrderCategory, string[]>>

const playerOrderCategories: PlayerOrderCategory[] = ['ASSIGNED', 'IN_SERVICE', 'REVIEW', 'COMPLETED']

function playerOrderSeenStorageKey(userId: number) {
  return `peiwan_player_order_seen_v1_${userId}`
}

function playerOrderCategory(order: RecordData): PlayerOrderCategory | undefined {
  const status = String(order.orderStatus || order.order_status || '')
  if (status === 'PENDING_CONFIRM' || status === 'WAIT_CUSTOMER_CONFIRM') return 'REVIEW'
  return playerOrderCategories.includes(status as PlayerOrderCategory) ? status as PlayerOrderCategory : undefined
}

function playerOrderSeenToken(order: RecordData) {
  const status = String(order.orderStatus || order.order_status || '')
  return `${String(order.id)}:${status}`
}

function readSeenPlayerOrders(userId: number): SeenPlayerOrders {
  const value = uni.getStorageSync(playerOrderSeenStorageKey(userId))
  return value && typeof value === 'object' ? value as SeenPlayerOrders : {}
}

export function getPlayerOrderUnreadSummary(orders: RecordData[], userId: number) {
  const seen = readSeenPlayerOrders(userId)
  return orders.reduce<Record<PlayerOrderCategory, number>>((summary, order) => {
    const category = playerOrderCategory(order)
    if (category && !(seen[category] || []).includes(playerOrderSeenToken(order))) summary[category] += 1
    return summary
  }, { ASSIGNED: 0, IN_SERVICE: 0, REVIEW: 0, COMPLETED: 0 })
}

export function markPlayerOrdersSeen(orders: RecordData[], userId: number, category: PlayerOrderCategory | 'ALL') {
  const seen = readSeenPlayerOrders(userId)
  const targets = category === 'ALL' ? playerOrderCategories : [category]
  targets.forEach(target => {
    seen[target] = orders.filter(order => playerOrderCategory(order) === target).map(playerOrderSeenToken)
  })
  uni.setStorageSync(playerOrderSeenStorageKey(userId), seen)
}
