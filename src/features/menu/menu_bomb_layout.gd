class_name MenuBombLayout
extends TextureRect

const DESIGN_SIZE := Vector2(1080.0, 1920.0)

signal layout_applied

@export var scaled_content: Control
@export var hint_marker: NodePath

var _hint_marker_node: Node2D


func _ready() -> void:
	if scaled_content == null:
		scaled_content = get_node_or_null("ScaledContent") as Control
	if not hint_marker.is_empty():
		_hint_marker_node = get_node_or_null(hint_marker) as Node2D
	elif has_node("ScaledContent/Marker2D"):
		_hint_marker_node = get_node("ScaledContent/Marker2D") as Node2D
	resized.connect(_apply_layout)
	call_deferred("_apply_layout")


func get_hint_marker_design_position() -> Vector2:
	if _hint_marker_node:
		return _hint_marker_node.position
	if scaled_content and scaled_content.has_node("Marker2D"):
		return (scaled_content.get_node("Marker2D") as Node2D).position
	return Vector2(DESIGN_SIZE.x * 0.5, 483.0)


func get_cover_scale() -> float:
	if size.x <= 0.0 or size.y <= 0.0:
		return 1.0
	return maxf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)


func _apply_layout() -> void:
	if not scaled_content:
		return
	var scale_factor := get_cover_scale()
	var scaled_size := DESIGN_SIZE * scale_factor
	var offset := (size - scaled_size) * 0.5
	scaled_content.scale = Vector2.ONE * scale_factor
	scaled_content.position = offset
	scaled_content.size = DESIGN_SIZE
	var dial := get_parent().get_node_or_null("DisplayBomb") as Control
	BombDialLayout.apply_to(dial, size)
	layout_applied.emit()
