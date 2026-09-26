---
description: Архитектура — контексты, события, FSM, ресурсы, F6, вес билда
paths:
  - "src/**/*.gd"
  - "src/**/*.tscn"
  - "core/**/*.gd"
  - "main.tscn"
---

# Архитектура

**Контексты:** `IContext` (`src/contexts/icontext.gd`: `initialize(data)`, `deinit()`). `MainContext.switch_game_context()` — async load. Цепочка: Menu → Game → Menu (`ev_return_to_menu` из `result`). Новый экран = `src/contexts/` + путь в MainContext.

**События:** Resource + `signal ev_*` (`MainEvents`, `GameEvents`, `MenuEvents`; экземпляры `.tres`). Подписка: `EventListener` (`core/lib/event_listener.gd`) + `listener.deinit()` в `_exit_tree()`. Контексты не линковать напрямую.

**FSM:** `core/lib/fsm/`, состояния `StateBase` в `GameManager`, константы `FSMGameEvents`.

**Ресурсы:** `class_name` Resource, save `user://account.tres` via `PersistentDataController` (`PDataAccount`). Дефолты в `.tres`.

**Сервисы:** под `main.tscn`, не autoloads. `@export` для зависимостей, не `get_node("/root/...")`. Исключения-autoloads (платформа/локаль): `LocaleService`, `YandexGames`, `PlatformServices`.

**F6:** `@export` дефолты в `.tscn`, тяжёлая логика в `initialize()`, не в `_ready()` контекста до add_child.

**Editor window:** play from editor uses 360×640 (`window_width/height_override` + `MainContext._apply_editor_window_size`). Viewport stays 1080×1920, stretch `canvas_items`, aspect `keep_width`.

**Ship weight:** textures VRAM-compressed (ETC2/ASTC mobile, S3TC web), importer_defaults VRAM + size_limit 1024; concept art under `assets/reference/` is `.gdignore`d + export exclude `assets/reference/*,tools/*`. `tools/optimize_build_assets.py` — MP3→mono 64–80kbps, Background ≤1024 + VRAM compress, SVG size caps, WAV mono/ADPCM. Re-run after replacing music; open editor once to reimport.
