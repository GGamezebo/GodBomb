# Yandex Games export

## Export

1. Godot → Project → Export → **Web (Yandex Games)**
2. Output: `bin/yandex/index.html` (ZIP root must be `index.html`)
3. Feature `yandex` enables `PlatformServices` hooks
4. HTML shell embeds `/sdk.js` + GodotYandexBridge

Package: Editor → Project → Tools → **Yandex Games: Package Web Export to Yandex ZIP**  
(or zip `bin/yandex/` so `index.html` is at the archive root)

## Moderation checklist

- [ ] Debug panel loader shows **IT** (not IF)
- [ ] Game Ready turns green when lobby is interactive (no fake timer)
- [ ] Gameplay green only in battle `play`; red in menu / result / pause
- [ ] Audio mutes on startup fullscreen ad / tab blur (`game_api_pause`)
- [ ] Portrait 1080×1920; first tap unlocks audio on mobile browsers

## Local debug

Use Yandex draft URL + SDK proxy, or editor mock (`YandexGames` autoload without `yandex` feature — hooks idle).
