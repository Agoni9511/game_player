import request from '@/utils/http'

export interface RechargePlan {
  id: number
  planCode: string
  planName: string
  rechargeAmount: number
  bonusAmount: number
  sortNo: number
  enabled: boolean
}

export type RechargePlanSave = Omit<RechargePlan, 'id'>

interface RechargePlanPage {
  records: RechargePlan[]
  current: number
  size: number
  total: number
}

export const fetchRechargePlanList = (params: { current: number; size: number }) =>
  request.get<RechargePlanPage>({ url: '/api/business/recharge-plan/list', params })

export const createRechargePlan = (params: RechargePlanSave) =>
  request.post<{ id: number }>({ url: '/api/business/recharge-plan', params })

export const updateRechargePlan = (id: number, params: RechargePlanSave) =>
  request.put<void>({ url: `/api/business/recharge-plan/${id}`, params })

export const setRechargePlanStatus = (id: number, enabled: boolean) =>
  request.put<void>({ url: `/api/business/recharge-plan/${id}/status`, params: { enabled } })
