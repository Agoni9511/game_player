import { defineConfig, type Plugin } from 'vite'
import uni from '@dcloudio/vite-plugin-uni'
import { copyFileSync, mkdirSync } from 'node:fs'
import { resolve } from 'node:path'

function copyWechatCustomTabBar(outputKind: 'dev' | 'build'): Plugin {
  const copy = () => {
    const source = resolve(__dirname, 'custom-tab-bar')
    const target = resolve(__dirname, `dist/${outputKind}/mp-weixin/custom-tab-bar`)
    mkdirSync(target, { recursive: true })
    for (const file of ['index.js', 'index.json', 'index.wxml', 'index.wxss']) {
      copyFileSync(resolve(source, file), resolve(target, file))
    }
  }
  return {
    name: 'copy-wechat-custom-tab-bar',
    buildStart() {
      copy()
    },
    configureServer(server) {
      copy()
      server.httpServer?.once('listening', () => setTimeout(copy, 1200))
      server.watcher.add(resolve(__dirname, 'custom-tab-bar/*'))
    },
    handleHotUpdate(context) {
      if (context.file.includes('custom-tab-bar')) copy()
    },
    writeBundle: copy,
    closeBundle: copy,
  }
}

export default defineConfig(({ command }) => ({
  plugins: [uni(), copyWechatCustomTabBar(command === 'serve' ? 'dev' : 'build')],
}))
