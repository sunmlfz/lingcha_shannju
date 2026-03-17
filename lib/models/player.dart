import 'package:hive/hive.dart';
import 'tea_type.dart';

part 'player.g.dart';

/// 六识属性
@HiveType(typeId: 4)
class SixSenses extends HiveObject {
  /// 眼识 - 提高鉴茶能力（品质识别+）
  @HiveField(0)
  double eye;

  /// 耳识 - 加快炒制速度
  @HiveField(1)
  double ear;

  /// 鼻识 - 提升茶叶香气值
  @HiveField(2)
  double nose;

  /// 舌识 - 增加品茗收益
  @HiveField(3)
  double tongue;

  /// 身识 - 加速种植生长
  @HiveField(4)
  double body;

  /// 意识 - 解锁稀有配方
  @HiveField(5)
  double mind;

  SixSenses({
    this.eye = 1.0,
    this.ear = 1.0,
    this.nose = 1.0,
    this.tongue = 1.0,
    this.body = 1.0,
    this.mind = 1.0,
  });

  SixSenses copyWith({
    double? eye,
    double? ear,
    double? nose,
    double? tongue,
    double? body,
    double? mind,
  }) {
    return SixSenses(
      eye: eye ?? this.eye,
      ear: ear ?? this.ear,
      nose: nose ?? this.nose,
      tongue: tongue ?? this.tongue,
      body: body ?? this.body,
      mind: mind ?? this.mind,
    );
  }

  /// 生长速度倍率（body 影响）
  double get growthSpeedMultiplier => 1.0 + (body - 1.0) * 0.3;

  /// 炒制速度倍率（ear 影响）
  double get processingSpeedMultiplier => 1.0 + (ear - 1.0) * 0.2;

  /// 产量倍率（body + nose 影响）
  double get yieldMultiplier => 1.0 + (body - 1.0) * 0.15 + (nose - 1.0) * 0.1;

  /// 品茗收益倍率（tongue 影响）
  double get drinkingBonusMultiplier => 1.0 + (tongue - 1.0) * 0.25;

  Map<String, double> toMap() => {
    '眼识': eye,
    '耳识': ear,
    '鼻识': nose,
    '舌识': tongue,
    '身识': body,
    '意识': mind,
  };
}

@HiveType(typeId: 5)
class TeaInventoryItem extends HiveObject {
  @HiveField(0)
  TeaVariety variety;

  @HiveField(1)
  TeaQuality quality;

  @HiveField(2)
  int quantity;

  TeaInventoryItem({
    required this.variety,
    required this.quality,
    required this.quantity,
  });
}

@HiveType(typeId: 6)
class Player extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int teaLeaves; // 茶青（原料）

  @HiveField(2)
  int teaCoins; // 茶钱（货币）

  @HiveField(3)
  SixSenses senses;

  @HiveField(4)
  List<TeaInventoryItem> inventory;

  @HiveField(5)
  int level;

  @HiveField(6)
  int experience;

  @HiveField(7)
  int lastSaveMs; // 最后保存时间戳

  Player({
    this.name = '茶人',
    this.teaLeaves = 0,
    this.teaCoins = 100,
    SixSenses? senses,
    List<TeaInventoryItem>? inventory,
    this.level = 1,
    this.experience = 0,
    int? lastSaveMs,
  })  : senses = senses ?? SixSenses(),
        inventory = inventory ?? [],
        lastSaveMs = lastSaveMs ?? DateTime.now().millisecondsSinceEpoch;

  int get experienceForNextLevel => level * 100;

  bool get canLevelUp => experience >= experienceForNextLevel;

  void levelUp() {
    if (canLevelUp) {
      experience -= experienceForNextLevel;
      level++;
    }
  }

  void addTeaLeaves(int amount) {
    teaLeaves += amount;
  }

  bool consumeTeaLeaves(int amount) {
    if (teaLeaves >= amount) {
      teaLeaves -= amount;
      return true;
    }
    return false;
  }

  void addCoins(int amount) {
    teaCoins += amount;
  }

  bool spendCoins(int amount) {
    if (teaCoins >= amount) {
      teaCoins -= amount;
      return true;
    }
    return false;
  }

  void addInventory(TeaVariety variety, TeaQuality quality, int amount) {
    final existing = inventory.firstWhere(
      (item) => item.variety == variety && item.quality == quality,
      orElse: () {
        final newItem = TeaInventoryItem(
          variety: variety,
          quality: quality,
          quantity: 0,
        );
        inventory.add(newItem);
        return newItem;
      },
    );
    existing.quantity += amount;
  }

  bool consumeInventory(TeaVariety variety, TeaQuality quality, int amount) {
    final item = inventory.firstWhere(
      (i) => i.variety == variety && i.quality == quality,
      orElse: () => TeaInventoryItem(
        variety: variety,
        quality: quality,
        quantity: 0,
      ),
    );
    if (item.quantity >= amount) {
      item.quantity -= amount;
      return true;
    }
    return false;
  }

  /// Drink tea: gain exp and sense growth
  Map<String, double> drinkTea(TeaVariety variety, TeaQuality quality) {
    final gainMap = <String, double>{};
    final qMul = quality.valueMultiplier;
    final bonus = senses.drinkingBonusMultiplier;

    // Different teas boost different senses
    switch (variety) {
      case TeaVariety.lvcha:
        senses.eye += 0.1 * qMul * bonus;
        gainMap['眼识'] = 0.1 * qMul * bonus;
        break;
      case TeaVariety.hongcha:
        senses.ear += 0.1 * qMul * bonus;
        gainMap['耳识'] = 0.1 * qMul * bonus;
        break;
      case TeaVariety.wulong:
        senses.nose += 0.1 * qMul * bonus;
        gainMap['鼻识'] = 0.1 * qMul * bonus;
        break;
      case TeaVariety.baihao:
        senses.tongue += 0.1 * qMul * bonus;
        gainMap['舌识'] = 0.1 * qMul * bonus;
        break;
      case TeaVariety.puer:
        senses.body += 0.1 * qMul * bonus;
        gainMap['身识'] = 0.1 * qMul * bonus;
        break;
      case TeaVariety.huangcha:
        senses.mind += 0.1 * qMul * bonus;
        gainMap['意识'] = 0.1 * qMul * bonus;
        break;
    }

    final expGain = (10 * qMul * bonus).round();
    experience += expGain;
    gainMap['经验'] = expGain.toDouble();

    while (canLevelUp) {
      levelUp();
    }

    return gainMap;
  }
}
