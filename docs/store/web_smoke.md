# Web smoke checklist (phone browser)

Export: Project → Export → Web → `bin/index.html`  
Serve locally (not `file://`): e.g. `npx serve bin` or Godot remote deploy.

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
10. Yandex draft (`/sdk.js` present): debug-mode=16 → loader **IT**, Game Ready after lobby, tab blur mutes audio  

See `docs/store/yandex_games.md`.  

## Fail notes

- White splash → Gradle/splash only on Android; Web uses `boot_splash`  
- No sound until tap → expected on mobile Safari/Chrome  
