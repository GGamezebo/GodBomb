---
description: Yandex Games — preset, SDK, требования модерации
paths:
  - "src/common/platform/**"
  - "addons/yandex_games/**"
  - "export_presets.cfg"
  - "project.godot"
  - "docs/store/**"
---

# Yandex Games

**Preset:** `Yandex` → `bin/yandex/`, feature `yandex`, HTML shell `addons/yandex_games/templates/yandex_template.html`. Отдельно от `Web` и `Android`.

**Интеграция:** plugin `Yandex Games SDK` (`addons/yandex_games/`, сторонний — не править без нужды) + autoload `YandexGames` + `PlatformServices` → `YandexBackend` (`src/common/platform/yandex_backend.gd`). Весь код, трогающий `YandexGames`, живёт **только** в `YandexBackend`; выбирается при `OS.has_feature("yandex")`. `project.godot`: `yandex_games/general/auto_call_game_ready=false` (ready шлём сами).

**Ловушка:** запуск редактора / `--import` плагин прописывает `html/custom_html_shell` Яндекса в пресет `Web` — откатывать (`git checkout -- export_presets.cfg`), у `Web` shell должен быть пустым.

**Граница слоёв:** `LocaleService` / `LocaleCatalog` / FSM / HUD — платформенно-нейтральны. Портальный `i18n.lang`, ads, `game_ready` — только через `PlatformServices`. Не тянуть `YandexGames` и `OS.has_feature("yandex")` в common/locale или contexts.

**Lifecycle (yandex):** `game_ready` после init · `gameplay_start` на `play` · `gameplay_stop` иначе (через `GameEvents.ev_game_state_changed`) · interstitial при выходе в меню после `result` · **2.14** `i18n.lang` → `LocaleService.set_locale` на старте.

**Листинги / черновики сторов:** `docs/store/` (`listing.md`, `yandex_draft.md`, `web_smoke.md`).
