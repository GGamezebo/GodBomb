extends Node

@export var game_events: GameEvents

var listener: EventListener = EventListener.new()


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)


func _exit_tree() -> void:
	listener.deinit()


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	match to_state:
		FSMGameStates.PLAY:
			_vibrate(35)
		FSMGameStates.EXPLOSION:
			_vibrate(120)


func _on_alert() -> void:
	_vibrate(20)


func _vibrate(duration_ms: int) -> void:
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"):
		Input.vibrate_handheld(duration_ms)
