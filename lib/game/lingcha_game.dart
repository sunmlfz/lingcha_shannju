import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tea_plot.dart';
import '../providers/garden_provider.dart';
import '../providers/processing_provider.dart';
import 'components/garden_scene.dart';

class LingchaGame extends FlameGame {
  final WidgetRef ref;

  GardenScene? _gardenScene;
  late TimerComponent _tickTimer;

  LingchaGame({required this.ref});

  @override
  Color backgroundColor() => const Color(0xFF4E342E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Background decorative text
    final titleText = TextComponent(
      text: '灵茶山居',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFFFD54F),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
        ),
      ),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, 12),
    );
    add(titleText);

    // Garden scene
    final plots = ref.read(gardenProvider);
    _gardenScene = GardenScene(
      plots: plots,
      onPlotTap: _handlePlotTap,
      position: Vector2(8, 50),
      size: Vector2(size.x - 16, size.y - 60),
    );
    add(_gardenScene!);

    // Periodic tick: update growing states every second
    _tickTimer = TimerComponent(
      period: 1,
      repeat: true,
      onTick: _onTick,
    );
    add(_tickTimer);
  }

  void _onTick() {
    ref.read(gardenProvider.notifier).tickAll();
    ref.read(processingProvider.notifier).tickAll();
  }

  void _handlePlotTap(int plotId) {
    // Notify UI layer via a callback / event bus
    // The actual logic is in the garden screen overlay
    _plotTapCallbacks.forEach((cb) => cb(plotId));
  }

  final List<void Function(int)> _plotTapCallbacks = [];

  void addPlotTapListener(void Function(int) cb) {
    _plotTapCallbacks.add(cb);
  }

  void removePlotTapListener(void Function(int) cb) {
    _plotTapCallbacks.remove(cb);
  }

  void refreshPlots(List<TeaPlot> plots) {
    _gardenScene?.updatePlots(plots);
  }
}
