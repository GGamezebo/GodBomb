class_name HoldProgressRing
extends Control

const TRACK_COLOR := Color(1.0, 1.0, 1.0, 0.22)
const PROGRESS_COLOR := Color(1.0, 0.82, 0.35, 0.98)
const GLOW_COLOR := Color(1.0, 0.78, 0.28, 0.42)

var progress: float = 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		queue_redraw()

var visible_ring: bool = false:
	set(value):
		visible_ring = value
		visible = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _draw() -> void:
	if not visible_ring:
		return
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.46
	draw_arc(center, radius, 0.0, TAU, 64, TRACK_COLOR, 8.0, true)
	if progress <= 0.001:
		return
	if progress >= 0.75:
		draw_arc(center, radius + 10.0, 0.0, TAU, 64, GLOW_COLOR, 20.0, true)
	var start_angle := -PI * 0.5
	var end_angle := start_angle + TAU * progress
	draw_arc(center, radius, start_angle, end_angle, 64, PROGRESS_COLOR, 10.0, true)
