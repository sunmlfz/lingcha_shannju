import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/processing_task.dart';
import '../models/tea_type.dart';
import '../services/save_service.dart';
import 'player_provider.dart';

class ProcessingNotifier extends Notifier<List<ProcessingTask>> {
  @override
  List<ProcessingTask> build() {
    return SaveService.instance.loadProcessingTasks();
  }

  /// Start a new processing task. Returns null if not enough leaves.
  Future<ProcessingTask?> startProcessing(
    TeaVariety variety,
    int inputLeaves,
  ) async {
    final player = ref.read(playerProvider);
    if (player.teaLeaves < inputLeaves) return null;

    // Check max concurrent tasks (3 slots)
    final active = state
        .where((t) => t.state == ProcessingState.processing)
        .length;
    if (active >= 3) return null;

    // Consume leaves
    final consumed = await ref
        .read(playerProvider.notifier)
        .consumeTeaLeaves(inputLeaves);
    if (!consumed) return null;

    final task = ProcessingTask.create(
      variety: variety,
      inputLeaves: inputLeaves,
      processingSpeedMultiplier: player.senses.processingSpeedMultiplier,
      eyeSense: player.senses.eye,
      noseSense: player.senses.nose,
      mindSense: player.senses.mind,
    );

    await SaveService.instance.saveProcessingTask(task);
    state = [...state, task];
    return task;
  }

  /// Collect a finished task. Returns true if collected.
  Future<bool> collectTask(String taskId) async {
    final idx = state.indexWhere((t) => t.id == taskId);
    if (idx < 0) return false;

    final task = state[idx];
    if (!task.isDone) return false;

    // Mark done
    task.state = ProcessingState.done;

    // Add to inventory
    await ref
        .read(playerProvider.notifier)
        .addInventory(task.variety, task.resultQuality, task.resultQuantity);

    // Remove from list
    await SaveService.instance.removeProcessingTask(taskId);
    final newList = List<ProcessingTask>.from(state);
    newList.removeAt(idx);
    state = newList;
    return true;
  }

  /// Tick all tasks, auto-collect done ones
  Future<void> tickAll() async {
    bool changed = false;
    for (final task in state) {
      if (task.state == ProcessingState.processing && task.isDone) {
        task.state = ProcessingState.done;
        changed = true;
      }
    }
    if (changed) {
      state = List.from(state);
    }
  }

  /// Apply offline completed tasks
  Future<void> applyOfflineCompleted(List<ProcessingTask> completed) async {
    for (final task in completed) {
      final idx = state.indexWhere((t) => t.id == task.id);
      if (idx >= 0) {
        state[idx].state = ProcessingState.done;
        // Inventory already added by OfflineService
        await SaveService.instance.saveProcessingTask(state[idx]);
      }
    }
    state = List.from(state);
  }

  void refresh() {
    state = List.from(state);
  }
}

final processingProvider =
    NotifierProvider<ProcessingNotifier, List<ProcessingTask>>(
  ProcessingNotifier.new,
);
