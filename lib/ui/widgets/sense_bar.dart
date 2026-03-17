import 'package:flutter/material.dart';

class SenseBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const SenseBar({
    super.key,
    required this.label,
    required this.value,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.toStringAsFixed(1);
    // Cap visual at 10 for display
    final progress = ((value - 1.0) / 9.0).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class SensesPanel extends StatelessWidget {
  final Map<String, double> senses;

  const SensesPanel({super.key, required this.senses});

  static const List<Color> _colors = [
    Color(0xFF1E88E5), // 眼识 - blue
    Color(0xFF43A047), // 耳识 - green
    Color(0xFFE53935), // 鼻识 - red
    Color(0xFF8E24AA), // 舌识 - purple
    Color(0xFFF4511E), // 身识 - orange
    Color(0xFF00897B), // 意识 - teal
  ];

  @override
  Widget build(BuildContext context) {
    final entries = senses.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < entries.length; i++)
          SenseBar(
            label: entries[i].key,
            value: entries[i].value,
            color: _colors[i % _colors.length],
          ),
      ],
    );
  }
}

/// Floating gain indicator — shown after drinking
class GainIndicator extends StatefulWidget {
  final Map<String, double> gains;
  final VoidCallback onDismiss;

  const GainIndicator({
    super.key,
    required this.gains,
    required this.onDismiss,
  });

  @override
  State<GainIndicator> createState() => _GainIndicatorState();
}

class _GainIndicatorState extends State<GainIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0)),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.gains.entries
                .where((e) => e.key != '经验' && e.value > 0)
                .map(
                  (e) => Text(
                    '${e.key} +${e.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
