import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/tea_type.dart';
import '../services/save_service.dart';

class PlayerNotifier extends Notifier<Player> {
  @override
  Player build() {
    return SaveService.instance.loadPlayer();
  }

  void refresh() {
    state = SaveService.instance.loadPlayer();
  }

  Future<void> addTeaLeaves(int amount) async {
    state.addTeaLeaves(amount);
    await _save();
  }

  Future<void> addCoins(int amount) async {
    state.addCoins(amount);
    await _save();
  }

  Future<bool> spendCoins(int amount) async {
    if (state.spendCoins(amount)) {
      await _save();
      return true;
    }
    return false;
  }

  Future<bool> consumeTeaLeaves(int amount) async {
    if (state.consumeTeaLeaves(amount)) {
      await _save();
      return true;
    }
    return false;
  }

  Future<void> addInventory(
    TeaVariety variety,
    TeaQuality quality,
    int amount,
  ) async {
    state.addInventory(variety, quality, amount);
    await _save();
  }

  Future<bool> consumeInventory(
    TeaVariety variety,
    TeaQuality quality,
    int amount,
  ) async {
    if (state.consumeInventory(variety, quality, amount)) {
      await _save();
      return true;
    }
    return false;
  }

  /// Returns gain map
  Future<Map<String, double>> drinkTea(
    TeaVariety variety,
    TeaQuality quality,
  ) async {
    // Check inventory
    final item = state.inventory.firstWhere(
      (i) => i.variety == variety && i.quality == quality,
      orElse: () => TeaInventoryItem(
        variety: variety,
        quality: quality,
        quantity: 0,
      ),
    );
    if (item.quantity <= 0) return {};

    item.quantity--;
    final gainMap = state.drinkTea(variety, quality);
    await _save();
    // Force UI update by reassigning
    state = state;
    return gainMap;
  }

  Future<void> _save() async {
    await SaveService.instance.savePlayer(state);
    // Trigger rebuild
    ref.notifyListeners();
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, Player>(
  PlayerNotifier.new,
);
