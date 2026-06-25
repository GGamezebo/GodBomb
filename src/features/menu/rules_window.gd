class_name RulesWindow
extends Control

const RULES_TEXT := """[font_size=52][b]Правила игры «Бомба»[/b][/font_size]

[font_size=38]Соберите компанию от 2 до 12 игроков за столом.

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
• Перетащи персонажа на стул другого персонажа для смены места.
• Удержание 1,5 секунды — изменить имя и цвет слайма."""

@export var rules_text: RichTextLabel
@export var close_button: StartActionButton


func _ready() -> void:
	visible = false
	if rules_text:
		rules_text.text = RULES_TEXT
	if close_button:
		close_button.pressed.connect(close)
		UiSounds.bind_button(close_button)
	call_deferred("_update_modal_layer_visibility")


func open() -> void:
	visible = true
	_show_modal_layer()
	UiSounds.play_modal_open()


func close() -> void:
	visible = false
	_update_modal_layer_visibility()
	UiSounds.play_modal_close()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _show_modal_layer() -> void:
	if get_parent() is CanvasLayer:
		(get_parent() as CanvasLayer).visible = true


func _update_modal_layer_visibility() -> void:
	var layer := get_parent() as CanvasLayer
	if not layer:
		return
	for child in layer.get_children():
		if child is Control and child.visible:
			layer.visible = true
			return
	layer.visible = false
