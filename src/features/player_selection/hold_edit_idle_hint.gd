class_name HoldEditIdleHint
extends Control

const BADGE_SIZE := Vector2(30, 30)
const RING_COLOR := Color(1.0, 0.82, 0.35, 0.95)

var _pulse: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = BADGE_SIZE
	size = BADGE_SIZE
	visible = false


func set_hint_visible(show_hint: bool) -> void:
	visible = show_hint
	if show_hint:
		_pulse = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if not visible:
		return
	_pulse += delta
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var pulse := 0.88 + sin(_pulse * 3.2) * 0.12
	var radius := 11.0 * pulse
	draw_arc(center, radius + 1.5, 0.0, TAU, 32, Color(1.0, 0.82, 0.35, 0.18), 3.0, true)
	draw_arc(center, radius, -PI * 0.15, PI * 1.05, 24, RING_COLOR, 3.0, true)
	draw_circle(center + Vector2(0.0, 3.0), 2.6, RING_COLOR)
