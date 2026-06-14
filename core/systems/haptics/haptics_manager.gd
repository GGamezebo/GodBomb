extends Node

const DURATION_AMBIENT := 14
const DURATION_ALERT := 40
const DURATION_TAP := 90
const DURATION_SWIPE := 90
const DURATION_EXPLOSION := 380

const INTERVAL_AMBIENT := 2.8
const INTERVAL_ALERT_MAX := 1.15
const INTERVAL_ALERT_MIN := 0.52

@export var game_events: GameEvents
@export var game_manager: GameManager
@export var account: PDataAccount

var listener: EventListener = EventListener.new()
var _play_tick_timer: float = 0.0
var _in_play: bool = false


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)
		listener.add(game_events.ev_touch_prev_player, _on_touch_prev_player)
	set_process(false)


func _exit_tree() -> void:
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
		var time_left := session.bomb_alive_time - session.bomb_duration
		var alert_window := session.game_config.alert_bomb_time
		var urgency := 1.0 - clampf(time_left / maxf(alert_window, 0.001), 0.0, 1.0)
		var interval := lerpf(INTERVAL_ALERT_MAX, INTERVAL_ALERT_MIN, urgency)
		_vibrate(DURATION_ALERT)
		_play_tick_timer = interval
	else:
		_vibrate(DURATION_AMBIENT)
		_play_tick_timer = INTERVAL_AMBIENT


func _on_game_state_changed(from_state: String, to_state: String) -> void:
	match to_state:
		FSMGameStates.PLAY:
			_in_play = true
			_play_tick_timer = INTERVAL_AMBIENT * 0.55
			set_process(true)
		FSMGameStates.EXPLOSION:
			_in_play = false
			set_process(false)
			_vibrate(DURATION_EXPLOSION)
		FSMGameStates.READY_TO_START, FSMGameStates.RESULT, FSMGameStates.PLAYER_CHOICE, FSMGameStates.COUNTDOWN:
			_in_play = false
			set_process(false)

	if from_state == FSMGameStates.READY_TO_START and to_state == FSMGameStates.COUNTDOWN:
		_vibrate(DURATION_TAP)


func _on_alert() -> void:
	if not _in_play:
		return
	_vibrate(DURATION_ALERT)
	_play_tick_timer = minf(_play_tick_timer, 0.25)


func _on_touch_prev_player() -> void:
	if game_manager == null or game_manager.fsm == null:
		return
	if game_manager.fsm.get_current_state_name() != FSMGameStates.PLAY:
		return
	_vibrate(DURATION_SWIPE)


func _vibrate(duration_ms: int) -> void:
	Haptics.vibrate(duration_ms, account)
