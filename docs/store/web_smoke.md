# Web smoke checklist (phone browser)

Export: Project → Export → **Web** → `bin/index.html`  
Yandex: Project → Export → **Web (Yandex Games)** → `bin/yandex/index.html` (feature `yandex`, custom HTML shell required).  
Serve locally (not `file://`): e.g. `npx serve bin` or Godot remote deploy. For Yandex SDK locally: `npx @yandex-games/sdk-dev-proxy -p ./bin/yandex --dev-mode=true`.

After `tools/optimize_build_assets.py` + editor reimport.

## On phone

1. First tap unlocks audio (gesture) — music/SFX start after interaction  
2. Lobby: add 2–3 players, drag swap, hold-edit  
3. Battle: multi-touch pass (all fingers up ≤0.3s)  
4. Table-center mode: dial rotates, hints stay upright  
5. Pass pulse: bomb stays aligned with glass (no drift)  
6. Between rounds: time + «ещё ~N» rounds line  
7. Emergency once: first-hint copy, then normal explanation  
8. Leave tab in background 30s → return without crash / huge lag  
9. Memory: play ~5 min, no browser kill  

## Yandex Games (draft / proxy)

1. SDK init succeeds (no `YaGames SDK script not found`)  
2. LoadingAPI.ready (`game_ready`) after boot  
3. GameplayAPI start/stop around battle `play`  
4. Return to menu after result may show interstitial (cooldown)  
5. Locale follows portal language when supported  

## Fail notes

- White splash → Gradle/splash only on Android; Web uses `boot_splash`  
- No sound until tap → expected on mobile Safari/Chrome  
- Generic Web export must stay without feature `yandex` / Yandex HTML shell  
