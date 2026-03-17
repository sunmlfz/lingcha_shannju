import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/processing_task.dart';
import '../../models/tea_type.dart';
import '../../providers/processing_provider.dart';
import '../../providers/player_provider.dart';

class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key});

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        ref.read(processingProvider.notifier).tickAll();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(processingProvider);
    final player = ref.watch(playerProvider);
    final activeTasks = tasks.where(
      (t) => t.state == ProcessingState.processing || t.state == ProcessingState.done,
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EE),
      appBar: AppBar(
        title: const Text('茶叶炒制', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4E342E),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                const Text('🍃 ', style: TextStyle(fontSize: 16)),
                Text(
                  '${player.teaLeaves}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStartSection(context, player.teaLeaves),
          const Divider(height: 1),
          Expanded(
            child: activeTasks.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: activeTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) =>
                        _buildTaskCard(ctx, activeTasks[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🫖', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            '暂无炒制任务',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            '收获茶青后，在此炒制成干茶',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStartSection(BuildContext context, int availableLeaves) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.brown.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '开始炒制',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            '可用茶青：$availableLeaves 份 | 最多同时进行 3 个任务',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TeaVariety.values.map((v) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _StartTeaChip(
                    variety: v,
                    onStart: (qty) => _startProcessing(context, v, qty),
                    maxLeaves: availableLeaves,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, ProcessingTask task) {
    final isDone = task.isDone;
    final progress = task.progress;
    final rem = task.remainingTime;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF0FFF0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? Colors.green.shade400 : Colors.brown.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                task.variety.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${task.variety.displayName} × ${task.inputLeaves}份',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '预计品质：${task.resultQuality.displayName}  '
                      '产出：${task.resultQuantity}份',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(task.resultQuality.hexColor),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDone)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => _collectTask(context, task),
                  child: const Text('收取', style: TextStyle(fontSize: 13)),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isDone
                          ? '完成!'
                          : rem.inMinutes > 0
                              ? '${rem.inMinutes}分${rem.inSeconds.remainder(60)}秒'
                              : '${rem.inSeconds}秒',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDone
                            ? Colors.green.shade600
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (!isDone) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.brown.shade400,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _startProcessing(
    BuildContext context,
    TeaVariety variety,
    int qty,
  ) async {
    final task = await ref
        .read(processingProvider.notifier)
        .startProcessing(variety, qty);
    if (task == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('茶青不足或炒制槽已满（最多3个）'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '开始炒制 ${variety.displayName} $qty 份！',
          ),
          backgroundColor: Colors.brown.shade600,
        ),
      );
    }
  }

  Future<void> _collectTask(BuildContext context, ProcessingTask task) async {
    final success =
        await ref.read(processingProvider.notifier).collectTask(task.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '收取了 ${task.resultQuantity} 份 ${task.resultQuality.displayName} '
            '${task.variety.displayName}！',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }
}

class _StartTeaChip extends StatefulWidget {
  final TeaVariety variety;
  final void Function(int qty) onStart;
  final int maxLeaves;

  const _StartTeaChip({
    required this.variety,
    required this.onStart,
    required this.maxLeaves,
  });

  @override
  State<_StartTeaChip> createState() => _StartTeaChipState();
}

class _StartTeaChipState extends State<_StartTeaChip> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQtyDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.brown.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.brown.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.variety.emoji),
            const SizedBox(width: 4),
            Text(
              widget.variety.displayName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showQtyDialog(BuildContext context) {
    final max = widget.maxLeaves.clamp(1, 50);
    double qty = (widget.variety.baseYield.toDouble()).clamp(1, max.toDouble());

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setS) => AlertDialog(
          title: Text(
            '炒制 ${widget.variety.emoji} ${widget.variety.displayName}',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '投入茶青：${qty.round()} 份',
                style: const TextStyle(fontSize: 14),
              ),
              Slider(
                value: qty,
                min: 1,
                max: max.toDouble(),
                divisions: max > 1 ? max - 1 : 1,
                label: qty.round().toString(),
                onChanged: (v) => setS(() => qty = v),
                activeColor: Colors.brown.shade600,
              ),
              Text(
                '炒制时长：${_formatSecs(widget.variety.processingSeconds)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: widget.maxLeaves < 1
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      widget.onStart(qty.round());
                    },
              child: const Text('开始'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSecs(int s) {
    if (s >= 60) {
      final m = s ~/ 60;
      final r = s % 60;
      return r > 0 ? '$m分$r秒' : '$m分钟';
    }
    return '$s秒';
  }
}
