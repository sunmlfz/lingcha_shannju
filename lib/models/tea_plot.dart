import 'package:hive/hive.dart';
import 'tea_type.dart';

part 'tea_plot.g.dart';

@HiveType(typeId: 2)
enum PlotState {
  @HiveField(0)
  empty, // 空地
  @HiveField(1)
  growing, // 生长中
  @HiveField(2)
  ready, // 可收获
}

extension PlotStateExt on PlotState {
  String get displayName {
    switch (this) {
      case PlotState.empty:
        return '空地';
      case PlotState.growing:
        return '生长中';
      case PlotState.ready:
        return '可收获';
    }
  }
}

@HiveType(typeId: 3)
class TeaPlot extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  PlotState state;

  @HiveField(2)
  TeaVariety? variety;

  @HiveField(3)
  int? plantedAtMs; // milliseconds since epoch

  @HiveField(4)
  int? growthDurationMs; // milliseconds to grow

  @HiveField(5)
  int pendingHarvest; // accumulated but not-yet-collected leaves

  TeaPlot({
    required this.id,
    this.state = PlotState.empty,
    this.variety,
    this.plantedAtMs,
    this.growthDurationMs,
    this.pendingHarvest = 0,
  });

  bool get isReady {
    if (state == PlotState.growing &&
        plantedAtMs != null &&
        growthDurationMs != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return now >= plantedAtMs! + growthDurationMs!;
    }
    return state == PlotState.ready;
  }

  /// Returns 0.0 - 1.0 growth progress
  double get growthProgress {
    if (state == PlotState.empty) return 0.0;
    if (state == PlotState.ready || isReady) return 1.0;
    if (plantedAtMs == null || growthDurationMs == null) return 0.0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - plantedAtMs!;
    return (elapsed / growthDurationMs!).clamp(0.0, 1.0);
  }

  Duration get remainingTime {
    if (plantedAtMs == null || growthDurationMs == null) {
      return Duration.zero;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final endTime = plantedAtMs! + growthDurationMs!;
    final remainingMs = endTime - now;
    if (remainingMs <= 0) return Duration.zero;
    return Duration(milliseconds: remainingMs);
  }

  void plant(TeaVariety selectedVariety, {double growthSpeedMultiplier = 1.0}) {
    variety = selectedVariety;
    state = PlotState.growing;
    plantedAtMs = DateTime.now().millisecondsSinceEpoch;
    growthDurationMs =
        (selectedVariety.growthSeconds * 1000 / growthSpeedMultiplier).round();
    pendingHarvest = 0;
  }

  /// Tick: check if growth complete, update state. Returns yield if harvested.
  int tick({double yieldMultiplier = 1.0}) {
    if (state == PlotState.growing && isReady) {
      state = PlotState.ready;
      pendingHarvest = (variety!.baseYield * yieldMultiplier).round();
    }
    return 0;
  }

  int harvest() {
    if (state != PlotState.ready && !isReady) return 0;
    final amount = pendingHarvest > 0
        ? pendingHarvest
        : (variety?.baseYield ?? 0);
    variety = null;
    state = PlotState.empty;
    plantedAtMs = null;
    growthDurationMs = null;
    pendingHarvest = 0;
    return amount;
  }
}
