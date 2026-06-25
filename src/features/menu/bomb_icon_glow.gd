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


func _process(delta: float) -> void:
	if not _glow_enabled:
		return
	_phase += delta
	queue_redraw()


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


func _draw() -> void:
	if not _glow_enabled:
		return
	var geo := _bezel_geometry()
	var tint := glow_tint
	if alert_glow:
		tint = Color(0.95, 0.42, 0.28, 1.0)
	var pulse := 0.5 + 0.5 * sin(_phase * TAU / PULSE_PERIOD)
	var alpha := BASE_GLOW_ALPHA + pulse * PULSE_GLOW_ALPHA + _hover_boost + _extra_boost
	if alert_glow:
		alpha += 0.05
	var ring_color := Color(tint.r, tint.g, tint.b, alpha)
	draw_polyline(_ellipse_points(geo.center, geo.rx, geo.ry), ring_color, LINE_WIDTH, true)
	var outer_color := Color(tint.r, tint.g, tint.b, alpha * 0.38)
	draw_polyline(
		_ellipse_points(geo.center, geo.rx + OUTER_GAP, geo.ry + OUTER_GAP * 0.85),
		outer_color,
		OUTER_LINE_WIDTH,
		true
	)
