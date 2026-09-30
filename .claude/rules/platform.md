---
description: Платформы — фасад PlatformServices, backend'ы Yandex / Google Play / Null
paths:
  - "src/common/platform/**"
  - "src/contexts/main_context/main_context.gd"
  - "export_presets.cfg"
  - "project.godot"
---

# Платформы

**Фасад:** autoload `PlatformServices` (`src/common/platform/platform_services.gd`) — единственная точка входа для игрового кода. Выбирает один `PlatformBackend` по export feature: `yandex` → `YandexBackend` · `play` → `GooglePlayBackend` · иначе `NullBackend` (plain Web, редактор, F6).

**Фасад делает сам (платформенно-нейтрально):** подписка на `GameEvents.ev_game_state_changed` → `set_gameplay_active(state == PLAY)`; флаг «матч завершён» на `RESULT` → `await_return_to_menu_gate()` вызывает `backend.on_match_finished_return_to_menu()` (Yandex: interstitial, Play: review). `MainContext` зовёт только `await_return_to_menu_gate()` / `on_left_battle_context()`.

**Backend API** (`platform_backend.gd`, всё no-op): `boot()` · `set_gameplay_active(bool)` · `on_match_finished_return_to_menu()` · `on_history_back()` · `on_user_input()` (фасад зовёт из `_input` на каждое нажатие; Yandex снимает «зависшую» платформенную паузу) · `get_id()` · `privacy_policy_url()` (дефолт — itch-страница политики; Yandex → "" = ссылка скрыта, модерация запрещает внешние ссылки). Новая платформа = новый subclass + ветка в `_create_backend()` + feature в пресете.

**Запрещено:** `OS.has_feature("yandex"/"play")` и SDK-синглтоны вне `src/common/platform/`. Контексты / FSM / HUD / locale про платформы не знают.

**Пресеты:** `Android` (feature `play`, Google Play) · `Web` (без feature → Null) · `Yandex` (feature `yandex`) → `yandex-games.md`, `google-play.md`.
