class_name ChairSwapRing
extends Control

@export var ring_radius: float = 52.0
@export var ring_color: Color = Color(1.0, 0.82, 0.35, 0.95)
@export var dash_count: int = 16

var visible_ring: bool = false:
	set(value):
		visible_ring = value
		visible = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	custom_minimum_size = Vector2(ring_radius * 2.0, ring_radius * 2.0)
	size = custom_minimum_size


func _draw() -> void:
	if not visible_ring:
		return
	var center := size * 0.5
	for i in dash_count:
		if i % 2 != 0:
			continue
		var a1 := i * TAU / float(dash_count)
		var a2 := (i + 1) * TAU / float(dash_count)
		draw_arc(center, ring_radius, a1, a2, 8, ring_color, 3.5, true)
