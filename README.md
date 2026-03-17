# 灵茶山居 🍵

一款以茶文化为背景的 Flutter + Flame 养成休闲游戏。

## 游戏简介

在古朴的茶山中，你是一位修行的茶人。种植、炒制、品茗，在茶香中磨练心性，开启"六识"之门。

## P0 MVP 功能

- **种植收获**：6 块茶园地块，种植茶叶，等待生长，收获茶青
- **基础炒制**：将茶青加工成不同品质的干茶（30 秒 ~ 3 分钟）
- **饮茶六识**：品茗后提升六识属性（眼/耳/鼻/舌/身/意）
- **存档系统**：使用 Hive 本地保存游戏进度
- **离线收益**：关闭游戏后茶叶继续生长，上线后补算收益

## 技术栈

- Flutter 3.x + Dart 3.x
- Flame 1.x（游戏引擎）
- flutter_riverpod 2.x（状态管理）
- Hive 2.x（本地存档）

## 运行方法

```bash
flutter pub get
flutter run
```

## 项目结构

```
lib/
├── main.dart                  # 入口
├── game/
│   ├── lingcha_game.dart      # Flame 游戏主类
│   └── components/
│       ├── tea_plot_component.dart  # 茶园地块组件
│       └── garden_scene.dart       # 园圃场景
├── models/                    # 数据模型
│   ├── tea_type.dart          # 茶叶类型
│   ├── tea_plot.dart          # 茶园地块
│   ├── player.dart            # 玩家数据
│   └── processing_task.dart   # 炒制任务
├── providers/                 # 状态管理
│   ├── garden_provider.dart
│   ├── player_provider.dart
│   └── processing_provider.dart
├── ui/
│   ├── screens/               # 主要页面
│   └── widgets/               # 通用组件
└── services/                  # 服务层
    ├── save_service.dart
    └── offline_service.dart
```

## 六识属性

| 六识 | 效果 |
|------|------|
| 眼识 | 提高鉴茶能力（品质识别+） |
| 耳识 | 加快炒制速度 |
| 鼻识 | 提升茶叶香气值 |
| 舌识 | 增加品茗收益 |
| 身识 | 加速种植生长 |
| 意识 | 解锁稀有配方 |

---

*"茶者，南方之嘉木也。" — 陆羽《茶经》*
