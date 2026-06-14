class_name PDataAccount
extends Resource

const SAVE_PATH := "user://account.tres"
const CURRENT_VERSION := 1
const RECENT_NAMES_MAX := 12

const DEFAULT_FUNNY_NAMES: Array[String] = [
	"Котлетка-O'Бомба",
	"Слайм Уолтер",
	"Пельмень 3000",
	"Батон-de-Boom",
	"Чебурек McCheb",
	"Тапок Судьбы",
	"Шлёмп Блым",
	"Крокодил Бум",
	"Булка с Фитилём",
	"КвазиБомба",
	"Mister Boom",
	"Пинг-Pong",
]

@export var data: Dictionary = {
	"version": CURRENT_VERSION,
	"players": [],
	"game_time_minutes": 5,
	"recent_player_names": [],
}


func get_players() -> Array:
	return data.get("players", []).duplicate(true)


func set_players(players: Array) -> void:
	data["players"] = players.duplicate(true)
	emit_changed()


func get_game_time_minutes() -> int:
	return int(data.get("game_time_minutes", 5))


func set_game_time_minutes(minutes: int) -> void:
	data["game_time_minutes"] = minutes
	emit_changed()


func get_recent_names() -> Array[String]:
	ensure_recent_names_initialized()
	return _to_string_array(data.get("recent_player_names", []))


func remember_removed_player(player_name: String) -> void:
	var trimmed := PlayerInfo.sanitize_name(player_name)
	if trimmed.is_empty():
		return
	ensure_recent_names_initialized()
	var names := get_recent_names()
	names.erase(trimmed)
	names.insert(0, trimmed)
	if names.size() > RECENT_NAMES_MAX:
		names = names.slice(0, RECENT_NAMES_MAX)
	data["recent_player_names"] = names
	emit_changed()


func ensure_recent_names_initialized() -> void:
	var stored = data.get("recent_player_names", null)
	if stored == null or (stored is Array and stored.is_empty()):
		data["recent_player_names"] = DEFAULT_FUNNY_NAMES.duplicate()
		emit_changed()


func player_info_from_dict(entry: Dictionary) -> PlayerInfo:
	return PlayerInfo.new(
		PlayerInfo.sanitize_name(str(entry.get("name", ""))),
		int(entry.get("preset_id", 0))
	)


func dict_from_player_info(info: PlayerInfo) -> Dictionary:
	return {"name": PlayerInfo.sanitize_name(info.name), "preset_id": info.preset_id}


func _to_string_array(source: Variant) -> Array[String]:
	var result: Array[String] = []
	if source is Array:
		for item in source:
			var text := PlayerInfo.sanitize_name(str(item))
			if not text.is_empty():
				result.append(text)
	return result
