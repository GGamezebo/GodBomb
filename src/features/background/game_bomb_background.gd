class_name GameBombBackground
extends MenuBombLayout

@export var game_events: GameEvents
@export var pulse_speed: float = 6.0

var listener: EventListener = EventListener.new()
var _tween: Tween
var _alert_active: bool = false
var _content_base_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	super._ready()
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if scaled_content:
		_content_base_pos = scaled_content.position
	if not layout_applied.is_connected(_on_layout_applied):
		layout_applied.connect(_on_layout_applied)
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)
	_apply_state(FSMGameStates.READY_TO_START)


func _exit_tree() -> void:
	listener.deinit()
	_kill_tween()


func _process(_delta: float) -> void:
	if not _alert_active:
		return
	var pulse := 0.07 * sin(Time.get_ticks_msec() * 0.01 * pulse_speed)
	modulate = Color(1.0 + pulse, 0.82 + pulse * 0.4, 0.62 + pulse * 0.25, 1.0)


func _on_layout_applied() -> void:
	if scaled_content:
		_content_base_pos = scaled_content.position


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	_apply_state(to_state)


func _on_alert() -> void:
	_alert_active = true


func _apply_state(state: String) -> void:
	match state:
		FSMGameStates.READY_TO_START, FSMGameStates.PLAYER_CHOICE, FSMGameStates.COUNTDOWN:
			_alert_active = false
			modulate = Color.WHITE
			_play_ready_pulse()
		FSMGameStates.PLAY:
			_alert_active = false
			modulate = Color.WHITE
			_play_comes_flash()
		FSMGameStates.EXPLOSION:
			_alert_active = false
			_play_explosion()
		FSMGameStates.RESULT:
			_alert_active = false
			modulate = Color(0.94, 0.92, 0.9, 1.0)


func _play_ready_pulse() -> void:
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(self, "modulate", Color(1.04, 1.02, 0.98, 1.0), 0.35).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "modulate", Color.WHITE, 0.35)


func _play_comes_flash() -> void:
	_kill_tween()
	modulate = Color(1, 1, 1, 0.88)
	_tween = create_tween()
	_tween.tween_property(self, "modulate", Color.WHITE, 0.45).set_trans(Tween.TRANS_SINE)


func _play_explosion() -> void:
	_kill_tween()
	modulate = Color(1.45, 0.42, 0.12, 1.0)
	_tween = create_tween()
	if scaled_content:
		var base := _content_base_pos
		for i in 6:
			var offset := Vector2(randf_range(-10, 10), randf_range(-10, 10))
			_tween.tween_property(scaled_content, "position", base + offset, 0.04)
		_tween.tween_property(scaled_content, "position", base, 0.06)
	_tween.parallel().tween_property(self, "modulate", Color(1.15, 0.32, 0.08, 0.75), 0.28)


func _kill_tween() -> void:
	if _tween:
		_tween.kill()
		_tween = null
