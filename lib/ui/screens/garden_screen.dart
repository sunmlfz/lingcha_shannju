import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tea_plot.dart';
import '../../models/tea_type.dart';
import '../../providers/garden_provider.dart';
import '../../providers/player_provider.dart';
import '../widgets/plot_card.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Refresh UI every second for countdowns
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
      ref.read(gardenProvider.notifier).tickAll();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plots = ref.watch(gardenProvider);
    final player = ref.watch(playerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EE),
      appBar: AppBar(
        title: const Text('茶园', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Text('🍃', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${player.teaLeaves}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                const Text('💰', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 4),
                Text(
                  '${player.teaCoins}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(player.teaLeaves),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: plots.length,
                itemBuilder: (context, index) {
                  return PlotCard(
                    plot: plots[index],
                    onTap: () => _handlePlotTap(context, plots[index], index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(int leaves) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Row(
        children: [
          const Text('🍃', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '茶青库存：$leaves 份',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Text(
                '点击空地种植，点击成熟的茶叶收获',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlotTap(
    BuildContext context,
    TeaPlot plot,
    int index,
  ) async {
    if (plot.state == PlotState.empty) {
      await _showPlantDialog(context, index);
    } else if (plot.state == PlotState.ready || plot.isReady) {
      final amount = await ref.read(gardenProvider.notifier).harvestPlot(index);
      if (amount > 0 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '收获了 $amount 份 ${plot.variety?.displayName ?? "茶叶"}！',
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Growing — show info
      if (context.mounted) {
        final rem = plot.remainingTime;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${plot.variety?.displayName ?? "茶叶"}生长中，还需 ${_formatDuration(rem)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _showPlantDialog(BuildContext context, int plotIndex) async {
    TeaVariety? selected;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择种植茶叶'),
        content: StatefulBuilder(
          builder: (ctx2, setS) => Column(
            mainAxisSize: MainAxisSize.min,
            children: TeaVariety.values.map((variety) {
              return RadioListTile<TeaVariety>(
                value: variety,
                groupValue: selected,
                onChanged: (v) => setS(() => selected = v),
                title: Text(
                  '${variety.emoji} ${variety.displayName}',
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '生长：${_formatSeconds(variety.growthSeconds)}  产量：${variety.baseYield}',
                  style: const TextStyle(fontSize: 11),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: selected == null
                ? null
                : () async {
                    Navigator.pop(ctx);
                    final success = await ref
                        .read(gardenProvider.notifier)
                        .plantTea(plotIndex, selected!);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '种下了 ${selected!.displayName}，'
                            '${_formatSeconds(selected!.growthSeconds)}后收获！',
                          ),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    }
                  },
            child: const Text('种植'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes > 0) {
      return '${d.inMinutes}分${d.inSeconds.remainder(60)}秒';
    }
    return '${d.inSeconds}秒';
  }

  String _formatSeconds(int s) {
    if (s >= 60) {
      final m = s ~/ 60;
      final sec = s % 60;
      return sec > 0 ? '$m分$sec秒' : '$m分钟';
    }
    return '$s秒';
  }
}
