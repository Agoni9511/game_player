import { API_BASE_URL } from '@/config/env'
import type { ApiResponse } from '@/types/api'

const TOKEN_KEY = 'peiwan_access_token'

export const tokenStorage = {
  get: () => String(uni.getStorageSync(TOKEN_KEY) || ''),
  set: (token: string) => uni.setStorageSync(TOKEN_KEY, token),
  clear: () => uni.removeStorageSync(TOKEN_KEY),
}

export function assetUrl(value: unknown): string {
  const url = String(value || '').trim()
  if (!url || url.startsWith('data:') || url.startsWith('wxfile:') || url.startsWith('blob:')) return url
  const demoProduct = url.match(/\/uploads\/demo\/products\/([^/?]+)\.png(?:[?#].*)?$/i)
  if (demoProduct) return `/static/products/${demoProduct[1]}.jpg`
  const demoPlayer = url.match(/\/uploads\/demo\/players\/([^/?]+)\.png(?:[?#].*)?$/i)
  if (demoPlayer) return `/static/players/${demoPlayer[1]}.jpg`
  if (url.startsWith('/')) return `${API_BASE_URL}${url}`
  return url.replace(/^https?:\/\/(?:localhost|127\.0\.0\.1)(?::\d+)?/i, API_BASE_URL)
}

export function request<T>(options: UniApp.RequestOptions): Promise<T> {
  return new Promise((resolve, reject) => {
    const token = tokenStorage.get()
    const requestData = options.data && !Array.isArray(options.data) && typeof options.data === 'object'
      ? Object.fromEntries(Object.entries(options.data as Record<string, unknown>).filter(([, value]) => value !== undefined && value !== null && value !== ''))
      : options.data
    uni.request({
      ...options,
      data: requestData,
      url: `${API_BASE_URL}${options.url}`,
      header: { 'content-type': 'application/json', ...(token ? { Authorization: `Bearer ${token}` } : {}), ...options.header },
      success: (response) => {
        const body = response.data as ApiResponse<T>
        if (response.statusCode === 401) {
          tokenStorage.clear()
          uni.$emit('auth:expired')
          uni.reLaunch({ url: '/pages/auth/login' })
          reject(new Error(body?.msg || '登录已失效'))
          return
        }
        if (response.statusCode >= 400 || body.code !== 200) {
          const message = body?.msg || '请求失败'
          uni.showToast({ title: message, icon: 'none' })
          reject(new Error(message))
          return
        }
        resolve(body.data)
      },
      fail: (error) => {
        uni.showToast({ title: '网络连接失败', icon: 'none' })
        reject(error)
      },
    })
  })
}

export function uploadFile(filePath: string, kind = 'IMAGE'): Promise<string> {
  return new Promise((resolve, reject) => {
    uni.uploadFile({
      url: `${API_BASE_URL}/api/file/upload`, filePath, name: 'file', formData: { kind },
      header: { Authorization: `Bearer ${tokenStorage.get()}` },
      success: (response) => {
        const body = JSON.parse(response.data) as ApiResponse<{ url: string }>
        if (response.statusCode >= 400 || body.code !== 200) { reject(new Error(body.msg || '上传失败')); return }
        resolve(body.data.url)
      },
      fail: reject,
    })
  })
}
