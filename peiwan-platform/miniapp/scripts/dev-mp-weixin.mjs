import { spawn } from 'node:child_process'
import { existsSync, statSync } from 'node:fs'
import { resolve } from 'node:path'

const root = resolve(import.meta.dirname, '..')
const uniCmd = resolve(root, 'node_modules', '.bin', process.platform === 'win32' ? 'uni.cmd' : 'uni')
const copyScript = resolve(root, 'scripts', 'copy-wechat-tabbar.mjs')
const outputDir = resolve(root, 'dist', 'dev', 'mp-weixin')
const sourceDir = resolve(root, 'custom-tab-bar')
const targetDir = resolve(outputDir, 'custom-tab-bar')
const tabBarFiles = ['index.js', 'index.json', 'index.wxml', 'index.wxss']
const tabBarConfig = resolve(outputDir, 'custom-tab-bar', 'index.json')
let syncing = false

function syncTabBar() {
  if (!existsSync(outputDir) || syncing) return
  const outdated = !existsSync(tabBarConfig) || tabBarFiles.some((file) => {
    const source = resolve(sourceDir, file)
    const target = resolve(targetDir, file)
    return !existsSync(target) || statSync(source).mtimeMs > statSync(target).mtimeMs
  })
  if (!outdated) return
  syncing = true
  const child = spawn(process.execPath, [copyScript, 'dev'], {
    cwd: root,
    stdio: 'inherit'
  })
  child.on('exit', () => { syncing = false })
}

// UniApp may recreate dist/dev after the watcher starts, so keep repairing the
// native custom tab bar whenever a rebuild removes it.
const syncTimer = setInterval(syncTabBar, 1000)

const devServer = spawn(uniCmd, ['-p', 'mp-weixin'], {
  cwd: root,
  stdio: 'inherit',
  shell: process.platform === 'win32'
})

const stop = () => {
  clearInterval(syncTimer)
  if (!devServer.killed) devServer.kill()
}

process.on('SIGINT', stop)
process.on('SIGTERM', stop)

devServer.on('exit', (code) => {
  clearInterval(syncTimer)
  process.exit(code ?? 0)
})
