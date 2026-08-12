import { tokenStorage } from '@/services/http'

let loginPromptVisible = false

export function requireLogin(content = '登录后才能使用该功能'): boolean {
  if (tokenStorage.get()) return true
  if (loginPromptVisible) return false

  loginPromptVisible = true
  uni.showModal({
    title: '请先登录',
    content,
    confirmText: '去登录',
    cancelText: '暂不登录',
    success: result => {
      if (result.confirm) uni.navigateTo({ url: '/pages/auth/login' })
    },
    complete: () => { loginPromptVisible = false },
  })
  return false
}

export function navigateToWithLogin(url: string, content?: string): boolean {
  if (!requireLogin(content)) return false
  uni.navigateTo({ url })
  return true
}
