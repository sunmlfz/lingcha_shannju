import 'package:hive/hive.dart';
import 'tea_type.dart';

part 'processing_task.g.dart';

@HiveType(typeId: 7)
enum ProcessingState {
  @HiveField(0)
  idle,
  @HiveField(1)
  processing,
  @HiveField(2)
  done,
}

@HiveType(typeId: 8)
class ProcessingTask extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  TeaVariety variety;

  @HiveField(2)
  int inputLeaves; // how many leaves going in

  @HiveField(3)
  ProcessingState state;

  @HiveField(4)
  int startedAtMs;

  @HiveField(5)
  int durationMs;

  @HiveField(6)
  TeaQuality resultQuality;

  @HiveField(7)
  int resultQuantity;

  ProcessingTask({
    required this.id,
    required this.variety,
    required this.inputLeaves,
    this.state = ProcessingState.idle,
    required this.startedAtMs,
    required this.durationMs,
    required this.resultQuality,
    required this.resultQuantity,
  });

  bool get isDone {
    if (state == ProcessingState.done) return true;
    if (state == ProcessingState.processing) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return now >= startedAtMs + durationMs;
    }
    return false;
  }

  double get progress {
    if (state == ProcessingState.idle) return 0.0;
    if (state == ProcessingState.done || isDone) return 1.0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - startedAtMs;
    return (elapsed / durationMs).clamp(0.0, 1.0);
  }

  Duration get remainingTime {
    final now = DateTime.now().millisecondsSinceEpoch;
    final endTime = startedAtMs + durationMs;
    final remainingMs = endTime - now;
    if (remainingMs <= 0) return Duration.zero;
    return Duration(milliseconds: remainingMs);
  }

  /// Calculate quality based on inputs and player senses
  static TeaQuality calculateQuality({
    required int inputLeaves,
    required TeaVariety variety,
    required double eyeSense, // 眼识影响品质识别
    required double mindSense, // 意识影响稀有概率
  }) {
    // Base quality calculation
    final qualityScore = (inputLeaves / variety.baseYield).clamp(0.5, 3.0);
    final eyeBonus = (eyeSense - 1.0) * 0.2;
    final mindBonus = (mindSense - 1.0) * 0.1;
    final total = qualityScore + eyeBonus + mindBonus;

    if (total >= 2.5) return TeaQuality.masterwork;
    if (total >= 2.0) return TeaQuality.superior;
    if (total >= 1.5) return TeaQuality.fine;
    if (total >= 1.0) return TeaQuality.common;
    return TeaQuality.crude;
  }

  static int calculateOutputQuantity({
    required int inputLeaves,
    required TeaVariety variety,
    required TeaQuality quality,
    required double noseSense, // 鼻识影响产出
  }) {
    final base = (inputLeaves * 0.4).round(); // 40% conversion rate
    final noseBonus = 1.0 + (noseSense - 1.0) * 0.1;
    final qualityBonus = quality == TeaQuality.masterwork ? 1.5 : 1.0;
    return (base * noseBonus * qualityBonus).round().clamp(1, inputLeaves);
  }

  static ProcessingTask create({
    required TeaVariety variety,
    required int inputLeaves,
    required double processingSpeedMultiplier,
    required double eyeSense,
    required double noseSense,
    required double mindSense,
  }) {
    final quality = calculateQuality(
      inputLeaves: inputLeaves,
      variety: variety,
      eyeSense: eyeSense,
      mindSense: mindSense,
    );
    final outputQty = calculateOutputQuantity(
      inputLeaves: inputLeaves,
      variety: variety,
      quality: quality,
      noseSense: noseSense,
    );
    final baseDurationMs = variety.processingSeconds * 1000;
    final durationMs =
        (baseDurationMs / processingSpeedMultiplier).round();

    return ProcessingTask(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      variety: variety,
      inputLeaves: inputLeaves,
      state: ProcessingState.processing,
      startedAtMs: DateTime.now().millisecondsSinceEpoch,
      durationMs: durationMs,
      resultQuality: quality,
      resultQuantity: outputQty,
    );
  }
}
