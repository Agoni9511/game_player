# 数据补图清单

> 更新时间：2026-08-09
> 目标：补齐当前演示数据中缺失的业务图片字段，优先覆盖后台可见的核心对象。

## 1. 当前结论

当前仓库里的演示数据已经有三角洲行动、无畏契约、商品、分类、陪玩师和订单基础记录，但大多数图片字段为空，主要缺失：

- `pw_game.icon_url`
- `pw_game.cover_url`
- `pw_product_category.icon_url`
- `pw_product.cover_url`
- `pw_player.avatar_url`
- `pw_player.cover_url`
- `pw_player_game.proof_url`
- `pw_player_media.media_url`
- `pw_player_media.thumbnail_url`

其中前端页面已经实际使用这些字段：

- 游戏管理：图标、封面
- 商品分类：图标
- 商品管理：商品封面
- 陪玩师管理：头像、主页封面、游戏证明、媒体资料
- 陪玩师工作台：头像
- 履约审核 / 售后：证明图片

## 2. 放图规则

建议统一手动放到后端上传目录下，保持与真实业务一致：

- 本地目录：`backend/data/uploads/demo/`
- 线上访问路径：`/uploads/demo/...`

推荐分目录：

- `backend/data/uploads/demo/games/`
- `backend/data/uploads/demo/categories/`
- `backend/data/uploads/demo/products/`
- `backend/data/uploads/demo/players/`
- `backend/data/uploads/demo/proofs/`
- `backend/data/uploads/demo/media/`

## 3. 命名规范

- 游戏图标：`{game_code}-icon.webp`
- 游戏封面：`{game_code}-cover.webp`
- 分类图标：`{category_code}-icon.webp`
- 商品封面：`{product_code}-cover.webp`
- 陪玩师头像：`{player_no}-avatar.webp`
- 陪玩师封面：`{player_no}-cover.webp`
- 游戏证明：`{player_no}-{game_code}-proof.webp`
- 展示媒体：`{player_no}-media-{index}.webp`
- 展示媒体缩略图：`{player_no}-media-{index}-thumb.webp`

## 4. 建议尺寸

- 游戏图标：`512x512`
- 游戏封面：`1600x900`
- 分类图标：`512x512`
- 商品封面：`1200x900`
- 陪玩师头像：`800x800`
- 陪玩师主页封面：`1600x900`
- 游戏证明图：`1200x1600`
- 展示媒体主图：`1200x1600` 或 `1600x900`
- 展示媒体缩略图：`600x600`

格式建议：

- 优先：`webp`
- 备选：`png`
- 不建议先用：超大 `jpg`、透明度无必要的 `png`

## 5. 生成清单

### 5.1 游戏

1. 三角洲行动
字段：
- `pw_game.icon_url`
- `pw_game.cover_url`

文件：
- `/uploads/demo/games/delta-force-icon.webp`
- `/uploads/demo/games/delta-force-cover.webp`

风格建议：
- 图标：现代战术射击、冷色、硬朗、识别度高
- 封面：大战场、载具、烟雾、战术推进、偏写实

2. 无畏契约
字段：
- `pw_game.icon_url`
- `pw_game.cover_url`

文件：
- `/uploads/demo/games/valorant-icon.webp`
- `/uploads/demo/games/valorant-cover.webp`

风格建议：
- 图标：竞技射击、利落、未来感、红黑白高对比
- 封面：英雄技能、枪战、霓虹、电竞感

### 5.2 商品分类

建议至少先补 6 张，优先所有叶子分类和两个一级分类。

1. `delta-category`
- `/uploads/demo/categories/delta-category-icon.webp`

2. `delta-regular`
- `/uploads/demo/categories/delta-regular-icon.webp`

3. `delta-single`
- `/uploads/demo/categories/delta-single-icon.webp`

4. `delta-special`
- `/uploads/demo/categories/delta-special-icon.webp`

5. `valorant-category`
- `/uploads/demo/categories/valorant-category-icon.webp`

6. `valorant-ranked`
- `/uploads/demo/categories/valorant-ranked-icon.webp`

7. `valorant-training`
- `/uploads/demo/categories/valorant-training-icon.webp`

风格建议：

- 图标尽量扁平、强识别、单主体、背景简洁
- 同一游戏下保持同系列视觉语言

### 5.3 商品封面

1. `delta-escort-experience`
- `/uploads/demo/products/delta-escort-experience-cover.webp`
- 场景：撤离护航、双人协作、路线带领

2. `delta-regular-package`
- `/uploads/demo/products/delta-regular-package-cover.webp`
- 场景：大战场指挥 + 护航组合，内容更丰富

3. `valorant-ranked-hour`
- `/uploads/demo/products/valorant-ranked-hour-cover.webp`
- 场景：双排上分、竞技对枪、协作突破

4. `valorant-growth-package`
- `/uploads/demo/products/valorant-growth-package-cover.webp`
- 场景：实战 + 教学复盘，有“成长型服务”感觉

### 5.4 陪玩师头像与主页封面

建议至少补这 6 位：

1. `DEMO-PW-001` 北极星
- `/uploads/demo/players/DEMO-PW-001-avatar.webp`
- `/uploads/demo/players/DEMO-PW-001-cover.webp`
- 人设：可靠指挥型、三角洲大战场老手

2. `DEMO-PW-002` 小熊突击手
- `/uploads/demo/players/DEMO-PW-002-avatar.webp`
- `/uploads/demo/players/DEMO-PW-002-cover.webp`
- 人设：亲和教学型、烽火地带护航

3. `DEMO-PW-003` 夜航
- `/uploads/demo/players/DEMO-PW-003-avatar.webp`
- `/uploads/demo/players/DEMO-PW-003-cover.webp`
- 人设：冷静高分段、无畏契约控场/先锋

4. `DEMO-PW-004` 糖果枪手
- `/uploads/demo/players/DEMO-PW-004-avatar.webp`
- `/uploads/demo/players/DEMO-PW-004-cover.webp`
- 人设：轻松娱乐型、决斗位、氛围感

5. `DEMO-PW-005` 灰鸽
- `/uploads/demo/players/DEMO-PW-005-avatar.webp`
- `/uploads/demo/players/DEMO-PW-005-cover.webp`
- 人设：待审核、双游戏资料、略朴素

6. `DEMO-ADMIN-PLAYER` 凌竞队长
- `/uploads/demo/players/DEMO-ADMIN-PLAYER-avatar.webp`
- `/uploads/demo/players/DEMO-ADMIN-PLAYER-cover.webp`
- 人设：平台演示账号、职业感、双游戏高手

统一要求：

- 头像建议半身或头肩构图
- 封面建议带游戏氛围，但别堆太多 UI 文本
- 风格尽量统一，不要一半写实一半二次元

### 5.5 游戏证明图

建议优先补这 6 张：

1. `DEMO-PW-001` + `delta-force`
- `/uploads/demo/proofs/DEMO-PW-001-delta-force-proof.webp`

2. `DEMO-PW-002` + `delta-force`
- `/uploads/demo/proofs/DEMO-PW-002-delta-force-proof.webp`

3. `DEMO-PW-003` + `valorant`
- `/uploads/demo/proofs/DEMO-PW-003-valorant-proof.webp`

4. `DEMO-PW-004` + `valorant`
- `/uploads/demo/proofs/DEMO-PW-004-valorant-proof.webp`

5. `DEMO-PW-005` + `delta-force`
- `/uploads/demo/proofs/DEMO-PW-005-delta-force-proof.webp`

6. `DEMO-PW-005` + `valorant`
- `/uploads/demo/proofs/DEMO-PW-005-valorant-proof.webp`

建议形式：

- 像“段位 / 战绩 / 游戏资料截图”的视觉
- 可做成仿截图风格，但不要使用真实账号隐私

### 5.6 陪玩师展示媒体

这个不是必须第一批完成，但做完后后台体验会明显更真实。

建议每位至少 2 张：

1. `DEMO-PW-001`
- `/uploads/demo/media/DEMO-PW-001-media-1.webp`
- `/uploads/demo/media/DEMO-PW-001-media-1-thumb.webp`
- `/uploads/demo/media/DEMO-PW-001-media-2.webp`
- `/uploads/demo/media/DEMO-PW-001-media-2-thumb.webp`

2. `DEMO-PW-002`
- `/uploads/demo/media/DEMO-PW-002-media-1.webp`
- `/uploads/demo/media/DEMO-PW-002-media-1-thumb.webp`

3. `DEMO-PW-003`
- `/uploads/demo/media/DEMO-PW-003-media-1.webp`
- `/uploads/demo/media/DEMO-PW-003-media-1-thumb.webp`
- `/uploads/demo/media/DEMO-PW-003-media-2.webp`
- `/uploads/demo/media/DEMO-PW-003-media-2-thumb.webp`

4. `DEMO-PW-004`
- `/uploads/demo/media/DEMO-PW-004-media-1.webp`
- `/uploads/demo/media/DEMO-PW-004-media-1-thumb.webp`

5. `DEMO-ADMIN-PLAYER`
- `/uploads/demo/media/DEMO-ADMIN-PLAYER-media-1.webp`
- `/uploads/demo/media/DEMO-ADMIN-PLAYER-media-1-thumb.webp`

内容建议：

- 战绩展示风
- 个人形象照
- 游戏氛围图
- 教学/带队场景图

## 6. 第一批最小可用集

如果想先最小成本提升后台观感，优先只做下面 22 张：

- 游戏：4 张
- 分类：7 张
- 商品：4 张
- 头像：6 张
- `DEMO-ADMIN-PLAYER` 额外封面：1 张

如果要让陪玩师详情页也更像真实平台，第二批再补：

- 陪玩师封面
- 游戏证明图
- 陪玩师媒体图

## 7. 你生成后怎么交接

你生成完后，直接把文件放到对应目录即可。

推荐步骤：

1. 创建目录：
`backend/data/uploads/demo/games`
`backend/data/uploads/demo/categories`
`backend/data/uploads/demo/products`
`backend/data/uploads/demo/players`
`backend/data/uploads/demo/proofs`
`backend/data/uploads/demo/media`

2. 按本文件中的命名保存图片

3. 告诉我“图片已放好”

我接下来会负责：

- 校验文件是否齐全
- 生成一版数据回填方案
- 优先采用新增迁移或初始化脚本，而不是手工零散改库
- 把这些 `/uploads/demo/...` URL 回填到演示数据里

## 8. 建议不要先做的内容

- 语音文件 `voice_url`
- 视频媒体
- 售后证明图
- 履约证明图

这些可以后续再补，当前对后台首屏观感提升不如头像、封面、商品图直接。
