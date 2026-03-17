import 'package:hive_flutter/hive_flutter.dart';
import '../models/tea_type.dart';
import '../models/tea_plot.dart';
import '../models/player.dart';
import '../models/processing_task.dart';

class SaveService {
  static const String _playerBoxName = 'player';
  static const String _plotBoxName = 'plots';
  static const String _processingBoxName = 'processing';
  static const String _metaBoxName = 'meta';

  static SaveService? _instance;
  static SaveService get instance => _instance ??= SaveService._();
  SaveService._();

  late Box<Player> _playerBox;
  late Box<TeaPlot> _plotBox;
  late Box<ProcessingTask> _processingBox;
  late Box<dynamic> _metaBox;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TeaQualityAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TeaVarietyAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PlotStateAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(TeaPlotAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SixSensesAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(TeaInventoryItemAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(PlayerAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(ProcessingStateAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(ProcessingTaskAdapter());
    }

    _playerBox = await Hive.openBox<Player>(_playerBoxName);
    _plotBox = await Hive.openBox<TeaPlot>(_plotBoxName);
    _processingBox = await Hive.openBox<ProcessingTask>(_processingBoxName);
    _metaBox = await Hive.openBox<dynamic>(_metaBoxName);

    _initialized = true;
  }

  // ---- Player ----

  Player loadPlayer() {
    final player = _playerBox.get('main');
    if (player != null) return player;
    final newPlayer = Player();
    _playerBox.put('main', newPlayer);
    return newPlayer;
  }

  Future<void> savePlayer(Player player) async {
    player.lastSaveMs = DateTime.now().millisecondsSinceEpoch;
    await _playerBox.put('main', player);
  }

  // ---- Plots ----

  List<TeaPlot> loadPlots() {
    if (_plotBox.isEmpty) {
      final plots = List.generate(6, (i) => TeaPlot(id: i));
      for (final plot in plots) {
        _plotBox.put(plot.id.toString(), plot);
      }
      return plots;
    }
    return _plotBox.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  }

  Future<void> savePlots(List<TeaPlot> plots) async {
    for (final plot in plots) {
      await _plotBox.put(plot.id.toString(), plot);
    }
  }

  Future<void> savePlot(TeaPlot plot) async {
    await _plotBox.put(plot.id.toString(), plot);
  }

  // ---- Processing tasks ----

  List<ProcessingTask> loadProcessingTasks() {
    return _processingBox.values.toList();
  }

  Future<void> saveProcessingTask(ProcessingTask task) async {
    await _processingBox.put(task.id, task);
  }

  Future<void> removeProcessingTask(String taskId) async {
    await _processingBox.delete(taskId);
  }

  // ---- Offline timestamp ----

  void saveLastOnlineTime() {
    _metaBox.put('lastOnlineMs', DateTime.now().millisecondsSinceEpoch);
  }

  int? loadLastOnlineTime() {
    return _metaBox.get('lastOnlineMs') as int?;
  }

  // ---- Full reset ----

  Future<void> resetAll() async {
    await _playerBox.clear();
    await _plotBox.clear();
    await _processingBox.clear();
    await _metaBox.clear();
  }
}
