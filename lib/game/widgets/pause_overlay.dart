import 'package:flutter/material.dart';

import '../../settings/game_settings.dart';
import '../../settings/sound_toggles.dart';
import 'glass_panel.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.settings,
    required this.onResume,
    required this.onRestart,
    required this.onMenu,
  });

  final GameSettings settings;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x99080A24),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: GlassPanel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Пауза',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    SoundToggles(settings: settings, showMotion: false),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onResume,
                      child: const Text('Продолжить'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: onRestart,
                      child: const Text('Начать уровень заново'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: onMenu,
                      child: const Text('В главное меню'),
                    ),
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
