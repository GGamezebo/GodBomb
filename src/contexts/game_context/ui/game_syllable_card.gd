class_name GameSyllableCard
extends PanelContainer

const ACCENT := TurnOrderArrowsLayer.ACCENT

var _condition_label: Label
var _syllable_label: Label
var _pattern_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(880, 340)
	_apply_panel_style()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	margin.add_child(col)

	_condition_label = Label.new()
	_condition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_condition_label.add_theme_font_size_override("font_size", 26)
	_condition_label.add_theme_color_override("font_color", Color(0.45, 0.32, 0.22, 1))
	col.add_child(_condition_label)

	_syllable_label = Label.new()
	_syllable_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_syllable_label.add_theme_font_size_override("font_size", 96)
	_syllable_label.add_theme_color_override("font_color", Color(0.12, 0.08, 0.06, 1))
	col.add_child(_syllable_label)

	_pattern_label = Label.new()
	_pattern_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pattern_label.add_theme_font_size_override("font_size", 36)
	_pattern_label.add_theme_color_override("font_color", Color(0.35, 0.28, 0.22, 0.85))
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


func _apply_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.995, 0.98, 0.97)
	style.border_color = ACCENT.lightened(0.15)
	style.set_border_width_all(3)
	style.set_corner_radius_all(28)
	style.shadow_color = Color(0.96, 0.28, 0.05, 0.12)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 5)
	add_theme_stylebox_override("panel", style)
