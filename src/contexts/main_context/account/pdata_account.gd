class_name PDataAccount
extends Resource

const SAVE_PATH := "user://account.tres"
const CURRENT_VERSION := 1

@export var data: Dictionary = {
	"version": CURRENT_VERSION,
	"players": [],
	"game_time_minutes": 5,
}


func get_players() -> Array:
	return data.get("players", [])


func set_players(players: Array) -> void:
	data["players"] = players


func get_game_time_minutes() -> int:
	return int(data.get("game_time_minutes", 5))


func set_game_time_minutes(minutes: int) -> void:
	data["game_time_minutes"] = minutes


func player_info_from_dict(entry: Dictionary) -> PlayerInfo:
	return PlayerInfo.new(str(entry.get("name", "")), int(entry.get("preset_id", 0)))


func dict_from_player_info(info: PlayerInfo) -> Dictionary:
	return {"name": info.name, "preset_id": info.preset_id}
