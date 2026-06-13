extends Node2D

@export var game_events: GameEvents
@export var particles: CPUParticles2D

var listener: EventListener = EventListener.new()


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if particles:
		particles.emitting = false
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)


func _exit_tree() -> void:
	listener.deinit()


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	if to_state == FSMGameStates.EXPLOSION:
		_play_burst()


func _play_burst() -> void:
	if not particles:
		return
	particles.restart()
	particles.emitting = true
