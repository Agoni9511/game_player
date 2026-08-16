import { request } from '@/services/http'
import type { PageResult, RecordData } from '@/types/api'

export const getCustomerOrders = (status?: string, current = 1, size = 20) => request<PageResult<RecordData>>({ url: '/api/customer/orders', method: 'GET', data: { current, size, status } })
export const getCustomerOrderSummary = () => request<Record<string, number>>({ url: '/api/customer/orders/summary', method: 'GET' })
export const getCustomerOrder = (id: number) => request<RecordData>({ url: `/api/customer/orders/${id}`, method: 'GET' })
export const getCustomerWallet = () => request<RecordData>({ url: '/api/customer/wallet', method: 'GET' })
export const getCustomerRechargePlans = () => request<RecordData[]>({ url: '/api/customer/recharge-plans', method: 'GET' })
export const rechargeCustomerWallet = (planId: number, requestNo: string) => request<RecordData>({ url: '/api/customer/wallet/recharge', method: 'POST', data: { planId, requestNo } })
export const getCustomerWalletTransactions = (data: { current?: number; size?: number; businessType?: string } = {}) => request<PageResult<RecordData>>({ url: '/api/customer/wallet/transactions', method: 'GET', data: { current: 1, size: 20, ...data } })
export const payCustomerOrder = (id: number, requestNo: string) => request<RecordData>({ url: `/api/customer/orders/${id}/pay`, method: 'POST', data: { requestNo } })
export const mockWechatPayCustomerOrder = (id: number, requestNo: string) => request<RecordData>({ url: `/api/customer/orders/${id}/pay/mock-wechat`, method: 'POST', data: { requestNo } })
export const getCustomerOrderPayment = (id: number) => request<RecordData>({ url: `/api/customer/orders/${id}/payment`, method: 'GET' })
export const confirmOrder = (id: number) => request<void>({ url: `/api/customer/orders/${id}/confirm`, method: 'PUT' })
export const cancelCustomerOrder = (id: number, reason = '用户主动取消') => request<void>({ url: `/api/customer/orders/${id}/cancel`, method: 'PUT', data: { reason } })
export const createAfterSale = (id: number, data: { reasonType: string; description: string; proofUrls: string[] }) => request<{ id: number }>({ url: `/api/customer/orders/${id}/after-sale`, method: 'POST', data })
export const createCustomerServiceException = (id: number, data: { requestType: 'TRANSFER' | 'ABORT' | 'PAUSE' | 'RESUME'; sourceOrderMemberId?: number; targetPlayerId?: number; reason: string; proofUrls?: string[] }) => request<{ id: number }>({ url: `/api/customer/orders/${id}/service-exceptions`, method: 'POST', data })
export const getTransferTargets = (id: number, sourceOrderMemberId?: number) => request<RecordData[]>({ url: `/api/service-orders/${id}/transfer-targets`, method: 'GET', data: { sourceOrderMemberId } })
export const getCatalogGames = () => request<RecordData[]>({ url: '/api/customer/catalog/games', method: 'GET' })
export const getCatalogCategories = () => request<RecordData[]>({ url: '/api/customer/catalog/categories', method: 'GET' })
export const getCatalogPlayerLevels = (gameId?: number) => request<RecordData[]>({ url: '/api/customer/catalog/player-levels', method: 'GET', data: { gameId } })
export const getCatalogPlayerTags = () => request<RecordData[]>({ url: '/api/customer/catalog/player-tags', method: 'GET' })
export const getCatalogProducts = (data: { keyword?: string; gameId?: number; categoryId?: number; productType?: string; serviceType?: string; playerLevelId?: number; minPrice?: number; maxPrice?: number; sort?: 'DEFAULT' | 'PRICE_ASC' | 'PRICE_DESC' | 'LATEST'; current?: number; size?: number } = {}) => request<PageResult<RecordData>>({ url: '/api/customer/catalog/products', method: 'GET', data: { current: 1, size: 20, ...data } })
export const getCatalogProduct = (id: number) => request<RecordData>({ url: `/api/customer/catalog/products/${id}`, method: 'GET' })
export const getGameConfig = (gameId: number) => request<RecordData>({ url: `/api/customer/catalog/games/${gameId}/config`, method: 'GET' })
export const getCustomerGameProfiles = (gameId?: number) => request<RecordData[]>({ url: '/api/customer/game-profiles', method: 'GET', data: { gameId } })
export const createCustomerGameProfile = (data: RecordData) => request<{ id: number }>({ url: '/api/customer/game-profiles', method: 'POST', data })
export const getCatalogPlayers = (data: { keyword?: string; workStatus?: string; gameId?: number; playerLevelId?: number; skuId?: number; tagId?: number; gender?: string; sort?: 'DEFAULT' | 'RATING' | 'ORDERS' | 'PRICE_ASC' | 'PRICE_DESC'; current?: number; size?: number } = {}) => request<PageResult<RecordData>>({ url: '/api/customer/catalog/players', method: 'GET', data: { current: 1, size: 50, ...data } })
export const getCatalogPlayer = (id: number) => request<RecordData>({ url: `/api/customer/catalog/players/${id}`, method: 'GET' })
export const getPlayerApplication = () => request<RecordData>({ url: '/api/customer/player-application', method: 'GET' })
export const createPlayerApplication = (data: { realName: string; phone: string; address: string }) => request<{ id: number }>({ url: '/api/customer/player-application', method: 'POST', data })
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
  requestedPlayerId?: number
  playerLevelId?: number
  customerGameProfileId?: number
  serverId?: number
  currentRankId?: number
  targetRankId?: number
}
export const createCustomerOrder = (data: CreateCustomerOrder) => request<{ id: number }>({ url: '/api/customer/orders', method: 'POST', data })
