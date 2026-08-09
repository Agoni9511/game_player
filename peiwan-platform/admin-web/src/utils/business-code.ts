/** 新增数据时生成可识别、低冲突的业务编码。 */
export function generateBusinessCode(prefix: string) {
  return `${prefix}-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 6)}`.toLowerCase()
}
