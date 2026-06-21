extends Node

@export var game_events: GameEvents
@export var countdown_stream: AudioStream
@export var round_music_stream: AudioStream
@export var win_music_stream: AudioStream
@export var explosion_stream: AudioStream
@export var pass_next_stream: AudioStream
@export var tick_streams: Array[AudioStream] = []

var listener: EventListener = EventListener.new()
var _round_gameplay_player: AudioStreamPlayer
var _win_music_player: AudioStreamPlayer


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	_setup_round_gameplay_player()
	_setup_win_music_player()
	if game_events:
		listener.add(game_events.ev_countdown_tick_changed, _on_countdown_tick)
		listener.add(game_events.ev_player_choice_tick_changed, _on_player_choice_tick)
		listener.add(game_events.ev_touch_next_player, _on_touch_next_player)
		listener.add(game_events.ev_alert, _on_alert)
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)


func _exit_tree() -> void:
	listener.deinit()
	_stop_round_gameplay_sound()
	_stop_win_music()


func _setup_round_gameplay_player() -> void:
	_round_gameplay_player = AudioStreamPlayer.new()
	_round_gameplay_player.bus = &"SFX"
	_round_gameplay_player.name = "RoundGameplayPlayer"
	add_child(_round_gameplay_player)
	if round_music_stream:
		_enable_stream_loop(round_music_stream)
		_round_gameplay_player.stream = round_music_stream


func _setup_win_music_player() -> void:
	_win_music_player = AudioStreamPlayer.new()
	_win_music_player.bus = &"SFX"
	_win_music_player.name = "WinMusicPlayer"
	add_child(_win_music_player)
	if win_music_stream:
		_enable_stream_loop(win_music_stream)
		_win_music_player.stream = win_music_stream


func _enable_stream_loop(stream: AudioStream) -> void:
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true


func _on_countdown_tick(_seconds_left: int) -> void:
	_play_tick_sound()


func _on_player_choice_tick() -> void:
	_play_tick_sound()


func _play_tick_sound() -> void:
	_play_one_shot(countdown_stream)


func _on_touch_next_player(_touch_position: Vector2 = Vector2.ZERO) -> void:
	_play_one_shot(pass_next_stream)


func _on_alert() -> void:
	if tick_streams.size() > 0:
		_play_one_shot(tick_streams[randi() % tick_streams.size()])


func _on_game_state_changed(from_state: String, to_state: String) -> void:
	match to_state:
		FSMGameStates.PLAY:
			_stop_win_music()
			if from_state == FSMGameStates.EMERGENCY:
				_resume_round_gameplay_sound()
			else:
				_start_round_gameplay_sound()
		FSMGameStates.EMERGENCY:
			_pause_round_gameplay_sound()
		FSMGameStates.EXPLOSION:
			_stop_win_music()
			_stop_round_gameplay_sound()
			_play_one_shot(explosion_stream)
		FSMGameStates.RESULT:
			_stop_round_gameplay_sound()
			_start_win_music()
		FSMGameStates.READY_TO_START, FSMGameStates.PLAYER_CHOICE, FSMGameStates.COUNTDOWN:
			_stop_win_music()
			_stop_round_gameplay_sound()


func _start_round_gameplay_sound() -> void:
	if round_music_stream == null:
		return
	if _round_gameplay_player.stream != round_music_stream:
		_enable_stream_loop(round_music_stream)
		_round_gameplay_player.stream = round_music_stream
	_round_gameplay_player.stream_paused = false
	_round_gameplay_player.play()


func _pause_round_gameplay_sound() -> void:
	if _round_gameplay_player and _round_gameplay_player.playing:
		_round_gameplay_player.stream_paused = true


func _resume_round_gameplay_sound() -> void:
	if _round_gameplay_player:
		_round_gameplay_player.stream_paused = false


func _stop_round_gameplay_sound() -> void:
	if _round_gameplay_player and _round_gameplay_player.playing:
		_round_gameplay_player.stop()


func _start_win_music() -> void:
	if win_music_stream == null:
		return
	if _win_music_player.stream != win_music_stream:
		_enable_stream_loop(win_music_stream)
		_win_music_player.stream = win_music_stream
	_win_music_player.play()


func _stop_win_music() -> void:
	if _win_music_player and _win_music_player.playing:
		_win_music_player.stop()


func _play_one_shot(stream: AudioStream) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = &"SFX"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
