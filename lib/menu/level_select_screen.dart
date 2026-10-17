import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../app/palette.dart';
import '../game/widgets/glass_panel.dart';
import '../navigation/app_routes.dart';
import 'sky_background.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ListenableBuilder(
                listenable: services.progress,
                builder: (context, _) => ListView(
                  padding: const EdgeInsets.all(24),
                  shrinkWrap: true,
                  children: [
                    Row(
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
                        Text(
                          'Острова',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final (i, level)
                        in services.catalog.levels.indexed) ...[
                      _LevelTile(
                        number: i + 1,
                        title: level.title,
                        subtitle: level.subtitle,
                        unlocked: services.progress.isUnlocked(level.id),
                        completed: services.progress.progress.isCompleted(
                          level.id,
                        ),
                        onTap: () => AppRoutes.openLevel(context, level),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  final int number;
  final String title;
  final String subtitle;
  final bool unlocked;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = completed ? 'пройден' : (unlocked ? 'открыт' : 'закрыт');
    return Semantics(
      button: unlocked,
      label: 'Уровень $number, $title, $state',
      excludeSemantics: true,
      child: Opacity(
        opacity: unlocked ? 1 : 0.55,
        child: GlassPanel(
          onTap: unlocked ? onTap : null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: completed ? Palette.gold : Palette.indigo,
                foregroundColor: completed ? Palette.night : Palette.pearl,
                child: Text('$number'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      unlocked ? subtitle : 'Пройди предыдущий остров',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(
                completed
                    ? Icons.check_circle_rounded
                    : (unlocked
                          ? Icons.play_arrow_rounded
                          : Icons.lock_outline_rounded),
                color: completed ? Palette.gold : Palette.mist,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
