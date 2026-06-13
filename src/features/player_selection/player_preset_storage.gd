class_name PlayerPresetStorage
extends Node

@export var game_config: GameConfig
@export var menu_events: MenuEvents

var _locked_presets: Dictionary = {}
var listener: EventListener = EventListener.new()


func _ready() -> void:
	listener.add(menu_events.ev_player_added, _on_players_changed)
	listener.add(menu_events.ev_player_removed, _on_players_changed_untyped)
	listener.add(menu_events.ev_player_modified, _on_players_changed_untyped)
	listener.add(menu_events.ev_player_swapped, _on_players_swapped)


func _exit_tree() -> void:
	listener.deinit()


func is_held(preset_id: int) -> bool:
	return _locked_presets.has(preset_id)


func rebuild_locks(players: Array) -> void:
	_locked_presets.clear()
	for entry in players:
		var preset_id: int = int(entry.get("preset_id", 0))
		_locked_presets[preset_id] = true


func _on_players_changed(_info: PlayerInfo) -> void:
	pass


func _on_players_changed_untyped(_a = null, _b = null) -> void:
	pass


func _on_players_swapped(_a: int, _b: int) -> void:
	pass
