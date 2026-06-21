class_name GameSyllableCard
extends Control

const ACCENT := TurnOrderArrowsLayer.ACCENT
const DIAL_SIZE := Vector2(440, 440)
const MAIN_TEXT_MAX_WIDTH := 400.0

var _main_label: RichTextLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = DIAL_SIZE
	size = DIAL_SIZE
	z_index = 2

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_bottom", 162)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	add_child(margin)

	var main_host := CenterContainer.new()
	main_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(main_host)

	_main_label = RichTextLabel.new()
	_main_label.bbcode_enabled = true
	_main_label.fit_content = true
	_main_label.scroll_active = false
	_main_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_main_label.custom_minimum_size = Vector2(MAIN_TEXT_MAX_WIDTH, 0)
	_main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_host.add_child(_main_label)


func set_card(card: GameCard) -> void:
	if not is_inside_tree():
		await ready
	_main_label.text = WordCondition.get_pattern_display_bbcode(
		card.word, card.condition, MAIN_TEXT_MAX_WIDTH
	)


func set_message(title: String) -> void:
	if not is_inside_tree():
		await ready
	_main_label.text = WordCondition.get_message_display_bbcode(title, MAIN_TEXT_MAX_WIDTH)


func pulse_next_turn() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.04, 1.04), 0.08).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_SINE)
