class_name OnboardingTutorialData
extends RefCounted

const ROUND_COUNT := 3
const SWAP_INDEX_A := 0
const SWAP_INDEX_B := 1
const BOMB_ALIVE_TIME := 10.0
const FIRST_PLAYER_INDEX := 0

const ROUNDS_RU: Array[Dictionary] = [
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

const ROUNDS_EN: Array[Dictionary] = [
	{
		"syllable": "BL",
		"condition": WordCondition.Type.BEGIN,
		"word_hint": "black",
		"examples": "black, blink, blow",
		"pass_hint": "Say a word out loud and tap the screen to pass the bomb.",
		"explode_player_index": 0,
	},
	{
		"syllable": "AND",
		"condition": WordCondition.Type.ANYWHERE,
		"word_hint": "sand",
		"examples": "sand, hand, random",
		"pass_hint": "Say a word and pass the bomb with a quick tap.",
		"explode_player_index": 1,
	},
	{
		"syllable": "OCK",
		"condition": WordCondition.Type.END,
		"word_hint": "clock",
		"examples": "clock, block, rock",
		"pass_hint": "Say a word and pass the bomb to your neighbor.",
		"explode_player_index": 0,
	},
]


static func rounds() -> Array[Dictionary]:
	if LocaleService.get_locale() == LocaleService.LOCALE_EN:
		return ROUNDS_EN
	return ROUNDS_RU


static func deck_entries() -> Array:
	var entries: Array = []
	for round in rounds():
		entries.append({
			"syllable": round["syllable"],
			"condition": round["condition"],
		})
	return entries


static func player_infos(account: PDataAccount) -> Array[PlayerInfo]:
	var infos: Array[PlayerInfo] = []
	var recent := account.get_recent_names_for_display() if account else []
	for i in ROUND_COUNT:
		var player_name := LocaleService.get_slime_name(i)
		if i < recent.size() and not str(recent[i]).is_empty():
			player_name = str(recent[i])
		infos.append(PlayerInfo.new(player_name, i))
	return infos


static func round_at(index: int) -> Dictionary:
	var all := rounds()
	return all[clampi(index, 0, all.size() - 1)]


static func explode_player_index(round_index: int) -> int:
	return int(round_at(round_index).get("explode_player_index", 0))


static func round_for_card(card: GameCard) -> Dictionary:
	if card == null:
		return rounds()[0]
	for round in rounds():
		if round["syllable"] == card.word and int(round["condition"]) == card.condition:
			return round
	return rounds()[0]


static func round_index_for_card(card: GameCard) -> int:
	if card == null:
		return 0
	var all := rounds()
	for i in all.size():
		var round := all[i]
		if round["syllable"] == card.word and int(round["condition"]) == card.condition:
			return i
	return 0


static func play_step_body_for_index(round_index: int) -> String:
	var round := round_at(round_index)
	return play_step_body(GameCard.new(str(round["syllable"]), int(round["condition"])))


static func play_step_body(card: GameCard) -> String:
	var round := round_for_card(card)
	var condition := WordCondition.get_label(int(round["condition"]))
	return LocaleService.text("TUTORIAL_PLAY_BODY") % [
		round["syllable"],
		condition,
		round["examples"],
		round["word_hint"],
		round["pass_hint"],
	]


static func explosion_explanation(player_name: String) -> String:
	var fallback := LocaleService.text("PLAYER_DEFAULT")
	var safe_name := player_name if not player_name.is_empty() else fallback
	return LocaleService.text("TUTORIAL_EXPLOSION") % safe_name
