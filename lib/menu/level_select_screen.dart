import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../app/palette.dart';
import '../game/levels/generated/chapters.dart';
import '../game/models/level_definition.dart';
import '../navigation/app_routes.dart';
import 'sky_background.dart';

/// All levels grouped by chapter, as a grid of numbered islands.
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final GlobalKey _currentKey = GlobalKey();
  bool _scrolled = false;

  void _scrollToCurrent() {
    if (_scrolled) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _currentKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx, alignment: 0.3);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final catalog = services.catalog;
    final byChapter = <int, List<(int, LevelDefinition)>>{};
    for (final (i, level) in catalog.levels.indexed) {
      byChapter.putIfAbsent(level.chapter, () => []).add((i, level));
    }
    _scrollToCurrent();
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListenableBuilder(
                listenable: services.progress,
                builder: (context, _) {
                  final progress = services.progress;
                  final current = progress.resumeLevel.id;
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: 'Назад',
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  semanticLabel: 'Назад',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Острова',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Text(
                                '${progress.progress.completedLevelIds.length} '
                                'из ${catalog.levels.length}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (final entry in byChapter.entries) ...[
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                          sliver: SliverToBoxAdapter(
                            child: _ChapterHeader(
                              title: chapters[entry.key].title,
                              done: entry.value
                                  .where(
                                    (e) =>
                                        progress.progress.isCompleted(e.$2.id),
                                  )
                                  .length,
                              total: entry.value.length,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid.count(
                            crossAxisCount: 5,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              for (final (i, level) in entry.value)
                                _LevelTile(
                                  key: level.id == current ? _currentKey : null,
                                  number: i + 1,
                                  title: level.title,
                                  unlocked: progress.isUnlocked(level.id),
                                  completed: progress.progress.isCompleted(
                                    level.id,
                                  ),
                                  current: level.id == current,
                                  onTap: () =>
                                      AppRoutes.openLevel(context, level),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  const _ChapterHeader({
    required this.title,
    required this.done,
    required this.total,
  });

  final String title;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        Text(
          '$done / $total',
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: Palette.mist),
        ),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    super.key,
    required this.number,
    required this.title,
    required this.unlocked,
    required this.completed,
    required this.current,
    required this.onTap,
  });

  final int number;
  final String title;
  final bool unlocked;
  final bool completed;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = completed ? 'пройден' : (unlocked ? 'открыт' : 'закрыт');
    final Color fill;
    final Color text;
    if (completed) {
      fill = Palette.gold;
      text = Palette.night;
    } else if (unlocked) {
      fill = Palette.indigo;
      text = Palette.pearl;
    } else {
      fill = Palette.panel;
      text = Palette.mist;
    }
    return Semantics(
      button: unlocked,
      label: 'Уровень $number, $title, $state',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: unlocked ? onTap : null,
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill.withValues(alpha: unlocked ? 1 : 0.6),
              border: Border.all(
                color: current ? Palette.softGold : const Color(0x44D9CFF2),
                width: current ? 2.5 : 1,
              ),
              boxShadow: current
                  ? const [BoxShadow(color: Color(0x88F2C46D), blurRadius: 14)]
                  : null,
            ),
            child: Center(
              child: unlocked
                  ? Text(
                      '$number',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: text, fontWeight: FontWeight.w600),
                    )
                  : Icon(Icons.lock_outline_rounded, size: 18, color: text),
            ),
          ),
        ),
      ),
    );
  }
}
