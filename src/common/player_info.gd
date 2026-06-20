class_name PlayerInfo
extends Resource

const MAX_NAME_LENGTH := 12

@export var name: String = ""
@export var preset_id: int = 0


func _init(p_name: String = "", p_preset_id: int = 0) -> void:
	name = sanitize_name(p_name)
	preset_id = p_preset_id


static func sanitize_name(raw: String) -> String:
	return raw.strip_edges().left(MAX_NAME_LENGTH)
