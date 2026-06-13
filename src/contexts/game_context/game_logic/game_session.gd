class_name GameSession
extends RefCounted

var game_config: GameConfig
var game_events: GameEvents
var players: Array[GamePlayer] = []
var cards: Array[GameCard] = []
var current_card: GameCard = null
var current_player_index: int = 0
var state_time: float = 0.0
var last_second: int = -1
var is_blocked_prev_player: bool = false
var max_rand_player_choices: int = 0

var bomb_alive_time: float = 0.0
var bomb_duration: float = 0.0
var bomb_is_alerted: bool = false
var bomb_is_exploded: bool = false

var explosion_duration: float = 0.0
var explosion_is_countdown: bool = false


func setup(p_config: GameConfig, p_events: GameEvents, account: PDataAccount) -> void:
	game_config = p_config
	game_events = p_events
	players.clear()
	cards.clear()

	var account_players: Array = account.get_players()
	if account_players.is_empty():
		account_players = [
			account.dict_from_player_info(PlayerInfo.new("Игрок 1", 0)),
			account.dict_from_player_info(PlayerInfo.new("Игрок 2", 1)),
		]
	for i in account_players.size():
		var entry: Dictionary = account_players[i]
		var info := account.player_info_from_dict(entry)
		players.append(GamePlayer.new(info, i))

	_build_card_deck(account.get_game_time_minutes())
	current_player_index = randi() % maxi(players.size(), 1)
	max_rand_player_choices = 40 + randi() % maxi(players.size(), 1)
	_emit_current_player()


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


func reset_round() -> void:
	state_time = 0.0
	last_second = -1
	is_blocked_prev_player = true


func reset_bomb() -> void:
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
	is_blocked_prev_player = false
	if current_player_index >= players.size() - 1:
		set_current_player_index(0)
	else:
		set_current_player_index(current_player_index + 1)
	try_add_bonus_bomb_time()


func prev_player() -> bool:
	if is_blocked_prev_player:
		return false

	if current_player_index == 0:
		set_current_player_index(players.size() - 1)
	else:
		set_current_player_index(current_player_index - 1)

	is_blocked_prev_player = true
	return true


func try_add_bonus_bomb_time() -> void:
	if bomb_is_alerted:
		bomb_alive_time = bomb_duration + game_config.bonus_bomb_alive_time


func update_bomb(delta: float) -> bool:
	if bomb_is_exploded:
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
		var result := get_sorted_results()
		if result.size() > 1 and result[0].score == result[1].score:
			var random_index := randi() % game_config.cards.size()
			cards.append(GameCard.new(game_config.cards[random_index], WordCondition.random()))
		else:
			return false

	current_card = cards.pop_front()
	if game_events:
		game_events.ev_card_changed.emit(current_card)
	return true


func get_sorted_results() -> Array[GamePlayer]:
	var result: Array[GamePlayer] = []
	result.assign(players)
	result.sort_custom(func(a: GamePlayer, b: GamePlayer) -> bool:
		return a.score < b.score
	)
	return result


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
