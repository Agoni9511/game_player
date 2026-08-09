import { request } from '@/services/http'
import type { LoginResult, UserInfo } from '@/types/api'

export const login = (userName: string, password: string) => request<LoginResult>({ url: '/api/auth/login', method: 'POST', data: { userName, password } })
export const getUserInfo = () => request<UserInfo>({ url: '/api/user/info', method: 'GET' })
export const updateUserProfile = (data: Record<string, unknown>) => request<void>({ url: '/api/user/profile', method: 'PUT', data })
