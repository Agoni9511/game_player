import { request } from '@/services/http'
import type { PageResult, RecordData } from '@/types/api'

export const getWorkbench = () => request<RecordData>({ url: '/api/player/workbench', method: 'GET' })
export const updateWorkStatus = (workStatus: 'AVAILABLE' | 'OFFLINE') => request<void>({ url: '/api/player/work-status', method: 'PUT', data: { workStatus } })
export const getPendingDispatches = () => request<RecordData[]>({ url: '/api/player/dispatch/pending', method: 'GET' })
export const acceptDispatch = (id: number) => request<void>({ url: `/api/player/dispatch/${id}/accept`, method: 'PUT' })
export const rejectDispatch = (id: number, reason: string) => request<void>({ url: `/api/player/dispatch/${id}/reject`, method: 'PUT', data: { reason } })
export const getPlayerOrders = (status?: string) => request<PageResult<RecordData>>({ url: '/api/player/orders', method: 'GET', data: { current: 1, size: 20, status } })
export const getPlayerOrder = (id: number) => request<RecordData>({ url: `/api/player/orders/${id}`, method: 'GET' })
export const startOrder = (id: number) => request<void>({ url: `/api/player/orders/${id}/start`, method: 'PUT' })
export const submitOrder = (id: number, data: RecordData) => request<void>({ url: `/api/player/orders/${id}/submit`, method: 'PUT', data })
