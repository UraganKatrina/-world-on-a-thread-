# Мир на нитке (World on a Thread)

Сюрреалистическая расслабляющая головоломка на Flutter. Игрок соединяет светящиеся
точки на парящих островах нитями, будит механизм и открывает проход.
Без таймеров, жизней и наказаний.

Статус: прототип первого спринта. Два уровня: «Пробуждение» (последовательность
из трёх нитей) и «Созвездие» (четыре пары в любом порядке).

## Требования

- Flutter 3.47.x (stable), Dart 3.13.x. Проверено на Flutter 3.47.7 / Dart 3.13.5.
- Android: Android Studio или Android SDK (platform 36, build-tools, platform-tools), JDK 17+.
- iOS: macOS, Xcode 16+, CocoaPods.

## Быстрый старт

```bash
flutter pub get
flutter analyze        # ожидается: No issues found!
flutter test           # ожидается: All tests passed! (26 тестов)
flutter run            # на подключённом устройстве или эмуляторе
```

Web-версия (так прототип проверялся в облаке):

```bash
flutter build web --release --no-web-resources-cdn
cd build/web && python3 -m http.server 8080   # открыть http://localhost:8080
```

## Android

```bash
flutter doctor --android-licenses   # один раз принять лицензии
flutter doctor                      # строка Android toolchain должна быть [✓]
flutter build apk --debug           # build/app/outputs/flutter-apk/app-debug.apk
flutter install                     # или: adb install build/app/outputs/flutter-apk/app-debug.apk
flutter build appbundle --release   # AAB для Google Play
```

Для публикации нужно создать ключ подписи и `android/key.properties`
(см. https://docs.flutter.dev/deployment/android). Сейчас release-сборка
подписывается debug-ключом, как в шаблоне Flutter. Application id:
`com.worldonathread.world_on_a_thread`; поменяйте его до публикации, если нужен другой.

## iOS (macOS + Xcode)

```bash
flutter pub get
cd ios && pod install && cd ..
open ios/Runner.xcworkspace
```

В Xcode: Runner → Signing & Capabilities → выбрать свою Team, при необходимости
сменить Bundle Identifier (`com.worldonathread.worldOnAThread`). Затем:

```bash
flutter run -d <id симулятора или iPhone>   # список: flutter devices
flutter build ios --release                 # или Product → Archive в Xcode
```

Что проверить на iOS: вырез и «чёлка» не перекрывают кнопки (SafeArea),
звук играет после первого касания, переключатели «Музыка» и «Эффекты» работают
раздельно, прогресс сохраняется после перезапуска приложения.

## Сборка без Mac и без Android SDK (GitHub Actions)

Файл `.github/workflows/build.yml` собирает всё в облаке GitHub при каждом push в `main`
(или вручную: Actions → Build → Run workflow):

- `test`: `flutter analyze` и `flutter test`;
- `android`: APK (`world-on-a-thread-android-apk` в разделе Artifacts запуска). Скачать на телефон,
  распаковать zip, открыть `app-release.apk`, разрешить установку из этого источника;
- `ios`: сборка на macOS-машине GitHub без подписи, `.ipa` в Artifacts. Это доказывает, что
  iOS-версия компилируется. Поставить её на iPhone без Mac можно через Sideloadly
  (Windows) с бесплатным Apple ID, приложение работает 7 дней. Для TestFlight и App Store
  нужен Apple Developer Program (99 $ в год), подписывать можно тоже в облаке (Codemagic или
  GitHub Actions), Mac не нужен;
- `web`: публикует игру на GitHub Pages (`https://<user>.github.io/<repo>/`). На iPhone её
  можно открыть в Safari и добавить на экран «Домой».

## Архитектура

```
lib/
  main.dart                 запуск, ориентация, сборка сервисов
  app/                      MaterialApp, тема, палитра, AppScope (DI)
  navigation/app_routes.dart переходы между экранами
  menu/                     главное меню, выбор уровней, финальный экран, фон
  game/
    models/                 PuzzleNode, Connection, WinCondition, LevelDefinition, визуальные параметры
    logic/                  PuzzleSession: чистая логика без UI, тексты обратной связи
    levels/                 уровни и LevelCatalog
    rendering/              BoardGeometry (координаты и касания), WorldPainter (Canvas)
    widgets/                PuzzleBoard, HUD, пауза, экран победы
    game_screen.dart        экран уровня
  audio/                    синтез звуков в WAV + воспроизведение через audioplayers
  persistence/              хранилище ключ-значение, GameProgress, ProgressRepository
  settings/                 GameSettings, переключатели, экран настроек
test/                       логика, каталог уровней, сохранение, виджет-тесты прохождения
```

Логика головоломки (`PuzzleSession`) не знает об отрисовке: она принимает касания
узлов и возвращает результат (выбран узел, нить натянута, нить отклонена с причиной,
уровень решён). Победа определяется `WinCondition.isSatisfied`, а не анимацией.

### Как добавить уровень

1. Создать файл в `lib/game/levels/` с `LevelDefinition`: id, узлы (координаты 0..1
   на поле с пропорцией 9:16), разрешённые соединения, условие победы
   (`SequenceCondition` или `AllConnectionsCondition`), острова, подсказка.
2. Добавить его в `LevelCatalog.standard()`.
3. `flutter test`: тест каталога проверит, что уровень корректен.

## Звук

Все звуки оригинальные и генерируются кодом (`audio/tone_synth.dart`), сторонних
аудиофайлов нет. Музыка и эффекты выключаются раздельно, есть общий выключатель.
Звук не обязателен: все сообщения дублируются текстом.

## Доступность

Крупные зоны касания (не меньше 48 px), текст на тёмных подложках, подписи для
экранного диктора, режим «Меньше движения» (также учитывается системная настройка),
поддержка безопасных областей экрана.
