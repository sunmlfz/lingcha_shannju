import 'package:flutter/material.dart';
import '../../models/tea_plot.dart';
import '../../models/tea_type.dart';

class PlotCard extends StatelessWidget {
  final TeaPlot plot;
  final VoidCallback onTap;

  const PlotCard({super.key, required this.plot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 4),
            Text(
              _title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _textColor,
              ),
            ),
            if (plot.state == PlotState.growing) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: plot.growthProgress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade500,
                    ),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _remainingLabel,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
              ),
            ],
            if (plot.state == PlotState.ready)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '收获!',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color get _bgColor {
    switch (plot.state) {
      case PlotState.empty:
        return const Color(0xFFF5F0E8);
      case PlotState.growing:
        return const Color(0xFFE8F5E9);
      case PlotState.ready:
        return const Color(0xFFFFFDE7);
    }
  }

  Color get _borderColor {
    switch (plot.state) {
      case PlotState.empty:
        return const Color(0xFFBCAAA4);
      case PlotState.growing:
        return Colors.green.shade400;
      case PlotState.ready:
        return Colors.orange.shade400;
    }
  }

  Color get _textColor {
    switch (plot.state) {
      case PlotState.empty:
        return Colors.brown.shade400;
      case PlotState.growing:
        return Colors.green.shade700;
      case PlotState.ready:
        return Colors.orange.shade700;
    }
  }

  String get _emoji {
    if (plot.state == PlotState.empty) return '🌱';
    if (plot.state == PlotState.ready) return plot.variety?.emoji ?? '🍵';
    final p = plot.growthProgress;
    if (p < 0.4) return '🌱';
    if (p < 0.8) return '🌿';
    return plot.variety?.emoji ?? '🌿';
  }

  String get _title {
    switch (plot.state) {
      case PlotState.empty:
        return '空地 #${plot.id + 1}';
      case PlotState.growing:
        return plot.variety?.displayName ?? '生长中';
      case PlotState.ready:
        return '${plot.variety?.displayName ?? "茶叶"} 熟了';
    }
  }

  String get _remainingLabel {
    final rem = plot.remainingTime;
    if (rem == Duration.zero) return '即将完成';
    if (rem.inMinutes > 0) {
      return '${rem.inMinutes}分${rem.inSeconds.remainder(60)}秒';
    }
    return '${rem.inSeconds}秒';
  }
}
