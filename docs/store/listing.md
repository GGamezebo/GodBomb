# Store listing — Tic-Tac-Bada-Boom

Use for itch.io and Google Play. Screenshots: capture on a real phone (1080×1920), portrait.

## Versions (export preset)

- `version/name`: **1.0.0**
- `version/code`: **1** (increment on every Play upload)
- package: `com.tictacbadaboom.app`

## Icons (already wired in `export_presets.cfg`)

| Role | Path |
|------|------|
| Legacy 192 | `res://assets/icon_192.png` |
| Adaptive FG 432 | `res://assets/icon_adaptive_fg.png` |
| Adaptive BG 432 | `res://assets/icon_adaptive_bg.png` |
| Master / project | `res://assets/icon.png` |

Regenerate: `powershell -File tools/generate_app_icons.ps1`

## Release signing

```powershell
powershell -ExecutionPolicy Bypass -File tools/create_android_release_keystore.ps1
```

Creates (gitignored):

- `secrets/tictacbadaboom-release.keystore`
- `secrets/keystore_passwords.txt`
- `export_credentials.cfg` (Godot reads release keystore from here)

**Backup `secrets/` offline.** Losing the keystore means you cannot update the same Play listing.

Export: Project → Export → Android → **Export Project** (Release), Gradle on.

---

## itch.io

**Title:** Tic-Tac-Bada-Boom

**Short (tagline):**
Party word bomb on one phone — pass it, invent words, don’t blow up.

**RU tagline:**
Вечериночная бомба-слова на одном телефоне — передавай, придумывай слова, не взорвись.

**Description (EN):**
Sit in a circle. One phone is the bomb. The dial shows a syllable and a rule — say a word out loud, tap to pass. The fuse is hidden. Too slow? Boom — a penalty point. Fewest penalties win. Ties go to overtime knockout.

2–12 players. Difficulty Easy / Medium / Hard. Optional “phone in the center” mode rotates the dial toward the current player so nobody spins the device.

Local multiplayer. No accounts. Vibration optional.

**Description (RU):**
Садитесь кругом. Один телефон — бомба. На циферблате слог и условие — назовите слово вслух и тапните, чтобы передать. Таймер скрыт. Не успели? Бум — штраф. Меньше штрафов — выше место. При ничьей — овертайм на вылет.

2–12 игроков. Сложность: лёгкая / средняя / сложная. Режим «телефон в центре» поворачивает текст к текущему игроку.

Локальная вечеринка. Без аккаунтов. Вибрация по желанию.

**Tags:** party, local multiplayer, word game, hot potato, mobile, casual, russian

**Kind of project:** Downloadable / HTML5 (if web export) · Mobile-friendly

## Yandex Games

Web preset injects `/sdk.js` and calls Game Ready / GameplayAPI. Upload the Web `bin/` zip. Details: `docs/store/yandex_games.md`.

---

## Google Play

**App name:** Tic-Tac-Bada-Boom  
**Short description (80 chars max):**
Party word bomb on one phone. Pass it, invent words, don’t explode.

**RU short:**
Бомба-слова на одном телефоне. Передавай, придумывай, не взорвись.

**Full description:** use the itch EN/RU blocks above (trim to Play limits if needed).

**Category:** Game → Casual / Word  
**Content rating:** Everyone / PEGI 3 (no online, no ads assumed)  
**Contact:** your email  
**Privacy policy:** required if you collect data — this build is offline-only; host a one-pager stating no personal data collected.

---

## Screenshot shot list (portrait 9:16)

Capture at least 4–6:

1. Lobby — players around the table, Start ready  
2. Battle — syllable + condition on dial, player pill  
3. Pass moment — sparks / pulse after tap  
4. Explosion / penalty feedback  
5. Results / ranking  
6. Optional: Settings (difficulty) or “phone in the center” hint  

Dev reference frames (not for store as-is): `assets/reference/concept/lobby-ready.png`, `battle-dial.png`.

**Feature graphic (Play, 1024×500):** bomb dial + title on dark metal — export separately when ready.

---

## Checklist before upload

- [ ] Release keystore created and backed up  
- [ ] Godot Export → Android icons preview looks correct  
- [ ] Signed **release** AAB/APK (`versionCode` unique)  
- [ ] Vibrate works; splash stays black (Gradle build)  
- [ ] Smoke: 2 players + 6 players, table-center mode, overtime  
- [ ] Store texts pasted; screenshots attached  
