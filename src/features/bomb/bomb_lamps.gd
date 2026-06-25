class_name BombLamps
extends Control

const LAMP_SIZE := Vector2(104.0, 148.0)
const LAMP_POSITIONS := [
	Vector2(205.0, 611.0),
	Vector2(875.0, 611.0),
	Vector2(205.0, 1245.0),
	Vector2(875.0, 1245.0),
]
const LAMP_COLORS := [
	Color(0.94, 0.18, 0.12, 1.0),
	Color(0.98, 0.78, 0.16, 1.0),
	Color(0.2, 0.86, 0.38, 1.0),
	Color(0.24, 0.68, 0.96, 1.0),
]

@export var game_events: GameEvents
@export var blink_interval_normal: float = 0.55
@export var blink_interval_alert: float = 0.22

var listener: EventListener = EventListener.new()
var _lamps: Array[BombIndicatorLamp] = []
var _active: bool = false
var _alert: bool = false
var _active_index: int = 0
var _timer: float = 0.0
var _fade_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = false
	z_index = 0
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = MenuBombLayout.DESIGN_SIZE
	_build_lamps()
	if game_events:
		_set_all_off()
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)
	else:
		_show_idle_glow()


func _show_idle_glow() -> void:
	for lamp in _lamps:
		lamp.set_lit(true)


func _exit_tree() -> void:
	listener.deinit()
	_kill_fade_tween()


func _process(delta: float) -> void:
	if not _active or _lamps.is_empty():
		return
	_timer += delta
	var interval := blink_interval_alert if _alert else blink_interval_normal
	if _timer < interval:
		return
	_timer -= interval
	_active_index = (_active_index + 1) % _lamps.size()
	_apply_blink_visuals()


func _build_lamps() -> void:
	for i in LAMP_POSITIONS.size():
		var lamp := BombIndicatorLamp.new()
		lamp.name = "Lamp%d" % i
		lamp.lamp_color = LAMP_COLORS[i]
		lamp.custom_minimum_size = LAMP_SIZE
		lamp.size = LAMP_SIZE
		lamp.position = LAMP_POSITIONS[i] - LAMP_SIZE * 0.5
		add_child(lamp)
		_lamps.append(lamp)


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	match to_state:
		FSMGameStates.PLAY:
			_show_lamps()
			_start_blink(false)
		FSMGameStates.EXPLOSION:
			_play_explosion_hide()
		FSMGameStates.RESULT, FSMGameStates.READY_TO_START, FSMGameStates.PLAYER_CHOICE, FSMGameStates.COUNTDOWN:
			_show_lamps()
			_stop_blink()
		_:
			_show_lamps()
			_stop_blink()


func _on_alert() -> void:
	if _active:
		_alert = true
		_timer = 0.0
		_apply_blink_visuals()


func _start_blink(alert: bool) -> void:
	_active = true
	_alert = alert
	_active_index = 0
	_timer = 0.0
	_apply_blink_visuals()


func _stop_blink() -> void:
	_active = false
	_alert = false
	_active_index = 0
	_timer = 0.0
	_set_all_off()


func _show_lamps() -> void:
	_kill_fade_tween()
	visible = true
	modulate = Color.WHITE


func _play_explosion_hide() -> void:
	_stop_blink()
	_kill_fade_tween()
	if not visible:
		return
	modulate = Color(1.45, 0.42, 0.12, 1.0)
	_fade_tween = create_tween()
	_fade_tween.tween_property(self, "modulate:a", 0.0, 0.14).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_fade_tween.tween_callback(func() -> void:
		visible = false
		modulate = Color.WHITE
	)


func _kill_fade_tween() -> void:
	if _fade_tween:
		_fade_tween.kill()
		_fade_tween = null


func _set_all_off() -> void:
	for lamp in _lamps:
		lamp.set_lit(false)


func _apply_blink_visuals() -> void:
	for i in _lamps.size():
		_lamps[i].set_lit(i == _active_index, _alert)
