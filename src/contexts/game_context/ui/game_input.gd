extends Control

const DEFAULT_GAME_CONFIG := preload("res://src/common/game_config_default.tres")

@export var game_manager: GameManager
@export var game_events: GameEvents
@export var main_events: MainEvents
@export var game_config: GameConfig
@export var start_round_button: BaseButton

var listener: EventListener = EventListener.new()
var touch_start_position: Vector2 = Vector2.ZERO


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


func _drag_prev_player_threshold() -> float:
	return _ensure_game_config().drag_prev_player_threshold


func _input(event: InputEvent) -> void:
	if not game_manager:
		return

	var state := game_manager.fsm.get_current_state_name()
	if state == FSMGameStates.PLAY:
		_handle_play_input(event)
	elif state == FSMGameStates.RESULT:
		_handle_result_input(event)


func _handle_play_input(event: InputEvent) -> void:
	var drag_threshold := _drag_prev_player_threshold()
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			touch_start_position = touch.position
		elif touch.position.distance_to(touch_start_position) > drag_threshold:
			if game_manager.prev_player() and game_events:
				game_events.ev_touch_prev_player.emit()
		else:
			game_manager.next_player()
			if game_events:
				game_events.ev_touch_next_player.emit(touch.position)
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			touch_start_position = mouse.position
		elif mouse.position.distance_to(touch_start_position) > drag_threshold:
			if game_manager.prev_player() and game_events:
				game_events.ev_touch_prev_player.emit()
		else:
			game_manager.next_player()
			if game_events:
				game_events.ev_touch_next_player.emit(mouse.position)


func _handle_result_input(event: InputEvent) -> void:
	var released := false
	if event is InputEventScreenTouch:
		released = not (event as InputEventScreenTouch).pressed
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		released = mouse.button_index == MOUSE_BUTTON_LEFT and not mouse.pressed

	if released and main_events:
		main_events.ev_return_to_menu.emit()
