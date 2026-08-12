import { cpSync, existsSync, mkdirSync } from 'node:fs'
import { resolve } from 'node:path'

const root = resolve(import.meta.dirname, '..')
const source = resolve(root, 'dist', 'build', 'mp-weixin')
const target = resolve(root, 'dist', 'dev', 'mp-weixin')

if (!existsSync(source)) throw new Error(`微信小程序构建目录不存在：${source}`)
mkdirSync(target, { recursive: true })
cpSync(source, target, { recursive: true, force: true })
console.log('微信小程序完整产物已同步到 dist/dev/mp-weixin')
