import 'package:flutter_test/flutter_test.dart';
import 'package:world_on_a_thread/game/levels/awakening_level.dart';
import 'package:world_on_a_thread/game/levels/constellation_level.dart';
import 'package:world_on_a_thread/game/logic/puzzle_session.dart';
import 'package:world_on_a_thread/game/models/connection.dart';

void main() {
  group('Connection', () {
    test('is undirected', () {
      expect(Connection('a', 'b'), Connection('b', 'a'));
      expect(Connection('a', 'b').hashCode, Connection('b', 'a').hashCode);
    });
  });

  group('Awakening (sequential level)', () {
    late PuzzleSession s;
    setUp(() => s = PuzzleSession(awakeningLevel));

    test('allowed connection in the right order is accepted', () {
      final r = s.tryConnect('west_circle', 'south_circle');
      expect(r, isA<ThreadConnected>());
      expect(s.connections, [Connection('west_circle', 'south_circle')]);
      expect(s.progressCount, 1);
      expect(s.isSolved, isFalse);
    });

    test('forbidden connection is rejected gently and changes nothing', () {
      final r = s.tryConnect('west_circle', 'east_diamond');
      expect(
        r,
        isA<ThreadRejected>().having(
          (x) => x.reason,
          'reason',
          RejectReason.notAllowed,
        ),
      );
      expect(s.connections, isEmpty);
      expect(s.rejectionCount, 1);
    });

    test('right pair in wrong order is rejected as wrongOrder', () {
      final r = s.tryConnect('west_diamond', 'east_diamond');
      expect(
        r,
        isA<ThreadRejected>().having(
          (x) => x.reason,
          'reason',
          RejectReason.wrongOrder,
        ),
      );
      expect(s.connections, isEmpty);
    });

    test('duplicates are prevented in either direction', () {
      s.tryConnect('west_circle', 'south_circle');
      final again = s.tryConnect('south_circle', 'west_circle');
      expect(
        again,
        isA<ThreadRejected>().having(
          (x) => x.reason,
          'reason',
          RejectReason.duplicate,
        ),
      );
      expect(s.connections.length, 1);
    });

    test(
      'win condition is checked programmatically after the full sequence',
      () {
        expect(
          s.tryConnect('west_circle', 'south_circle'),
          isA<ThreadConnected>().having((x) => x.solvedNow, 'solved', false),
        );
        expect(
          s.tryConnect('east_triangle', 'south_triangle'),
          isA<ThreadConnected>().having((x) => x.solvedNow, 'solved', false),
        );
        expect(
          s.tryConnect('east_diamond', 'west_diamond'),
          isA<ThreadConnected>().having((x) => x.solvedNow, 'solved', true),
        );
        expect(s.isSolved, isTrue);
        expect(s.progress, 1);
        expect(
          awakeningLevel.winCondition.isSatisfied(
            s.connections,
            awakeningLevel,
          ),
          isTrue,
        );
      },
    );

    test('after solving, further input is ignored', () {
      s.tryConnect('west_circle', 'south_circle');
      s.tryConnect('east_triangle', 'south_triangle');
      s.tryConnect('east_diamond', 'west_diamond');
      expect(s.tapNode('west_circle'), isA<TapIgnored>());
      expect(s.selectedNodeId, isNull);
    });

    test('reset clears threads, selection, rejections and solved flag', () {
      s.tryConnect('west_circle', 'south_circle');
      s.tryConnect('west_circle', 'east_diamond');
      s.tapNode('east_triangle');
      s.reset();
      expect(s.connections, isEmpty);
      expect(s.selectedNodeId, isNull);
      expect(s.rejectionCount, 0);
      expect(s.isSolved, isFalse);
      // And the level is playable again from scratch.
      expect(
        s.tryConnect('west_circle', 'south_circle'),
        isA<ThreadConnected>(),
      );
    });
  });

  group('Taps', () {
    late PuzzleSession s;
    setUp(() => s = PuzzleSession(awakeningLevel));

    test('tap, tap connects; tapping the same node twice deselects', () {
      expect(s.tapNode('west_circle'), isA<NodeSelected>());
      expect(s.tapNode('west_circle'), isA<SelectionCleared>());
      expect(s.selectedNodeId, isNull);
      expect(s.tapNode('west_circle'), isA<NodeSelected>());
      expect(s.tapNode('south_circle'), isA<ThreadConnected>());
      expect(s.selectedNodeId, isNull);
    });

    test('unknown node ids are ignored', () {
      expect(s.tapNode('nope'), isA<TapIgnored>());
      expect(s.tryConnect('west_circle', 'nope'), isA<TapIgnored>());
    });

    test('rapid repeated tapping never creates duplicates or crashes', () {
      for (var i = 0; i < 200; i++) {
        s.tapNode(i.isEven ? 'west_circle' : 'south_circle');
      }
      expect(s.connections, [Connection('west_circle', 'south_circle')]);
      expect(s.isSolved, isFalse);
    });
  });

  group('Constellation (unordered level)', () {
    test('pairs may be connected in any order', () {
      final s = PuzzleSession(constellationLevel);
      for (final c in constellationLevel.winCondition.required.reversed) {
        expect(s.tryConnect(c.second, c.first), isA<ThreadConnected>());
      }
      expect(s.isSolved, isTrue);
    });
  });
}
