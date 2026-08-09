import request from '@/utils/http'
import { AppRouteRecord } from '@/types/router'

// 获取用户列表
export function fetchGetUserList(params: Api.SystemManage.UserSearchParams) {
  return request.get<Api.SystemManage.UserList>({
    url: '/api/user/list',
    params
  })
}

// 获取角色列表
export function fetchGetRoleList(params: Api.SystemManage.RoleSearchParams) {
  return request.get<Api.SystemManage.RoleList>({
    url: '/api/role/list',
    params
  })
}

// 获取菜单列表
export function fetchGetMenuList() {
  return request.get<AppRouteRecord[]>({
    url: '/api/v3/system/menus'
  })
}

export function fetchGetMenuTree() {
  return request.get<AppRouteRecord[]>({ url: '/api/menu/tree' })
}

export function fetchGetRoleOptions() {
  return request.get<Api.SystemManage.RoleOption[]>({ url: '/api/role/options' })
}

export function fetchCreateUser(params: Api.SystemManage.UserSaveParams) {
  return request.post<{ id: number }>({ url: '/api/user', params })
}

export function fetchUpdateUser(id: number, params: Api.SystemManage.UserSaveParams) {
  return request.put<void>({ url: `/api/user/${id}`, params })
}

export function fetchSetUserStatus(id: number, enabled: boolean) {
  return request.put<void>({ url: `/api/user/${id}/status`, params: { enabled } })
}

export function fetchResetUserPassword(id: number, password: string) {
  return request.put<void>({ url: `/api/user/${id}/password`, params: { password } })
}

export function fetchAssignUserRoles(id: number, ids: number[]) {
  return request.put<void>({ url: `/api/user/${id}/roles`, params: { ids } })
}

export function fetchDeleteUser(id: number) {
  return request.del<void>({ url: `/api/user/${id}` })
}

export function fetchCreateRole(params: Api.SystemManage.RoleListItem) {
  return request.post<{ id: number }>({ url: '/api/role', params })
}

export function fetchUpdateRole(id: number, params: Api.SystemManage.RoleListItem) {
  return request.put<void>({ url: `/api/role/${id}`, params })
}

export function fetchSetRoleStatus(id: number, enabled: boolean) {
  return request.put<void>({ url: `/api/role/${id}/status`, params: { enabled } })
}

export function fetchDeleteRole(id: number) {
  return request.del<void>({ url: `/api/role/${id}` })
}

export function fetchGetRoleMenus(id: number) {
  return request.get<number[]>({ url: `/api/role/${id}/menus` })
}

export function fetchAssignRoleMenus(id: number, ids: number[]) {
  return request.put<void>({ url: `/api/role/${id}/menus`, params: { ids } })
}

export function fetchCreateMenu(params: Api.SystemManage.MenuSaveParams) {
  return request.post<{ id: number }>({ url: '/api/menu', params })
}

export function fetchUpdateMenu(id: number, params: Api.SystemManage.MenuSaveParams) {
  return request.put<void>({ url: `/api/menu/${id}`, params })
}

export function fetchDeleteMenu(id: number) {
  return request.del<void>({ url: `/api/menu/${id}` })
}

export function fetchGetLoginLogs(params: { current:number; size:number; username?:string; success?:boolean }) {
  return request.get<Api.SystemManage.LoginLogList>({ url: '/api/login-log/list', params })
}

export function fetchGetOperationLogs(params: { current:number; size:number; operator?:string; operation?:string; targetType?:string }) {
  return request.get<Api.SystemManage.OperationLogList>({ url: '/api/operation-log/list', params })
}
