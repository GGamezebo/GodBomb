class_name BombDialLayout
extends RefCounted

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const GLASS_DESIGN_POSITION := Vector2(138.0, 550.0)
const GLASS_DESIGN_SIZE := Vector2(800.0, 800.0)


static func get_cover_scale(host_size: Vector2) -> float:
	if host_size.x <= 0.0 or host_size.y <= 0.0:
		return 1.0
	return maxf(host_size.x / DESIGN_SIZE.x, host_size.y / DESIGN_SIZE.y)


static func get_cover_offset(host_size: Vector2) -> Vector2:
	var scale_factor := get_cover_scale(host_size)
	return (host_size - DESIGN_SIZE * scale_factor) * 0.5


static func apply_to(glass: Control, host_size: Vector2) -> void:
	if glass == null:
		return
	var scale_factor := get_cover_scale(host_size)
	var offset := get_cover_offset(host_size)
	glass.set_anchors_preset(Control.PRESET_TOP_LEFT)
	glass.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	glass.grow_vertical = Control.GROW_DIRECTION_BEGIN
	glass.scale = Vector2.ONE
	glass.position = offset + GLASS_DESIGN_POSITION * scale_factor
	glass.size = GLASS_DESIGN_SIZE * scale_factor
