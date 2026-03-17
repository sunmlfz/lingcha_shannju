import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/tea_plot.dart';
import 'tea_plot_component.dart';

class GardenScene extends PositionComponent {
  final List<TeaPlot> plots;
  final void Function(int plotId) onPlotTap;
  final List<TeaPlotComponent> _plotComponents = [];

  GardenScene({
    required this.plots,
    required this.onPlotTap,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildPlots();
  }

  void _buildPlots() {
    for (final c in _plotComponents) {
      c.removeFromParent();
    }
    _plotComponents.clear();

    const cols = 3;
    const rows = 2;
    const plotSize = 90.0;
    const gap = 12.0;

    final totalW = cols * plotSize + (cols - 1) * gap;
    final totalH = rows * plotSize + (rows - 1) * gap;
    final startX = (size.x - totalW) / 2;
    final startY = (size.y - totalH) / 2;

    for (int i = 0; i < plots.length && i < cols * rows; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final x = startX + col * (plotSize + gap);
      final y = startY + row * (plotSize + gap);

      final comp = TeaPlotComponent(
        plot: plots[i],
        onTap: onPlotTap,
        position: Vector2(x, y),
      );
      _plotComponents.add(comp);
      add(comp);
    }
  }

  void updatePlots(List<TeaPlot> newPlots) {
    // Update plot data in existing components
    for (int i = 0; i < _plotComponents.length && i < newPlots.length; i++) {
      // Re-read from the same object reference (plots are mutated in place)
    }
    // Trigger re-render by marking dirty - components read from plot directly
  }

  @override
  void render(Canvas canvas) {
    // Draw ground
    final groundPaint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..style = PaintingStyle.fill;
    final groundRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(
      RRect.fromRectAndRadius(groundRect, const Radius.circular(16)),
      groundPaint,
    );

    // Garden title
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: '茶园',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF5D4037),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    titlePainter.paint(canvas, const Offset(12, 8));
  }
}
