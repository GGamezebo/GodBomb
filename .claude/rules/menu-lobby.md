---
description: Лобби — игроки, DnD, edit window, настройки, UI sounds
paths:
  - "src/features/player_selection/**"
  - "src/features/menu/**"
  - "src/features/onboarding/**"
  - "src/contexts/menu_context/**"
  - "src/contexts/game_context/ui/battle_player_lobby_overlay.*"
  - "src/common/player_info.gd"
  - "src/common/slime_colors.gd"
---

# Лобби

MenuContext + `PlayerSelectionWidget`. Party kitchen, bomb bg `MenuBombLayout` (1080×1920 cover). `ScaledContent`: TopBar, стол, Start, hint Marker2D. `ModalLayer.follow_viewport_enabled = true` в `player_selection_widget.tscn`.

**Игроки:** 2–12 · `PDataAccount`→`PlayerInfo`(name, **max 12 chars**, preset_id) · slimes `party_kitchen/slimes/{id}.svg` · `SlimeColors` · занятые цвета — `PlayerPresetStorage`

**Порядок:** `SeatOrderBadge` 38×38 font 26 · стрелки `TurnOrderArrowsLayer` (`RING_MARGIN=24`, accent 75% on drag) · badges gap `BADGE_GAP_AFTER_ARROWS=10`

**Swap:** drag slime → swap · hint: «Перетащи персонажа на стул другого…» · hit: circle–circle (`get_grab_radius_global`, `seat_interaction_radius`)

**Remove:** `+` → delete mode · dashed ring **child of `add_player_button`** (не table_area) · drop slime center in ring · min_players_for_remove=0

**Touch:** `TOUCH_GRAB_RADIUS=78` · `HOLD_HOME_TOLERANCE=36` · haptics on drag pickup / target lock / lobby action

**Hold-edit:** `hold_time=1.4` (hint «1,5 сек») · `HoldProgressRing` · move > tolerance cancels · `EditPlayerWindow` · hints until `has_edited_player`

**EditPlayerWindow:** no scroll · margins как settings (32/64 panel, 48 inner, buttons 180) · colors grid под name history · OK add / Apply edit / Cancel · sounds → `audio.md`

**Start:** `StartActionButton` (pulse, `refresh_label_layout()` centers label on SVG pill, clip_contents=false) · menu Start + battle Done share script · SVG `start_active/inactive` viewBox `-6 0 452 120`

**Min 2:** start disabled · `+` pulse · banner hint

**Settings:** party 1–30min · **difficulty** easy/medium/hard + hint under label (deck: syllable length / rule hardness; `*_RESTRICT` still applies) · music volume slider only (mute = TopBar) · sfx→SFX · haptics on/off + strength · reset: 2-step confirm · `reset_progress()` clears players, recent names = slime defaults · язык — `LanguageFlagPicker` → `locale.md` · `PrivacyLink` под панелью в нижней полосе окна (не в скролле — иначе список перестаёт помещаться; LinkButton, URL из `PlatformServices.privacy_policy_url()`, пусто → скрыт; требование Google Play)

**Onboarding:** `OnboardingController` + `OnboardingOverlay` + `OnboardingTutorialData` — шаги RULES → LOBBY_ADD/NAME/SWAP/START → GAME_CHOICE/READY/PLAY/RESULT; туториальный бой `session.is_tutorial` (без овертайма). Coach: `set_progress(n, total)` (точки + `ONBOARDING_STEP`, вызывается в `_present_current_step`), fade/pop при смене шага; spotlight-шейдер `onboarding_spotlight.gdshader` рисует пульсирующее медное кольцо. **Раскладка:** «Пропустить» — всегда pill в правом верхнем углу (`SKIP_PILL_*`); coach-док снизу, но уходит наверх (под pill), если дырка spotlight заходит под док (`_wants_top_dock`); док ≤ 36% высоты, body скроллится только при переполнении. На результатах «В МЕНЮ» — большая кнопка в доке (`set_bottom_action`), pill скрыт. **Жесты:** `OnboardingGestureHint` (`onboarding_gesture_hint.gd`) — `overlay.set_gesture(kind, from, to, point)`: TAP/HOLD/DRAG анимированным пальцем над целью (swap = drag A→B по пунктирной дуге), тот же жест мини-значком слева от заголовка coach (WAIT для жребия, BOOM для взрыва). **Имена:** туториал кэширует `recent_player_names` в `_cache_roster()` и возвращает в `_restore_roster()` (`PDataAccount.set_recent_names`) — иначе добавленные в обучении игроки съедают дефолтные имена. Проверка раскладки: прогон туториала с `APPDATA` во временной папке (чистый профиль) + скриншоты по шагам через `skip_current_step()`.

**Rules window:** `RulesWindow` строит 8 карточек (`RULE_CARDS`: CIRCLE, SYLLABLE, PASS, BOOM, WIN, LOBBY, OOPS, CENTER) — `RulesIllustration` (`src/features/menu/rules_illustration.gd`, анимированный `_draw` в канве 900×340, слаймы + `icon_emergency.svg`, подписи из `RULES_ILL_*`) + номер, заголовок, текст. Под карточками `RulesText` = подвал (`RULES_TEXT_*`: разработчики / пожелание). F6 на `rules_window.tscn` открывает окно.

**UI sounds:** см. `audio.md` · widget: click `+`, lobby add/remove/swap

**Start game:** bomb preview → `ev_start_game` → GameContext · `SCOPE_MENU` off
