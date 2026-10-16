---
description: Google Play — Android preset, backend, релиз
paths:
  - "src/common/platform/google_play_backend.gd"
  - "export_presets.cfg"
  - "android/**"
  - "tools/create_android_release_keystore.ps1"
---

# Google Play

**Решения:** **бесплатно** (выставлено в Console 2026-09-27; после публикации сделать платным нельзя) · **без рекламы** на старте · In-App Review · Play Games не подключаем.

**Монетизация — план на потом:** «Поддержать разработчика» / паки колод только через **Google Play Billing** (consumable/one-time IAP) в `GooglePlayBackend`. Внешние ссылки на донаты (Boosty и т.п.) из игры — запрещено правилами Play и модерацией Яндекса. Блокер: нужен платёжный профиль продавца (ограничения для РФ — проверить). При добавлении рекламы/IAP обновить Data safety, декларации «Реклама»/«Рекламный идентификатор», политику конфиденциальности.

**Backend:** `GooglePlayBackend` (`src/common/platform/google_play_backend.gd`), feature `play`. Все Android/Play-вызовы только отсюда.

**In-App Review:** без Kotlin-плагина — `JavaClassWrapper` + `AndroidRuntime.getActivity()`, Play Tasks опрашиваются `isComplete()`. Gradle-зависимость `com.google.android.play:review` добавляет `addons/godbomb_android` (EditorExportPlugin, только для пресетов с feature `play`). Политика: после 3-го завершённого матча, не чаще раза в 30 дней, не блокирует возврат в меню; состояние `user://platform_play.cfg`. Диалог показывается только у установки из Play (internal/closed track) — локально не проверить.

**Presets:** `Android` → Play upload, feature `play`, **AAB** → `bin/android/tictacbadaboom.aab`; `Android APK` (preset.3) → sideload на свой телефон, feature `play`, APK. Общее: (`gradle_build/export_format=1`), gradle build (`android/build/`, нужен для splash bg), arm64 only, `com.tictacbadaboom.app`, immersive. target SDK пустой = дефолт шаблона 4.7.1 (36, `android/build/config.gradle`). `version/code` +1 на каждую загрузку в Console. Сейчас 1.0.5 (code 6). Название: в Play «TicTacBadaBoom: Party Game», подпись под иконкой на телефоне — `package/name="TicTacBadaBoom"` (длинное обрезается лаунчером). Темированная иконка Android 13+: `adaptive_monochrome` = `assets/icon_adaptive_mono.png` (генерирует `tools/generate_app_icons_from_art.py`; пустое поле = заглушка Godot).

**Рендерер:** Android = `gl_compatibility` (`project.godot` → `renderer/rendering_method.mobile`). Vulkan-рендерер `mobile` давал горизонтальные полосы-артефакты поверх всего кадра (арт + текст) на Adreno 710 / Snapdragon 7s Gen 3 (Nothing Phone 3a). Игра 2D, Web уже на compatibility — не возвращать `mobile` без проверки на таком устройстве.

**Иконки и экран запуска:** в обоих Android-пресетах `launcher_icons/*` должны указывать на `assets/icon_192.png`, `icon_adaptive_fg.png`, `icon_adaptive_bg.png`. При пустых путях Godot не создаёт ресурс `icon_background`, на который ссылается тема экрана запуска Android 12+ (`windowSplashScreenBackground`) → при холодном старте белый фон с иконкой, потом резко тёмный. Проверка: после экспорта есть `android/build/res/mipmap/icon_background.webp`. Но Android 12+ ждёт там **цвет**, а не картинку, и берёт светлый фон (розово-белый кадр при холодном старте) → в `android/build/res/values-v31/godot_splash_override.xml` тема `GodotAppSplashTheme` переопределена с чёрным `windowSplashScreenBackground`. `android/build/` не в git — копия файла лежит в `tools/android_template/`, при переустановке шаблона Android скопировать обратно в `res/values-v31/`.

**Подпись:** upload key через `tools/create_android_release_keystore.ps1` → `secrets/` (gitignored). Godot 4.7 берёт keystore из `.godot/export_credentials.cfg` (заполняется в окне Export у **каждого** пресета отдельно), корневой `export_credentials.cfg` скрипта не используется. Пароли вводит пользователь, в репо/чат не попадают. Play App Signing.

**Console:** новый личный аккаунт → закрытый тест 12+ тестировщиков 14 дней до продакшна. Готовые ответы/тексты → `docs/store/google_play_draft.md`; политика конфиденциальности → https://igorion.itch.io/tic-tac-bada-boom-privacy (исходник `docs/privacy/index.html`, при правке — вставить заново в описание itch-проекта); feature graphic → `assets/reference/store/google_play_feature_1024x500.png`; иконка Play (квадрат без скруглений, Google скругляет сам) → `assets/reference/store/google_play_icon_512.png`. Store listing: en-US (по умолчанию) + ru-RU, по 8 скриншотов из `yandex_screen_shots_en/` и `_ru/`. При изменении разрешений/SDK — обновить Data safety и политику.
