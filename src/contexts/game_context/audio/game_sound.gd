extends Node

@export var game_events: GameEvents
@export var countdown_stream: AudioStream
@export var play_stream: AudioStream
@export var explosion_stream: AudioStream
@export var tick_streams: Array[AudioStream] = []

var listener: EventListener = EventListener.new()
var _players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	listener.add(game_events.ev_countdown_tick_changed, _on_countdown_tick)
	listener.add(game_events.ev_alert, _on_alert)
	listener.add(game_events.ev_game_state_changed, _on_game_state_changed)


func _exit_tree() -> void:
	listener.deinit()


func _on_countdown_tick(_seconds_left: int) -> void:
	_play_one_shot(countdown_stream)


func _on_alert() -> void:
	if tick_streams.size() > 0:
		_play_one_shot(tick_streams[randi() % tick_streams.size()])


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	match to_state:
		FSMGameStates.PLAY:
			_play_one_shot(play_stream)
		FSMGameStates.EXPLOSION:
			_play_one_shot(explosion_stream)


func _play_one_shot(stream: AudioStream) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = &"SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
