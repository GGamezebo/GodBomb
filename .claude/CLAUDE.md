# GodBomb (Tic-Tac-Bada-Boom)

Party hot-potato, слоги. Godot **4.7** GDScript, 1080×1920 portrait, mobile renderer на десктопе; Android и web = `gl_compatibility`. Entry: `main.tscn` → `MainContext`.

**Цикл:** 2–12 игроков, слог+условие, передача бомбы, скрытый таймер, взрыв = +1 штраф, победа = min score. Основное время = countdown+play до `game_time_minutes`; истекло: уникальный лидер → result, ничья → овертайм на вылет.

**FSM:** `player_choice` → `ready_to_start` → `countdown` → `play` ⇄ `emergency` → `explosion` → … → `result`

**Контексты:** MenuContext (лобби) · GameContext (бой). Онбординг/туториал — `src/features/onboarding/` (`OnboardingController`, `session.is_tutorial`).

**Папки:** `src/contexts/` экраны · `src/features/` механики · `src/common/` config/events/locale/platform · `src/ui/` тема + loading screen · `core/` FSM, `EventListener`, systems (audio, haptics) · `assets/` · `tools/` генераторы/оптимизаторы · `tests/` headless · `docs/store/` листинги сторов.

## Правила по областям

Детальные правила лежат в `.claude/rules/*.md` и подгружаются по `paths:` при работе с соответствующими файлами:

| Файл | Область |
|------|---------|
| `rules/architecture.md` | контексты, события, FSM, ресурсы, F6, вес билда |
| `rules/gdscript.md` | стиль GDScript, имена, куда класть код |
| `rules/game-battle.md` | бой: FSM, HUD, input, овертайм, emergency |
| `rules/menu-lobby.md` | лобби: игроки, DnD, edit window, настройки |
| `rules/audio.md` | шины, music, `GameSound`, `UiSounds` |
| `rules/visual-style.md` | визуальный концепт (industrial bomb UI) |
| `rules/platform.md` | фасад `PlatformServices` + backend'ы (Yandex / Play / Null) |
| `rules/yandex-games.md` | preset Yandex, SDK, модерация |
| `rules/google-play.md` | preset Android, Google Play, релиз |
| `rules/locale.md` | `LocaleService`, строки, колоды слогов |

Если задача затрагивает область, а правило не подгрузилось автоматически — прочитай его явно. Планы крупных фич — `.claude/plans/`.

## Поддержка правил (обязательно)

После изменений механик / UI / audio / архитектуры / платформ — **сразу** обнови нужный `.claude/rules/*.md` (кратко, факты + пути, без дублирования между файлами). Новая область → новый файл в `rules/` + строка в таблице выше.

`.cursor/rules/*.mdc` — исходная (legacy) версия этих же правил от Cursor. Источник истины теперь `.claude/rules/`; `.cursor/` не редактировать без просьбы пользователя.

## Общие правила разработки

- Код и комментарии — **английский**. UI-тексты — только через `LocaleService.text("KEY")` (ru/en + доп. локали), не хардкодить строки.
- **Минимальный дифф.** Не рефакторить попутно то, что не просили.
- Не редактировать `.godot/`, `*.import`, `*.uid` вручную; `.godot/` не читать. `project.godot` / `export_presets.cfg` — править аккуратно, точечно.
- Любая сцена должна запускаться через **F6** без падений (дефолтные `@export` в `.tscn`) — см. `rules/architecture.md`.
- Вес билда (mobile + HTML): после замены музыки/текстур — `python tools/optimize_build_assets.py`, затем открыть редактор для реимпорта.
- Stores: presets `Android` (feature `play`) · `Web` (generic) · `Yandex` (feature `yandex`) → `rules/platform.md`.

## Запуск и проверка

- Godot (console build, это папка + exe внутри): `G="D:/Godot/Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe"`
- Тесты (headless): `"$G" --headless --path . --script res://tests/test_match_clock.gd` → ожидать `test_match_clock: OK`, exit 0. Первая строка `Failed to load script ... Compilation failed` при этом — известный шум, не падение. Запускать после правок `GameSession` / часов матча / овертайма.
- Проверка парсинга скриптов: `"$G" --headless --path . --quit` (ошибки парсинга в stderr).

## Известные расхождения

- `README.md` устарел (Godot 4.6.3, «длинный свайп», «удержание 2 сек») — актуальны правила в `.claude/rules/` и код.
- Autoloads существуют только для кросс-платформенных сервисов: `LocaleService`, `YandexGames`, `PlatformServices`. Новые autoloads для связи экранов **не** добавлять — сервисы под `main.tscn` + `@export`.
