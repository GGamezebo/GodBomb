class_name PlayerInfo
extends Resource

@export var name: String = ""
@export var preset_id: int = 0


func _init(p_name: String = "", p_preset_id: int = 0) -> void:
	name = p_name
	preset_id = p_preset_id
