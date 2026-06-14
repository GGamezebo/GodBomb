class_name PDataAccount
extends Resource

const SAVE_PATH := "user://account.tres"
const CURRENT_VERSION := 1
const RECENT_NAMES_MAX := 12
const SWAP_HINT_GAMES_MAX := 5
const HOLD_EDIT_HINT_MAX_VIEWS := 2
const DEFAULT_MUSIC_VOLUME := 0.6
const DEFAULT_SFX_VOLUME := 1.0

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


func get_games_played() -> int:
	return maxi(0, int(data.get("games_played", 0)))


func increment_games_played() -> void:
	data["games_played"] = get_games_played() + 1
	emit_changed()


func should_show_swap_hints() -> bool:
	return get_games_played() < SWAP_HINT_GAMES_MAX


func has_seen_swap_hint() -> bool:
	return not should_show_swap_hints()


func mark_swap_hint_seen() -> void:
	pass


func _get_hints_seen() -> Dictionary:
	if not data.has("hints_seen") or not data["hints_seen"] is Dictionary:
		data["hints_seen"] = {}
	return data["hints_seen"]


func get_hold_edit_hint_views() -> int:
	return maxi(0, int(_get_hints_seen().get("hold_edit", 0)))


func increment_hold_edit_hint_views() -> void:
	var hints := _get_hints_seen()
	hints["hold_edit"] = get_hold_edit_hint_views() + 1
	data["hints_seen"] = hints
	emit_changed()


func has_edited_player() -> bool:
	return bool(data.get("has_edited_player", false))


func mark_has_edited_player() -> void:
	data["has_edited_player"] = true
	emit_changed()


func should_show_hold_edit_hint() -> bool:
	return not has_edited_player() and get_hold_edit_hint_views() < HOLD_EDIT_HINT_MAX_VIEWS


func get_music_enabled() -> bool:
	return bool(data.get("music_enabled", true))


func set_music_enabled(enabled: bool) -> void:
	data["music_enabled"] = enabled
	emit_changed()


func get_music_volume() -> float:
	return clampf(float(data.get("music_volume", DEFAULT_MUSIC_VOLUME)), 0.0, 1.0)


func set_music_volume(linear: float) -> void:
	data["music_volume"] = clampf(linear, 0.0, 1.0)
	emit_changed()


func get_sfx_volume() -> float:
	return clampf(float(data.get("sfx_volume", DEFAULT_SFX_VOLUME)), 0.0, 1.0)


func set_sfx_volume(linear: float) -> void:
	data["sfx_volume"] = clampf(linear, 0.0, 1.0)
	emit_changed()


func reset_progress() -> void:
	data["games_played"] = 0
	data["recent_player_names"] = DEFAULT_FUNNY_NAMES.duplicate()
	data.erase("has_edited_player")
	data["hints_seen"] = {}
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
