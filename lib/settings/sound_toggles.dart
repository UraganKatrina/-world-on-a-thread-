import 'package:flutter/material.dart';

import 'game_settings.dart';

/// Switches for sound, music, effects and reduced motion. Rebuilds itself
/// when settings change.
class SoundToggles extends StatelessWidget {
  const SoundToggles({
    super.key,
    required this.settings,
    this.showMotion = true,
  });

  final GameSettings settings;
  final bool showMotion;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tile(
            context,
            'Звук',
            'Общий выключатель',
            settings.soundEnabled,
            (v) => settings.soundEnabled = v,
          ),
          _tile(
            context,
            'Музыка',
            null,
            settings.musicEnabled,
            settings.soundEnabled ? (v) => settings.musicEnabled = v : null,
          ),
          _tile(
            context,
            'Эффекты',
            null,
            settings.effectsEnabled,
            settings.soundEnabled ? (v) => settings.effectsEnabled = v : null,
          ),
          if (showMotion)
            _tile(
              context,
              'Меньше движения',
              'Острова не покачиваются, анимации короче',
              settings.reduceMotion,
              (v) => settings.reduceMotion = v,
            ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    String? subtitle,
    bool value,
    ValueChanged<bool>? onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      value: value,
      onChanged: onChanged,
    );
  }
}
