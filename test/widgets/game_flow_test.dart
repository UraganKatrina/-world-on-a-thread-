import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_on_a_thread/app/app_services.dart';
import 'package:world_on_a_thread/app/world_app.dart';
import 'package:world_on_a_thread/audio/audio_service.dart';
import 'package:world_on_a_thread/game/levels/level_catalog.dart';
import 'package:world_on_a_thread/game/logic/feedback_messages.dart';
import 'package:world_on_a_thread/game/logic/puzzle_session.dart';
import 'package:world_on_a_thread/game/models/level_definition.dart';
import 'package:world_on_a_thread/game/rendering/board_geometry.dart';
import 'package:world_on_a_thread/game/widgets/puzzle_board.dart';
import 'package:world_on_a_thread/persistence/key_value_store.dart';
import 'package:world_on_a_thread/persistence/progress_repository.dart';
import 'package:world_on_a_thread/settings/game_settings.dart';

AppServices _services(MemoryStore store, SilentAudioService audio) {
  final catalog = LevelCatalog.standard();
  final settings = GameSettings(store)..reduceMotion = true;
  return AppServices(
    catalog: catalog,
    progress: ProgressRepository(store, catalog),
    settings: settings,
    audio: audio,
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tapNode(WidgetTester tester, String id) async {
  final board = find.byType(PuzzleBoard);
  final state = tester.widget<PuzzleBoard>(board);
  final LevelDefinition level = state.session.level;
  final geometry = BoardGeometry(tester.getSize(board), padding: state.padding);
  final local = geometry.nodeCenter(
    level,
    level.nodeById(id),
    Duration.zero,
    still: true,
  );
  await tester.tapAt(tester.getTopLeft(board) + local);
  await tester.pump(const Duration(milliseconds: 50));
}

PuzzleSession _session(WidgetTester tester) =>
    tester.widget<PuzzleBoard>(find.byType(PuzzleBoard)).session;

void main() {
  for (final size in const [Size(360, 640), Size(800, 400), Size(1024, 1366)]) {
    testWidgets(
      'level 1 can be completed by tapping nodes at ${size.width}x${size.height}',
      (tester) async {
        tester.view.physicalSize = size * 2;
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);

        final store = MemoryStore();
        final audio = SilentAudioService();
        final services = _services(store, audio);
        await tester.pumpWidget(WorldApp(services: services));
        await tester.pump();

        await tester.tap(find.text('Играть'));
        await _settle(tester);
        expect(find.text('Пробуждение'), findsOneWidget);

        // A wrong pair gets a soft explanation, no thread.
        await _tapNode(tester, 'west_circle');
        await _tapNode(tester, 'east_diamond');
        expect(
          find.text(rejectionMessage(RejectReason.notAllowed)),
          findsOneWidget,
        );
        expect(_session(tester).connections, isEmpty);

        // The right sequence.
        await _tapNode(tester, 'west_circle');
        await _tapNode(tester, 'south_circle');
        await _tapNode(tester, 'south_triangle');
        await _tapNode(tester, 'east_triangle');
        expect(_session(tester).progressCount, 2);

        // Restart in the middle of the puzzle.
        await tester.tap(find.byTooltip('Начать заново'));
        await tester.pump();
        expect(_session(tester).connections, isEmpty);

        await _tapNode(tester, 'west_circle');
        await _tapNode(tester, 'south_circle');
        await _tapNode(tester, 'south_triangle');
        await _tapNode(tester, 'east_triangle');
        await _tapNode(tester, 'west_diamond');
        await _tapNode(tester, 'east_diamond');
        expect(_session(tester).isSolved, isTrue);
        expect(audio.played.last, SoundEffect.solved);

        await _settle(tester);
        expect(find.text('Проход открыт'), findsOneWidget);
        expect(services.progress.progress.isCompleted('awakening'), isTrue);
        expect(services.progress.isUnlocked('constellation'), isTrue);

        await tester.tap(find.text('Дальше'));
        await _settle(tester);
        expect(find.text('Созвездие'), findsOneWidget);
        expect(services.progress.progress.lastOpenedLevelId, 'constellation');
      },
    );
  }

  testWidgets('pause blocks input and lets the player toggle music', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final services = _services(MemoryStore(), SilentAudioService());
    await tester.pumpWidget(WorldApp(services: services));
    await tester.pump();
    await tester.tap(find.text('Играть'));
    await _settle(tester);

    await tester.tap(find.byTooltip('Пауза'));
    await tester.pump();
    expect(find.text('Пауза'), findsWidgets);
    await tester.tap(find.text('Музыка'));
    await tester.pump();
    expect(services.settings.musicEnabled, isFalse);
    expect(services.settings.effectsEnabled, isTrue);

    await tester.tap(find.text('Продолжить'));
    await tester.pump();
    await _tapNode(tester, 'west_circle');
    expect(_session(tester).selectedNodeId, 'west_circle');
  });

  testWidgets(
    'second level is locked in level select until the first is done',
    (tester) async {
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final services = _services(MemoryStore(), SilentAudioService());
      await tester.pumpWidget(WorldApp(services: services));
      await tester.pump();
      await tester.tap(find.text('Уровни'));
      await _settle(tester);
      expect(
        find.bySemanticsLabel('Уровень 2, Созвездие, закрыт'),
        findsOneWidget,
      );
      await tester.tap(find.bySemanticsLabel('Уровень 2, Созвездие, закрыт'));
      await _settle(tester);
      expect(find.byType(PuzzleBoard), findsNothing);
    },
  );
}
