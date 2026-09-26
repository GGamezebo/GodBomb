---
description: Google Play — Android preset, backend, релиз
paths:
  - "src/common/platform/google_play_backend.gd"
  - "export_presets.cfg"
  - "android/**"
  - "tools/create_android_release_keystore.ps1"
---

# Google Play

**Решения:** бесплатно, **без рекламы** на старте · In-App Review (в работе) · Play Games не подключаем.

**Backend:** `GooglePlayBackend` (`src/common/platform/google_play_backend.gd`), feature `play`. Все Android/Play-плагины вызываются только отсюда.

**Preset `Android`:** gradle build (`android/build/`, нужен для splash bg), arm64 only, `com.tictacbadaboom.app`, immersive. TODO релиза: feature `play`, AAB (`gradle_build/export_format=1`), явный target SDK, `version/code` +1 на каждую загрузку.

**Подпись:** upload key через `tools/create_android_release_keystore.ps1` → `secrets/` (gitignored). Пароли вводит пользователь, в репо/чат не попадают. Play App Signing.

**Console:** новый личный аккаунт → закрытый тест 12+ тестировщиков 14 дней до продакшна. Нужен URL политики конфиденциальности.
