class_name RulesWindow
extends Control

signal onboarding_continue_pressed
signal tutorial_requested

## Illustrated rule cards, in order; locale keys RULES_<NAME>_TITLE / _BODY.
const RULE_CARDS := {
	"CIRCLE": RulesIllustration.Kind.CIRCLE,
	"SYLLABLE": RulesIllustration.Kind.SYLLABLE,
	"PASS": RulesIllustration.Kind.PASS,
	"BOOM": RulesIllustration.Kind.BOOM,
	"WIN": RulesIllustration.Kind.WIN,
	"LOBBY": RulesIllustration.Kind.LOBBY,
	"OOPS": RulesIllustration.Kind.OOPS,
	"CENTER": RulesIllustration.Kind.CENTER,
}
const CARD_BG := Color(1.0, 0.98, 0.94, 0.05)
const CARD_BORDER := Color(0.88, 0.62, 0.38, 0.38)
const CARD_TITLE_COLOR := Color(0.99, 0.96, 0.9, 1.0)
const CARD_BODY_COLOR := Color(0.92, 0.88, 0.82, 0.95)
const BADGE_COLOR := Color(0.88, 0.62, 0.38, 0.95)

@export var rules_scroll: ScrollContainer
@export var rules_text: RichTextLabel
@export var close_button: StartActionButton
@export var tutorial_button: StartActionButton
@export var onboarding_skip_button: Button

var _layout_pending := false
var _onboarding_mode := false
var _layout_width := -1
var _card_titles: Dictionary = {}
var _card_bodies: Dictionary = {}
var _illustrations: Array[RulesIllustration] = []


func _ready() -> void:
	visible = false
	if not LocaleService.locale_changed.is_connected(refresh_localized):
		LocaleService.locale_changed.connect(refresh_localized)
	if rules_text:
		rules_text.text = LocaleService.get_rules_text()
		rules_text.scroll_active = false
		rules_text.fit_content = true
		rules_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rules_text.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		rules_text.bbcode_enabled = true
		rules_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_rule_cards()
	if rules_scroll:
		ModalScroll.configure(rules_scroll)
		if not rules_scroll.resized.is_connected(_queue_rules_layout):
			rules_scroll.resized.connect(_queue_rules_layout)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		UiSounds.bind_button(close_button)
	if tutorial_button:
		tutorial_button.pressed.connect(_on_tutorial_pressed)
		UiSounds.bind_button(tutorial_button, &"confirm")
	if onboarding_skip_button:
		onboarding_skip_button.pressed.connect(_on_onboarding_skip_pressed)
		UiSounds.bind_button(onboarding_skip_button)
	_apply_mode_ui()
	call_deferred("_update_modal_layer_visibility")
	call_deferred("_queue_rules_layout")
	refresh_localized()
	if get_tree().current_scene == self:
		call_deferred("open")


func refresh_localized(_locale: String = "") -> void:
	if rules_text:
		rules_text.text = LocaleService.get_rules_text()
	for card_name: String in _card_titles:
		(_card_titles[card_name] as Label).text = LocaleService.text("RULES_%s_TITLE" % card_name)
		(_card_bodies[card_name] as Label).text = LocaleService.text("RULES_%s_BODY" % card_name)
	for illustration in _illustrations:
		illustration.queue_redraw()
	var title := get_node_or_null("Panel/Margin/VBox/TitleBlock/TitleRules") as Label
	if title:
		title.text = LocaleService.text("RULES_TITLE")
	var subtitle := get_node_or_null("Panel/Margin/VBox/TitleBlock/TitleGame") as Label
	if subtitle:
		subtitle.text = LocaleService.text("RULES_GAME_NAME")
	if onboarding_skip_button:
		onboarding_skip_button.text = LocaleService.text("RULES_SKIP")
	if tutorial_button:
		tutorial_button.action_text = LocaleService.text("RULES_TUTORIAL")
	_apply_mode_ui()


func _build_rule_cards() -> void:
	if rules_text == null or not _card_titles.is_empty():
		return
	var content := rules_text.get_parent() as VBoxContainer
	if content == null:
		return
	content.add_theme_constant_override("separation", 28)
	var number := 0
	for card_name: String in RULE_CARDS:
		number += 1
		var card := _build_rule_card(card_name, RULE_CARDS[card_name], number)
		content.add_child(card)
		content.move_child(card, rules_text.get_index())


func _build_rule_card(card_name: String, kind: RulesIllustration.Kind, number: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "Rule%s" % card_name.capitalize()
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_theme_stylebox_override("panel", _rounded_style(CARD_BG, CARD_BORDER, 28, 22))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	card.add_child(column)

	var frame := PanelContainer.new()
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_theme_stylebox_override("panel", _rounded_style(Color(0.0, 0.0, 0.0, 0.3), Color(0, 0, 0, 0), 20, 6))
	column.add_child(frame)
	var illustration := RulesIllustration.new()
	illustration.kind = kind
	illustration.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	frame.add_child(illustration)
	_illustrations.append(illustration)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	column.add_child(header)
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(56.0, 56.0)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.add_theme_stylebox_override("panel", _rounded_style(BADGE_COLOR, Color(0, 0, 0, 0), 28, 0))
	var badge_label := _card_label(str(number), 32, Color(0.1, 0.06, 0.03, 1.0))
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_child(badge_label)
	header.add_child(badge)
	var title := _card_label("", 46, CARD_TITLE_COLOR)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var body := _card_label("", 36, CARD_BODY_COLOR)
	column.add_child(body)
	_card_titles[card_name] = title
	_card_bodies[card_name] = body
	return card


func _card_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


static func _rounded_style(bg: Color, border: Color, radius: int, padding: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2 if border.a > 0.0 else 0)
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(padding)
	style.anti_aliasing = true
	return style


func open() -> void:
	_onboarding_mode = false
	_apply_mode_ui()
	_open_common()


func open_for_onboarding() -> void:
	_onboarding_mode = true
	_apply_mode_ui()
	_open_common()


func _open_common() -> void:
	visible = true
	_show_modal_layer()
	_layout_width = -1
	if rules_scroll:
		ModalScroll.reset_position(rules_scroll)
	_queue_rules_layout()
	UiSounds.play_modal_open()


func close() -> void:
	_onboarding_mode = false
	_apply_mode_ui()
	visible = false
	_update_modal_layer_visibility()
	UiSounds.play_modal_close()


func _on_close_pressed() -> void:
	if _onboarding_mode:
		onboarding_continue_pressed.emit()
	close()


func _on_tutorial_pressed() -> void:
	close()
	tutorial_requested.emit()


func _on_onboarding_skip_pressed() -> void:
	close()
	var controller := OnboardingController.get_controller(get_tree())
	if controller:
		controller.skip_current_step()


func _apply_mode_ui() -> void:
	if close_button:
		close_button.action_text = (
			LocaleService.text("RULES_NEXT") if _onboarding_mode else LocaleService.text("RULES_CLOSE")
		)
		close_button.disabled = false
	if tutorial_button:
		tutorial_button.visible = not _onboarding_mode
	if onboarding_skip_button:
		onboarding_skip_button.visible = _onboarding_mode


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if _onboarding_mode:
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
	if text_width == _layout_width:
		return
	_layout_width = text_width

	rules_text.fit_content = true
	rules_text.custom_minimum_size.x = text_width
	rules_text.custom_maximum_size.x = text_width
	await get_tree().process_frame
	if rules_scroll:
		ModalScroll.reset_position(rules_scroll)


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
