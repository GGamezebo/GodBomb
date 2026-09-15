class_name GameSession
extends RefCounted

const SPLASH_OVERTIME := "overtime"
const SPLASH_ELIMINATED := "eliminated"
const _STILL_IN := 1_000_000

var game_config: GameConfig
var game_events: GameEvents
var players: Array[GamePlayer] = []
var cards: Array[GameCard] = []
var current_card: GameCard = null
var current_player_index: int = 0
var state_time: float = 0.0
var last_second: int = -1
var max_rand_player_choices: int = 0

var bomb_alive_time: float = 0.0
var bomb_duration: float = 0.0
var bomb_is_alerted: bool = false
var bomb_is_exploded: bool = false

var explosion_duration: float = 0.0
var explosion_is_countdown: bool = false
var match_cards_total: int = 0
var is_tutorial: bool = false
var is_overtime: bool = false
var _deck_game_time_minutes: int = -1
var _knockout_seq: int = 0


func setup(p_config: GameConfig, p_events: GameEvents, account: PDataAccount) -> void:
	game_config = p_config
	game_events = p_events
	players.clear()
	cards.clear()

	var account_players: Array = account.get_players()
	for i in account_players.size():
		var entry: Dictionary = account_players[i]
		var info := account.player_info_from_dict(entry)
		players.append(GamePlayer.new(info, i))

	rebuild_card_deck(account.get_game_time_minutes())
	is_overtime = false
	_knockout_seq = 0
	current_player_index = randi() % maxi(players.size(), 1)
	max_rand_player_choices = 40 + randi() % maxi(players.size(), 1)
	_emit_current_player()


func resync_players_from_account(account: PDataAccount) -> void:
	if is_overtime:
		return
	if players.is_empty():
		setup(game_config, game_events, account)
		return

	var score_by_key: Dictionary = {}
	var active_by_key: Dictionary = {}
	var eliminated_by_key: Dictionary = {}
	for player in players:
		var key := _player_key(player.info)
		score_by_key[key] = player.score
		active_by_key[key] = player.is_active
		eliminated_by_key[key] = player.eliminated_at

	var current_key := _player_key(get_current_player().info) if not players.is_empty() else ""
	var previous_index := current_player_index
	var old_players: Array[GamePlayer] = []
	old_players.assign(players)

	players.clear()
	var account_players: Array = account.get_players()
	for i in account_players.size():
		var info := account.player_info_from_dict(account_players[i])
		var player := GamePlayer.new(info, i)
		var key := _player_key(info)
		player.score = int(score_by_key.get(key, 0))
		player.is_active = bool(active_by_key.get(key, true))
		player.eliminated_at = int(eliminated_by_key.get(key, -1))
		players.append(player)

	if players.is_empty():
		current_player_index = 0
		return

	var next_index := 0
	var found_current := false
	for i in players.size():
		if _player_key(players[i].info) == current_key:
			next_index = i
			found_current = true
			break
	if not found_current:
		next_index = _next_clockwise_player_index(previous_index, old_players, account)

	current_player_index = next_index
	max_rand_player_choices = 40 + randi() % maxi(players.size(), 1)
	_emit_current_player()


func _next_clockwise_player_index(from_index: int, old_players: Array[GamePlayer], account: PDataAccount) -> int:
	var account_players: Array = account.get_players()
	var old_count := old_players.size()
	if old_count == 0 or account_players.is_empty():
		return 0
	for step in range(1, old_count + 1):
		var old_idx := (from_index + step) % old_count
		var key := _player_key(old_players[old_idx].info)
		for i in account_players.size():
			var info := account.player_info_from_dict(account_players[i])
			if _player_key(info) == key:
				return i
	return 0


func _player_key(info: PlayerInfo) -> String:
	return "%d|%s" % [info.preset_id, info.name]


func rebuild_card_deck(game_time_minutes: int) -> void:
	if is_tutorial or is_overtime:
		return
	cards.clear()
	current_card = null
	_build_card_deck(game_time_minutes)
	_deck_game_time_minutes = game_time_minutes


func ensure_card_deck_for_game_time(game_time_minutes: int) -> void:
	if is_tutorial or is_overtime:
		return
	if game_time_minutes == _deck_game_time_minutes and not cards.is_empty():
		return
	rebuild_card_deck(game_time_minutes)


func _build_card_deck(game_time_minutes: int) -> void:
	var card_strings: Array[String] = []
	for syllable in game_config.cards:
		card_strings.append(syllable)
	card_strings.shuffle()

	var avg_bomb_time := (game_config.max_bomb_alive_time - game_config.min_bomb_alive_time) / 2.0
	var card_numbers := int((game_time_minutes * 60) / avg_bomb_time)
	card_numbers = clampi(card_numbers, 1, card_strings.size())

	var deck: Array[String] = card_strings.slice(0, card_numbers)
	var length := randi() % deck.size()
	if length == 0:
		length = 1

	for i in length:
		cards.append(GameCard.new(deck[i], WordCondition.random()))
	match_cards_total = cards.size()


func apply_tutorial_deck(entries: Array) -> void:
	cards.clear()
	current_card = null
	is_tutorial = true
	_deck_game_time_minutes = -1
	is_overtime = false
	_knockout_seq = 0
	for player in players:
		player.score = 0
		player.is_active = true
		player.eliminated_at = -1
	for entry in entries:
		cards.append(GameCard.new(str(entry["syllable"]), int(entry["condition"])))
	match_cards_total = cards.size()


func apply_tutorial_final_scores() -> void:
	if not is_tutorial:
		return
	for player in players:
		player.score = 0
	for round_idx in OnboardingTutorialData.ROUND_COUNT:
		var explode_idx := OnboardingTutorialData.explode_player_index(round_idx)
		if explode_idx >= 0 and explode_idx < players.size():
			players[explode_idx].score += 1


func reset_round() -> void:
	state_time = 0.0
	last_second = -1


func reset_bomb() -> void:
	if is_tutorial:
		bomb_alive_time = OnboardingTutorialData.BOMB_ALIVE_TIME
	else:
		bomb_alive_time = game_config.min_bomb_alive_time + randf() * (
			game_config.max_bomb_alive_time - game_config.min_bomb_alive_time
		)
	bomb_duration = 0.0
	bomb_is_alerted = false
	bomb_is_exploded = false


func reset_explosion() -> void:
	explosion_duration = 0.0
	explosion_is_countdown = false


func get_current_player() -> GamePlayer:
	return players[current_player_index]


func set_current_player_index(index: int) -> void:
	current_player_index = index
	_emit_current_player()


func next_player() -> void:
	var count := players.size()
	if count == 0:
		return
	for _step in count:
		current_player_index = (current_player_index + 1) % count
		if players[current_player_index].is_active:
			break
	_emit_current_player()
	try_add_bonus_bomb_time()


func try_add_bonus_bomb_time() -> void:
	if bomb_is_alerted:
		bomb_alive_time = bomb_duration + game_config.bonus_bomb_alive_time


func update_bomb(delta: float) -> bool:
	if bomb_is_exploded:
		return false

	if is_tutorial:
		if not bomb_is_alerted and (bomb_alive_time - bomb_duration) < game_config.alert_bomb_time:
			bomb_is_alerted = true
			if game_events:
				game_events.ev_alert.emit()
		bomb_duration += delta
		return false

	if not bomb_is_alerted and (bomb_alive_time - bomb_duration) < game_config.alert_bomb_time:
		bomb_is_alerted = true
		if game_events:
			game_events.ev_alert.emit()

	if (bomb_alive_time - bomb_duration) <= 0.0:
		bomb_is_exploded = true
		get_current_player().on_explosion()
		return true

	bomb_duration += delta
	return false


func update_explosion(delta: float) -> bool:
	if explosion_is_countdown:
		return false

	explosion_duration += delta
	if explosion_duration > game_config.explosion_countdown_time:
		explosion_is_countdown = true
		return true
	return false


func next_card() -> bool:
	if cards.is_empty():
		return false
	current_card = cards.pop_front()
	if game_events:
		game_events.ev_card_changed.emit(current_card)
	return true


func ensure_overtime_card() -> bool:
	if cards.is_empty():
		_append_random_card()
	return next_card()


func _append_random_card() -> void:
	if game_config == null or game_config.cards.is_empty():
		return
	var random_index := randi() % game_config.cards.size()
	cards.append(GameCard.new(game_config.cards[random_index], WordCondition.random()))


func get_min_score() -> int:
	if players.is_empty():
		return 0
	var min_score := players[0].score
	for player in players:
		if player.score < min_score:
			min_score = player.score
	return min_score


func has_unique_leader() -> bool:
	if players.size() <= 1:
		return true
	var min_score := get_min_score()
	var tied := 0
	for player in players:
		if player.score == min_score:
			tied += 1
			if tied > 1:
				return false
	return true


func active_count() -> int:
	var n := 0
	for player in players:
		if player.is_active:
			n += 1
	return n


func enter_overtime() -> void:
	is_overtime = true
	_knockout_seq = 0
	var min_score := get_min_score()
	for player in players:
		if player.score > min_score:
			player.is_active = false
			player.eliminated_at = 0


func eliminate_player(player: GamePlayer) -> void:
	if player == null or not player.is_active:
		return
	_knockout_seq += 1
	player.is_active = false
	player.eliminated_at = _knockout_seq


func get_rounds_remaining() -> int:
	var remaining := cards.size()
	if current_card != null:
		remaining += 1
	return remaining


func get_match_remaining_ratio() -> float:
	if match_cards_total <= 0:
		return 1.0
	return float(get_rounds_remaining()) / float(match_cards_total)


func get_sorted_results() -> Array[GamePlayer]:
	var result: Array[GamePlayer] = []
	result.assign(players)
	result.sort_custom(func(a: GamePlayer, b: GamePlayer) -> bool:
		if a.score != b.score:
			return a.score < b.score
		return _rank_eliminated_at(a) > _rank_eliminated_at(b)
	)
	return result


func get_sorted_active() -> Array[GamePlayer]:
	var result: Array[GamePlayer] = []
	for player in get_sorted_results():
		if player.is_active:
			result.append(player)
	return result


func get_sorted_eliminated() -> Array[GamePlayer]:
	var result: Array[GamePlayer] = []
	for player in get_sorted_results():
		if not player.is_active:
			result.append(player)
	return result


func _rank_eliminated_at(player: GamePlayer) -> int:
	if player.eliminated_at < 0:
		return _STILL_IN
	return player.eliminated_at


func get_player_choice_index() -> int:
	var t := state_time / game_config.player_choice_time
	var eased := 1.0 - (1.0 - t) * (1.0 - t)
	var number := lerpf(0.0, float(max_rand_player_choices), eased)
	return int(number) % maxi(players.size(), 1)


func tick_countdown() -> void:
	var current_second := int(state_time)
	if current_second > last_second:
		last_second = current_second
		var countdown_time := int(game_config.countdown_time)
		var count := countdown_time - last_second
		if count > 0 and game_events:
			game_events.ev_countdown_tick_changed.emit(count)


func advance_time(delta: float) -> void:
	state_time += delta


func _emit_current_player() -> void:
	if players.is_empty() or not game_events:
		return
	game_events.ev_current_player_changed.emit(get_current_player())
