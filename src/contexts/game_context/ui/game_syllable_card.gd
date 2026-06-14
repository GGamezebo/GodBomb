class_name GameSyllableCard
extends Control

const ACCENT := TurnOrderArrowsLayer.ACCENT
const DIAL_SIZE := Vector2(440, 440)

var _condition_label: Label
var _syllable_label: Label
var _pattern_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = DIAL_SIZE
	size = DIAL_SIZE

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(col)

	_condition_label = Label.new()
	_condition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_condition_label.add_theme_font_size_override("font_size", 24)
	_condition_label.add_theme_color_override("font_color", Color(0.82, 0.68, 0.48, 0.95))
	col.add_child(_condition_label)

	_syllable_label = Label.new()
	_syllable_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_syllable_label.add_theme_font_size_override("font_size", 92)
	_syllable_label.add_theme_color_override("font_color", Color(0.98, 0.94, 0.86, 1))
	_syllable_label.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.75))
	_syllable_label.add_theme_constant_override("outline_size", 3)
	col.add_child(_syllable_label)

	_pattern_label = Label.new()
	_pattern_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pattern_label.add_theme_font_size_override("font_size", 32)
	_pattern_label.add_theme_color_override("font_color", Color(0.72, 0.58, 0.42, 0.9))
	col.add_child(_pattern_label)


func set_card(card: GameCard) -> void:
	if not is_inside_tree():
		await ready
	_condition_label.text = WordCondition.get_label(card.condition)
	_syllable_label.text = card.word
	_pattern_label.text = WordCondition.get_pattern_hint(card.word, card.condition)


func set_message(title: String, subtitle: String = "") -> void:
	if not is_inside_tree():
		await ready
	_condition_label.text = subtitle
	_syllable_label.text = title
	_pattern_label.text = ""


func pulse_next_turn() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.04, 1.04), 0.08).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_SINE)
