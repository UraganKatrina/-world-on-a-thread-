import 'package:flutter_test/flutter_test.dart';
import 'package:world_on_a_thread/game/levels/level_catalog.dart';

void main() {
  final catalog = LevelCatalog.standard();

  test('every level is well-formed', () {
    for (final level in catalog.levels) {
      expect(level.validate(), isEmpty, reason: level.id);
      for (final n in level.nodes) {
        expect(n.position.dx, inInclusiveRange(0, 1));
        expect(n.position.dy, inInclusiveRange(0, 1));
      }
    }
  });

  test('first level is «Пробуждение» with three ordered pairs', () {
    expect(catalog.first.id, 'awakening');
    expect(catalog.first.title, 'Пробуждение');
    expect(catalog.first.winCondition.required.length, 3);
    expect(catalog.first.visuals.islands.length, 3);
  });

  test('level transitions follow catalog order', () {
    expect(catalog.nextAfter('awakening')?.id, 'constellation');
    expect(catalog.nextAfter('constellation'), isNull);
    expect(catalog.nextAfter('missing'), isNull);
  });
}
