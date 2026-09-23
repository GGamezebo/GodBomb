extends SceneTree
## Headless: godot --headless --path . --script res://tests/test_yandex_games.gd

func _init() -> void:
	var failed := 0
	failed += _test_gameplay_states()
	failed += _test_export_preset_has_sdk()
	failed += _test_platform_mute()
	failed += await _test_node_noop_offline()
	if failed == 0:
		print("test_yandex_games: OK")
		quit(0)
	else:
		printerr("test_yandex_games: %d failed" % failed)
		quit(1)


func _test_gameplay_states() -> int:
	var active := PackedStringArray([FSMGameStates.COUNTDOWN, FSMGameStates.PLAY])
	var idle := PackedStringArray([
		FSMGameStates.PLAYER_CHOICE,
		FSMGameStates.READY_TO_START,
		FSMGameStates.EMERGENCY,
		FSMGameStates.EXPLOSION,
		FSMGameStates.RESULT,
		"",
		"menu",
	])
	for state_name in active:
		if not YandexGames.is_gameplay_state(state_name):
			printerr("expected gameplay: %s" % state_name)
			return 1
	for state_name in idle:
		if YandexGames.is_gameplay_state(state_name):
			printerr("did not expect gameplay: %s" % state_name)
			return 1
	return 0


func _test_platform_mute() -> int:
	var audio := GameAudioController.new()
	root.add_child(audio)
	var master := AudioServer.get_bus_index(&"Master")
	if master < 0:
		printerr("Master bus missing")
		audio.queue_free()
		return 1
	audio.set_platform_muted(true)
	if not AudioServer.is_bus_mute(master):
		printerr("Master not muted for Yandex pause")
		audio.set_platform_muted(false)
		audio.queue_free()
		return 1
	audio.set_platform_muted(false)
	if AudioServer.is_bus_mute(master):
		printerr("Master stayed muted after Yandex resume")
		audio.queue_free()
		return 1
	audio.queue_free()
	return 0


func _test_export_preset_has_sdk() -> int:
	var cfg := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not cfg.contains("/sdk.js"):
		printerr("Web export head_include missing /sdk.js")
		return 1
	if not cfg.contains("YaGames.init"):
		printerr("Web export head_include missing YaGames.init")
		return 1
	return 0


func _test_node_noop_offline() -> int:
	var node := YandexGames.new()
	root.add_child(node)
	node.notify_interactive()
	node.on_left_game()
	await node.maybe_show_fullscreen_on_menu_return(false)
	if node.is_available:
		printerr("expected SDK unavailable offline")
		node.queue_free()
		return 1
	if node.is_ready_sent:
		printerr("ready should not be sent offline")
		node.queue_free()
		return 1
	if node.is_platform_paused:
		printerr("platform should not start paused offline")
		node.queue_free()
		return 1
	node.queue_free()
	return 0
