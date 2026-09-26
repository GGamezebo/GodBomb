---
description: Google Play — Android preset, backend, релиз
paths:
  - "src/common/platform/google_play_backend.gd"
  - "export_presets.cfg"
  - "android/**"
  - "tools/create_android_release_keystore.ps1"
---

# Google Play

**Решения:** бесплатно, **без рекламы** на старте · In-App Review · Play Games не подключаем.

**Backend:** `GooglePlayBackend` (`src/common/platform/google_play_backend.gd`), feature `play`. Все Android/Play-вызовы только отсюда.

**In-App Review:** без Kotlin-плагина — `JavaClassWrapper` + `AndroidRuntime.getActivity()`, Play Tasks опрашиваются `isComplete()`. Gradle-зависимость `com.google.android.play:review` добавляет `addons/godbomb_android` (EditorExportPlugin, только для пресетов с feature `play`). Политика: после 3-го завершённого матча, не чаще раза в 30 дней, не блокирует возврат в меню; состояние `user://platform_play.cfg`. Диалог показывается только у установки из Play (internal/closed track) — локально не проверить.

**Presets:** `Android` → Play upload, feature `play`, **AAB** → `bin/android/tictacbadaboom.aab`; `Android APK` (preset.3) → sideload на свой телефон, feature `play`, APK. Общее: (`gradle_build/export_format=1`), gradle build (`android/build/`, нужен для splash bg), arm64 only, `com.tictacbadaboom.app`, immersive. target SDK пустой = дефолт шаблона 4.7.1 (36, `android/build/config.gradle`). `version/code` +1 на каждую загрузку в Console.

**Подпись:** upload key через `tools/create_android_release_keystore.ps1` → `secrets/` (gitignored). Godot 4.7 берёт keystore из `.godot/export_credentials.cfg` (заполняется в окне Export у **каждого** пресета отдельно), корневой `export_credentials.cfg` скрипта не используется. Пароли вводит пользователь, в репо/чат не попадают. Play App Signing.

**Console:** новый личный аккаунт → закрытый тест 12+ тестировщиков 14 дней до продакшна. Готовые ответы/тексты → `docs/store/google_play_draft.md`; политика конфиденциальности → https://igorion.itch.io/tic-tac-bada-boom-privacy (исходник `docs/privacy/index.html`, при правке — вставить заново в описание itch-проекта); feature graphic → `assets/reference/store/google_play_feature_1024x500.png`. При изменении разрешений/SDK — обновить Data safety и политику.
