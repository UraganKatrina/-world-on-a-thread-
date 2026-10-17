import 'package:flutter/material.dart';

import '../menu/main_menu_screen.dart';
import 'app_services.dart';
import 'theme.dart';

class WorldApp extends StatelessWidget {
  const WorldApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
        title: 'Мир на нитке',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const MainMenuScreen(),
      ),
    );
  }
}
