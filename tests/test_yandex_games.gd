extends SceneTree
## Headless: godot --headless --path . --script res://tests/test_yandex_games.gd

const YandexGamesScript := preload("res://core/systems/yandex/yandex_games.gd")


func _init() -> void:
	var failed := 0
	failed += _test_gameplay_states()
	failed += _test_export_preset_has_sdk()
	failed += await _test_node_noop_offline()
	if failed == 0:
		print("test_yandex_games: OK")
		quit(0)
	else:
		printerr("test_yandex_games: %d failed" % failed)
		quit(1)


func _test_gameplay_states() -> int:
	var active := PackedStringArray(["countdown", "play"])
	var idle := PackedStringArray([
		"player_choice",
		"ready_to_start",
		"emergency",
		"explosion",
		"result",
		"",
		"menu",
	])
	for state_name in active:
		if not YandexGamesScript.is_gameplay_state(state_name):
			printerr("expected gameplay: %s" % state_name)
			return 1
	for state_name in idle:
		if YandexGamesScript.is_gameplay_state(state_name):
			printerr("did not expect gameplay: %s" % state_name)
			return 1
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
	var node := YandexGamesScript.new()
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
