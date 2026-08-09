export interface ApiResponse<T> { code: number; msg: string; data: T }
export interface LoginResult { token: string; refreshToken: string }
export interface UserInfo { userId: number; userName: string; nickName: string; email?: string; phone?: string; gender?: string; avatar?: string; roles: string[]; buttons: string[] }
export interface PageResult<T> { records: T[]; total: number; current: number; size: number }
export type RecordData = Record<string, unknown>
