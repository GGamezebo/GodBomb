class_name GameAudioController
extends Node

const GROUP := "game_audio"

const MUSIC_BUS := &"Music"
const SFX_BUS := &"SFX"

@export var music_player: AudioStreamPlayer
@export var account: PDataAccount

var _in_battle: bool = false


func _ready() -> void:
	add_to_group(GROUP)
	if not music_player:
		music_player = get_node_or_null("../MusicPlayer") as AudioStreamPlayer
	_prepare_music_stream()
	if account:
		account.changed.connect(_apply_from_account)
	_apply_from_account()


func set_in_battle(in_battle: bool) -> void:
	_in_battle = in_battle
	_sync_music_player()


func _prepare_music_stream() -> void:
	if not music_player or not music_player.stream:
		return
	if music_player.stream is AudioStreamMP3:
		(music_player.stream as AudioStreamMP3).loop = true
	elif music_player.stream is AudioStreamOggVorbis:
		(music_player.stream as AudioStreamOggVorbis).loop = true


func _apply_from_account() -> void:
	if not account:
		return
	_apply_bus(MUSIC_BUS, account.get_music_volume(), account.get_music_enabled())
	_apply_bus(SFX_BUS, account.get_sfx_volume(), true)
	_sync_music_player()


func _apply_bus(bus_name: StringName, linear_volume: float, enabled: bool) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	var clamped := clampf(linear_volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(clamped, 0.001)))
	AudioServer.set_bus_mute(bus_index, not enabled)


func _can_play_menu_music() -> bool:
	return not _in_battle and account.get_music_enabled()


func _sync_music_player() -> void:
	if not music_player or not account:
		return
	if _can_play_menu_music():
		if not music_player.playing:
			music_player.play()
	else:
		music_player.stop()


func toggle_music() -> bool:
	if not account:
		return true
	var enabled := not account.get_music_enabled()
	account.set_music_enabled(enabled)
	_apply_from_account()
	return enabled


func set_music_enabled(enabled: bool) -> void:
	if not account:
		return
	account.set_music_enabled(enabled)
	_apply_from_account()


func set_music_volume(linear: float) -> void:
	if not account:
		return
	account.set_music_volume(linear)
	_apply_from_account()


func set_sfx_volume(linear: float) -> void:
	if not account:
		return
	account.set_sfx_volume(linear)
	_apply_from_account()
