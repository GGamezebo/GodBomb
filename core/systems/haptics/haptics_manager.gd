extends Node

const INTERVAL_AMBIENT := 3.0
const INTERVAL_ALERT := 1.0

const EXPLOSION_FADE_SEC := 3.0
const EXPLOSION_PULSE_COUNT := 18
const EXPLOSION_DURATION_MAX := 175
const EXPLOSION_DURATION_MIN := 12

@export var game_events: GameEvents
@export var game_manager: GameManager
@export var account: PDataAccount

var listener: EventListener = EventListener.new()
var _play_tick_timer: float = 0.0
var _in_play: bool = false
var _explosion_tween: Tween
var _battle_start_tween: Tween


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)
		listener.add(game_events.ev_touch_next_player, _on_touch_pass)
		listener.add(game_events.ev_touch_prev_player, _on_touch_pass)
	set_process(false)


func _exit_tree() -> void:
	_cancel_explosion_fade()
	_cancel_battle_start_haptic()
	listener.deinit()


func _process(delta: float) -> void:
	if not _in_play or game_manager == null or game_manager.fsm == null:
		return
	if game_manager.fsm.get_current_state_name() != FSMGameStates.PLAY:
		return

	_play_tick_timer -= delta
	if _play_tick_timer > 0.0:
		return

	var session := game_manager.session
	if session.bomb_is_alerted:
		Haptics.vibrate_alert_tick(account)
		_play_tick_timer = INTERVAL_ALERT
	else:
		Haptics.vibrate_ambient(account)
		_play_tick_timer = INTERVAL_AMBIENT


func _on_game_state_changed(from_state: String, to_state: String) -> void:
	if from_state == FSMGameStates.COUNTDOWN and to_state == FSMGameStates.PLAY:
		_play_battle_start_haptic()

	match to_state:
		FSMGameStates.PLAY:
			_cancel_explosion_fade()
			_in_play = true
			_play_tick_timer = INTERVAL_AMBIENT * 0.4
			set_process(true)
		FSMGameStates.EXPLOSION:
			_in_play = false
			set_process(false)
			_play_explosion_fade()
		FSMGameStates.READY_TO_START, FSMGameStates.RESULT, FSMGameStates.PLAYER_CHOICE, FSMGameStates.COUNTDOWN:
			_cancel_explosion_fade()
			_cancel_battle_start_haptic()
			_in_play = false
			set_process(false)


func _on_alert() -> void:
	if not _in_play:
		return
	Haptics.vibrate_alert_tick(account)
	_play_tick_timer = INTERVAL_ALERT


func _on_touch_pass() -> void:
	if game_manager == null or game_manager.fsm == null:
		return
	if game_manager.fsm.get_current_state_name() != FSMGameStates.PLAY:
		return
	Haptics.vibrate_strong(account)


func _play_explosion_fade() -> void:
	_cancel_explosion_fade()
	var gap := EXPLOSION_FADE_SEC / float(maxi(EXPLOSION_PULSE_COUNT - 1, 1))
	_explosion_tween = create_tween()
	for i in EXPLOSION_PULSE_COUNT:
		var t := float(i) / float(maxi(EXPLOSION_PULSE_COUNT - 1, 1))
		var fade := t * t
		var duration := int(lerpf(float(EXPLOSION_DURATION_MAX), float(EXPLOSION_DURATION_MIN), fade))
		_explosion_tween.tween_callback(Haptics.vibrate.bind(duration, account))
		if i < EXPLOSION_PULSE_COUNT - 1:
			_explosion_tween.tween_interval(gap)


func _play_battle_start_haptic() -> void:
	_cancel_battle_start_haptic()
	_battle_start_tween = create_tween()
	_battle_start_tween.tween_callback(Haptics.vibrate_battle_start.bind(account))
	_battle_start_tween.tween_interval(0.14)
	_battle_start_tween.tween_callback(Haptics.vibrate_strong.bind(account))


func _cancel_battle_start_haptic() -> void:
	if _battle_start_tween:
		_battle_start_tween.kill()
		_battle_start_tween = null


func _cancel_explosion_fade() -> void:
	if _explosion_tween:
		_explosion_tween.kill()
		_explosion_tween = null
