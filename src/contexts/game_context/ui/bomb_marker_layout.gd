class_name BombMarkerLayout
extends RefCounted

static func get_marker_position(root: Control, marker_name: StringName, fallback: Vector2) -> Vector2:
	if root == null:
		return fallback
	var marker := root.get_node_or_null(NodePath(String(marker_name))) as Node2D
	if marker:
		return marker.position
	return fallback


static func place_control_at_marker(control: Control, root: Control, marker_name: StringName, fallback: Vector2) -> void:
	if control == null:
		return
	var anchor := get_marker_position(root, marker_name, fallback)
	var size := control.size
	if size.x <= 0.0 or size.y <= 0.0:
		size = control.custom_minimum_size
	control.position = anchor - size * 0.5
