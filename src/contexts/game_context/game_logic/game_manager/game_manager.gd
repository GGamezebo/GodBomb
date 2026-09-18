class_name GameManager
extends Node

@export var game_events: GameEvents

var fsm: FSM
var session: GameSession = GameSession.new()
var states: Array[StateBase] = []
var _session_ready: bool = false
var _paused: bool = false
var _account: PDataAccount = null
var _awaiting_splash: bool = false
var _pending_post_explosion_event: String = ""
var _debug_clock_label: Label = null


func _ready() -> void:
	_collect_states()
	_setup_editor_clock_overlay()
	set_process(_session_ready)


func _exit_tree() -> void:
	if fsm:
		fsm.deinit()


func setup_session(game_config: GameConfig, account: PDataAccount) -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	_account = account
	session.setup(game_config, game_events, account)
	_session_ready = true
	_awaiting_splash = false
	_pending_post_explosion_event = ""
	if fsm == null:
		_start_fsm()
	set_process(true)


func refresh_session_account(account: PDataAccount) -> void:
	if not account:
		return
	_account = account
	if not _session_ready:
		return
	session.ensure_card_deck_for_game_time(account.get_game_time_minutes())


func set_paused(paused: bool) -> void:
	_paused = paused


func resync_players_from_account(account: PDataAccount) -> void:
	if not _session_ready or not account or session.is_overtime:
		return
	session.resync_players_from_account(account)


func resync_players_from_entries(entries: Array) -> void:
	if not _session_ready or session.is_overtime:
		return
	var roster_account := PDataAccount.new()
	roster_account.set_players(entries.duplicate(true))
	session.resync_players_from_account(roster_account)


func _collect_states() -> void:
	if not states.is_empty():
		return
	for child in get_children():
		if child is StateBase:
			states.append(child)


func _start_fsm() -> void:
	for state in states:
		if state.state_name.is_empty():
			var state_script := state.get_script() as GDScript
			if state_script:
				state.state_name = state_script.call_static("get_state")
		state.initialize(self)

	fsm = FSM.new({
		"initial": {"state": FSMGameStates.PLAYER_CHOICE},
		"transitions": [
			{
				"src": FSMGameStates.PLAYER_CHOICE,
				"dst": FSMGameStates.READY_TO_START,
				"event": FSMGameEvents.PLAYER_CHOICE_DONE,
			},
			{
				"src": FSMGameStates.READY_TO_START,
				"dst": FSMGameStates.COUNTDOWN,
				"event": FSMGameEvents.START_ROUND,
			},
			{
				"src": FSMGameStates.COUNTDOWN,
				"dst": FSMGameStates.PLAY,
				"event": FSMGameEvents.COUNTDOWN_DONE,
			},
			{
				"src": FSMGameStates.PLAY,
				"dst": FSMGameStates.EMERGENCY,
				"event": FSMGameEvents.ENTER_EMERGENCY,
			},
			{
				"src": FSMGameStates.EMERGENCY,
				"dst": FSMGameStates.PLAY,
				"event": FSMGameEvents.EMERGENCY_CONTINUE,
			},
			{
				"src": FSMGameStates.PLAY,
				"dst": FSMGameStates.EXPLOSION,
				"event": FSMGameEvents.EXPLODE,
			},
			{
				"src": FSMGameStates.EXPLOSION,
				"dst": FSMGameStates.READY_TO_START,
				"event": FSMGameEvents.EXPLOSION_DONE,
			},
			{
				"src": FSMGameStates.EXPLOSION,
				"dst": FSMGameStates.RESULT,
				"event": FSMGameEvents.MATCH_END,
			},
		],
		"states": states,
	})
	fsm.ev_state_changed.connect(_on_state_changed)


func _process(delta: float) -> void:
	_update_editor_clock_overlay()
	if not _session_ready or fsm == null or _paused:
		return

	var state_name := fsm.get_current_state_name()
	match state_name:
		FSMGameStates.PLAYER_CHOICE:
			_process_player_choice(delta)
		FSMGameStates.COUNTDOWN:
			_process_countdown(delta)
		FSMGameStates.PLAY:
			_process_play(delta)
		FSMGameStates.EXPLOSION:
			_process_explosion(delta)


func apply_tutorial_deck(entries: Array) -> void:
	if not _session_ready:
		return
	session.apply_tutorial_deck(entries)
	session.set_current_player_index(OnboardingTutorialData.FIRST_PLAYER_INDEX)


func force_finish_player_choice() -> void:
	if fsm == null or fsm.get_current_state_name() != FSMGameStates.PLAYER_CHOICE:
		return
	session.set_current_player_index(OnboardingTutorialData.FIRST_PLAYER_INDEX)
	session.state_time = session.game_config.player_choice_time + 1.0


func force_enter_play_from_countdown() -> void:
	if fsm == null or fsm.get_current_state_name() != FSMGameStates.COUNTDOWN:
		return
	session.state_time = session.game_config.countdown_time + 1.0


func force_finish_explosion() -> void:
	if fsm == null or fsm.get_current_state_name() != FSMGameStates.EXPLOSION:
		return
	session.explosion_is_countdown = true
	_on_explosion_finished()


func force_tutorial_explosion_at(player_index: int) -> void:
	if fsm == null:
		return
	var state_name := fsm.get_current_state_name()
	if state_name == FSMGameStates.COUNTDOWN:
		force_enter_play_from_countdown()
		call_deferred("_deferred_tutorial_explosion_at", player_index)
		return
	if state_name != FSMGameStates.PLAY:
		return
	_apply_tutorial_explosion_at(player_index)


func force_tutorial_explosion() -> void:
	if session == null:
		return
	force_tutorial_explosion_at(session.current_player_index)


func _deferred_tutorial_explosion_at(player_index: int) -> void:
	if fsm == null or fsm.get_current_state_name() != FSMGameStates.PLAY:
		return
	_apply_tutorial_explosion_at(player_index)


func _apply_tutorial_explosion_at(player_index: int) -> void:
	if session.bomb_is_exploded:
		return
	session.set_current_player_index(player_index)
	session.bomb_is_exploded = true
	if not session.is_tutorial:
		session.get_current_player().on_explosion()
	fsm.add_event(FSMGameEvents.EXPLODE)


func start_round() -> void:
	if _account:
		session.ensure_card_deck_for_game_time(_account.get_game_time_minutes())
	session.reset_round()
	fsm.add_event(FSMGameEvents.START_ROUND)


func next_player() -> void:
	session.next_player()
	if session.is_tutorial:
		_try_tutorial_landing_explosion()


func enter_emergency() -> void:
	if fsm == null or fsm.get_current_state_name() != FSMGameStates.PLAY:
		return
	set_paused(true)
	fsm.add_event(FSMGameEvents.ENTER_EMERGENCY)


func continue_emergency(player_index: int) -> void:
	if fsm == null or fsm.get_current_state_name() != FSMGameStates.EMERGENCY:
		return
	fsm.add_event(FSMGameEvents.EMERGENCY_CONTINUE)
	set_paused(false)
	if session.is_tutorial:
		call_deferred("_deferred_tutorial_scripted_explosion")
		return
	if player_index < 0 or player_index >= session.players.size():
		player_index = session.current_player_index
	elif not session.players[player_index].is_active:
		player_index = session.current_player_index
	session.set_current_player_index(player_index)
	session.try_add_bonus_bomb_time()
	if session.bomb_is_alerted and game_events:
		game_events.ev_alert.emit()


func _process_player_choice(delta: float) -> void:
	session.advance_time(delta)
	var index := session.get_player_choice_index()
	if index != session.current_player_index:
		session.set_current_player_index(index)
		if game_events:
			game_events.ev_player_choice_tick_changed.emit()
	if session.state_time > session.game_config.player_choice_time:
		fsm.add_event(FSMGameEvents.PLAYER_CHOICE_DONE)


func _process_countdown(delta: float) -> void:
	session.advance_time(delta)
	session.advance_match_clock(delta)
	session.tick_countdown()
	if session.state_time >= session.game_config.countdown_time:
		session.reset_bomb()
		session.reset_explosion()
		if session.current_card == null:
			session.next_card()
		fsm.add_event(FSMGameEvents.COUNTDOWN_DONE)


func _process_play(delta: float) -> void:
	session.advance_match_clock(delta)
	if session.update_bomb(delta):
		fsm.add_event(FSMGameEvents.EXPLODE)


func _process_explosion(delta: float) -> void:
	if _awaiting_splash:
		return
	if session.update_explosion(delta):
		_on_explosion_finished()


func _on_explosion_finished() -> void:
	if _awaiting_splash:
		return
	if session.is_tutorial:
		_finish_tutorial_explosion()
		return
	if session.is_overtime:
		_finish_overtime_explosion()
		return
	session.note_regulation_boom()
	if session.is_regulation_time_up():
		if session.has_unique_leader():
			fsm.add_event(FSMGameEvents.MATCH_END)
			return
		session.enter_overtime()
		session.ensure_overtime_card()
		session.next_player()
		session.reset_round()
		_queue_post_explosion(FSMGameEvents.EXPLOSION_DONE, GameSession.SPLASH_OVERTIME, null)
		return
	if session.next_card():
		session.next_player()
		session.reset_round()
		fsm.add_event(FSMGameEvents.EXPLOSION_DONE)
		return
	fsm.add_event(FSMGameEvents.MATCH_END)


func _finish_tutorial_explosion() -> void:
	if session.next_card():
		session.next_player()
		session.reset_round()
		fsm.add_event(FSMGameEvents.EXPLOSION_DONE)
	else:
		session.apply_tutorial_final_scores()
		fsm.add_event(FSMGameEvents.MATCH_END)


func _finish_overtime_explosion() -> void:
	var exploded := session.get_current_player()
	session.eliminate_player(exploded)
	if session.active_count() <= 1:
		_queue_post_explosion(FSMGameEvents.MATCH_END, GameSession.SPLASH_ELIMINATED, exploded)
		return
	session.ensure_overtime_card()
	session.next_player()
	session.reset_round()
	_queue_post_explosion(FSMGameEvents.EXPLOSION_DONE, GameSession.SPLASH_ELIMINATED, exploded)


func _queue_post_explosion(event: String, splash_kind: String, player: GamePlayer) -> void:
	_pending_post_explosion_event = event
	if splash_kind.is_empty() or game_events == null:
		_emit_pending_post_explosion()
		return
	_awaiting_splash = true
	game_events.ev_battle_splash.emit(splash_kind, player)


func finish_battle_splash() -> void:
	if not _awaiting_splash:
		return
	_awaiting_splash = false
	_emit_pending_post_explosion()


func is_awaiting_battle_splash() -> bool:
	return _awaiting_splash


func _emit_pending_post_explosion() -> void:
	var event := _pending_post_explosion_event
	_pending_post_explosion_event = ""
	if event.is_empty() or fsm == null:
		return
	fsm.add_event(event)


func _get_tutorial_round_index() -> int:
	if session.current_card != null:
		return OnboardingTutorialData.round_index_for_card(session.current_card)
	var played := session.match_cards_total - session.cards.size()
	return clampi(played - 1, 0, OnboardingTutorialData.ROUND_COUNT - 1)


func _try_tutorial_landing_explosion() -> void:
	if fsm == null or fsm.get_current_state_name() != FSMGameStates.PLAY:
		return
	if session.bomb_is_exploded:
		return
	var explode_idx := OnboardingTutorialData.explode_player_index(_get_tutorial_round_index())
	if session.current_player_index == explode_idx:
		_apply_tutorial_explosion_at(explode_idx)


func _deferred_tutorial_scripted_explosion() -> void:
	if fsm == null or fsm.get_current_state_name() != FSMGameStates.PLAY:
		return
	var explode_idx := OnboardingTutorialData.explode_player_index(_get_tutorial_round_index())
	_apply_tutorial_explosion_at(explode_idx)


func _on_state_changed(from_state_name: String, to_state_name: String) -> void:
	if game_events:
		game_events.ev_game_state_changed.emit(from_state_name, to_state_name)
	_update_editor_clock_overlay()


func _setup_editor_clock_overlay() -> void:
	if not OS.has_feature("editor"):
		return
	if _debug_clock_label:
		return
	var layer := CanvasLayer.new()
	layer.layer = 128
	add_child(layer)
	_debug_clock_label = Label.new()
	_debug_clock_label.position = Vector2(12, 12)
	_debug_clock_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_debug_clock_label.add_theme_font_size_override("font_size", 18)
	_debug_clock_label.add_theme_color_override("font_color", Color(0.75, 1.0, 0.55, 1.0))
	_debug_clock_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.02, 0.9))
	_debug_clock_label.add_theme_constant_override("outline_size", 4)
	layer.add_child(_debug_clock_label)
	set_process(true)


func _update_editor_clock_overlay() -> void:
	if _debug_clock_label == null:
		return
	if not _session_ready or fsm == null:
		_debug_clock_label.text = "clock -- / --\nWAIT\nend: session not ready"
		return
	_debug_clock_label.text = session.get_match_clock_debug_text(
		fsm.get_current_state_name(),
		_paused
	)
