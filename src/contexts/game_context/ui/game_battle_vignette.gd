class_name GameBattleVignette
extends Control

const ACCENT := TurnOrderArrowsLayer.ACCENT

@export var game_events: GameEvents

var listener: EventListener = EventListener.new()
var _edge_alpha: float = 0.12
var _pulse_boost: float = 0.0
var _target_alpha: float = 0.12
var _alert_active: bool = false
var _explosion_active: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = -1
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)


func _exit_tree() -> void:
	listener.deinit()


func _process(delta: float) -> void:
	_pulse_boost = move_toward(_pulse_boost, 0.0, delta * 2.4)
	var pulse := 0.0
	if _alert_active and not _explosion_active:
		pulse = 0.14 * sin(Time.get_ticks_msec() * 0.012)
	_target_alpha = 0.12 + _pulse_boost + pulse
	if _explosion_active:
		_target_alpha = 0.55 + 0.1 * sin(Time.get_ticks_msec() * 0.02)
	_edge_alpha = move_toward(_edge_alpha, _target_alpha, delta * 8.0)
	queue_redraw()


func _draw() -> void:
	var rect := get_rect()
	var edge := 56.0 + _pulse_boost * 80.0
	var base := ACCENT
	base.a = _edge_alpha
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, edge)), base)
	draw_rect(Rect2(rect.position.x, rect.position.y + rect.size.y - edge, rect.size.x, edge), base)
	draw_rect(Rect2(rect.position, Vector2(edge, rect.size.y)), base)
	draw_rect(Rect2(rect.position.x + rect.size.x - edge, rect.position.y, edge, rect.size.y), base)

	var corner := edge * 1.35
	var corner_color := base
	corner_color.a = _edge_alpha * 1.25
	draw_circle(rect.position + Vector2(corner * 0.55, corner * 0.55), corner * 0.65, corner_color)
	draw_circle(rect.position + Vector2(rect.size.x - corner * 0.55, corner * 0.55), corner * 0.65, corner_color)
	draw_circle(rect.position + Vector2(corner * 0.55, rect.size.y - corner * 0.55), corner * 0.65, corner_color)
	draw_circle(
		rect.position + Vector2(rect.size.x - corner * 0.55, rect.size.y - corner * 0.55),
		corner * 0.65,
		corner_color
	)


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	match to_state:
		FSMGameStates.PLAY:
			_alert_active = false
			_explosion_active = false
			_target_alpha = 0.12
		FSMGameStates.EXPLOSION:
			_explosion_active = true
			_alert_active = false
			_pulse_boost = 0.35
		FSMGameStates.READY_TO_START, FSMGameStates.COUNTDOWN, FSMGameStates.PLAYER_CHOICE:
			_alert_active = false
			_explosion_active = false
			_target_alpha = 0.08
		FSMGameStates.RESULT:
			_explosion_active = false
			_target_alpha = 0.06


func _on_alert() -> void:
	_alert_active = true
	_pulse_boost = 0.28
