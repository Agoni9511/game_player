type DateValue = string | number | Date | null | undefined

const DATE_TIME_PATTERN =
  /^(\d{4})-(\d{1,2})-(\d{1,2})(?:[T\s](\d{1,2}):(\d{1,2})(?::(\d{1,2}))?(?:\.\d+)?)?$/

const pad = (value: number | string) => String(value).padStart(2, '0')

const formatParts = (
  year: number | string,
  month: number | string,
  day: number | string,
  hour?: number | string,
  minute?: number | string,
  second?: number | string
) => ({
  date: `${year}-${pad(month)}-${pad(day)}`,
  time: `${pad(hour ?? 0)}:${pad(minute ?? 0)}:${pad(second ?? 0)}`
})

/**
 * 解析后端日期。
 * - 带 Z/时区偏移的 ISO 字符串按绝对时间转换为浏览器本地时间。
 * - 不带时区的 LocalDateTime 按本地时间原样展示，避免重复偏移。
 */
function getDateParts(value: DateValue) {
  if (value === null || value === undefined || value === '') return null

  if (typeof value === 'string') {
    const normalized = value.trim()
    if (!normalized) return null

    const localMatch = normalized.match(DATE_TIME_PATTERN)
    if (localMatch) {
      const [, year, month, day, hour, minute, second] = localMatch
      return formatParts(year, month, day, hour, minute, second)
    }
  }

  const date = value instanceof Date ? value : new Date(value)
  if (Number.isNaN(date.getTime())) return null

  return formatParts(
    date.getFullYear(),
    date.getMonth() + 1,
    date.getDate(),
    date.getHours(),
    date.getMinutes(),
    date.getSeconds()
  )
}

export function formatDateTime(value: DateValue, fallback = '-') {
  const parts = getDateParts(value)
  return parts ? `${parts.date} ${parts.time}` : fallback
}

export function formatDate(value: DateValue, fallback = '-') {
  return getDateParts(value)?.date ?? fallback
}

export function formatTime(value: DateValue, fallback = '-') {
  return getDateParts(value)?.time ?? fallback
}
