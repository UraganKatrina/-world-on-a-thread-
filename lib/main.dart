import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app_services.dart';
import 'app/world_app.dart';
import 'audio/audio_service.dart';
import 'game/levels/level_catalog.dart';
import 'persistence/key_value_store.dart';
import 'persistence/progress_repository.dart';
import 'settings/game_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The board is designed for portrait; layouts still adapt if a platform
  // ignores the preference (tablets in split view, web).
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final store = await SharedPreferencesStore.open();
  final catalog = LevelCatalog.standard();
  final settings = GameSettings(store);
  final services = AppServices(
    catalog: catalog,
    progress: ProgressRepository(store, catalog),
    settings: settings,
    audio: SynthAudioService(settings),
  );
  runApp(WorldApp(services: services));
}
