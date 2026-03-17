import '../models/tea_plot.dart';
import '../models/processing_task.dart';
import '../models/player.dart';
import 'save_service.dart';

class OfflineResult {
  final int harvestedLeaves;
  final List<ProcessingTask> completedTasks;
  final Duration offlineDuration;

  const OfflineResult({
    required this.harvestedLeaves,
    required this.completedTasks,
    required this.offlineDuration,
  });

  bool get hasAnyGain => harvestedLeaves > 0 || completedTasks.isNotEmpty;
}

class OfflineService {
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();
  OfflineService._();

  /// Called on game start. Calculates offline gains and applies them.
  OfflineResult calculateOfflineGains({
    required Player player,
    required List<TeaPlot> plots,
    required List<ProcessingTask> processingTasks,
  }) {
    final lastOnlineMs = SaveService.instance.loadLastOnlineTime();
    if (lastOnlineMs == null) {
      // First launch, no offline gains
      SaveService.instance.saveLastOnlineTime();
      return OfflineResult(
        harvestedLeaves: 0,
        completedTasks: [],
        offlineDuration: Duration.zero,
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final offlineMs = now - lastOnlineMs;
    final offlineDuration = Duration(milliseconds: offlineMs);

    // Cap offline time at 8 hours to prevent massive overflow
    final effectiveOfflineMs = offlineMs.clamp(0, 8 * 3600 * 1000);

    int harvestedLeaves = 0;

    // Check plots: any that would have completed offline
    for (final plot in plots) {
      if (plot.state == PlotState.growing &&
          plot.plantedAtMs != null &&
          plot.growthDurationMs != null) {
        final plantedAt = plot.plantedAtMs!;
        final endTime = plantedAt + plot.growthDurationMs!;

        if (now >= endTime) {
          // Completed while offline
          plot.state = PlotState.ready;
          plot.pendingHarvest = (plot.variety!.baseYield *
              player.senses.yieldMultiplier)
              .round();
          // Auto-harvest for offline mode
          harvestedLeaves += plot.harvest();
        }
      }
    }

    // Add offline-gained leaves to player
    if (harvestedLeaves > 0) {
      player.addTeaLeaves(harvestedLeaves);
    }

    // Check processing tasks
    final completed = <ProcessingTask>[];
    for (final task in processingTasks) {
      if (task.state == ProcessingState.processing && task.isDone) {
        task.state = ProcessingState.done;
        completed.add(task);
        // Add finished tea to player inventory
        player.addInventory(task.variety, task.resultQuality, task.resultQuantity);
      }
    }

    // Update last online time
    SaveService.instance.saveLastOnlineTime();

    return OfflineResult(
      harvestedLeaves: harvestedLeaves,
      completedTasks: completed,
      offlineDuration: Duration(milliseconds: effectiveOfflineMs),
    );
  }

  String formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}小时${d.inMinutes.remainder(60)}分钟';
    } else if (d.inMinutes > 0) {
      return '${d.inMinutes}分钟${d.inSeconds.remainder(60)}秒';
    } else {
      return '${d.inSeconds}秒';
    }
  }
}
