class_name BombIconGlow
extends Control

enum ShapeProfile { TOP_BAR_120, TABLE_144 }

const PULSE_PERIOD := 2.6
const BASE_GLOW_ALPHA := 0.2
const PULSE_GLOW_ALPHA := 0.32
const GLOW_SCALE := 1.09
const LINE_WIDTH := 5.5
const OUTER_LINE_WIDTH := 2.5
const OUTER_GAP := 5.0

const ALERT_IDLE_ALPHA := 0.2
const ALERT_IDLE_PULSE := 0.055
const ALERT_IDLE_PERIOD := 4.2
const ALERT_FILL_ALPHA := 0.1
const ALERT_SPARKLE_PEAK := 0.42
const ALERT_SPARKLE_FILL := 0.16
const ALERT_SPARKLE_DURATION := 1.15
const ALERT_GAP_MIN := 3.6
const ALERT_GAP_MAX := 6.8
const ALERT_FIRST_GAP_MAX := 1.8

const CENTER_Y_120 := 58.0 / 120.0
const RX_120 := 54.0 / 120.0
const RY_120 := 50.0 / 120.0
const CENTER_Y_144 := 70.0 / 144.0
const RX_144 := 62.0 / 144.0
const RY_144 := 56.0 / 144.0

@export var shape_profile: ShapeProfile = ShapeProfile.TOP_BAR_120
@export var glow_tint: Color = Color(0.92, 0.58, 0.28, 1.0)
@export var alert_glow: bool = false

var _glow_enabled := true
var _hover_boost := 0.0
var _extra_boost := 0.0
var _phase := 0.0
var _alert_was_on := false
var _alert_next_in := -1.0
var _alert_sparkle_t := -1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(_glow_enabled)


func set_glow_enabled(enabled: bool) -> void:
	_glow_enabled = enabled
	visible = enabled
	set_process(enabled)
	queue_redraw()


func set_hover_boost(boost: float) -> void:
	_hover_boost = boost
	queue_redraw()


func set_extra_boost(boost: float) -> void:
	_extra_boost = boost
	queue_redraw()


func get_alert_sparkle_amount() -> float:
	return _alert_sparkle_amount() if alert_glow else 0.0


func _process(delta: float) -> void:
	if not _glow_enabled:
		return
	_phase += delta
	if alert_glow:
		_update_alert_sparkle(delta)
	elif _alert_was_on:
		_reset_alert_sparkle()
	_alert_was_on = alert_glow
	queue_redraw()


func _reset_alert_sparkle() -> void:
	_alert_next_in = -1.0
	_alert_sparkle_t = -1.0


func _update_alert_sparkle(delta: float) -> void:
	if not _alert_was_on:
		_alert_sparkle_t = -1.0
		_alert_next_in = randf_range(0.45, ALERT_FIRST_GAP_MAX)
	if _alert_sparkle_t >= 0.0:
		_alert_sparkle_t += delta
		if _alert_sparkle_t >= ALERT_SPARKLE_DURATION:
			_alert_sparkle_t = -1.0
			_alert_next_in = randf_range(ALERT_GAP_MIN, ALERT_GAP_MAX)
		return
	_alert_next_in -= delta
	if _alert_next_in <= 0.0:
		_alert_sparkle_t = 0.0


func _alert_sparkle_amount() -> float:
	if _alert_sparkle_t < 0.0:
		return 0.0
	var t := clampf(_alert_sparkle_t / ALERT_SPARKLE_DURATION, 0.0, 1.0)
	var envelope := sin(PI * t)
	return envelope * envelope


func _bezel_geometry() -> Dictionary:
	var min_dim := minf(size.x, size.y)
	match shape_profile:
		ShapeProfile.TABLE_144:
			return {
				"center": Vector2(size.x * 0.5, size.y * CENTER_Y_144),
				"rx": min_dim * RX_144 * GLOW_SCALE,
				"ry": min_dim * RY_144 * GLOW_SCALE,
			}
		_:
			return {
				"center": Vector2(size.x * 0.5, size.y * CENTER_Y_120),
				"rx": min_dim * RX_120 * GLOW_SCALE,
				"ry": min_dim * RY_120 * GLOW_SCALE,
			}


func _ellipse_points(center: Vector2, rx: float, ry: float, segments: int = 72) -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.resize(segments + 1)
	for i in segments + 1:
		var angle := float(i) / float(segments) * TAU
		pts[i] = center + Vector2(cos(angle) * rx, sin(angle) * ry)
	return pts


func _ellipse_arc_points(
	center: Vector2, rx: float, ry: float, start_angle: float, end_angle: float, segments: int = 28
) -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.resize(segments + 1)
	for i in segments + 1:
		var t := float(i) / float(segments)
		var angle := lerpf(start_angle, end_angle, t)
		pts[i] = center + Vector2(cos(angle) * rx, sin(angle) * ry)
	return pts


func _draw() -> void:
	if not _glow_enabled:
		return
	var geo := _bezel_geometry()
	var tint := glow_tint
	var alpha: float
	var sparkle := 0.0
	if alert_glow:
		tint = Color(1.0, 0.46, 0.3, 1.0)
		sparkle = _alert_sparkle_amount()
		var idle := 0.5 + 0.5 * sin(_phase * TAU / ALERT_IDLE_PERIOD)
		alpha = (
			ALERT_IDLE_ALPHA
			+ idle * ALERT_IDLE_PULSE
			+ sparkle * ALERT_SPARKLE_PEAK
			+ _hover_boost
			+ _extra_boost
		)
	else:
		var pulse := 0.5 + 0.5 * sin(_phase * TAU / PULSE_PERIOD)
		alpha = BASE_GLOW_ALPHA + pulse * PULSE_GLOW_ALPHA + _hover_boost + _extra_boost
	var rx: float = geo.rx
	var ry: float = geo.ry
	if sparkle > 0.0:
		var swell := 1.0 + sparkle * 0.05
		rx *= swell
		ry *= swell
	if alert_glow:
		var fill_alpha := ALERT_FILL_ALPHA + sparkle * ALERT_SPARKLE_FILL + _hover_boost * 0.35
		var fill := Color(tint.r, tint.g, tint.b, fill_alpha)
		draw_colored_polygon(_ellipse_points(geo.center, rx * 0.92, ry * 0.92, 48), fill)
	var ring_color := Color(tint.r, tint.g, tint.b, alpha)
	draw_polyline(_ellipse_points(geo.center, rx, ry), ring_color, LINE_WIDTH + (1.2 if alert_glow else 0.0), true)
	var outer_color := Color(tint.r, tint.g, tint.b, alpha * (0.38 + sparkle * 0.28))
	draw_polyline(
		_ellipse_points(geo.center, rx + OUTER_GAP, ry + OUTER_GAP * 0.85),
		outer_color,
		OUTER_LINE_WIDTH + (0.6 if alert_glow else 0.0),
		true
	)
	if alert_glow and sparkle > 0.08:
		var glint := Color(1.0, 0.86, 0.72, sparkle * 0.55)
		draw_polyline(
			_ellipse_arc_points(geo.center, rx * 0.78, ry * 0.72, -2.35, -0.75),
			glint,
			2.4,
			true
		)
		var spark_a := Color(1.0, 0.92, 0.82, sparkle * 0.7)
		var spark_b := Color(1.0, 0.78, 0.55, sparkle * 0.45)
		draw_circle(geo.center + Vector2(-rx * 0.42, -ry * 0.38), 2.2 + sparkle * 1.4, spark_a)
		draw_circle(geo.center + Vector2(rx * 0.48, -ry * 0.12), 1.6 + sparkle * 1.0, spark_b)
