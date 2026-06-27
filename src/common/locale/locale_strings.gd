class_name LocaleStrings
extends RefCounted

const RULES_TEXT_RU := """[font_size=36]Весёлая словесная игра для вечеринок на одном экране: садитесь с друзьями кругом, бомба-телефон передаётся друг другу по очереди, вы на лету придумываете слова. Не успели — бум и штраф. Для двоих и для большой компании.

[font_size=40][b]Как играть?[/b][/font_size]
На циферблате — слог, например «ЛО», и подсказка: слог в начале, в конце или в любом месте слова.

Назовите слово вслух и передайте бомбу соседу — коротким нажатием на экран.

Лодка — полотно — весло — алоэ — ло… бум! У кого бомба взорвалась — +1 штраф.

Сначала жребий выбирает первого. Потом «Готовы?», отсчёт — и раунд пошёл.

[font_size=40][b]Когда бум?[/b][/font_size]
Каждый раз по-своему: таймер случайный. Может рвануть сразу, а может дать много кругов. Перед взрывом бомба предупреждает.

Между раундами мелькает полоска — сколько партии ещё осталось.

[font_size=40][b]Кто победил?[/b][/font_size]
В конце — таблица результатов. Меньше штрафов — выше место.

[font_size=40][b]Сбор игроков[/b][/font_size]
От 2 до 12 человек. [b]+[/b] — добавить, перетащите слайм на соседа — сменить место, удержите 1,5 с — имя и цвет.

В настройках — длительность партии, от неё зависит число раундов.

[font_size=40][b]Если накосячили[/b][/font_size]
Неверное слово или ложное нажатие? Аварийная кнопка в бою — выберите, кто переигрывает ход. Состав можно поправить через кнопку со списком игроков.


[font_size=24][color=#ffffff18]————————————————[/color][/font_size]


[font_size=36][b]Разработчики[/b][/font_size]
Екатерина Кровш — продакт-менеджер
Герман Гульдеров — sound-дизайнер
Игорь Белов — вайб-кодер

[center][font_size=40][b]Приятной игры![/b][/font_size][/center]"""

const RULES_TEXT_EN := """[font_size=36]A fun word party game on one screen: sit in a circle with friends, pass the phone-bomb in turn, and make up words on the fly. Too slow — boom and a penalty. For two players or a big group.

[font_size=40][b]How to play?[/b][/font_size]
The dial shows a syllable, e.g. «LO», and a hint: at the start, end, or anywhere in the word.

Say a word out loud and pass the bomb to your neighbor — with a quick tap on the screen.

Boat — canvas — paddle — aloe — lo… boom! Whoever gets caught with the bomb gets +1 penalty.

First, a lottery picks who goes first. Then «Ready?», countdown — and the round begins.

[font_size=40][b]When does it boom?[/b][/font_size]
Every time is different: the timer is random. It may blow up right away or give you many turns. The bomb warns you before exploding.

Between rounds a bar flashes — how much of the match is left.

[font_size=40][b]Who wins?[/b][/font_size]
At the end — a scoreboard. Fewer penalties — higher rank.

[font_size=40][b]Gathering players[/b][/font_size]
2 to 12 people. [b]+[/b] to add, drag a slime onto a neighbor to swap seats, hold 1.5 s for name and color.

In settings — match length, which sets the number of rounds.

[font_size=40][b]Made a mistake?[/b][/font_size]
Wrong word or accidental tap? The emergency button in battle — pick who replays the turn. Adjust the roster via the player list button.


[font_size=24][color=#ffffff18]————————————————[/color][/font_size]


[font_size=36][b]Developers[/b][/font_size]
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
	"SETTINGS_MUSIC_MENU": "Музыка в меню",
	"SETTINGS_MUSIC_VOLUME": "Громкость музыки",
	"SETTINGS_SFX_VOLUME": "Громкость звуков",
	"SETTINGS_HAPTICS": "Вибрация",
	"SETTINGS_HAPTICS_STRENGTH": "Мощность вибрации",
	"SETTINGS_RESET_HINT": "Сбросит настройки, подсказки и имена игроков по умолчанию.",
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
	"RESULT_FEWER_PENALTIES": "МЕНЬШЕ ШТРАФОВ",
	"RESULT_TO_MENU": "В МЕНЮ",
	"EXPLOSION_BOOM": "БУМ!",
	"ACTION_HINT_TAP": "Нажми экран — передай бомбу",
	"TIME_PROGRESS_LABEL": "До конца партии",
	"HUD_LOTTERY": "Жребий — кто ходит первым?",
	"HUD_READY": "Готовы?",
	"HUD_START_ROUND": "Начать раунд",
	"HUD_START_ROUND_HINT": "Нажми «Начать раунд»",
	"ONBOARDING_SKIP": "Пропустить",
	"ONBOARDING_GOT_IT": "Понятно",
	"ONBOARDING_ADD_TITLE": "Соберите команду",
	"ONBOARDING_ADD_BODY": "Нажмите «+» и добавьте трёх игроков — так вы освоите стол.",
	"ONBOARDING_NAME_TITLE": "Дайте имена",
	"ONBOARDING_NAME_BODY": "Удержите слайм ~1,5 с — откроется имя и цвет. Так каждый узнает себя на экране.",
	"ONBOARDING_SWAP_TITLE": "Рассадка",
	"ONBOARDING_SWAP_BODY": "Перетащите одного слайма на другого — поменяетесь местами. Порядок на экране = порядок вокруг стола.",
	"ONBOARDING_START_TITLE": "В бой!",
	"ONBOARDING_START_BODY": "Когда все готовы — нажмите «СТАРТ». Покажем бой на практике — три коротких раунда.",
	"ONBOARDING_CHOICE_TITLE": "Жребий",
	"ONBOARDING_CHOICE_BODY": "Сейчас циферблат выберет, кто ходит первым. Следите за подсветкой игрока.",
	"ONBOARDING_READY_TITLE": "Старт раунда",
	"ONBOARDING_READY_BODY": "Нажмите «Начать раунд» внизу — пойдёт отсчёт, и бомба заведётся.",
	"ONBOARDING_PLAY_TITLE": "Ваш ход",
	"ONBOARDING_TIME_UP_TITLE": "Время вышло",
	"ONBOARDING_DONE_TITLE": "Обучение пройдено!",
	"ONBOARDING_DONE_BODY": "Теперь вы знаете правила Тик-Так-Бадабум. Соберите друзей и играйте!",
	"TUTORIAL_PLAY_BODY": "Слог «%s» — %s.\nПодойдут слова: %s.\nНапример: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s не успел(а) придумать слово — бомба взорвалась.",
}

const _EN: Dictionary = {
	"LANG_RU": "Русский",
	"LANG_EN": "English",
	"SETTINGS_TITLE": "Settings",
	"SETTINGS_LANGUAGE": "Language",
	"SETTINGS_GAME_TIME": "Match length: %d min",
	"SETTINGS_MUSIC_MENU": "Menu music",
	"SETTINGS_MUSIC_VOLUME": "Music volume",
	"SETTINGS_SFX_VOLUME": "Sound volume",
	"SETTINGS_HAPTICS": "Vibration",
	"SETTINGS_HAPTICS_STRENGTH": "Vibration strength",
	"SETTINGS_RESET_HINT": "Resets settings, hints, and default player names.",
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
	"RESULT_FEWER_PENALTIES": "FEWER PENALTIES",
	"RESULT_TO_MENU": "TO MENU",
	"EXPLOSION_BOOM": "BOOM!",
	"ACTION_HINT_TAP": "Tap the screen — pass the bomb",
	"TIME_PROGRESS_LABEL": "Match time left",
	"HUD_LOTTERY": "Lottery — who goes first?",
	"HUD_READY": "Ready?",
	"HUD_START_ROUND": "Start round",
	"HUD_START_ROUND_HINT": "Tap «Start round»",
	"ONBOARDING_SKIP": "Skip",
	"ONBOARDING_GOT_IT": "Got it",
	"ONBOARDING_ADD_TITLE": "Build your team",
	"ONBOARDING_ADD_BODY": "Tap «+» and add three players to learn the table.",
	"ONBOARDING_NAME_TITLE": "Name everyone",
	"ONBOARDING_NAME_BODY": "Hold a slime ~1.5 s to open name and color. Everyone finds themselves on screen.",
	"ONBOARDING_SWAP_TITLE": "Seating",
	"ONBOARDING_SWAP_BODY": "Drag one slime onto another to swap seats. Screen order = order around the table.",
	"ONBOARDING_START_TITLE": "Into battle!",
	"ONBOARDING_START_BODY": "When everyone is ready — tap «START». We'll show a short battle — three quick rounds.",
	"ONBOARDING_CHOICE_TITLE": "Lottery",
	"ONBOARDING_CHOICE_BODY": "The dial will pick who goes first. Watch the highlighted player.",
	"ONBOARDING_READY_TITLE": "Start round",
	"ONBOARDING_READY_BODY": "Tap «Start round» at the bottom — countdown begins and the bomb starts ticking.",
	"ONBOARDING_PLAY_TITLE": "Your turn",
	"ONBOARDING_TIME_UP_TITLE": "Time's up",
	"ONBOARDING_DONE_TITLE": "Tutorial complete!",
	"ONBOARDING_DONE_BODY": "Now you know the rules of Tic-Tac-Bada-Boom. Gather friends and play!",
	"TUTORIAL_PLAY_BODY": "Syllable «%s» — %s.\nWords like: %s.\nFor example: «%s».\n%s",
	"TUTORIAL_EXPLOSION": "%s ran out of time — the bomb exploded.",
}

const _SLIME_RU: Array[String] = [
	"Красный", "Синий", "Зелёный", "Розовый", "Оранжевый", "Жёлтый",
	"Чёрный", "Белый", "Фиолетовый", "Коричневый", "Бирюзовый", "Лайм",
]

const _SLIME_EN: Array[String] = [
	"Red", "Blue", "Green", "Pink", "Orange", "Yellow",
	"Black", "White", "Purple", "Brown", "Cyan", "Lime",
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
