<p align="center">
  <h1 align="center">LifeOS</h1>
  <p align="center">记录生活，而不是记录数字。</p>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.44-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.12-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
</p>

---

## 项目简介

LifeOS 是一个**日记 + 记账 + ToDo + 周计划 + 情绪记录**一体化的个人生活管理应用。

与传统记账软件不同，LifeOS 不追求冰冷的数字报表，而是强调**今天发生了什么、心情怎么样、完成了哪些事情**——最终形成一本有温度的**生活账本**。

### 设计理念

| 关键词 | |
|---|---|
| Minimal · Paper · Warm · Soft · Nature · Notebook · Diary | 极简 · 纸张 · 暖色 · 柔和 · 自然 · 手账 · 日记 |

---

## 功能模块

| 模块 | 说明 |
|---|---|
| 📔 **日记** | 每日记录（Markdown + 图片/视频/录音/位置/标签）、心情/天气标记、今日待办勾选 |
| 💰 **记账** | 时间轴账单（上午/下午/晚上分组）、三步快速记账（金额→分类→备注）、自定义数字键盘 |
| 📅 **周计划** | 七日网格视图、每日事件与备注、目标追踪 |
| ✅ **清单** | 多列表管理、优先级标记、滑动完成/删除 |
| 📊 **统计** | 生活值仪表盘、消费分类占比、温暖文案月度总结 |
| 📖 **书本模式** | 翻页浏览所有日记，装订线双页展开效果 |

---

## 技术栈

| 类别 | 技术 |
|---|---|
| 框架 | Flutter 3.44 |
| 语言 | Dart 3.12 |
| 状态管理 | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) |
| 路由 | [go_router](https://pub.dev/packages/go_router) (StatefulShellRoute) |
| 本地存储 | [sqflite](https://pub.dev/packages/sqflite) (SQLite) |
| 动画 | [flutter_animate](https://pub.dev/packages/flutter_animate) |
| 翻页 | [turnable_page](https://pub.dev/packages/turnable_page) |
| 图片选择 | [image_picker](https://pub.dev/packages/image_picker) |
| 国际化 | [intl](https://pub.dev/packages/intl) |

---

## 项目结构

```
lib/
├── app/                              # 应用配置
│   ├── theme/                        # 主题系统
│   │   ├── app_colors.dart           #   配色 (8色体系)
│   │   ├── app_typography.dart       #   字体规范 (7级)
│   │   ├── app_radius.dart           #   圆角规范 (4种)
│   │   ├── app_shadows.dart          #   阴影规范
│   │   ├── app_durations.dart        #   动效时长
│   │   └── app_theme.dart            #   ThemeData 工厂
│   ├── router.dart                   # go_router 路由配置
│   └── constants.dart                # 常量 + 中文文案
│
├── core/                             # 核心基础设施
│   ├── database/
│   │   └── database_helper.dart      # sqflite 数据库 (7表)
│   ├── models/                       # 数据模型
│   │   ├── diary_entry.dart          #   日记条目
│   │   ├── transaction.dart          #   交易/账单
│   │   ├── todo_item.dart            #   待办事项
│   │   ├── weekly_plan.dart          #   周计划
│   │   └── mood_entry.dart           #   心情记录
│   ├── widgets/
│   │   └── capsule_nav_bar.dart      # 胶囊导航栏
│   └── utils/
│       ├── date_helpers.dart         # 日期工具
│       └── currency_utils.dart       # 货币格式化
│
├── features/                         # 功能模块 (Feature-First)
│   ├── diary/                        # 日记
│   │   └── presentation/
│   │       ├── pages/diary_page.dart
│   │       └── widgets/
│   │           ├── diary_header.dart       # 日期 + 心情/天气
│   │           ├── today_checklist.dart    # 今日待办
│   │           ├── diary_editor.dart       # Markdown 编辑器
│   │           └── spending_summary.dart   # 消费摘要卡片
│   │
│   ├── ledger/                       # 记账
│   │   └── presentation/
│   │       ├── pages/ledger_page.dart
│   │       └── widgets/
│   │           ├── transaction_timeline.dart  # 时间轴列表
│   │           ├── transaction_tile.dart      # 交易条目
│   │           └── add_expense_sheet.dart     # 3步记账 BottomSheet
│   │
│   ├── planner/                      # 周计划
│   │   └── presentation/pages/planner_page.dart
│   │
│   ├── checklist/                    # 清单
│   │   └── presentation/pages/checklist_page.dart
│   │
│   ├── statistics/                   # 统计
│   │   └── presentation/
│   │       ├── pages/statistics_page.dart
│   │       └── widgets/
│   │           ├── life_value_gauge.dart      # 生活值仪表盘
│   │           ├── category_breakdown.dart    # 分类占比
│   │           └── monthly_summary.dart       # 月度总结
│   │
│   ├── book/                         # 书本模式
│   │   └── presentation/pages/book_page.dart
│   │
│   └── profile/                      # 我的
│       └── presentation/pages/profile_page.dart
│
└── main.dart                         # 应用入口
```

---

## 设计系统

### 配色

| Token | 色值 | 用途 |
|---|---|---|
| Primary BG | `#F7F3EE` | 页面背景（奶白色） |
| Card | `#FFFDFB` | 卡片背景 |
| Secondary BG | `#F3EEE8` | 次要背景 |
| Primary Text | `#2B2B2B` | 主文字 |
| Secondary Text | `#757575` | 辅助文字 |
| Divider | `#E8E1D8` | 分割线 |
| Accent | `#8E7C66` | 强调色 |
| Success | `#86B66E` | 完成/收入 |
| Expense | `#C96C5C` | 支出 |
| Income | `#6B9D78` | 收入 |

### 圆角

| Token | 值 | 用途 |
|---|---|---|
| `tag` | 8px | 标签 |
| `input` | 16px | 输入框 |
| `card` | 20px | 卡片 |
| `sheet` | 28px | 底部弹出 |

### 字体

| Token | 字号 | 字重 |
|---|---|---|
| `date42` | 42 | Light |
| `amount34` | 34 | Bold |
| `title32` | 32 | SemiBold |
| `h1_26` | 26 | Medium |
| `body17` | 17 | Regular |
| `caption14` | 14 | Regular |
| `navLabel` | 12 | Medium |

### 动效

- 时长：全部 **250~350ms**，禁止快速动画
- 曲线：`easeOutQuart` (Cubic 0.25, 1.0, 0.5, 1.0)
- 阴影：Blur **12px**，Opacity **5%**

---

## 快速启动

### 环境要求

- Flutter SDK >= 3.44
- Dart >= 3.12
- Android Studio / VS Code
- Windows: 需开启[开发者模式](ms-settings:developers)

### 安装依赖

```bash
cd TallyJie
flutter pub get
```

### 运行

```bash
# Web（最快启动，推荐调试用）
flutter run -d chrome

# Windows 桌面
flutter run -d windows

# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

### 静态分析

```bash
flutter analyze
```

### 构建

```bash
# Web
flutter build web

# Windows
flutter build windows

# Android
flutter build apk

# iOS
flutter build ios
```

---

## 路线图

- [x] 项目骨架 + 设计系统
- [x] 胶囊导航 + 5 个一级页面
- [x] 日记页（日期/心情/天气/待办/编辑器）
- [x] 记账页（时间轴 + 3 步 BottomSheet）
- [x] 周计划页（七日网格）
- [x] 清单页（CRUD + 滑动操作）
- [x] 统计页（生活值 + 分类 + 月度总结）
- [x] 书本翻页模式
- [x] 个人中心页
- [ ] 数据库接入（sqflite 已定义，待连线）
- [ ] 通知监听自动记账
- [ ] 数据导出
- [ ] 深色模式
- [ ] iCloud/WebDAV 同步

---

## 许可

MIT License © 2026 BlockChain
