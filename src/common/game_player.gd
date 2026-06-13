class_name GamePlayer
extends RefCounted

var info: PlayerInfo
var index: int
var score: int = 0


func _init(p_info: PlayerInfo, p_index: int) -> void:
	info = p_info
	index = p_index


func on_explosion() -> void:
	score += 1
