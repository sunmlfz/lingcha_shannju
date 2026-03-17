import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/tea_type.dart';
import '../../providers/player_provider.dart';
import '../widgets/sense_bar.dart';

class CultivationScreen extends ConsumerStatefulWidget {
  const CultivationScreen({super.key});

  @override
  ConsumerState<CultivationScreen> createState() => _CultivationScreenState();
}

class _CultivationScreenState extends ConsumerState<CultivationScreen> {
  Map<String, double>? _lastGain;
  bool _showGain = false;

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final senses = player.senses;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EE),
      appBar: AppBar(
        title: const Text('饮茶修行', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlayerCard(player.name, player.level, player.experience,
                player.experienceForNextLevel),
            const SizedBox(height: 16),
            _buildSensesCard(senses.toMap()),
            const SizedBox(height: 16),
            _buildInventorySection(context),
            if (_showGain && _lastGain != null) ...[
              const SizedBox(height: 16),
              _buildGainCard(_lastGain!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(String name, int level, int exp, int nextLevelExp) {
    final progress = nextLevelExp > 0 ? exp / nextLevelExp : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade700, Colors.brown.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🧘', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Lv.$level 茶人',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.amber),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '经验：$exp / $nextLevelExp',
                  style:
                      const TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensesCard(Map<String, double> sensesMap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          const Row(
            children: [
              Text('✨', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                '六识修为',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '品茶可提升对应六识属性',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const Divider(height: 16),
          SensesPanel(senses: sensesMap),
          const SizedBox(height: 8),
          _buildSenseEffectsTable(),
        ],
      ),
    );
  }

  Widget _buildSenseEffectsTable() {
    final effects = [
      ('眼识', '提高鉴茶品质识别'),
      ('耳识', '加快炒制速度'),
      ('鼻识', '提升茶叶香气/产量'),
      ('舌识', '增加品茗属性收益'),
      ('身识', '加速种植生长+产量'),
      ('意识', '解锁稀有配方'),
    ];
    return Column(
      children: effects.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  e.$1,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                e.$2,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInventorySection(BuildContext context) {
    final player = ref.watch(playerProvider);
    final inventory =
        player.inventory.where((i) => i.quantity > 0).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          const Row(
            children: [
              Text('🍵', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                '茶叶收藏',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '点击饮用获得六识成长',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const Divider(height: 16),
          if (inventory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '还没有干茶，去炒制吧～',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.2,
              children: inventory.map((item) {
                return GestureDetector(
                  onTap: () => _drinkTea(context, item.variety, item.quality),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(item.quality.hexColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(item.quality.hexColor).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          item.variety.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                item.variety.displayName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${item.quality.displayName} ×${item.quantity}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(
                                      item.quality.hexColor),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildGainCard(Map<String, double> gain) {
    final entries =
        gain.entries.where((e) => e.key != '经验' && e.value > 0).toList();
    final expGain = gain['经验'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '☕ 品茗所得',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...entries.map(
            (e) => Text(
              '${e.key} +${e.value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (expGain > 0)
            Text(
              '经验 +${expGain.round()}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _drinkTea(
    BuildContext context,
    TeaVariety variety,
    TeaQuality quality,
  ) async {
    final gain =
        await ref.read(playerProvider.notifier).drinkTea(variety, quality);
    if (gain.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('没有茶叶了'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _lastGain = gain;
      _showGain = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showGain = false);
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('品了一杯 ${variety.displayName}，心旷神怡！'),
          backgroundColor: Colors.teal.shade600,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
