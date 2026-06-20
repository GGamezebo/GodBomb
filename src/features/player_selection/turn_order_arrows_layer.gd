class_name TurnOrderArrowsLayer
extends Control

const ACCENT := Color(0.96, 0.28, 0.05, 1.0)
const SEGMENTS := 28
const RING_MARGIN := 24.0
const OUTER_HEAD_EXTENSION := HEAD_LENGTH * 0.55 + STROKE * 0.5
const GAP_ANGLE := 0.42
const STROKE := 6.0
const HEAD_LENGTH := 20.0
const HEAD_WIDTH := 14.0
const TAIL_LENGTH := 7.0
const TAIL_WIDTH := 5.0

var _table_size: Vector2 = Vector2.ZERO
var _center_button_radius: float = 72.0
var _alpha_scale: float = 1.0
var _pulse_boost: float = 1.0
var _drag_alpha: float = 1.0
var _show_arrows: bool = false


static func arc_centerline_radius(center_button_radius: float) -> float:
	return center_button_radius + RING_MARGIN


static func min_clearance_radius(center_button_radius: float) -> float:
	return arc_centerline_radius(center_button_radius) + OUTER_HEAD_EXTENSION + 4.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func update_state(
	table_size: Vector2,
	can_start: bool,
	show: bool,
	center_button_radius: float = 72.0
) -> void:
	_table_size = table_size
	_center_button_radius = center_button_radius
	_alpha_scale = 1.0 if can_start else 0.85
	_pulse_boost = 1.0
	_show_arrows = show
	visible = show
	queue_redraw()


func set_dimmed(dimmed: bool) -> void:
	set_drag_alpha(0.75 if dimmed else 1.0)


func set_drag_alpha(alpha: float) -> void:
	_drag_alpha = clampf(alpha, 0.0, 1.0)
	visible = _show_arrows
	queue_redraw()


func play_start_pulse() -> void:
	if not visible:
		return
	var tween := create_tween()
	_pulse_boost = 1.0
	tween.tween_method(_set_pulse_boost, 1.0, 1.35, 0.18).set_trans(Tween.TRANS_SINE)
	tween.tween_method(_set_pulse_boost, 1.35, 1.0, 0.28).set_trans(Tween.TRANS_SINE)


func _set_pulse_boost(value: float) -> void:
	_pulse_boost = value
	queue_redraw()


func _draw() -> void:
	if not visible or _table_size == Vector2.ZERO:
		return

	var center := _table_size * 0.5
	var radius := arc_centerline_radius(_center_button_radius) * _pulse_boost
	var alpha := clampf(_alpha_scale * _pulse_boost * _drag_alpha, 0.0, 1.0)
	var color := Color(ACCENT.r, ACCENT.g, ACCENT.b, ACCENT.a * alpha)

	var arc_span := (TAU - GAP_ANGLE * 2.0) * 0.5
	var arc_a_start := PI * 0.5 + GAP_ANGLE
	var arc_a_end := arc_a_start + arc_span
	var arc_b_start := arc_a_end + GAP_ANGLE
	var arc_b_end := arc_b_start + arc_span

	_draw_arrow_arc(center, radius, arc_a_start, arc_a_end, color, STROKE)
	_draw_arrow_arc(center, radius, arc_b_start, arc_b_end, color, STROKE)


func _draw_arrow_arc(
	center: Vector2,
	radius: float,
	angle_from: float,
	angle_to: float,
	color: Color,
	width: float
) -> void:
	var points := _arc_points(center, radius, angle_from, angle_to)
	if points.size() < 2:
		return

	var forward_start := (points[1] - points[0]).normalized()
	var forward_end := (points[-1] - points[-2]).normalized()
	var head_trim := HEAD_LENGTH * 0.55
	var tail_trim := TAIL_LENGTH * 0.55
	points[0] = points[0] + forward_start * tail_trim
	points[-1] = points[-1] - forward_end * head_trim

	draw_polyline(points, color, width, true)
	_draw_sharp_tip(points[-1], forward_end, color, HEAD_LENGTH, HEAD_WIDTH)
	_draw_sharp_tip(points[0], -forward_start, color, TAIL_LENGTH, TAIL_WIDTH)


func _arc_points(center: Vector2, radius: float, angle_from: float, angle_to: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.resize(SEGMENTS + 1)
	for step in SEGMENTS + 1:
		var t := float(step) / float(SEGMENTS)
		var angle := lerpf(angle_from, angle_to, t)
		points[step] = center + Vector2(cos(angle), sin(angle)) * radius
	return points


func _draw_sharp_tip(tip: Vector2, direction: Vector2, color: Color, tip_length: float, tip_width: float) -> void:
	if direction.length_squared() < 0.001:
		return
	direction = direction.normalized()
	var ortho := direction.orthogonal()
	var base := tip - direction * tip_length
	draw_colored_polygon(
		PackedVector2Array([
			tip,
			base + ortho * tip_width * 0.5,
			base - ortho * tip_width * 0.5,
		]),
		color
	)
