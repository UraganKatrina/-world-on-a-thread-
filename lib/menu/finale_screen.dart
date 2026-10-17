import 'package:flutter/material.dart';

import '../app/palette.dart';
import '../game/widgets/glass_panel.dart';
import '../navigation/app_routes.dart';
import 'sky_background.dart';

/// Shown after the last available level.
class FinaleScreen extends StatelessWidget {
  const FinaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: GlassPanel(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.nights_stay_rounded,
                        color: Palette.gold,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Все острова соединены',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Это все уровни прототипа. Новые острова появятся в следующих версиях.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () => AppRoutes.backToMenu(context),
                        child: const Text('В главное меню'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
