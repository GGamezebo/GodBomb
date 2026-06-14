class_name GamePlayerStrip
extends PanelContainer

const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"

var _slime: TextureRect
var _name_label: Label
var _turn_label: Label
var _accent_bar: ColorRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(920, 132)
	_apply_panel_style()

	var outer := MarginContainer.new()
	outer.add_theme_constant_override("margin_left", 14)
	outer.add_theme_constant_override("margin_top", 10)
	outer.add_theme_constant_override("margin_right", 14)
	outer.add_theme_constant_override("margin_bottom", 10)
	add_child(outer)

	var root := HBoxContainer.new()
	root.add_theme_constant_override("separation", 18)
	outer.add_child(root)

	_slime = TextureRect.new()
	_slime.custom_minimum_size = Vector2(96, 96)
	_slime.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_slime.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(_slime)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 4)
	root.add_child(text_col)

	_turn_label = Label.new()
	_turn_label.text = "Сейчас ходит"
	_turn_label.add_theme_font_size_override("font_size", 22)
	_turn_label.add_theme_color_override("font_color", TurnOrderArrowsLayer.ACCENT)
	text_col.add_child(_turn_label)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 44)
	_name_label.add_theme_color_override("font_color", Color(0.18, 0.13, 0.1, 1))
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	text_col.add_child(_name_label)

	_accent_bar = ColorRect.new()
	_accent_bar.custom_minimum_size = Vector2(6, 0)
	_accent_bar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_accent_bar.color = TurnOrderArrowsLayer.ACCENT
	root.add_child(_accent_bar)


func set_player(player: GamePlayer) -> void:
	if not is_inside_tree():
		await ready
	_slime.texture = load(SLIME_PATH % player.info.preset_id)
	_name_label.text = player.info.name
	_accent_bar.color = SlimeColors.get_color(player.info.preset_id).lightened(0.05)


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


func _apply_panel_style() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.99, 0.96, 0.94)
	style.border_color = Color(0.88, 0.62, 0.38, 0.55)
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	style.shadow_color = Color(0.14, 0.08, 0.04, 0.16)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	add_theme_stylebox_override("panel", style)
