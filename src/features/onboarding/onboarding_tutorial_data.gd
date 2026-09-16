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
		"examples": "лодка, лось, ложка",
		"pass_hint": "Скажите слово вслух и коснитесь экрана — передайте бомбу.",
		"explode_player_index": 0,
	},
	{
		"syllable": "ка",
		"condition": WordCondition.Type.ANYWHERE,
		"word_hint": "карта",
		"examples": "карта, макака, собака",
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

const ROUNDS_SR: Array[Dictionary] = [
	{
		"syllable": "КА",
		"condition": WordCondition.Type.BEGIN,
		"word_hint": "кафа",
		"examples": "кафа, како, калем",
		"pass_hint": "Izgovori reč naglas i dodirni ekran — prebaci bombu.",
		"explode_player_index": 0,
	},
	{
		"syllable": "СТ",
		"condition": WordCondition.Type.ANYWHERE,
		"word_hint": "стол",
		"examples": "стол, листа, бистро",
		"pass_hint": "Izgovori reč i prebaci bombu kratkim dodirom.",
		"explode_player_index": 1,
	},
	{
		"syllable": "ОК",
		"condition": WordCondition.Type.END,
		"word_hint": "молоток",
		"examples": "молоток, блок, ток",
		"pass_hint": "Izgovori reč i prebaci bombu susedu.",
		"explode_player_index": 0,
	},
]

const ROUNDS_ES: Array[Dictionary] = [
	{
		"syllable": "BL",
		"condition": WordCondition.Type.BEGIN,
		"word_hint": "blanco",
		"examples": "blanco, bloque, blusa",
		"pass_hint": "Di una palabra en voz alta y toca la pantalla para pasar la bomba.",
		"explode_player_index": 0,
	},
	{
		"syllable": "AND",
		"condition": WordCondition.Type.ANYWHERE,
		"word_hint": "sandalias",
		"examples": "sandalias, mandarina, random",
		"pass_hint": "Di una palabra y pasa la bomba con un toque rápido.",
		"explode_player_index": 1,
	},
	{
		"syllable": "AR",
		"condition": WordCondition.Type.END,
		"word_hint": "mar",
		"examples": "mar, avatar, popular",
		"pass_hint": "Di una palabra y pasa la bomba al vecino.",
		"explode_player_index": 0,
	},
]

const ROUNDS_HI: Array[Dictionary] = [
	{
		"syllable": "का",
		"condition": WordCondition.Type.BEGIN,
		"word_hint": "कार",
		"examples": "कार, कान, काव्य",
		"pass_hint": "शब्द ज़ोर से बोलें और बम आगे पास करने के लिए स्क्रीन टैप करें।",
		"explode_player_index": 0,
	},
	{
		"syllable": "र",
		"condition": WordCondition.Type.ANYWHERE,
		"word_hint": "गर्म",
		"examples": "गर्म, परदा, बर्फ",
		"pass_hint": "शब्द बोलें और जल्दी टैप करके बम पास करें।",
		"explode_player_index": 1,
	},
	{
		"syllable": "न",
		"condition": WordCondition.Type.END,
		"word_hint": "धन",
		"examples": "धन, कन, ज्ञान",
		"pass_hint": "शब्द बोलें और बम पड़ोसी को पास करें।",
		"explode_player_index": 0,
	},
]

const ROUNDS_DE: Array[Dictionary] = [
	{
		"syllable": "TRA",
		"condition": WordCondition.Type.BEGIN,
		"word_hint": "Traum",
		"examples": "Traum, Traktor, Transport",
		"pass_hint": "Sag ein Wort laut und tippe kurz auf den Bildschirm, um die Bombe weiterzugeben.",
		"explode_player_index": 0,
	},
	{
		"syllable": "AND",
		"condition": WordCondition.Type.ANYWHERE,
		"word_hint": "Hand",
		"examples": "Hand, Land, Band",
		"pass_hint": "Sag ein Wort und gib die Bombe mit einem schnellen Tipp weiter.",
		"explode_player_index": 1,
	},
	{
		"syllable": "END",
		"condition": WordCondition.Type.END,
		"word_hint": "Abend",
		"examples": "Abend, Lebend, Schlafend",
		"pass_hint": "Sag ein Wort und gib die Bombe an deinen Nachbarn weiter.",
		"explode_player_index": 0,
	},
]

const ROUNDS_FR: Array[Dictionary] = [
	{
		"syllable": "CH",
		"condition": WordCondition.Type.BEGIN,
		"word_hint": "chien",
		"examples": "chien, chat, chocolat",
		"pass_hint": "Dis un mot à voix haute et touche l'écran pour passer la bombe.",
		"explode_player_index": 0,
	},
	{
		"syllable": "ER",
		"condition": WordCondition.Type.ANYWHERE,
		"word_hint": "erreur",
		"examples": "erreur, mer, terre",
		"pass_hint": "Dis un mot et passe la bombe d'un tap rapide.",
		"explode_player_index": 1,
	},
	{
		"syllable": "AN",
		"condition": WordCondition.Type.END,
		"word_hint": "roman",
		"examples": "roman, écran, plan",
		"pass_hint": "Dis un mot et passe la bombe à ton voisin.",
		"explode_player_index": 0,
	},
]

const ROUNDS_IT: Array[Dictionary] = [
	{
		"syllable": "ST",
		"condition": WordCondition.Type.BEGIN,
		"word_hint": "stella",
		"examples": "stella, storia, strada",
		"pass_hint": "Di una parola ad alta voce e tocca lo schermo per passare la bomba.",
		"explode_player_index": 0,
	},
	{
		"syllable": "TR",
		"condition": WordCondition.Type.ANYWHERE,
		"word_hint": "metro",
		"examples": "metro, patria, contro",
		"pass_hint": "Di una parola e passa la bomba con un tocco rapido.",
		"explode_player_index": 1,
	},
	{
		"syllable": "ATO",
		"condition": WordCondition.Type.END,
		"word_hint": "formato",
		"examples": "formato, mercato, stato",
		"pass_hint": "Di una parola e passa la bomba al vicino.",
		"explode_player_index": 0,
	},
]

const ROUNDS_BY_LOCALE: Dictionary = {
	LocaleCatalog.LOCALE_RU: ROUNDS_RU,
	LocaleCatalog.LOCALE_EN: ROUNDS_EN,
	LocaleCatalog.LOCALE_SR: ROUNDS_SR,
	LocaleCatalog.LOCALE_ES: ROUNDS_ES,
	LocaleCatalog.LOCALE_HI: ROUNDS_HI,
	LocaleCatalog.LOCALE_DE: ROUNDS_DE,
	LocaleCatalog.LOCALE_FR: ROUNDS_FR,
	LocaleCatalog.LOCALE_IT: ROUNDS_IT,
}


static func rounds() -> Array[Dictionary]:
	var locale := LocaleService.get_locale()
	if ROUNDS_BY_LOCALE.has(locale):
		return ROUNDS_BY_LOCALE[locale]
	return ROUNDS_RU


static func deck_entries() -> Array:
	var entries: Array = []
	for round_def in rounds():
		entries.append({
			"syllable": round_def["syllable"],
			"condition": round_def["condition"],
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
	for round_def in rounds():
		if round_def["syllable"] == card.word and int(round_def["condition"]) == card.condition:
			return round_def
	return rounds()[0]


static func round_index_for_card(card: GameCard) -> int:
	if card == null:
		return 0
	var all := rounds()
	for i in all.size():
		var round_def: Dictionary = all[i]
		if round_def["syllable"] == card.word and int(round_def["condition"]) == card.condition:
			return i
	return 0


static func play_step_body_for_index(round_index: int) -> String:
	var round_def := round_at(round_index)
	return play_step_body(GameCard.new(str(round_def["syllable"]), int(round_def["condition"])))


static func play_step_body(card: GameCard) -> String:
	var round_def := round_for_card(card)
	var condition := WordCondition.get_label(int(round_def["condition"]))
	return LocaleService.text("TUTORIAL_PLAY_BODY") % [
		round_def["syllable"],
		condition,
		round_def["examples"],
		round_def["word_hint"],
		round_def["pass_hint"],
	]


static func explosion_explanation(player_name: String) -> String:
	var fallback := LocaleService.text("PLAYER_DEFAULT")
	var safe_name := player_name if not player_name.is_empty() else fallback
	return LocaleService.text("TUTORIAL_EXPLOSION") % safe_name
