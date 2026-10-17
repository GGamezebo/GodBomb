---
description: Бой — FSM, HUD, input, овертайм, emergency, C4 background
paths:
  - "src/contexts/game_context/**"
  - "src/features/background/**"
  - "src/features/bomb/**"
  - "src/features/explosion/**"
  - "src/common/game_*.gd"
  - "src/common/word_condition.gd"
  - "tests/**"
---

# Бой

**FSM:** choice → ready → countdown → play ⇄ **emergency** → explosion → ready|result. First card at countdown end if null. After boom: next_card→next_player→ready, or match end / overtime.

**Score = points:** `GameSession.award_round(exploded)` on each boom → `rounds_played += 1`, every other **active** player `+1` (`GamePlayer.on_round_survived`). Winner = max points; `get_sorted_results()` desc. Tutorial: `apply_tutorial_final_scores()` (rounds = `ROUND_COUNT`).

**Overtime knockout:** regulation clock up after boom → unique max = `result`. Tie on max → `enter_overtime()` (players below max out), splash `OVERTIME_*` (`BattleSplashOverlay` child of HUD fullscreen — not cover-scaled `ScaledContent`). Roster hidden. Each OT boom: exploded out, others +1. Splash **Continue** (`EMERGENCY_CONTINUE`) bottom slot like results. OT board: plain VBox/Scroll + expand-fill rows (no CenterContainer / `_fit_control_size`). Tutorial skips OT. Подробности / лидерборд → `.claude/plans/battle-overtime-knockout.md`.

**Match clock:** `match_elapsed_seconds` only in **countdown** + **play** (not ready/explosion/emergency/pause/roster). Limit = `game_time_minutes * 60`. Roster resync does not reset clock. After boom: time up → result or overtime; else next card. Editor (`OS.has_feature("editor")`): top-left debug clock on GameManager CanvasLayer. Тест: `tests/test_match_clock.gd` (headless).

**Time left banner:** between rounds `GameTimeProgressBanner` — minutes left + estimated «ещё ~N» rounds (`regulation_boom_count` pace). Hidden in overtime. Toggle `FixedPhoneButton` force-clears this slot before table-center / ready hint.

**Emergency first open:** `BattleEmergencyOverlay` shows `EMERGENCY_FIRST_HINT` once per match (`session.emergency_intro_shown`), then `EMERGENCY_EXPLANATION`.

**UI init trap:** FSM starts in `initialize()` before child `_ready`. HUD + `game_input` MUST `_sync_to_current_state()` in `_ready`.

**Layout:** dial@`RoundWord` · player pill on lower dial · `TableHintBanner`@`PlayerName` · pass hint y≈1410 (`GameActionHints`).

**HUD:** SyllableCard — fitted single-line center text · hints via `TableHintBanner` · PlayerStrip on dial · **table-center mode** (`table_center_mode`): TopBar toggle `FixedPhoneButton` (`icon_fixed_phone` / `icon_pass_phone`) · only dial content (syllable + name + countdown) rotates as one group around dial center via `DialFacingLayer` / `DisplayFacing` · hints/buttons stay fixed.

State UI: choice/ready/countdown/play share dial layout · ready=«Готовы?»+StartRoundButton · play=full HUD.

**Input** (`game_input.gd`): `mouse_filter=IGNORE`. PLAY: multi-touch pass — next only when **all** fingers up within **0.3s**; hold longer = invalid · tap→next + sparks. **Emergency** button (PLAY only) → `EMERGENCY` state, pause game+audio, overlay to re-pick current player · continue → `try_add_bonus_bomb_time()`. RESULT→`GameResultOverlay` «В МЕНЮ» button (10s reveal, haptics, no tap-skip).

**Pass sparks:** `pass_bomb_spark_layer.gd` on `ScaledContent` — radial additive fire burst at touch (one-shot CPUParticles2D). Pass also pulses whole bomb (`GameBombBackground.pulse_pass`) — art + dial glass + ScaledContent scale+position around dial center (no `pivot_offset`; TextureRect+pivot drifted on device).

**Emergency:** `BattleEmergencyOverlay` + `EmergencyState` · `PlayerSelectionWidget.set_emergency_mode()` · `GameBattleChrome/EmergencyButton` (`alert_glow`: volumetric `icon_emergency.svg` + soft aura / occasional sparkle via `BombIconGlow`) · icon `icon_emergency.svg`. В овертайме выбирать только `is_active`.

**Battle lobby overlay:** `BattlePlayerLobbyOverlay` — edit roster mid-game · hidden/locked in overtime · Done = confirm if roster ok else click · reuses `PlayerSelectionWidget` + `StartActionButton`.

**Visual:** `GameBombBackground` — player-color backdrop · `DisplayBomb`/`BombDialGlass` dial glass (`BombDialLayout` cover-scale 800@138,550) · hides with bomb on explosion/result · alert pulse · bomb flash/shake on explosion · `ExplosionEffect` · `GameResultOverlay` (`game_result_overlay.tscn`, instanced by HUD; F6 = demo leaderboard via `preview_*` exports) full-screen winner tint, subtitle `RESULT_TOTAL_ROUNDS` (session `rounds_played`), rank rows show points, celebration particles.

**Audio:** gameplay → `GameSound` · UI buttons → `UiSounds` → `audio.md`.

**Core:** `game_manager.gd` `game_session.gd` `game_sound.gd` `word_condition.gd` · decks `GameDecks` → `locale.md`. Условие карты берётся через `WordCondition.random_for(syllable)`.

**Match length:** clock from `account.game_time_minutes`; deck refills as needed. OT does not rebuild the deck. Roster add/remove does not reset the clock.
