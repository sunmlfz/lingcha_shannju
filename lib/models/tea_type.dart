// ignore_for_file: constant_identifier_names

import 'package:hive/hive.dart';

part 'tea_type.g.dart';

@HiveType(typeId: 0)
enum TeaQuality {
  @HiveField(0)
  crude, // 粗茶
  @HiveField(1)
  common, // 普通
  @HiveField(2)
  fine, // 精品
  @HiveField(3)
  superior, // 上品
  @HiveField(4)
  masterwork, // 极品
}

extension TeaQualityExt on TeaQuality {
  String get displayName {
    switch (this) {
      case TeaQuality.crude:
        return '粗茶';
      case TeaQuality.common:
        return '普通';
      case TeaQuality.fine:
        return '精品';
      case TeaQuality.superior:
        return '上品';
      case TeaQuality.masterwork:
        return '极品';
    }
  }

  double get valueMultiplier {
    switch (this) {
      case TeaQuality.crude:
        return 0.5;
      case TeaQuality.common:
        return 1.0;
      case TeaQuality.fine:
        return 2.0;
      case TeaQuality.superior:
        return 4.0;
      case TeaQuality.masterwork:
        return 10.0;
    }
  }

  int get hexColor {
    switch (this) {
      case TeaQuality.crude:
        return 0xFF8D6E63;
      case TeaQuality.common:
        return 0xFF4CAF50;
      case TeaQuality.fine:
        return 0xFF2196F3;
      case TeaQuality.superior:
        return 0xFF9C27B0;
      case TeaQuality.masterwork:
        return 0xFFFF9800;
    }
  }
}

@HiveType(typeId: 1)
enum TeaVariety {
  @HiveField(0)
  lvcha, // 绿茶
  @HiveField(1)
  hongcha, // 红茶
  @HiveField(2)
  wulong, // 乌龙
  @HiveField(3)
  baihao, // 白毫
  @HiveField(4)
  puer, // 普洱
  @HiveField(5)
  huangcha, // 黄茶
}

extension TeaVarietyExt on TeaVariety {
  String get displayName {
    switch (this) {
      case TeaVariety.lvcha:
        return '绿茶';
      case TeaVariety.hongcha:
        return '红茶';
      case TeaVariety.wulong:
        return '乌龙';
      case TeaVariety.baihao:
        return '白毫';
      case TeaVariety.puer:
        return '普洱';
      case TeaVariety.huangcha:
        return '黄茶';
    }
  }

  /// 生长时间（秒）
  int get growthSeconds {
    switch (this) {
      case TeaVariety.lvcha:
        return 60; // 1分钟
      case TeaVariety.hongcha:
        return 120; // 2分钟
      case TeaVariety.wulong:
        return 180; // 3分钟
      case TeaVariety.baihao:
        return 90; // 1.5分钟
      case TeaVariety.puer:
        return 300; // 5分钟
      case TeaVariety.huangcha:
        return 150; // 2.5分钟
    }
  }

  /// 基础产量（茶青数量）
  int get baseYield {
    switch (this) {
      case TeaVariety.lvcha:
        return 10;
      case TeaVariety.hongcha:
        return 8;
      case TeaVariety.wulong:
        return 12;
      case TeaVariety.baihao:
        return 15;
      case TeaVariety.puer:
        return 6;
      case TeaVariety.huangcha:
        return 9;
    }
  }

  /// 炒制时间（秒）
  int get processingSeconds {
    switch (this) {
      case TeaVariety.lvcha:
        return 30;
      case TeaVariety.hongcha:
        return 60;
      case TeaVariety.wulong:
        return 120;
      case TeaVariety.baihao:
        return 90;
      case TeaVariety.puer:
        return 180;
      case TeaVariety.huangcha:
        return 150;
    }
  }

  String get emoji {
    switch (this) {
      case TeaVariety.lvcha:
        return '🍵';
      case TeaVariety.hongcha:
        return '🫖';
      case TeaVariety.wulong:
        return '🌿';
      case TeaVariety.baihao:
        return '🌸';
      case TeaVariety.puer:
        return '🍂';
      case TeaVariety.huangcha:
        return '🌻';
    }
  }
}
