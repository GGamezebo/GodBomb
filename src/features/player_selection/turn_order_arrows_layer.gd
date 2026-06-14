class_name TurnOrderArrowsLayer
extends Control

const SEGMENTS := 28
const RING_MARGIN := 42.0
const GAP_ANGLE := 0.42
const STROKE := 5.0
const HIGHLIGHT_STROKE := 2.0

var _table_size: Vector2 = Vector2.ZERO
var _center_button_radius: float = 72.0
var _alpha_scale: float = 0.4
var _pulse_boost: float = 1.0
var _dimmed: bool = false


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
	_alpha_scale = 0.85 if can_start else 0.45
	_pulse_boost = 1.0
	visible = show and not _dimmed
	queue_redraw()


func set_dimmed(dimmed: bool) -> void:
	_dimmed = dimmed
	if _dimmed:
		visible = false
	else:
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
	var radius := (_center_button_radius + RING_MARGIN) * _pulse_boost
	var alpha := clampf(_alpha_scale * _pulse_boost, 0.0, 1.0)
	var shadow := Color(0.12, 0.08, 0.06, alpha * 0.16)
	var track := Color(0.72, 0.68, 0.64, alpha * 0.55)
	var main := Color(0.94, 0.52, 0.3, alpha) if alpha > 0.55 else Color(0.58, 0.55, 0.52, alpha)
	var shine := Color(1.0, 0.78, 0.55, alpha * 0.95)

	# Two symmetric clockwise chevrons around the center button; gaps at bottom.
	var arc_span := (TAU - GAP_ANGLE * 2.0) * 0.5
	var arc_a_start := PI * 0.5 + GAP_ANGLE
	var arc_a_end := arc_a_start + arc_span
	var arc_b_start := arc_a_end + GAP_ANGLE
	var arc_b_end := arc_b_start + arc_span

	_draw_modern_arc(center, radius + 2.0, arc_a_start, arc_a_end, shadow, STROKE + 2.0, false)
	_draw_modern_arc(center, radius + 2.0, arc_b_start, arc_b_end, shadow, STROKE + 2.0, false)
	_draw_modern_arc(center, radius, arc_a_start, arc_a_end, track, STROKE + 1.0, false)
	_draw_modern_arc(center, radius, arc_b_start, arc_b_end, track, STROKE + 1.0, false)
	_draw_modern_arc(center, radius, arc_a_start, arc_a_end, main, STROKE, true)
	_draw_modern_arc(center, radius, arc_b_start, arc_b_end, main, STROKE, true)
	_draw_modern_arc(center, radius - 1.5, arc_a_start, arc_a_end, shine, HIGHLIGHT_STROKE, false)
	_draw_modern_arc(center, radius - 1.5, arc_b_start, arc_b_end, shine, HIGHLIGHT_STROKE, false)


func _draw_modern_arc(
	center: Vector2,
	radius: float,
	angle_from: float,
	angle_to: float,
	color: Color,
	width: float,
	with_head: bool
) -> void:
	var points := _arc_points(center, radius, angle_from, angle_to)
	if points.size() < 2:
		return
	draw_polyline(points, color, width, true)
	if with_head:
		var tip_dir := (points[-1] - points[-2]).normalized()
		_draw_chevron_head(points[-1], tip_dir, color, width)


func _arc_points(center: Vector2, radius: float, angle_from: float, angle_to: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.resize(SEGMENTS + 1)
	for step in SEGMENTS + 1:
		var t := float(step) / float(SEGMENTS)
		var angle := lerpf(angle_from, angle_to, t)
		points[step] = center + Vector2(cos(angle), sin(angle)) * radius
	return points


func _draw_chevron_head(tip: Vector2, direction: Vector2, color: Color, width: float) -> void:
	if direction.length_squared() < 0.001:
		return
	var size := 10.0 + width * 1.6
	var depth := 14.0 + width * 1.2
	var ortho := direction.orthogonal()
	var base := tip - direction * depth
	var wing := ortho * size
	var notch := base - direction * (depth * 0.42)
	draw_colored_polygon(PackedVector2Array([tip, base + wing, notch, base - wing]), color)
