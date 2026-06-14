class_name RulesWindow
extends Control

const RULES_TEXT := """[font_size=34][b]Правила игры «Бомба»[/b][/font_size]

[font_size=26]Соберите компанию от 2 до 12 игроков за столом.

[b]Цель[/b]
Не оказаться с «горящей» бомбой в руках, когда время выйдет. У кого меньше штрафных очков — тот победил.

[b]Ход партии[/b]
• Игроки ходят по кругу.
• На карточке — слог. Нужно назвать слово с этим слогом и передать бомбу дальше.
• [b]Тап[/b] по экрану — передать бомбу следующему.
• [b]Длинный свайп[/b] — вернуть предыдущему (один раз за раунд).
• Бомба взрывается через случайное время. Игрок с бомбой получает штрафное очко.

[b]Лобби[/b]
• Кнопка «+» — добавить игрока.
• Перетаскивание на другое место — поменяться местами.
• Удержание 2 секунды — изменить имя и цвет слайма."""

@export var rules_text: RichTextLabel
@export var close_button: Button


func _ready() -> void:
	visible = false
	if rules_text:
		rules_text.text = RULES_TEXT
	if close_button:
		close_button.pressed.connect(close)


func open() -> void:
	visible = true


func close() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
