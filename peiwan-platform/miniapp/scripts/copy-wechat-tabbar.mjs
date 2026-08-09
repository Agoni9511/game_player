import { copyFileSync, existsSync, mkdirSync } from 'node:fs'
import { resolve } from 'node:path'

const outputKind = process.argv[2] || 'dev'
const root = resolve(import.meta.dirname, '..')
const sourceDir = resolve(root, 'custom-tab-bar')
const targetDir = resolve(root, `dist/${outputKind}/mp-weixin/custom-tab-bar`)
const files = ['index.js', 'index.json', 'index.wxml', 'index.wxss']

function syncTabBar() {
  if (!existsSync(sourceDir)) return false
  mkdirSync(targetDir, { recursive: true })
  for (const file of files) {
    copyFileSync(resolve(sourceDir, file), resolve(targetDir, file))
  }
  return true
}

if (!syncTabBar()) {
  console.error(`custom-tab-bar source not found: ${sourceDir}`)
  process.exit(1)
}

console.log(`custom-tab-bar synced to dist/${outputKind}/mp-weixin/custom-tab-bar`)
