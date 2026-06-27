class_name OnboardingTutorialData
extends RefCounted

const ROUND_COUNT := 3
const SWAP_INDEX_A := 0
const SWAP_INDEX_B := 1
const BOMB_ALIVE_TIME := 10.0
const FIRST_PLAYER_INDEX := 0

const ROUNDS: Array[Dictionary] = [
	{
		"syllable": "ло",
		"condition": WordCondition.Type.BEGIN,
		"word_hint": "лодка",
		"examples": "лодка, лось, полотно",
		"pass_hint": "Скажите слово вслух и коснитесь экрана — передайте бомбу.",
		"explode_player_index": 0,
	},
	{
		"syllable": "ка",
		"condition": WordCondition.Type.ANYWHERE,
		"word_hint": "карта",
		"examples": "карта, макака, окно",
		"pass_hint": "Назовите слово и передайте бомбу коротким нажатием.",
		"explode_player_index": 1,
	},
	{
		"syllable": "ок",
		"condition": WordCondition.Type.END,
		"word_hint": "песок",
		"examples": "песок, молоток, дружок",
		"pass_hint": "Назовите слово и передайте бомбу соседу.",
		"explode_player_index": 0,
	},
]


static func deck_entries() -> Array:
	var entries: Array = []
	for round in ROUNDS:
		entries.append({
			"syllable": round["syllable"],
			"condition": round["condition"],
		})
	return entries


static func player_infos(account: PDataAccount) -> Array[PlayerInfo]:
	var infos: Array[PlayerInfo] = []
	var recent := account.get_recent_names_for_display() if account else []
	for i in ROUND_COUNT:
		var player_name := SlimeColors.NAMES[i]
		if i < recent.size() and not str(recent[i]).is_empty():
			player_name = str(recent[i])
		infos.append(PlayerInfo.new(player_name, i))
	return infos


static func round_at(index: int) -> Dictionary:
	return ROUNDS[clampi(index, 0, ROUNDS.size() - 1)]


static func explode_player_index(round_index: int) -> int:
	return int(round_at(round_index).get("explode_player_index", 0))


static func round_for_card(card: GameCard) -> Dictionary:
	if card == null:
		return ROUNDS[0]
	for round in ROUNDS:
		if round["syllable"] == card.word and int(round["condition"]) == card.condition:
			return round
	return ROUNDS[0]


static func round_index_for_card(card: GameCard) -> int:
	if card == null:
		return 0
	for i in ROUNDS.size():
		var round := ROUNDS[i]
		if round["syllable"] == card.word and int(round["condition"]) == card.condition:
			return i
	return 0


static func play_step_body_for_index(round_index: int) -> String:
	var round := round_at(round_index)
	return play_step_body(GameCard.new(str(round["syllable"]), int(round["condition"])))


static func play_step_body(card: GameCard) -> String:
	var round := round_for_card(card)
	var condition := WordCondition.get_label(int(round["condition"]))
	return (
		"Слог «%s» — %s.\nПодойдут слова: %s.\nНапример: «%s».\n%s"
		% [
			round["syllable"],
			condition,
			round["examples"],
			round["word_hint"],
			round["pass_hint"],
		]
	)


static func explosion_explanation(player_name: String) -> String:
	var safe_name := player_name if not player_name.is_empty() else "Игрок"
	return "%s не успел(а) придумать слово — бомба взорвалась." % safe_name
