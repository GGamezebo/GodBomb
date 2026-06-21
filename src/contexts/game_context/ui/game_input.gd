extends Control

const DEFAULT_GAME_CONFIG := preload("res://src/common/game_config_default.tres")
const PASS_RELEASE_WINDOW_SEC := 0.3
const MOUSE_TOUCH_INDEX := -1

@export var game_manager: GameManager
@export var game_events: GameEvents
@export var main_events: MainEvents
@export var game_config: GameConfig
@export var game_battle_chrome: GameBattleChrome
@export var start_round_button: BaseButton

var listener: EventListener = EventListener.new()
var _active_touches: Dictionary = {}
var _gesture_fingers: Dictionary = {}
var _gesture_started_at: float = -1.0
var _gesture_expired: bool = false
var _gesture_id: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_game_config()
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if start_round_button:
		start_round_button.pressed.connect(_on_start_round_pressed)
		UiSounds.bind_button(start_round_button, &"confirm")
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
	_sync_to_current_state()


func _exit_tree() -> void:
	listener.deinit()
	if start_round_button is StartActionButton:
		(start_round_button as StartActionButton).set_pulse_active(false)


func _on_start_round_pressed() -> void:
	if game_manager:
		game_manager.start_round()


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	if to_state != FSMGameStates.PLAY:
		_reset_gesture_state()
	if not start_round_button:
		return
	var ready := to_state == FSMGameStates.READY_TO_START
	start_round_button.visible = ready
	if start_round_button is StartActionButton:
		(start_round_button as StartActionButton).set_pulse_active(ready)


func _sync_to_current_state() -> void:
	if not game_manager or not game_manager.fsm:
		return
	_on_game_state_changed("", game_manager.fsm.get_current_state_name())


func _ensure_game_config() -> GameConfig:
	if game_config:
		return game_config
	if game_manager and game_manager.session.game_config:
		game_config = game_manager.session.game_config
		return game_config
	game_config = DEFAULT_GAME_CONFIG.duplicate(true)
	return game_config


func _input(event: InputEvent) -> void:
	if not game_manager:
		return

	var state := game_manager.fsm.get_current_state_name()
	if state == FSMGameStates.PLAY:
		_handle_play_input(event)
	elif state == FSMGameStates.RESULT:
		_handle_result_input(event)


func _handle_play_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_on_finger_pressed(touch.index, touch.position)
		else:
			_on_finger_released(touch.index, touch.position)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		_on_finger_moved(drag.index, drag.position)
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_on_finger_pressed(MOUSE_TOUCH_INDEX, mouse.position)
		else:
			_on_finger_released(MOUSE_TOUCH_INDEX, mouse.position)
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if motion.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_on_finger_moved(MOUSE_TOUCH_INDEX, motion.position)


func _on_finger_pressed(index: int, position: Vector2) -> void:
	if _is_pass_blocked_at(position):
		return
	if _active_touches.is_empty():
		_begin_gesture()
	var finger := {"start": position, "end": position}
	_active_touches[index] = finger
	_gesture_fingers[index] = finger


func _on_finger_moved(index: int, position: Vector2) -> void:
	if not _active_touches.has(index):
		return
	_active_touches[index]["end"] = position
	_gesture_fingers[index]["end"] = position


func _on_finger_released(index: int, position: Vector2) -> void:
	if not _active_touches.has(index):
		return
	_on_finger_moved(index, position)
	_active_touches.erase(index)
	if _active_touches.is_empty():
		_finalize_gesture()


func _begin_gesture() -> void:
	_gesture_id += 1
	var gesture_id := _gesture_id
	_gesture_fingers.clear()
	_gesture_started_at = Time.get_ticks_msec() / 1000.0
	_gesture_expired = false
	get_tree().create_timer(PASS_RELEASE_WINDOW_SEC).timeout.connect(
		func() -> void: _on_pass_window_timeout(gesture_id),
		CONNECT_ONE_SHOT
	)


func _finalize_gesture() -> void:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _gesture_started_at
	var valid := not _gesture_expired and elapsed <= PASS_RELEASE_WINDOW_SEC
	if valid:
		_apply_gesture_result()
	_reset_gesture_state()


func _apply_gesture_result() -> void:
	if _gesture_fingers.is_empty():
		return
	if _gesture_started_on_blocked_ui():
		return
	game_manager.next_player()
	if game_events:
		game_events.ev_touch_next_player.emit(_gesture_touch_centroid())


func _is_pass_blocked_at(position: Vector2) -> bool:
	if game_battle_chrome and game_battle_chrome.is_pass_blocked_at(position):
		return true
	if start_round_button and start_round_button.visible:
		return start_round_button.get_global_rect().has_point(position)
	return false


func _gesture_started_on_blocked_ui() -> bool:
	for finger in _gesture_fingers.values():
		if _is_pass_blocked_at(Vector2(finger["start"])):
			return true
	return false


func _gesture_touch_centroid() -> Vector2:
	var sum := Vector2.ZERO
	for finger in _gesture_fingers.values():
		sum += Vector2(finger["end"])
	return sum / float(_gesture_fingers.size())


func _on_pass_window_timeout(gesture_id: int) -> void:
	if gesture_id != _gesture_id:
		return
	if not _active_touches.is_empty():
		_gesture_expired = true


func _reset_gesture_state() -> void:
	_active_touches.clear()
	_gesture_fingers.clear()
	_gesture_started_at = -1.0
	_gesture_expired = false


func _handle_result_input(event: InputEvent) -> void:
	var released := false
	if event is InputEventScreenTouch:
		released = not (event as InputEventScreenTouch).pressed
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		released = mouse.button_index == MOUSE_BUTTON_LEFT and not mouse.pressed

	if released and main_events:
		main_events.ev_return_to_menu.emit()
