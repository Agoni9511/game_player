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
