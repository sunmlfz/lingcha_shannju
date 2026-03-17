import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/player.dart';
import '../../providers/garden_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/processing_provider.dart';
import '../../services/offline_service.dart';
import '../../services/save_service.dart';
import 'garden_screen.dart';
import 'processing_screen.dart';
import 'cultivation_screen.dart';

class MainGameScreen extends ConsumerStatefulWidget {
  const MainGameScreen({super.key});

  @override
  ConsumerState<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends ConsumerState<MainGameScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  static const _screens = [
    GardenScreen(),
    ProcessingScreen(),
    CultivationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOfflineGains();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Save last online time when app goes to background
      SaveService.instance.saveLastOnlineTime();
      _saveAll();
    } else if (state == AppLifecycleState.resumed) {
      _checkOfflineGains();
    }
  }

  Future<void> _saveAll() async {
    final player = ref.read(playerProvider);
    final plots = ref.read(gardenProvider);
    await SaveService.instance.savePlayer(player);
    await SaveService.instance.savePlots(plots);
  }

  Future<void> _checkOfflineGains() async {
    final player = ref.read(playerProvider);
    final plots = ref.read(gardenProvider);
    final tasks = ref.read(processingProvider);

    final result = OfflineService.instance.calculateOfflineGains(
      player: player,
      plots: plots,
      processingTasks: tasks,
    );

    if (result.hasAnyGain && mounted) {
      // calculateOfflineGains() mutates player/plots in-memory but does NOT
      // persist to Hive. We must save BEFORE calling refresh(), otherwise
      // refresh() reloads stale Hive data and discards all mutations.
      await SaveService.instance.savePlayer(player);
      await SaveService.instance.savePlots(plots);

      // Now reload providers from updated Hive data
      ref.read(playerProvider.notifier).refresh();

      // applyOfflineHarvest(0): tea leaves already credited by OfflineService.
      // This call still persists plots state and triggers the garden UI rebuild.
      await ref.read(gardenProvider.notifier).applyOfflineHarvest(0);

      await ref.read(processingProvider.notifier).applyOfflineCompleted(
        result.completedTasks,
      );

      if (mounted) _showOfflineDialog(result);
    }
  }

  void _showOfflineDialog(dynamic result) {
    final dur = OfflineService.instance.formatDuration(result.offlineDuration);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('☕ 离线收益'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('离线时长：$dur'),
            const SizedBox(height: 8),
            if (result.harvestedLeaves > 0)
              Text(
                '收获了 ${result.harvestedLeaves} 份茶青',
                style: const TextStyle(color: Colors.green),
              ),
            if (result.completedTasks.isNotEmpty)
              Text(
                '完成了 ${result.completedTasks.length} 个炒制任务',
                style: const TextStyle(color: Colors.brown),
              ),
            if (!result.hasAnyGain)
              const Text('没有新的收益，茶园等待你归来～'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('好的'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF4E342E),
        indicatorColor: Colors.brown.shade300,
        destinations: [
          NavigationDestination(
            icon: const Text('🌿', style: TextStyle(fontSize: 22)),
            selectedIcon: const Text('🌿', style: TextStyle(fontSize: 24)),
            label: '茶园',
          ),
          NavigationDestination(
            icon: _buildProcessingIcon(ref),
            selectedIcon: _buildProcessingIcon(ref),
            label: '炒制',
          ),
          NavigationDestination(
            icon: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🧘', style: TextStyle(fontSize: 22)),
                Text(
                  'Lv.${player.level}',
                  style: const TextStyle(fontSize: 8, color: Colors.white70),
                ),
              ],
            ),
            selectedIcon: const Text('🧘', style: TextStyle(fontSize: 24)),
            label: '修行',
          ),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }

  Widget _buildProcessingIcon(WidgetRef ref) {
    final tasks = ref.watch(processingProvider);
    final doneCount =
        tasks.where((t) => t.isDone).length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Text('🫖', style: TextStyle(fontSize: 22)),
        if (doneCount > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$doneCount',
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
