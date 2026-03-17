import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../models/tea_plot.dart';
import '../../models/tea_type.dart';

class TeaPlotComponent extends PositionComponent with TapCallbacks {
  final TeaPlot plot;
  final void Function(int plotId) onTap;

  static const double _size = 90.0;
  static const double _padding = 8.0;

  TeaPlotComponent({
    required this.plot,
    required this.onTap,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(_size, _size),
          anchor: Anchor.topLeft,
        );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, _size, _size);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Background
    final bgPaint = Paint()
      ..color = _getBackgroundColor()
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = _getBorderColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rrect, borderPaint);

    // Progress bar (if growing)
    if (plot.state == PlotState.growing) {
      final progress = plot.growthProgress;
      final barRect = Rect.fromLTWH(
        _padding,
        _size - 14,
        (_size - _padding * 2) * progress,
        8,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(4)),
        Paint()
          ..color = Colors.green.shade400
          ..style = PaintingStyle.fill,
      );
      // Bar bg
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(_padding, _size - 14, _size - _padding * 2, 8),
          const Radius.circular(4),
        ),
        Paint()
          ..color = Colors.black26
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Emoji
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getEmoji(),
        style: const TextStyle(fontSize: 32),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (_size - textPainter.width) / 2,
        (_size - textPainter.height) / 2 - 8,
      ),
    );

    // State label
    final labelPainter = TextPainter(
      text: TextSpan(
        text: _getLabel(),
        style: TextStyle(
          fontSize: 10,
          color: _getLabelColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset((_size - labelPainter.width) / 2, 6),
    );
  }

  Color _getBackgroundColor() {
    switch (plot.state) {
      case PlotState.empty:
        return const Color(0xFFF5F0E8);
      case PlotState.growing:
        return const Color(0xFFE8F5E9);
      case PlotState.ready:
        return const Color(0xFFFFF9C4);
    }
  }

  Color _getBorderColor() {
    switch (plot.state) {
      case PlotState.empty:
        return const Color(0xFFBCAAA4);
      case PlotState.growing:
        return const Color(0xFF66BB6A);
      case PlotState.ready:
        return const Color(0xFFFFCA28);
    }
  }

  String _getEmoji() {
    if (plot.state == PlotState.empty) return '🌱';
    if (plot.state == PlotState.ready || plot.isReady) {
      return plot.variety?.emoji ?? '🍵';
    }
    // growing
    final progress = plot.growthProgress;
    if (progress < 0.33) return '🌱';
    if (progress < 0.66) return '🌿';
    return plot.variety?.emoji ?? '🌿';
  }

  String _getLabel() {
    if (plot.state == PlotState.empty) return '空地';
    if (plot.state == PlotState.ready || plot.isReady) return '可收获!';
    final rem = plot.remainingTime;
    if (rem.inMinutes > 0) return '${rem.inMinutes}分${rem.inSeconds.remainder(60)}秒';
    return '${rem.inSeconds}秒';
  }

  Color _getLabelColor() {
    switch (plot.state) {
      case PlotState.empty:
        return Colors.brown.shade400;
      case PlotState.growing:
        return Colors.green.shade700;
      case PlotState.ready:
        return Colors.orange.shade700;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(plot.id);
  }
}

/// Simple particle effect for harvest
class HarvestParticle extends PositionComponent {
  final Vector2 velocity;
  double _alpha = 1.0;
  final String emoji;

  HarvestParticle({
    required Vector2 position,
    required this.velocity,
    this.emoji = '🍵',
  }) : super(position: position, size: Vector2(24, 24));

  @override
  void update(double dt) {
    position += velocity * dt;
    velocity.y += 80 * dt; // gravity
    _alpha -= dt * 1.5;
    if (_alpha <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(0, 0);
    final paint = Paint()..color = Colors.white.withOpacity(_alpha.clamp(0, 1));
    final textPainter = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 20)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}
