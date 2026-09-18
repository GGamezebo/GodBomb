extends SceneTree
## Headless: godot --headless --path . --script res://tests/test_match_clock.gd

func _init() -> void:
	var failed := 0
	failed += _test_time_up_unique_leader_vs_overtime()
	failed += _test_resync_preserves_match_clock()
	failed += _test_estimated_rounds()
	if failed == 0:
		print("test_match_clock: OK")
		quit(0)
	else:
		printerr("test_match_clock: %d failed" % failed)
		quit(1)


func _test_time_up_unique_leader_vs_overtime() -> int:
	var session := GameSession.new()
	session.is_tutorial = false
	session.is_overtime = false
	session.match_limit_seconds = 60.0
	session.match_elapsed_seconds = 60.0
	session.players = [
		_player("A", 0, 1),
		_player("B", 1, 3),
	]
	if not session.is_regulation_time_up():
		printerr("expected regulation time up")
		return 1
	if not session.has_unique_leader():
		printerr("expected unique leader A")
		return 1

	session.players[1].score = 1
	if session.has_unique_leader():
		printerr("expected tie → overtime path")
		return 1
	session.enter_overtime()
	if not session.is_overtime:
		printerr("expected overtime flag")
		return 1
	return 0


func _test_resync_preserves_match_clock() -> int:
	var session := GameSession.new()
	session.is_tutorial = false
	session.is_overtime = false
	session.match_limit_seconds = 300.0
	session.match_elapsed_seconds = 123.5
	session.regulation_boom_count = 4
	session.players = [_player("A", 0, 0), _player("B", 1, 0)]

	# Minimal account stub via PDataAccount resource if available.
	var account := PDataAccount.new()
	account.set_players([
		{"name": "A", "preset_id": 0},
		{"name": "B", "preset_id": 1},
	])
	var before := session.match_elapsed_seconds
	var booms := session.regulation_boom_count
	session.resync_players_from_account(account)
	if not is_equal_approx(session.match_elapsed_seconds, before):
		printerr("resync reset match clock: %s -> %s" % [before, session.match_elapsed_seconds])
		return 1
	if session.regulation_boom_count != booms:
		printerr("resync reset boom count")
		return 1
	return 0


func _test_estimated_rounds() -> int:
	var session := GameSession.new()
	session.match_limit_seconds = 120.0
	session.match_elapsed_seconds = 40.0
	session.regulation_boom_count = 2
	# avg 20s → remaining 80s → ~4 rounds
	var est := session.get_estimated_rounds_remaining()
	if est < 3 or est > 5:
		printerr("unexpected estimated rounds: %d" % est)
		return 1
	return 0


func _player(player_name: String, index: int, score: int) -> GamePlayer:
	var info := PlayerInfo.new(player_name, index)
	var player := GamePlayer.new(info, index)
	player.score = score
	return player
