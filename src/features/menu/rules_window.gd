class_name RulesWindow
extends Control

const RULES_TEXT := """[font_size=36]Весёлая словесная игра на одном экране: садитесь кругом, бомба ходит по очереди, вы на лету придумываете слова. Не успели — бум и штраф. Для двоих и для большой компании.

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

const SCROLL_TRACK := Color(0.08, 0.06, 0.05, 0.42)
const SCROLL_GRABBER := Color(0.78, 0.48, 0.28, 0.9)
const SCROLL_GRABBER_HI := Color(0.94, 0.6, 0.34, 0.98)

@export var rules_scroll: ScrollContainer
@export var rules_text: RichTextLabel
@export var close_button: StartActionButton

var _layout_pending := false


func _ready() -> void:
	visible = false
	if rules_text:
		rules_text.text = RULES_TEXT
		rules_text.scroll_active = false
		rules_text.fit_content = true
		rules_text.bbcode_enabled = true
		rules_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if rules_scroll:
		_configure_scroll(rules_scroll)
		if not rules_scroll.resized.is_connected(_queue_rules_layout):
			rules_scroll.resized.connect(_queue_rules_layout)
	if close_button:
		close_button.pressed.connect(close)
		UiSounds.bind_button(close_button)
	call_deferred("_update_modal_layer_visibility")
	call_deferred("_queue_rules_layout")


func open() -> void:
	visible = true
	_show_modal_layer()
	if rules_scroll:
		rules_scroll.scroll_vertical = 0
	_queue_rules_layout()
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


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and visible:
		_queue_rules_layout()


func _queue_rules_layout() -> void:
	if _layout_pending:
		return
	_layout_pending = true
	call_deferred("_sync_rules_text_layout")


func _sync_rules_text_layout() -> void:
	_layout_pending = false
	if rules_scroll == null or rules_text == null:
		return
	var width := int(floorf(rules_scroll.size.x))
	if width <= 1:
		return
	var text_width := maxi(width - 18, 1)
	rules_text.custom_minimum_size = Vector2(text_width, 0.0)
	rules_text.size.x = text_width
	rules_text.fit_content = true
	await get_tree().process_frame
	var content_h := maxf(rules_text.get_content_height(), rules_text.size.y)
	rules_text.custom_minimum_size = Vector2(text_width, content_h)
	rules_text.size = rules_text.custom_minimum_size


static func _configure_scroll(scroll: ScrollContainer) -> void:
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 16
	scroll.scroll_vertical_custom_step = 80.0
	scroll.clip_contents = true
	_style_vertical_scroll_bar(scroll.get_v_scroll_bar())


static func _style_vertical_scroll_bar(bar: VScrollBar) -> void:
	if bar == null:
		return
	bar.custom_minimum_size.x = 12
	var track := StyleBoxFlat.new()
	track.bg_color = SCROLL_TRACK
	track.set_corner_radius_all(6)
	track.content_margin_top = 6.0
	track.content_margin_bottom = 6.0
	track.content_margin_left = 2.0
	track.content_margin_right = 2.0
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = SCROLL_GRABBER
	grabber.set_corner_radius_all(6)
	var grabber_hi := grabber.duplicate() as StyleBoxFlat
	grabber_hi.bg_color = SCROLL_GRABBER_HI
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("grabber", grabber)
	bar.add_theme_stylebox_override("grabber_highlight", grabber_hi)
	bar.add_theme_constant_override("minimum_grabber_size", 64)


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
