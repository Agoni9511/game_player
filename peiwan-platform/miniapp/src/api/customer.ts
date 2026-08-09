import { request } from '@/services/http'
import type { PageResult, RecordData } from '@/types/api'

export const getCustomerOrders = (status?: string) => request<PageResult<RecordData>>({ url: '/api/customer/orders', method: 'GET', data: { current: 1, size: 20, status } })
export const getCustomerOrder = (id: number) => request<RecordData>({ url: `/api/customer/orders/${id}`, method: 'GET' })
export const confirmOrder = (id: number) => request<void>({ url: `/api/customer/orders/${id}/confirm`, method: 'PUT' })
export const cancelCustomerOrder = (id: number, reason = '用户主动取消') => request<void>({ url: `/api/customer/orders/${id}/cancel`, method: 'PUT', data: { reason } })
export const createAfterSale = (id: number, data: { reasonType: string; description: string; proofUrls: string[] }) => request<{ id: number }>({ url: `/api/customer/orders/${id}/after-sale`, method: 'POST', data })
export const getCatalogGames = () => request<RecordData[]>({ url: '/api/customer/catalog/games', method: 'GET' })
export const getCatalogCategories = () => request<RecordData[]>({ url: '/api/customer/catalog/categories', method: 'GET' })
export const getCatalogProducts = (data: { keyword?: string; gameId?: number; categoryId?: number; productType?: string; current?: number; size?: number } = {}) => request<PageResult<RecordData>>({ url: '/api/customer/catalog/products', method: 'GET', data: { current: 1, size: 20, ...data } })
export const getCatalogProduct = (id: number) => request<RecordData>({ url: `/api/customer/catalog/products/${id}`, method: 'GET' })
export const getCatalogPlayers = (data: { keyword?: string; workStatus?: string; current?: number; size?: number } = {}) => request<PageResult<RecordData>>({ url: '/api/customer/catalog/players', method: 'GET', data: { current: 1, size: 50, ...data } })
export interface CreateCustomerOrder {
  skuId: number
  quantity: number
  contactName: string
  contactPhone: string
  customerRemark?: string
  gameAccount: string
  gameNickname: string
  serverName?: string
  rankName?: string
  extraRequirement?: string
}
export const createCustomerOrder = (data: CreateCustomerOrder) => request<{ id: number }>({ url: '/api/customer/orders', method: 'POST', data })
