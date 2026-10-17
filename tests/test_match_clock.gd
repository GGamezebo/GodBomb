extends SceneTree
## Headless: godot --headless --path . --script res://tests/test_match_clock.gd

func _init() -> void:
	var failed := 0
	failed += _test_time_up_unique_leader_vs_overtime()
	failed += _test_resync_preserves_match_clock()
	failed += _test_estimated_rounds()
	failed += _test_points_for_survived_rounds()
	failed += _test_late_joiner_and_leaver()
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
		printerr("expected unique leader B (most points)")
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


func _test_points_for_survived_rounds() -> int:
	var session := GameSession.new()
	session.players = [_player("A", 0, 0), _player("B", 1, 0), _player("C", 2, 0)]
	session.award_round(session.players[0])
	session.award_round(session.players[1])
	if session.rounds_played != 2:
		printerr("expected 2 rounds played, got %d" % session.rounds_played)
		return 1
	var scores := [session.players[0].score, session.players[1].score, session.players[2].score]
	if scores != [1, 1, 2]:
		printerr("unexpected points: %s" % [scores])
		return 1
	if session.get_sorted_results()[0].info.name != "C":
		printerr("expected C (most points) ranked first")
		return 1
	session.enter_overtime()
	if session.players[0].is_active or not session.players[2].is_active:
		printerr("overtime should keep only max-points players")
		return 1
	return 0


func _test_late_joiner_and_leaver() -> int:
	var session := GameSession.new()
	session.players = [_player("A", 0, 0), _player("B", 1, 0)]
	session.match_elapsed_seconds = 30.0
	session.award_round(session.players[0])
	session.award_round(session.players[0])
	session.award_round(session.players[1])
	var roster := PDataAccount.new()
	roster.set_players([{"name": "A", "preset_id": 0}, {"name": "C", "preset_id": 2}])
	session.resync_players_from_account(roster)
	var joiner := session.players[1]
	if joiner.info.name != "C" or joiner.score != 3 or joiner.joined_round != 3:
		printerr("late joiner should get 3 points at round 3, got %d / %d" % [joiner.score, joiner.joined_round])
		return 1
	if session.departed_players.size() != 1 or session.departed_players[0].left_reason != GameSession.LEFT_REMOVED:
		printerr("removed player B should be kept as departed")
		return 1
	if session.get_stats_players().size() != 3:
		printerr("stats should list all 3 participants")
		return 1
	# B returns: keeps own explosions, missed rounds count as survived.
	roster.set_players([{"name": "A", "preset_id": 0}, {"name": "C", "preset_id": 2}, {"name": "B", "preset_id": 1}])
	session.award_round(session.players[0])
	session.resync_players_from_account(roster)
	var back := session.players[2]
	if back.score != 3 or back.explosions != 1 or not session.departed_players.is_empty():
		printerr("returning B expected 3 pts / 1 boom, got %d / %d" % [back.score, back.explosions])
		return 1
	return 0


func _player(player_name: String, index: int, score: int) -> GamePlayer:
	var info := PlayerInfo.new(player_name, index)
	var player := GamePlayer.new(info, index)
	player.score = score
	return player
