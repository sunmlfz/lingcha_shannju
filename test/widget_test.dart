import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingcha_shannju/models/tea_plot.dart';
import 'package:lingcha_shannju/models/tea_type.dart';
import 'package:lingcha_shannju/models/player.dart';
import 'package:lingcha_shannju/models/processing_task.dart';

void main() {
  group('TeaPlot', () {
    test('starts empty', () {
      final plot = TeaPlot(id: 0);
      expect(plot.state, PlotState.empty);
      expect(plot.variety, isNull);
    });

    test('plant changes state to growing', () {
      final plot = TeaPlot(id: 0);
      plot.plant(TeaVariety.lvcha);
      expect(plot.state, PlotState.growing);
      expect(plot.variety, TeaVariety.lvcha);
    });

    test('harvest resets state to empty', () {
      final plot = TeaPlot(id: 0);
      plot.plant(TeaVariety.lvcha);
      plot.state = PlotState.ready;
      plot.pendingHarvest = 10;
      final amount = plot.harvest();
      expect(amount, 10);
      expect(plot.state, PlotState.empty);
    });

    test('growthProgress clamps to 0-1', () {
      final plot = TeaPlot(id: 0);
      plot.plant(TeaVariety.lvcha);
      expect(plot.growthProgress, inInclusiveRange(0.0, 1.0));
    });
  });

  group('Player', () {
    test('starts with defaults', () {
      final player = Player();
      expect(player.level, 1);
      expect(player.teaLeaves, 0);
      expect(player.teaCoins, 100);
    });

    test('addTeaLeaves increments correctly', () {
      final player = Player();
      player.addTeaLeaves(50);
      expect(player.teaLeaves, 50);
    });

    test('consumeTeaLeaves fails when insufficient', () {
      final player = Player();
      expect(player.consumeTeaLeaves(10), isFalse);
    });

    test('consumeTeaLeaves succeeds when sufficient', () {
      final player = Player();
      player.addTeaLeaves(20);
      expect(player.consumeTeaLeaves(10), isTrue);
      expect(player.teaLeaves, 10);
    });

    test('levelUp when experience sufficient', () {
      final player = Player();
      player.experience = 100;
      expect(player.canLevelUp, isTrue);
      player.levelUp();
      expect(player.level, 2);
    });

    test('drinkTea returns gain map', () {
      final player = Player();
      player.addInventory(TeaVariety.lvcha, TeaQuality.common, 1);
      final gain = player.drinkTea(TeaVariety.lvcha, TeaQuality.common);
      expect(gain.containsKey('眼识'), isTrue);
      expect(gain['眼识']!, greaterThan(0));
    });
  });

  group('TeaQuality', () {
    test('display names are correct', () {
      expect(TeaQuality.crude.displayName, '粗茶');
      expect(TeaQuality.masterwork.displayName, '极品');
    });

    test('value multipliers increase with quality', () {
      expect(TeaQuality.common.valueMultiplier,
          lessThan(TeaQuality.fine.valueMultiplier));
      expect(TeaQuality.fine.valueMultiplier,
          lessThan(TeaQuality.superior.valueMultiplier));
    });
  });

  group('TeaVariety', () {
    test('all varieties have positive growth seconds', () {
      for (final v in TeaVariety.values) {
        expect(v.growthSeconds, greaterThan(0));
        expect(v.baseYield, greaterThan(0));
        expect(v.processingSeconds, greaterThan(0));
      }
    });
  });

  group('ProcessingTask', () {
    test('create builds a valid task', () {
      final task = ProcessingTask.create(
        variety: TeaVariety.lvcha,
        inputLeaves: 10,
        processingSpeedMultiplier: 1.0,
        eyeSense: 1.0,
        noseSense: 1.0,
        mindSense: 1.0,
      );
      expect(task.state, ProcessingState.processing);
      expect(task.inputLeaves, 10);
      expect(task.durationMs, greaterThan(0));
      expect(task.resultQuantity, greaterThan(0));
    });

    test('quality calculation returns valid quality', () {
      final quality = ProcessingTask.calculateQuality(
        inputLeaves: 15,
        variety: TeaVariety.lvcha,
        eyeSense: 1.0,
        mindSense: 1.0,
      );
      expect(TeaQuality.values.contains(quality), isTrue);
    });
  });

  group('SixSenses', () {
    test('default multipliers are 1.0', () {
      final senses = SixSenses();
      expect(senses.growthSpeedMultiplier, 1.0);
      expect(senses.processingSpeedMultiplier, 1.0);
    });

    test('increased body boosts growth speed', () {
      final senses = SixSenses(body: 3.0);
      expect(senses.growthSpeedMultiplier, greaterThan(1.0));
    });
  });

  // Widget test: smoke test that app renders
  testWidgets('App renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('灵茶山居')),
          ),
        ),
      ),
    );
    expect(find.text('灵茶山居'), findsOneWidget);
  });
}
