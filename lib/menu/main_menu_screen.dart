import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../app/palette.dart';
import '../navigation/app_routes.dart';
import 'sky_background.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: ListenableBuilder(
                  listenable: services.progress,
                  builder: (context, _) {
                    final started =
                        services
                            .progress
                            .progress
                            .completedLevelIds
                            .isNotEmpty ||
                        services.progress.progress.lastOpenedLevelId != null;
                    final resume = services.progress.resumeLevel;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Мир на нитке',
                          style: text.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'WORLD ON A THREAD',
                          style: text.bodyMedium?.copyWith(
                            letterSpacing: 4,
                            color: Palette.softGold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        FilledButton(
                          onPressed: () {
                            services.audio.ensureMusic();
                            AppRoutes.openLevel(context, resume);
                          },
                          child: Text(
                            started ? 'Продолжить: ${resume.title}' : 'Играть',
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => AppRoutes.openLevelSelect(context),
                          child: const Text('Уровни'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => AppRoutes.openSettings(context),
                          child: const Text('Настройки'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
