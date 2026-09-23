# Yandex Games SDK

Web export is wired for [Yandex Games SDK](https://yandex.com/dev/games/doc/en/sdk/sdk-about). Android / editor / local `npx serve` stay no-op if `/sdk.js` is missing.

## What the build does

| Requirement | Where |
|---|---|
| Connect `/sdk.js` (relative, async + `YaGames.init`) | `export_presets.cfg` → Web `html/head_include` |
| `LoadingAPI.ready()` after lobby is interactive, Godot splash gone | `YandexGames.notify_interactive()` from `MainContext` |
| `GameplayAPI.start/stop` | countdown + play = start; menu / ready / emergency / explosion / result / ads / tab blur = stop |
| Mute + pause on `game_api_pause` / `game_api_resume` | `YandexGames` → Master mute + `GameManager.set_paused` |
| Interstitial after a real match | Return to menu (skip tutorial) → `showFullscreenAdv` |

Service node: `core/systems/yandex/yandex_games.gd` under `main.tscn` (not an autoload).

COOP isolation headers are off on the Web preset so the Yandex iframe can talk to the SDK.

## Export

Project → Export → **Web** → `bin/index.html`.

Zip `bin/` and upload in the [Yandex Games console](https://games.yandex.ru/console). Draft iframe serves `/sdk.js`; `npx serve bin` will 404 that script and the game still runs.

## Debug panel

Open the draft with `&debug-mode=16` (or **Open with debug panel** in the console).

- Loader **IT** = `/sdk.js` + `YaGames.init()` ok. **IF** = old loader URL. **W** = still waiting.
- Game Ready should flip after the lobby is up.
- Gameplay indicator green only during countdown / play.

## Checklist

- [ ] Web export includes `<script src="/sdk.js"` in `index.html`
- [ ] Debug loader = IT, Game Ready fires once, no loading overlay at that moment
- [ ] Tab blur / interstitial mutes music + SFX
- [ ] After a finished (non-tutorial) match, **В МЕНЮ** can show a fullscreen ad
- [ ] Portrait 1080×1920 still fits the Yandex iframe
