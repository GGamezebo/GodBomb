class_name ChairSwapRing
extends Control

const DEFAULT_RING_RADIUS := 52.0
const DEFAULT_RING_COLOR := Color(1.0, 0.82, 0.35, 0.95)

@export var ring_radius: float = DEFAULT_RING_RADIUS
@export var ring_color: Color = DEFAULT_RING_COLOR
@export var dash_count: int = 16
@export var solid: bool = false
@export var line_width: float = 3.5

var visible_ring: bool = false:
	set(value):
		visible_ring = value
		visible = value
		queue_redraw()


static func radius_for_half_extent(half_extent: float, reference_half: float = 50.0) -> float:
	if reference_half <= 0.0:
		return DEFAULT_RING_RADIUS
	return half_extent * (DEFAULT_RING_RADIUS / reference_half)


func set_ring_radius(radius: float) -> void:
	ring_radius = radius
	custom_minimum_size = Vector2(ring_radius * 2.0, ring_radius * 2.0)
	size = custom_minimum_size
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
	if solid:
		draw_arc(center, ring_radius, 0.0, TAU, 64, ring_color, line_width, true)
		return
	for i in dash_count:
		if i % 2 != 0:
			continue
		var a1 := i * TAU / float(dash_count)
		var a2 := (i + 1) * TAU / float(dash_count)
		draw_arc(center, ring_radius, a1, a2, 8, ring_color, 3.5, true)
