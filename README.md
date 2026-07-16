# LifeOS

LifeOS 是一个 **日记 + 记账 + ToDo + 周计划 + 情绪记录** 一体化的个人生活管理应用。

与传统记账软件不同，LifeOS 不追求冰冷的数字报表，而是强调 **今天发生了什么、心情怎么样、完成了哪些事情**——最终形成一本有温度的**生活账本**。

本仓库是一个 Flutter 跨平台项目：

- `lib/app`：应用配置层，包含主题系统（配色、字体、圆角、阴影、动效）、路由和常量。
- `lib/core`：核心基础设施，包含 SQLite 数据库、数据模型、共享组件和工具类。
- `lib/features`：功能模块，按 Feature-First 架构组织，每个模块包含 `presentation/pages/` 和 `presentation/widgets/`。
- `test`：单元测试和 Widget 测试。
- `android`、`ios`、`windows`、`macos`、`linux`、`web`：各平台入口与原生配置。

## 功能概览

### 日记

- 每日日期展示（大号日期 + 星期 + 完整日期）。
- 心情标记（5 级 emoji 选择器）和天气标记（晴天/多云/雨天/雪天/大风）。
- 今日待办清单（勾选完成、划线动画、每日自动生成默认项）。
- 富文本日记编辑器（Markdown 语法支持、图片/视频/录音/位置/标签工具栏）。
- 今日消费摘要卡片，点击可跳转至记账页。

### 记账

- 时间轴视图，按上午（6-12）、下午（12-18）、晚上（18-6）分组展示。
- 每笔交易以卡片形式呈现：分类图标、名称、备注、时间、金额和收支颜色。
- 三步新增流程（类型 → 金额 → 分类+备注），全部在 BottomSheet 内完成，无需跳页。
- 自定义数字键盘，支持小数点输入，限制两位小数精度。
- 滑动删除交易。

### 周计划

- 七日网格视图（周一至周日）。
- 周导航切换（上一周/下一周），显示周范围标签。
- 每日列包含日期数字（今天高亮）+ 事件占位区。
- 目标标签编辑和事件增删（待接入数据库）。

### 清单

- 多列表管理（全部/自定义列表切换）。
- 待办事项增删改查、优先级标记（4 级彩色指示点）。
- 勾选完成带动画过渡（划线 + 变色 + 缩放反馈）。
- 滑动右删除、左完成。
- 新增待办通过 BottomSheet 快速输入。

### 统计

- 生活值环形仪表盘（加权综合：日记连续 × 任务完成 × 预算健康 × 心情均值）。
- 消费分类占比条形图，带动画进度条。
- 温暖文案月度总结卡片。

### 书本模式

- 翻页浏览所有历史日记。
- 双页展开效果（左页内容 + 右页标题），装订线渐变装饰。
- 页码导航。

### 个人中心

- 头像展示（带强调色环）。
- 连续记录天数徽章。
- 数据统计卡片（日记篇数、账单条数、照片数量）。
- 生活值预览卡片，点击进入详细统计页。
- 快捷操作入口（书本模式、统计、设置）。

## 设计系统

### 设计关键词

```
Minimal · Paper · Warm · Soft · Nature · Notebook · Diary
极简   · 纸张  · 暖色 · 柔和 · 自然  · 手账    · 日记
```

### 配色

| Token | 色值 | 用途 |
| --- | --- | --- |
| Primary BG | `#F7F3EE` | 页面背景（奶白色） |
| Card | `#FFFDFB` | 卡片背景 |
| Secondary BG | `#F3EEE8` | 次要背景 / 选中态 |
| Primary Text | `#2B2B2B` | 主文字 / 导航选中 |
| Secondary Text | `#757575` | 辅助文字 / 导航未选中 |
| Divider | `#E8E1D8` | 分割线 / 边框 |
| Accent | `#8E7C66` | 强调色 / 进度条 |
| Success | `#86B66E` | 完成 / 勾选 |
| Expense | `#C96C5C` | 支出金额 |
| Income | `#6B9D78` | 收入金额 |

### 圆角

| Token | 值 | 用途 |
| --- | --- | --- |
| `tag` | 8px | 标签、徽章 |
| `input` | 16px | 输入框、按钮 |
| `card` | 20px | 卡片、导航胶囊 |
| `sheet` | 28px | 底部弹出（顶部圆角） |

### 字体层级

| Token | 字号 | 字重 | 用途 |
| --- | --- | --- | --- |
| `date42` | 42 | Light (w300) | 大号日期数字 |
| `amount34` | 34 | Bold (w700) | 金额显示 |
| `amountInput` | 48 | Light (w300) | 记账金额输入 |
| `title32` | 32 | SemiBold (w600) | 页面标题 |
| `h1_26` | 26 | Medium (w500) | 一级标题 |
| `body17` | 17 | Regular (w400) | 正文 / 列表项 |
| `caption14` | 14 | Regular (w400) | 辅助文字 / 标签 |
| `navLabel` | 12 | Medium (w500) | 导航栏文字 |

### 动效与阴影

- 动画时长统一 **250 ~ 350ms**，禁止快速动画。
- 默认曲线 `easeOutQuart`（Cubic 0.25, 1.0, 0.5, 1.0）。
- 卡片阴影：Blur **12px**，Opacity **5%**，不出现 Material Design 明显阴影。
- 页面转场：Fade + Slide（300ms）。
- BottomSheet：系统 Spring 弹性动画。
- 导航胶囊切换：AnimatedContainer 300ms。

## 技术栈

| 层 | 技术 |
| --- | --- |
| 框架 | Flutter 3.44 |
| 语言 | Dart 3.12 |
| 状态管理 | flutter_riverpod 2.6 |
| 路由 | go_router 14.8（StatefulShellRoute） |
| 本地存储 | sqflite 2.4（SQLite） |
| 动画 | flutter_animate 4.5 |
| 翻页 | turnable_page 1.0 |
| 图片选择 | image_picker 1.2 |
| 日期格式化 | intl 0.19 |
| 字体 | google_fonts 6.3 |
| 持久化 KV | shared_preferences 2.5 |

## 目录结构

```text
lib/
├── app/                              # 应用配置
│   ├── theme/                        # 主题系统
│   │   ├── app_colors.dart           #   配色常量（10 色）
│   │   ├── app_typography.dart       #   字体规范（8 级）
│   │   ├── app_radius.dart           #   圆角规范（4 种）
│   │   ├── app_shadows.dart          #   阴影规范（3 种）
│   │   ├── app_durations.dart        #   动效时长（3 档）
│   │   └── app_theme.dart            #   ThemeData 工厂 + easeOutQuart 曲线
│   ├── router.dart                   # go_router 配置（StatefulShellRoute + 5 分支）
│   └── constants.dart                # App 常量 + 中文文案（AppStrings）
│
├── core/                             # 核心基础设施
│   ├── database/
│   │   └── database_helper.dart      # sqflite 初始化（7 表 + 默认数据种子）
│   ├── models/                       # 数据模型（toMap / fromMap / copyWith）
│   │   ├── diary_entry.dart          #   日记条目（日期、内容、心情、天气、媒体、标签）
│   │   ├── transaction.dart          #   交易记录（金额、类型、分类、图标、备注、时段）
│   │   ├── todo_item.dart            #   待办事项（标题、完成状态、优先级、截止日期）
│   │   ├── weekly_plan.dart          #   周计划（周起始日、目标、每日备注、事件）
│   │   └── mood_entry.dart           #   心情记录
│   ├── widgets/
│   │   └── capsule_nav_bar.dart      # 胶囊式底部导航栏
│   └── utils/
│       ├── date_helpers.dart         # 日期工具（格式化、相对日期、周/月起止、同天判断）
│       └── currency_utils.dart       # 货币格式化（¥ 符号、千分位）
│
├── features/                         # 功能模块（Feature-First）
│   ├── diary/                        # 📔 日记
│   │   └── presentation/
│   │       ├── pages/diary_page.dart
│   │       └── widgets/
│   │           ├── diary_header.dart       # 日期显示 + 心情/天气选择器
│   │           ├── today_checklist.dart    # 今日待办勾选卡片
│   │           ├── diary_editor.dart       # 文本编辑器 + Markdown 工具栏
│   │           └── spending_summary.dart   # 今日消费摘要卡片
│   │
│   ├── ledger/                       # 💰 记账
│   │   └── presentation/
│   │       ├── pages/ledger_page.dart
│   │       └── widgets/
│   │           ├── transaction_timeline.dart  # 按日期+时段分组的时间轴
│   │           ├── transaction_tile.dart      # 单条交易卡片
│   │           └── add_expense_sheet.dart     # 3 步新增 BottomSheet
│   │
│   ├── planner/                      # 📅 周计划
│   │   └── presentation/pages/planner_page.dart
│   │
│   ├── checklist/                    # ✅ 清单
│   │   └── presentation/pages/checklist_page.dart
│   │
│   ├── statistics/                   # 📊 统计
│   │   └── presentation/
│   │       ├── pages/statistics_page.dart
│   │       └── widgets/
│   │           ├── life_value_gauge.dart      # 生活值环形仪表盘
│   │           ├── category_breakdown.dart    # 消费分类占比条形图
│   │           └── monthly_summary.dart       # 月度总结文案卡片
│   │
│   ├── book/                         # 📖 书本模式
│   │   └── presentation/pages/book_page.dart
│   │
│   └── profile/                      # 👤 我的
│       └── presentation/pages/profile_page.dart
│
└── main.dart                         # 应用入口（ProviderScope + MaterialApp.router）
```

## 前置要求

### 本地开发

- Flutter SDK >= 3.44，建议与 `pubspec.yaml` 中的 `environment.sdk` 保持一致。
- Dart >= 3.12。
- Android Studio 或 VS Code（推荐安装 Flutter 插件）。
- Windows：需开启[开发者模式](ms-settings:developers)以支持插件符号链接。
- macOS：需安装 Xcode Command Line Tools。
- 可选：Android Emulator、iOS Simulator、Chrome（Web 调试）。

## 快速启动

### 方式一：命令行启动

适合日常开发，支持热重载。

```bash
# 1. 安装依赖
cd TallyJie
flutter pub get

# 2. 静态分析（确保代码无错误）
flutter analyze

# 3. 运行（按优先级选择可用设备）
flutter run          # 自动选择已连接设备
flutter run -d chrome  # Web 浏览器（推荐调试用，启动最快）
flutter run -d windows # Windows 桌面
flutter run -d android # Android 设备/模拟器
flutter run -d ios     # iOS 模拟器（仅 macOS）
```

### 方式二：IDE 启动

1. 用 VS Code 或 Android Studio 打开项目根目录。
2. 等待 Flutter 插件完成依赖解析。
3. 在设备选择器中选择目标设备。
4. 按 `F5` 或点击 "Run" 启动调试。

## 常用命令

### 静态分析与格式化

```bash
flutter analyze        # 静态分析（零警告目标）
dart format lib/       # 代码格式化
```

### 测试

```bash
flutter test                    # 运行所有测试
flutter test test/widget_test.dart  # 运行单个测试文件
```

### 构建

```bash
# Web
flutter build web

# Windows
flutter build windows

# Android
flutter build apk          # debug APK
flutter build apk --release  # release APK
flutter build appbundle      # AAB（Google Play）

# iOS（仅 macOS）
flutter build ios

# macOS 桌面
flutter build macos

# Linux 桌面
flutter build linux
```

### 依赖管理

```bash
flutter pub get              # 安装依赖
flutter pub outdated         # 检查可更新的包
flutter pub upgrade --major-versions  # 升级到最新主版本
```

### 清理

```bash
flutter clean                # 清理构建缓存
flutter pub cache repair     # 修复 pub 缓存
```

## 数据库说明

项目使用 sqflite（SQLite）作为本地存储方案。数据库文件存储在应用文档目录下的 `lifeos.db`。

### 数据表

| 表名 | 说明 | 主要字段 |
| --- | --- | --- |
| `diary_entries` | 日记条目 | `id`, `date`(UNIQUE), `content`, `weather`, `mood`, `location`, `media_paths`, `tags` |
| `transactions` | 交易记录 | `id`, `amount`, `type`, `category`, `category_icon`, `note`, `timestamp`, `source` |
| `todo_items` | 待办事项 | `id`, `title`, `is_completed`, `priority`, `date`, `due_date`, `sort_order` |
| `weekly_plans` | 周计划 | `id`, `week_start`(UNIQUE), `goals` |
| `daily_plan_notes` | 每日计划备注 | `id`, `week_start`, `day_index`, `notes` |
| `plan_events` | 日程事件 | `id`, `week_start`, `day_index`, `title`, `time`, `color` |
| `mood_entries` | 心情记录 | `id`, `date`(UNIQUE), `mood`, `note` |
| `user_settings` | 用户设置 | `id`, `name`, `avatar_path` |

### 初始化与迁移

数据库在首次启动时通过 `DatabaseHelper._onCreate` 自动创建所有表和默认数据。当前版本号为 `1`。后续迁移通过 `onUpgrade` 回调处理，按版本号递增执行对应 SQL。

### 默认数据

- 默认用户（`user_settings` 表 id=1）。
- 每日默认待办项：学习、运动、阅读、记账、冥想。

### 模型转换

所有模型类均实现 `toMap()` 和 `fromMap()` 方法，直接与 sqflite 的 `db.insert` / `db.query` 对接，不引入额外 ORM 层。

## 页面路由

| 路由 | 页面 | 所属分支 | 说明 |
| --- | --- | --- | --- |
| `/diary` | 日记 | Branch 0 | 首页，默认加载 |
| `/planner` | 周计划 | Branch 1 | 七日网格视图 |
| `/checklist` | 清单 | Branch 2 | 待办管理 |
| `/ledger` | 记账 | Branch 3 | 时间轴账单 |
| `/profile` | 我的 | Branch 4 | 个人中心 |
| `/profile/statistics` | 统计 | 独立页面 | 详细统计图表 |
| `/profile/book` | 书本模式 | 独立页面 | 翻页浏览日记 |

路由使用 `StatefulShellRoute` 保证每个 Tab 的导航状态独立保存，切换时不丢失滚动位置和表单输入。

## 胶囊导航栏

底部导航采用自定义胶囊式设计：

- 5 个 Tab：日记、周计划、清单、记账、我的。
- 选中态：黑色背景（`#2B2B2B`）、白色图标 + 文字。
- 未选中态：透明背景、灰色图标。
- 切换动画：AnimatedContainer 300ms easeOutQuart，图标 + 文字同时切换。
- 每个分支通过 `StatefulShellBranch` 与路由绑定，点击调用 `navigationShell.goBranch(index)`。

## 记账 BottomSheet

新增账单采用三步流程，完全在 `showModalBottomSheet` 内完成：

| 步骤 | 内容 | 交互 |
| --- | --- | --- |
| Step 0 | 类型选择 | 支出 / 收入 切换按钮 |
| Step 1 | 金额输入 | 大号数字显示 + 自定义 4×3 键盘（含小数点、退格） |
| Step 2 | 分类 + 备注 | 3×3 分类图标网格（选中变黑）+ 备注文本框 + 保存按钮 |

- 底部操作栏：上一步 / 下一步 / 保存（按钮状态按输入有效性启用/禁用）。
- 步骤指示器：顶部 3 个圆点，已完成和当前步骤为黑色，未完成步骤为灰色。
- 保存后弹出 SnackBar 提示。

## 测试与验收

### 静态分析

```bash
flutter analyze
```

目标：**零警告、零错误**。

### Widget 测试

```bash
flutter test
```

### 手动验收清单

| 序号 | 验收项 | 预期 |
| --- | --- | --- |
| 1 | 应用启动 | 默认进入日记页，底部胶囊导航可见 |
| 2 | 导航切换 | 点击 5 个 Tab 均正常切换，动画流畅 |
| 3 | 日记页 | 日期/心情/天气显示正确，待办可勾选 |
| 4 | 记账页 | 交易时间轴展示，FAB 点击弹出 BottomSheet |
| 5 | 新增账单 | 三步流程完整走通，保存后 SnackBar 弹出 |
| 6 | 周计划 | 周导航切换正常，日期高亮本周 |
| 7 | 清单 | 可添加/勾选/删除待办，动画正常 |
| 8 | 统计 | 仪表盘/条形图/月度总结卡片正常渲染 |
| 9 | 书本模式 | 翻页动画正常，内容展示正确 |
| 10 | 我的页 | 头像/统计/快捷入口正常显示 |

## 开发约定

- 功能模块遵循 Feature-First 架构，每个 feature 内部按 `presentation/pages/` 和 `presentation/widgets/` 分层。
- 共享组件放在 `lib/core/widgets/`，页面级独立组件放在对应 feature 的 `widgets/` 目录。
- UI 文案统一收口到 `lib/app/constants.dart` 的 `AppStrings` 类，方便后续国际化。
- 主题 Token 不允许在页面中硬编码色值/字号/圆角，必须引用 `AppColors`、`AppTypography`、`AppRadius` 等常量。
- 数据模型统一实现 `toMap()` / `fromMap()` / `copyWith()` 方法。
- 提交粒度：每完成一个独立功能模块或修复后即提交，遵循 `feat:` / `fix:` / `docs:` / `chore:` 前缀。
- 不要提交 `.env`、构建产物、IDE 个人配置文件。

## 路线图

- [x] 项目骨架 + 完整设计系统（配色/字体/圆角/阴影/动效）
- [x] 胶囊导航 + StatefulShellRoute 路由
- [x] 日记页（日期/心情/天气/待办/编辑器/消费摘要）
- [x] 记账页（时间轴 + 3 步 BottomSheet + 自定义键盘）
- [x] 周计划页（七日网格 + 周导航）
- [x] 清单页（CRUD + 滑动操作 + 优先级）
- [x] 统计页（生活值仪表盘 + 分类占比 + 月度总结）
- [x] 书本翻页模式
- [x] 个人中心页
- [ ] Riverpod 状态管理层（数据库连接 + Notifier 重构）
- [ ] 数据库操作接入（替换当前内存模拟数据）
- [ ] 通知监听自动记账（Android NotificationListenerService）
- [ ] 数据导出（JSON / CSV）
- [ ] 深色模式
- [ ] 云端同步（iCloud / WebDAV）
- [ ] 国际化（英文版本）

## License

MIT License © 2026 BlockChain
