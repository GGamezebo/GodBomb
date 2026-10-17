class_name LocaleStrings
extends RefCounted

## Rules footer (credits / sign-off) under the illustrated rule cards (`RULES_<KIND>_*`).
const RULES_TEXT_RU := """[font_size=36][b]Разработчики[/b][/font_size]
Екатерина Кровш — продакт-менеджер
Герман Гульдеров — sound-дизайнер
Игорь Белов — вайб-кодер

[center][font_size=40][b]Приятной игры![/b][/font_size][/center]"""

const RULES_TEXT_EN := """[font_size=36][b]Developers[/b][/font_size]
Ekaterina Krovsh — product manager
German Gulderov — sound designer
Igor Belov — vibe coder

[center][font_size=40][b]Have fun![/b][/font_size][/center]"""

const _RU: Dictionary = {
	"LANG_RU": "Русский",
	"LANG_EN": "English",
	"SETTINGS_TITLE": "Настройки",
	"SETTINGS_LANGUAGE": "Язык",
	"SETTINGS_GAME_TIME": "Длительность партии: %d мин",
	"SETTINGS_DIFFICULTY": "Сложность: %s",
	"SETTINGS_DIFFICULTY_EASY": "Лёгкая",
	"SETTINGS_DIFFICULTY_MEDIUM": "Средняя",
	"SETTINGS_DIFFICULTY_HARD": "Сложная",
	"SETTINGS_DIFFICULTY_HINT": "Меняет колоду: длина слогов и жёсткость условий",
	"TIME_PROGRESS_ROUNDS": "ещё ~%d раундов",
	"EMERGENCY_FIRST_HINT": "1) Выберите, кто переигрывает ход.\n2) «Продолжить» — партия идёт дальше.",
	"SETTINGS_MUSIC_MENU": "Музыка в меню",
	"SETTINGS_MUSIC_VOLUME": "Громкость музыки",
	"SETTINGS_SFX_VOLUME": "Громкость звуков",
	"SETTINGS_HAPTICS": "Вибрация",
	"SETTINGS_HAPTICS_STRENGTH": "Мощность вибрации",
	"SETTINGS_RESET_HINT": "Вернуть дефолтные настройки и имена игроков.",
	"SETTINGS_PRIVACY_POLICY": "Политика конфиденциальности",
	"SETTINGS_RESET": "Сбросить прогресс",
	"SETTINGS_RESET_CONFIRM": "Точно сбросить?",
	"SETTINGS_CLOSE": "Закрыть",
	"MENU_START": "СТАРТ",
	"RULES_TITLE": "Правила игры",
	"RULES_GAME_NAME": "Тик-Так-Бадабум",
	"RULES_SKIP": "Пропустить",
	"RULES_TUTORIAL": "Пройти обучение",
	"RULES_CLOSE": "Закрыть",
	"RULES_NEXT": "Дальше",
	"HINT_SWAP_IDLE": "Перетащи слайм на соседа — смените места",
	"HINT_SWAP_DRAG": "Отпусти — поменяетесь местами",
	"HINT_REMOVE": "Отпусти на «+» — убрать игрока",
	"HINT_MIN_PLAYERS": "Нужно минимум 2 игрока",
	"HINT_HOLD_EDIT": "Удержи 1,5 с — имя и цвет",
	"PLAYER_DEFAULT": "Игрок",
	"PLAYER_EDIT_PLACEHOLDER": "Имя (до 12 символов)",
	"EDIT_CANCEL": "Отмена",
	"EDIT_ADD": "Добавить",
	"EDIT_APPLY": "Применить",
	"WORD_COND_BEGIN": "Слог в начале слова",
	"WORD_COND_ANYWHERE": "Слог в любом месте",
	"WORD_COND_END": "Слог в конце слова",
	"WORD_COND_NOT_BEGIN": "Слог не в начале слова",
	"WORD_COND_NOT_END": "Слог не в конце слова",
	"LOADING": "ЗАГРУЗКА",
	"EXIT_CONFIRM_MESSAGE": "Завершить партию?",
	"EXIT_CANCEL": "Отмена",
	"EXIT_CONFIRM": "Выйти",
	"EMERGENCY_TITLE": "Аварийная пауза",
	"EMERGENCY_EXPLANATION": "Ошибка в слове или случайное нажатие? Выберите, кто переигрывает ход.",
	"EMERGENCY_CONTINUE": "Продолжить",
	"LOBBY_EXPLANATION": "Смените состав за столом — партия не прервётся.",
	"LOBBY_READY": "ГОТОВО",
	"RESULT_RANKING": "РЕЙТИНГ",
	"RESULT_WINNER": "ПОБЕДИТЕЛЬ",
	"RESULT_TOTAL_ROUNDS": "РАУНДОВ: %d",
	"RESULT_TO_MENU": "В МЕНЮ",
	"RESULT_PLAY_AGAIN": "ЕЩЁ РАЗ",
	"RESULT_STATS": "СТАТИСТИКА",
	"STATS_TITLE": "СТАТИСТИКА МАТЧА",
	"STATS_ROUNDS": "раундов",
	"STATS_DURATION": "время",
	"STATS_BOOMS": "взрывов",
	"STATS_OVERTIME": "овертайм",
	"STATS_PLAYERS": "ИГРОКИ",
	"STATS_TIMELINE": "ХРОНОЛОГИЯ",
	"STATS_POINTS": "%d очк.",
	"STATS_EXPLOSIONS": "Взрывов: %d",
	"STATS_IN_START": "Вход: с начала",
	"STATS_IN_AT": "Вход: раунд %d · %s",
	"STATS_OUT_END": "До конца матча",
	"STATS_OUT_AT": "Выход: раунд %d · %s",
	"STATS_OUT_KNOCKED": "Вылет: раунд %d · овертайм",
	"STATS_TAG_BOOM": "ВЗРЫВ",
	"STATS_TAG_JOIN": "ВХОД",
	"STATS_TAG_LEAVE": "ВЫХОД",
	"STATS_TAG_OUT": "ВЫЛЕТ",
	"STATS_ROUND_SHORT": "Р%d",
	"STATS_BACK": "НАЗАД",
	"STATS_NO_EVENTS": "Событий пока нет",
	"EXPLOSION_BOOM": "БУМ!",
	"ACTION_HINT_TAP": "Нажми экран — передай бомбу",
	"ACTION_HINT_TAP_TABLE": "Нажми экран — ход следующего",
	"TIME_PROGRESS_LABEL": "До конца игры",
	"TIME_PROGRESS_MINUTES": "%d мин",
	"HUD_LOTTERY": "Жребий — кто ходит первым?",
	"HUD_READY": "Готовы?",
	"HUD_START_ROUND": "Начать раунд",
	"HUD_START_ROUND_HINT": "Нажми «Начать раунд»",
	"HUD_TABLE_CENTER_HINT": "Положите телефон в центр стола",
	"ONBOARDING_SKIP": "Пропустить",
	"ONBOARDING_GOT_IT": "Понятно",
	"ONBOARDING_ADD_TITLE": "Соберите команду",
	"ONBOARDING_ADD_BODY": "Нажмите «+» и добавьте трёх игроков — так вы освоите стол.",
	"ONBOARDING_NAME_TITLE": "Дайте имена",
	"ONBOARDING_NAME_BODY": "Удержите слайм ~1,5 с — откроется имя и цвет. Так каждый узнает себя на экране.",
	"ONBOARDING_SWAP_TITLE": "Рассадка",
	"ONBOARDING_SWAP_BODY": "Перетащите одного слайма на другого — поменяетесь местами. Порядок на экране = порядок вокруг стола.",
	"ONBOARDING_START_TITLE": "В бой!",
	"ONBOARDING_START_BODY": "Когда все готовы — «СТАРТ». Для большой компании потом включите «телефон в центре» на столе.",
	"ONBOARDING_CHOICE_TITLE": "Жребий",
	"ONBOARDING_CHOICE_BODY": "Сейчас циферблат выберет, кто ходит первым. Следите за подсветкой игрока.",
	"ONBOARDING_READY_TITLE": "Старт раунда",
	"ONBOARDING_READY_BODY": "Нажмите «Начать раунд» внизу — пойдёт отсчёт, и бомба заведётся.",
	"ONBOARDING_PLAY_TITLE": "Ваш ход",
	"ONBOARDING_TIME_UP_TITLE": "Время вышло",
	"ONBOARDING_DONE_TITLE": "Обучение пройдено!",
	"ONBOARDING_DONE_BODY": "Правила ясны. Для 6–12 человек: режим «телефон в центре» — экран сам поворачивается к ходящему. Соберите друзей!",
	"TUTORIAL_PLAY_BODY": "Слог «%s» — %s.\nПодойдут слова: %s.\nНапример: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s не успел(а) — бомба взорвалась. Все остальные получают +1 очко.",
	"OVERTIME_TITLE": "Основное время истекло",
	"OVERTIME_BODY": "Играют только лидеры с одинаковым числом очков. Остальные выбывают.",
	"OVERTIME_STILL_IN": "ОСТАЮТСЯ",
	"OVERTIME_OUT": "ВЫБЫЛИ",
	"PLAYER_ELIMINATED": "%s выбывает из игры",
	"RULES_CIRCLE_TITLE": "Бомба по кругу",
	"RULES_CIRCLE_BODY": "Садитесь в круг — от 2 до 12 человек. Один телефон — это бомба: её передают друг другу по очереди.",
	"RULES_SYLLABLE_TITLE": "Слог и условие",
	"RULES_SYLLABLE_BODY": "На бомбе — слог и подсказка, где он должен стоять: в начале, в конце или где угодно в слове. Быстро придумайте подходящее слово.",
	"RULES_PASS_TITLE": "Сказал — передай",
	"RULES_PASS_BODY": "Назовите слово вслух, коротко коснитесь экрана и отдайте телефон соседу. Долгое касание не считается.",
	"RULES_BOOM_TITLE": "Бум!",
	"RULES_BOOM_BODY": "Таймер скрыт и каждый раз разный, перед взрывом бомба предупреждает. У кого взорвалась — без очка, все остальные получают +1.",
	"RULES_WIN_TITLE": "Кто победил",
	"RULES_WIN_BODY": "Длительность партии — в настройках, между раундами видно, сколько осталось. Больше очков — выше место. Ничья у лидеров — овертайм на вылет.",
	"RULES_LOBBY_TITLE": "Сбор игроков",
	"RULES_LOBBY_BODY": "«+» — добавить игрока. Удержите слайм 1,5 с — имя и цвет. Перетащите слайм на соседа — поменяться местами. Порядок за столом = порядок передачи.",
	"RULES_OOPS_TITLE": "Если накосячили",
	"RULES_OOPS_BODY": "Неверное слово или случайное касание? Аварийная кнопка ставит паузу — выберите, кто переигрывает ход. Состав меняется прямо в бою.",
	"RULES_CENTER_TITLE": "Телефон в центре",
	"RULES_CENTER_BODY": "Для компании 6–12 человек: включите режим «телефон в центре» и положите смартфон на стол. Текст сам поворачивается к тому, чей ход.",
	"RULES_ILL_SYLLABLE": "ЛО",
	"RULES_ILL_CONDITION": "в начале слова",
	"RULES_ILL_WORD_OK1": "[ЛО]дка",
	"RULES_ILL_WORD_OK2": "[ЛО]жка",
	"RULES_ILL_WORD_BAD": "мо[ЛО]ко",
	"RULES_ILL_SAY": "Лодка!",
	"RULES_ILL_TAP": "коротко коснуться",
	"RULES_ILL_MORE_POINTS": "больше очков — выше",
	"RULES_ILL_ADD": "добавить",
	"RULES_ILL_HOLD": "имя и цвет",
	"RULES_ILL_HOLD_TIME": "1,5 с",
	"RULES_ILL_SWAP": "поменяться",
	"RULES_ILL_EMERGENCY": "аварийная кнопка",
	"RULES_ILL_REPICK": "кто переигрывает",
	"ONBOARDING_STEP": "Шаг %d из %d",
}

const _EN: Dictionary = {
	"LANG_RU": "Русский",
	"LANG_EN": "English",
	"SETTINGS_TITLE": "Settings",
	"SETTINGS_LANGUAGE": "Language",
	"SETTINGS_GAME_TIME": "Match length: %d min",
	"SETTINGS_DIFFICULTY": "Difficulty: %s",
	"SETTINGS_DIFFICULTY_EASY": "Easy",
	"SETTINGS_DIFFICULTY_MEDIUM": "Medium",
	"SETTINGS_DIFFICULTY_HARD": "Hard",
	"SETTINGS_DIFFICULTY_HINT": "Changes the deck: syllable length and rule hardness",
	"TIME_PROGRESS_ROUNDS": "~%d rounds",
	"EMERGENCY_FIRST_HINT": "1) Pick who replays the turn.\n2) Tap Continue — the match goes on.",
	"SETTINGS_MUSIC_MENU": "Menu music",
	"SETTINGS_MUSIC_VOLUME": "Music volume",
	"SETTINGS_SFX_VOLUME": "Sound volume",
	"SETTINGS_HAPTICS": "Vibration",
	"SETTINGS_HAPTICS_STRENGTH": "Vibration strength",
	"SETTINGS_RESET_HINT": "Restore default settings and player names.",
	"SETTINGS_PRIVACY_POLICY": "Privacy policy",
	"SETTINGS_RESET": "Reset progress",
	"SETTINGS_RESET_CONFIRM": "Reset for sure?",
	"SETTINGS_CLOSE": "Close",
	"MENU_START": "START",
	"RULES_TITLE": "Game rules",
	"RULES_GAME_NAME": "Tic-Tac-Bada-Boom",
	"RULES_SKIP": "Skip",
	"RULES_TUTORIAL": "Start tutorial",
	"RULES_CLOSE": "Close",
	"RULES_NEXT": "Next",
	"HINT_SWAP_IDLE": "Drag a slime to a neighbor to swap seats",
	"HINT_SWAP_DRAG": "Release to swap places",
	"HINT_REMOVE": "Drop on «+» to remove player",
	"HINT_MIN_PLAYERS": "At least 2 players required",
	"HINT_HOLD_EDIT": "Hold 1.5 s for name and color",
	"PLAYER_DEFAULT": "Player",
	"PLAYER_EDIT_PLACEHOLDER": "Name (up to 12 chars)",
	"EDIT_CANCEL": "Cancel",
	"EDIT_ADD": "Add",
	"EDIT_APPLY": "Apply",
	"WORD_COND_BEGIN": "Syllable at word start",
	"WORD_COND_ANYWHERE": "Syllable anywhere",
	"WORD_COND_END": "Syllable at word end",
	"WORD_COND_NOT_BEGIN": "Syllable not at word start",
	"WORD_COND_NOT_END": "Syllable not at word end",
	"LOADING": "LOADING",
	"EXIT_CONFIRM_MESSAGE": "End the match?",
	"EXIT_CANCEL": "Cancel",
	"EXIT_CONFIRM": "Exit",
	"EMERGENCY_TITLE": "Emergency pause",
	"EMERGENCY_EXPLANATION": "Wrong word or accidental tap? Choose who replays the turn.",
	"EMERGENCY_CONTINUE": "Continue",
	"LOBBY_EXPLANATION": "Change the roster at the table — the match won't stop.",
	"LOBBY_READY": "DONE",
	"RESULT_RANKING": "RANKING",
	"RESULT_WINNER": "WINNER",
	"RESULT_TOTAL_ROUNDS": "ROUNDS: %d",
	"RESULT_TO_MENU": "TO MENU",
	"RESULT_PLAY_AGAIN": "PLAY AGAIN",
	"RESULT_STATS": "STATS",
	"STATS_TITLE": "MATCH STATS",
	"STATS_ROUNDS": "rounds",
	"STATS_DURATION": "time",
	"STATS_BOOMS": "booms",
	"STATS_OVERTIME": "overtime",
	"STATS_PLAYERS": "PLAYERS",
	"STATS_TIMELINE": "TIMELINE",
	"STATS_POINTS": "%d pts",
	"STATS_EXPLOSIONS": "Booms: %d",
	"STATS_IN_START": "In: from the start",
	"STATS_IN_AT": "In: round %d · %s",
	"STATS_OUT_END": "Played to the end",
	"STATS_OUT_AT": "Out: round %d · %s",
	"STATS_OUT_KNOCKED": "Knocked out: round %d · overtime",
	"STATS_TAG_BOOM": "BOOM",
	"STATS_TAG_JOIN": "JOIN",
	"STATS_TAG_LEAVE": "LEFT",
	"STATS_TAG_OUT": "OUT",
	"STATS_ROUND_SHORT": "R%d",
	"STATS_BACK": "BACK",
	"STATS_NO_EVENTS": "No events yet",
	"EXPLOSION_BOOM": "BOOM!",
	"ACTION_HINT_TAP": "Tap the screen — pass the bomb",
	"ACTION_HINT_TAP_TABLE": "Tap the screen — next player's turn",
	"TIME_PROGRESS_LABEL": "Until the end",
	"TIME_PROGRESS_MINUTES": "%d min",
	"HUD_LOTTERY": "Lottery — who goes first?",
	"HUD_READY": "Ready?",
	"HUD_START_ROUND": "Start round",
	"HUD_START_ROUND_HINT": "Tap «Start round»",
	"HUD_TABLE_CENTER_HINT": "Place the phone in the center of the table",
	"ONBOARDING_SKIP": "Skip",
	"ONBOARDING_GOT_IT": "Got it",
	"ONBOARDING_ADD_TITLE": "Build your team",
	"ONBOARDING_ADD_BODY": "Tap «+» and add three players to learn the table.",
	"ONBOARDING_NAME_TITLE": "Name everyone",
	"ONBOARDING_NAME_BODY": "Hold a slime ~1.5 s to open name and color. Everyone finds themselves on screen.",
	"ONBOARDING_SWAP_TITLE": "Seating",
	"ONBOARDING_SWAP_BODY": "Drag one slime onto another to swap seats. Screen order = order around the table.",
	"ONBOARDING_START_TITLE": "Into battle!",
	"ONBOARDING_START_BODY": "When everyone is ready — tap START. For a big table, turn on «phone in the center» later.",
	"ONBOARDING_CHOICE_TITLE": "Lottery",
	"ONBOARDING_CHOICE_BODY": "The dial will pick who goes first. Watch the highlighted player.",
	"ONBOARDING_READY_TITLE": "Start round",
	"ONBOARDING_READY_BODY": "Tap «Start round» at the bottom — countdown begins and the bomb starts ticking.",
	"ONBOARDING_PLAY_TITLE": "Your turn",
	"ONBOARDING_TIME_UP_TITLE": "Time's up",
	"ONBOARDING_DONE_TITLE": "Tutorial complete!",
	"ONBOARDING_DONE_BODY": "You know the rules. For 6–12 players: «phone in the center» turns the dial toward whoever's up. Gather friends!",
	"TUTORIAL_PLAY_BODY": "Syllable «%s» — %s.\nWords like: %s.\nFor example: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s ran out of time — the bomb exploded. Everyone else gets +1 point.",
	"OVERTIME_TITLE": "Regulation time is over",
	"OVERTIME_BODY": "Only the leaders tied on points keep playing. Everyone else is out.",
	"OVERTIME_STILL_IN": "STILL IN",
	"OVERTIME_OUT": "OUT",
	"PLAYER_ELIMINATED": "%s is out of the game",
	"RULES_CIRCLE_TITLE": "Bomb around the circle",
	"RULES_CIRCLE_BODY": "Sit in a circle — 2 to 12 players. One phone is the bomb: you pass it to each other in turn.",
	"RULES_SYLLABLE_TITLE": "Syllable and rule",
	"RULES_SYLLABLE_BODY": "The bomb shows a syllable and where it must be: at the start, at the end or anywhere in the word. Think of a fitting word fast.",
	"RULES_PASS_TITLE": "Say it — pass it",
	"RULES_PASS_BODY": "Say the word out loud, give the screen a quick tap and hand the phone to your neighbor. A long press doesn't count.",
	"RULES_BOOM_TITLE": "Boom!",
	"RULES_BOOM_BODY": "The timer is hidden and different every time; the bomb warns you before it blows. Whoever holds it gets nothing — everyone else gets +1.",
	"RULES_WIN_TITLE": "Who wins",
	"RULES_WIN_BODY": "Match length is in settings; between rounds you see how much time is left. Most points wins. A tie at the top — overtime knockout.",
	"RULES_LOBBY_TITLE": "Gather players",
	"RULES_LOBBY_BODY": "«+» adds a player. Hold a slime 1.5 s for name and color. Drag a slime onto another to swap seats. Order at the table = passing order.",
	"RULES_OOPS_TITLE": "Messed up?",
	"RULES_OOPS_BODY": "Wrong word or accidental tap? The emergency button pauses the game — pick who replays the turn. You can change the roster mid-match.",
	"RULES_CENTER_TITLE": "Phone in the center",
	"RULES_CENTER_BODY": "For 6–12 players: turn on «phone in the center» and lay the phone on the table. The text turns toward whoever's up.",
	"RULES_ILL_SYLLABLE": "BA",
	"RULES_ILL_CONDITION": "at the start",
	"RULES_ILL_WORD_OK1": "[Ba]nana",
	"RULES_ILL_WORD_OK2": "[Ba]sket",
	"RULES_ILL_WORD_BAD": "Tu[ba]",
	"RULES_ILL_SAY": "Banana!",
	"RULES_ILL_TAP": "quick tap",
	"RULES_ILL_MORE_POINTS": "more points — higher",
	"RULES_ILL_ADD": "add",
	"RULES_ILL_HOLD": "name & color",
	"RULES_ILL_HOLD_TIME": "1.5 s",
	"RULES_ILL_SWAP": "swap seats",
	"RULES_ILL_EMERGENCY": "emergency button",
	"RULES_ILL_REPICK": "who replays",
	"ONBOARDING_STEP": "Step %d of %d",
}

const _SLIME_RU: Array[String] = [
	"Помидор", "Аватар", "Огурчик", "Креветка", "Апельсин", "Цыплёнок",
	"Уголёк", "Сахарок", "Баклажан", "Шоколадка", "Смузи", "Киви",
]

const _SLIME_EN: Array[String] = [
	"Tomato", "Avatar", "Pickle", "Shrimp", "Orange", "Chick",
	"Coal", "Sugar", "Eggplant", "Chocolate", "Smoothie", "Kiwi",
]


## Pre-2026-10 default names (colors), same index order. Still recognized as
## defaults so saved rosters get remapped to the current names.
const _LEGACY_SLIME_NAMES: Array = [
	[
		"Красный", "Синий", "Зелёный", "Розовый", "Оранжевый", "Жёлтый",
		"Чёрный", "Белый", "Фиолетовый", "Коричневый", "Бирюзовый", "Лайм",
	],
	[
		"Red", "Blue", "Green", "Pink", "Orange", "Yellow",
		"Black", "White", "Purple", "Brown", "Cyan", "Lime",
	],
	[
		"Crvena", "Plava", "Zelena", "Roze", "Narandžasta", "Žuta",
		"Crna", "Bela", "Ljubičasta", "Braon", "Tirkizna", "Limeta",
	],
	[
		"Rojo", "Azul", "Verde", "Rosa", "Naranja", "Amarillo",
		"Negro", "Blanco", "Morado", "Marrón", "Cian", "Lima",
	],
	[
		"लाल", "नीला", "हरा", "गुलाबी", "नारंगी", "पीला",
		"काला", "सफ़ेद", "बैंगनी", "भूरा", "सियान", "लाइम",
	],
	[
		"Rot", "Blau", "Grün", "Pink", "Orange", "Gelb",
		"Schwarz", "Weiß", "Lila", "Braun", "Türkis", "Limette",
	],
	[
		"Rouge", "Bleu", "Vert", "Rose", "Orange", "Jaune",
		"Noir", "Blanc", "Violet", "Marron", "Cyan", "Citron vert",
	],
	[
		"Rosso", "Blu", "Verde", "Rosa", "Arancione", "Giallo",
		"Nero", "Bianco", "Viola", "Marrone", "Ciano", "Lime",
	],
]


static func lookup(locale: String, key: String) -> String:
	if key.begins_with("LANG_"):
		return LocaleCatalog.native_name(key.substr(5).to_lower())
	var normalized := LocaleCatalog.normalize(locale)
	match normalized:
		LocaleCatalog.LOCALE_EN:
			return str(_EN.get(key, key))
		LocaleCatalog.LOCALE_RU:
			return str(_RU.get(key, key))
		_:
			var extra := LocaleStringsLocales.ui_table(normalized)
			if extra.has(key):
				return str(extra[key])
			return str(_EN.get(key, key))


static func get_rules_text(locale: String) -> String:
	var normalized := LocaleCatalog.normalize(locale)
	match normalized:
		LocaleCatalog.LOCALE_EN:
			return RULES_TEXT_EN
		LocaleCatalog.LOCALE_RU:
			return RULES_TEXT_RU
		_:
			var extra := LocaleStringsLocales.rules_text(normalized)
			if not extra.is_empty():
				return extra
			return RULES_TEXT_EN


static func get_slime_names(locale: String) -> Array[String]:
	var normalized := LocaleCatalog.normalize(locale)
	match normalized:
		LocaleCatalog.LOCALE_EN:
			return _SLIME_EN.duplicate()
		LocaleCatalog.LOCALE_RU:
			return _SLIME_RU.duplicate()
		_:
			var extra := LocaleStringsLocales.slime_names(normalized)
			if not extra.is_empty():
				return extra
			return _SLIME_EN.duplicate()


static func get_slime_name(locale: String, preset_id: int) -> String:
	var names := get_slime_names(locale)
	if preset_id < 0 or preset_id >= names.size():
		return ""
	return names[preset_id]


## Returns the color index if `player_name` matches a default slime name (current
## or legacy) in any supported locale, otherwise -1. Colors share the same order across locales,
## so the index is unambiguous regardless of the source language.
static func default_slime_index(player_name: String) -> int:
	var trimmed := player_name.strip_edges()
	if trimmed.is_empty():
		return -1
	for locale: String in LocaleCatalog.ORDER:
		var names := get_slime_names(locale)
		for i in names.size():
			if names[i].strip_edges() == trimmed:
				return i
	for names: Array in _LEGACY_SLIME_NAMES:
		var legacy_index := names.find(trimmed)
		if legacy_index >= 0:
			return legacy_index
	return -1


## If `player_name` is a default color name (in any locale), returns the matching
## default name for `target_locale`; otherwise returns `player_name` unchanged.
static func remap_default_name(player_name: String, target_locale: String) -> String:
	var index := default_slime_index(player_name)
	if index < 0:
		return player_name
	return get_slime_name(target_locale, index)
