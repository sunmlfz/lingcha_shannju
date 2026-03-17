import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tea_plot.dart';
import '../models/tea_type.dart';
import '../services/save_service.dart';
import 'player_provider.dart';

class GardenNotifier extends Notifier<List<TeaPlot>> {
  @override
  List<TeaPlot> build() {
    return SaveService.instance.loadPlots();
  }

  void refresh() {
    state = List.from(state); // trigger rebuild
  }

  Future<bool> plantTea(int plotIndex, TeaVariety variety) async {
    if (plotIndex < 0 || plotIndex >= state.length) return false;
    final plot = state[plotIndex];
    if (plot.state != PlotState.empty) return false;

    final player = ref.read(playerProvider);
    final growthSpeed = player.senses.growthSpeedMultiplier;

    plot.plant(variety, growthSpeedMultiplier: growthSpeed);
    await SaveService.instance.savePlot(plot);
    state = List.from(state);
    return true;
  }

  Future<int> harvestPlot(int plotIndex) async {
    if (plotIndex < 0 || plotIndex >= state.length) return 0;
    final plot = state[plotIndex];

    // Check if ready (could be offline completed)
    plot.tick(yieldMultiplier: ref.read(playerProvider).senses.yieldMultiplier);

    if (plot.state != PlotState.ready && !plot.isReady) return 0;

    final amount = plot.harvest();
    if (amount > 0) {
      await ref.read(playerProvider.notifier).addTeaLeaves(amount);
    }
    await SaveService.instance.savePlot(plot);
    state = List.from(state);
    return amount;
  }

  /// Tick all plots — call periodically to update growing states
  Future<void> tickAll() async {
    bool changed = false;
    final yieldMul = ref.read(playerProvider).senses.yieldMultiplier;
    for (final plot in state) {
      if (plot.state == PlotState.growing) {
        plot.tick(yieldMultiplier: yieldMul);
        if (plot.state == PlotState.ready) {
          changed = true;
          await SaveService.instance.savePlot(plot);
        }
      }
    }
    if (changed) {
      state = List.from(state);
    }
  }

  /// Apply offline harvest results (called on startup)
  Future<void> applyOfflineHarvest(int totalLeaves) async {
    if (totalLeaves > 0) {
      await ref.read(playerProvider.notifier).addTeaLeaves(totalLeaves);
    }
    await SaveService.instance.savePlots(state);
    state = List.from(state);
  }
}

final gardenProvider = NotifierProvider<GardenNotifier, List<TeaPlot>>(
  GardenNotifier.new,
);
