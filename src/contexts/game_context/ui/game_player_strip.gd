class_name GamePlayerStrip
extends Control

const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"
const PLATE_SIZE := Vector2(560, 104)

var _slime: TextureRect
var _name_label: Label
var _turn_label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = PLATE_SIZE
	size = PLATE_SIZE
	_build_lighten_plate()
	_build_content()


func _build_lighten_plate() -> void:
	var lighten := PanelContainer.new()
	lighten.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lighten.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.99, 0.96, 0.17)
	style.set_border_width_all(0)
	style.set_corner_radius_all(18)
	lighten.add_theme_stylebox_override("panel", style)
	add_child(lighten)


func _build_content() -> void:
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layer)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center)

	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(root)

	_slime = TextureRect.new()
	_slime.custom_minimum_size = Vector2(64, 64)
	_slime.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_slime.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(_slime)

	var text_col := VBoxContainer.new()
	text_col.add_theme_constant_override("separation", 2)
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_child(text_col)

	_turn_label = Label.new()
	_turn_label.text = "Сейчас ходит"
	_turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_turn_label.add_theme_font_size_override("font_size", 20)
	_turn_label.add_theme_color_override("font_color", TurnOrderArrowsLayer.ACCENT.lightened(0.05))
	text_col.add_child(_turn_label)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 40)
	_name_label.add_theme_color_override("font_color", Color(0.12, 0.09, 0.07, 1))
	_name_label.add_theme_color_override("font_outline_color", Color(1, 0.98, 0.94, 0.35))
	_name_label.add_theme_constant_override("outline_size", 2)
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	text_col.add_child(_name_label)


func set_player(player: GamePlayer) -> void:
	if not is_inside_tree():
		await ready
	_slime.texture = load(SLIME_PATH % player.info.preset_id)
	_name_label.text = player.info.name


func set_turn_caption(text: String) -> void:
	if not is_inside_tree():
		await ready
	_turn_label.text = text


func pulse_choice_tick() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.05).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_slime, "modulate", Color(1.25, 1.15, 1.05, 1.0), 0.05)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_slime, "modulate", Color.WHITE, 0.12)
