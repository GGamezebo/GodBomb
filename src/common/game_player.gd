class_name GamePlayer
extends RefCounted

var info: PlayerInfo
var index: int
## Points: +1 for every round this player survived (was not blown up).
var score: int = 0
var is_active: bool = true
var eliminated_at: int = -1


func _init(p_info: PlayerInfo, p_index: int) -> void:
	info = p_info
	index = p_index


func on_round_survived() -> void:
	score += 1
