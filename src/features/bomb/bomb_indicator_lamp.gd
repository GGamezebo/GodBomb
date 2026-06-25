class_name BombIndicatorLamp
extends Control

const BEZEL_RX := 42.0
const BEZEL_RY := 62.0
const LENS_RADIUS := 22.0

const BEZEL_BASE := Color(0.42, 0.26, 0.14, 1.0)
const BEZEL_MID := Color(0.58, 0.36, 0.2, 1.0)
const BEZEL_HIGH := Color(0.78, 0.52, 0.3, 1.0)
const BEZEL_SHADOW := Color(0.14, 0.08, 0.05, 0.85)
const SOCKET := Color(0.05, 0.04, 0.035, 1.0)
const SCREW := Color(0.11, 0.09, 0.07, 1.0)
const SCREW_HEAD := Color(0.34, 0.29, 0.24, 1.0)

@export var lamp_color: Color = Color(0.92, 0.2, 0.12, 1.0)

var _lit: bool = false
var _alert: bool = false


func _ready() -> void:
	clip_contents = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func set_lit(lit: bool, alert: bool = false) -> void:
	if _lit == lit and _alert == alert:
		return
	_lit = lit
	_alert = alert
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	_draw_mount_shadow(center)
	if _lit:
		_draw_glow(center)
	_draw_bezel(center)
	_draw_screws(center)
	_draw_socket(center)
	_draw_lens(center)


func _draw_mount_shadow(center: Vector2) -> void:
	draw_circle(center + Vector2(0.0, 6.0), BEZEL_RX * 0.92, Color(0.0, 0.0, 0.0, 0.28))


func _draw_glow(center: Vector2) -> void:
	var boost := 1.35 if _alert else 1.0
	for i in 6:
		var t := float(i) / 5.0
		var radius := lerpf(LENS_RADIUS + 6.0, BEZEL_RX + 34.0, t)
		var alpha := lerpf(0.34, 0.0, t) * boost
		draw_circle(center, radius, Color(lamp_color.r, lamp_color.g, lamp_color.b, alpha))


func _draw_bezel(center: Vector2) -> void:
	_draw_filled_ellipse(center + Vector2(0.0, 3.0), BEZEL_RX * 1.02, BEZEL_RY * 1.02, BEZEL_SHADOW)
	_draw_filled_ellipse(center, BEZEL_RX, BEZEL_RY, BEZEL_BASE)
	_draw_filled_ellipse(center + Vector2(-5.0, -7.0), BEZEL_RX * 0.78, BEZEL_RY * 0.72, BEZEL_MID)
	_draw_bezel_rim(center)
	_draw_wire_stub(center)


func _draw_bezel_rim(center: Vector2) -> void:
	var rim_pts := _ellipse_points(center, BEZEL_RX - 2.0, BEZEL_RY - 2.0, 48)
	draw_polyline(rim_pts, Color(0.24, 0.14, 0.08, 0.55), 2.0, true)
	var highlight_pts := _ellipse_arc_points(
		center + Vector2(-4.0, -8.0),
		BEZEL_RX * 0.72,
		BEZEL_RY * 0.62,
		2.1,
		4.0,
		18
	)
	draw_polyline(highlight_pts, Color(BEZEL_HIGH.r, BEZEL_HIGH.g, BEZEL_HIGH.b, 0.72), 3.0)


func _draw_wire_stub(center: Vector2) -> void:
	var base := center + Vector2(0.0, BEZEL_RY - 4.0)
	draw_line(base, base + Vector2(0.0, 10.0), Color(0.12, 0.1, 0.08, 0.85), 4.0)
	draw_line(base + Vector2(0.0, 10.0), base + Vector2(8.0, 18.0), lamp_color.darkened(0.65), 3.0)


func _draw_screws(center: Vector2) -> void:
	var offsets: Array[Vector2] = [
		Vector2(-BEZEL_RX + 10.0, -BEZEL_RY + 14.0),
		Vector2(BEZEL_RX - 10.0, -BEZEL_RY + 14.0),
		Vector2(-BEZEL_RX + 10.0, BEZEL_RY - 18.0),
		Vector2(BEZEL_RX - 10.0, BEZEL_RY - 18.0),
	]
	for offset in offsets:
		var screw_center: Vector2 = center + offset
		draw_circle(screw_center, 5.5, SCREW)
		draw_circle(screw_center, 3.8, SCREW_HEAD)
		draw_line(screw_center + Vector2(-2.5, 0.0), screw_center + Vector2(2.5, 0.0), Color(0.08, 0.07, 0.06, 0.8), 1.2)


func _draw_socket(center: Vector2) -> void:
	draw_circle(center, LENS_RADIUS + 7.0, SOCKET)
	draw_arc(center, LENS_RADIUS + 7.0, 0.0, TAU, 48, Color(0.02, 0.015, 0.01, 0.9), 2.5, true)


func _draw_lens(center: Vector2) -> void:
	if _lit:
		draw_circle(center, LENS_RADIUS + 2.0, Color(lamp_color.r, lamp_color.g, lamp_color.b, 0.28))
		draw_circle(center, LENS_RADIUS, Color(lamp_color.r, lamp_color.g, lamp_color.b, 0.96))
		draw_circle(
			center,
			LENS_RADIUS * 0.72,
			Color(
				minf(lamp_color.r * 1.15, 1.0),
				minf(lamp_color.g * 1.15, 1.0),
				minf(lamp_color.b * 1.15, 1.0),
				0.72
			)
		)
		draw_circle(center + Vector2(-7.0, -9.0), 5.5, Color(1.0, 0.98, 0.92, 0.62))
		draw_circle(center + Vector2(6.0, 8.0), 3.0, Color(lamp_color.r, lamp_color.g, lamp_color.b, 0.35))
	else:
		var dim := Color(lamp_color.r * 0.18, lamp_color.g * 0.18, lamp_color.b * 0.18, 0.72)
		draw_circle(center, LENS_RADIUS, dim)
		draw_circle(center + Vector2(-6.0, -8.0), 4.5, Color(1.0, 1.0, 1.0, 0.08))
		draw_arc(center, LENS_RADIUS, 0.0, TAU, 48, Color(lamp_color.r, lamp_color.g, lamp_color.b, 0.22), 1.5, true)


func _draw_filled_ellipse(center: Vector2, rx: float, ry: float, color: Color) -> void:
	draw_colored_polygon(_ellipse_points(center, rx, ry, 56), color)


func _ellipse_points(center: Vector2, rx: float, ry: float, segments: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.resize(segments)
	for i in segments:
		var angle := float(i) / float(segments) * TAU
		pts[i] = center + Vector2(cos(angle) * rx, sin(angle) * ry)
	return pts


func _ellipse_arc_points(
	center: Vector2,
	rx: float,
	ry: float,
	start: float,
	end: float,
	segments: int
) -> PackedVector2Array:
	var pts := PackedVector2Array()
	pts.resize(segments)
	for i in segments:
		var angle := lerpf(start, end, float(i) / float(segments - 1))
		pts[i] = center + Vector2(cos(angle) * rx, sin(angle) * ry)
	return pts
