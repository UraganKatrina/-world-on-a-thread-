import 'package:flutter_test/flutter_test.dart';
import 'package:world_on_a_thread/game/levels/first_light_level.dart';
import 'package:world_on_a_thread/game/levels/level_catalog.dart';
import 'package:world_on_a_thread/game/levels/lighthouse_level.dart';
import 'package:world_on_a_thread/game/levels/no_tangles_level.dart';
import 'package:world_on_a_thread/game/logic/puzzle_session.dart';
import 'package:world_on_a_thread/game/logic/puzzle_solver.dart';
import 'package:world_on_a_thread/game/logic/thread_geometry.dart';

Matcher rejectedFor(RejectReason reason) =>
    isA<ThreadRejected>().having((r) => r.reason, 'reason', reason);

void main() {
  group('Light («Первый свет»)', () {
    test('threads only grow from a glowing point', () {
      final s = PuzzleSession(firstLightLevel);
      expect(
        s.tryConnect('south_west', 'south_east'),
        rejectedFor(RejectReason.dark),
      );
      expect(s.tryConnect('star', 'west'), isA<ThreadConnected>());
      expect(s.litNodeIds, containsAll(['star', 'west']));
      expect(s.tryConnect('west', 'south_west'), isA<ThreadConnected>());
      expect(s.progressCount, 2);
    });

    test('light flows along a chain and wins when every lamp glows', () {
      final s = PuzzleSession(firstLightLevel);
      s.tryConnect('star', 'west');
      s.tryConnect('west', 'south_west');
      s.tryConnect('south_west', 'south_east');
      final last = s.tryConnect('south_east', 'east');
      expect(
        last,
        isA<ThreadConnected>().having((r) => r.solvedNow, 'solved', true),
      );
    });

    test('untying cuts the light off downstream', () {
      final s = PuzzleSession(firstLightLevel);
      s.tryConnect('star', 'west');
      s.tryConnect('west', 'south_west');
      expect(s.tryConnect('west', 'star'), isA<ThreadUntied>());
      expect(s.litNodeIds, {'star'});
      expect(s.connections.length, 1);
      expect(s.progressCount, 0);
    });
  });

  group('No crossing, one thread per point («Без узелков»)', () {
    test('a point holds only one thread', () {
      final s = PuzzleSession(noTanglesLevel);
      expect(s.tryConnect('n2', 'e2'), isA<ThreadConnected>());
      expect(s.tryConnect('n2', 's1'), rejectedFor(RejectReason.nodeBusy));
    });

    test('crossing threads are rejected', () {
      final s = PuzzleSession(noTanglesLevel);
      expect(s.tryConnect('s2', 'w2'), isA<ThreadConnected>());
      expect(s.tryConnect('e2', 's1'), rejectedFor(RejectReason.crossing));
      // The intended pairing never crosses.
      expect(s.tryConnect('n1', 'e1'), isA<ThreadConnected>());
      expect(s.tryConnect('n2', 'e2'), isA<ThreadConnected>());
      final last = s.tryConnect('s1', 'w1');
      expect(
        last,
        isA<ThreadConnected>().having((r) => r.solvedNow, 'solved', true),
      );
    });

    test('untie frees both points again', () {
      final s = PuzzleSession(noTanglesLevel);
      s.tryConnect('n2', 'e2');
      expect(s.tapNode('e2'), isA<NodeSelected>());
      expect(s.tapNode('n2'), isA<ThreadUntied>());
      expect(s.connections, isEmpty);
      expect(s.tryConnect('n2', 's1'), isA<ThreadConnected>());
    });

    test('levels without untie still reject duplicates', () {
      final s = PuzzleSession(LevelCatalog.standard().first);
      s.tryConnect('west_circle', 'south_circle');
      expect(
        s.tryConnect('south_circle', 'west_circle'),
        rejectedFor(RejectReason.duplicate),
      );
    });
  });

  group('Geometry', () {
    test('segments that share an end point never cross', () {
      const a = Offset(0, 0),
          b = Offset(1, 1),
          c = Offset(0, 1),
          d = Offset(1, 0);
      expect(segmentsCross(a, b, c, d), isTrue);
      expect(segmentsCross(a, b, a, d), isFalse);
      expect(segmentsCross(a, c, b, d), isFalse); // parallel sides
    });
  });

  group('Every level can be finished', () {
    for (final level in LevelCatalog.standard().levels) {
      test(level.title, () {
        final report = solveLevel(level);
        expect(report.solvable, isTrue, reason: level.id);
        // Replaying the solver's answer through a fresh session wins.
        final s = PuzzleSession(level);
        for (final c in report.shortest!) {
          s.tryConnect(c.first, c.second);
        }
        expect(s.isSolved, isTrue);
      });
    }

    test('«Без узелков» has exactly one way to pair the points', () {
      expect(solveLevel(noTanglesLevel).solutionCount, 1);
    });

    test('«Маяк» has dead ends: a wrong long thread blocks the south', () {
      final s = PuzzleSession(lighthouseLevel);
      s.tryConnect('beacon', 'west_near');
      s.tryConnect('west_near', 'south_east');
      s.tryConnect('beacon', 'east_near');
      expect(
        s.tryConnect('east_near', 'south_west'),
        rejectedFor(RejectReason.crossing),
      );
    });
  });
}
