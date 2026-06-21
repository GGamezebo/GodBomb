class_name GameExplosionOverlay
extends PanelContainer

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const CONTENT_ANCHOR := Vector2(540.0, 930.0)
const EXPLOSION_PILL_SCALE := 1.65

var _headline: Label
var _player_strip: GamePlayerStrip
var _content_col: VBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	modulate.a = 0.0
	z_index = 9
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	size = DESIGN_SIZE
	_build_ui()


func _build_ui() -> void:
	var backdrop := StyleBoxFlat.new()
	backdrop.bg_color = Color(0.04, 0.02, 0.01, 0.72)
	add_theme_stylebox_override("panel", backdrop)

	var stack := Control.new()
	stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stack)

	_content_col = VBoxContainer.new()
	_content_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_content_col.add_theme_constant_override("separation", 36)
	stack.add_child(_content_col)

	_headline = Label.new()
	_headline.text = "ВАС ПОДОРВАЛО!"
	_headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_headline.add_theme_font_size_override("font_size", 92)
	_headline.add_theme_color_override("font_color", Color.WHITE)
	_headline.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.88))
	_headline.add_theme_constant_override("outline_size", 8)
	_content_col.add_child(_headline)

	var pill_host := CenterContainer.new()
	_content_col.add_child(pill_host)

	_player_strip = GamePlayerStrip.new()
	_player_strip.set_visual_scale(EXPLOSION_PILL_SCALE)
	pill_host.add_child(_player_strip)


func _layout_content() -> void:
	if not _content_col:
		return
	_content_col.reset_size()
	var col_size := _content_col.get_combined_minimum_size()
	_content_col.size = col_size
	_content_col.position = CONTENT_ANCHOR - Vector2(col_size.x * 0.5, col_size.y * 0.48)


func show_for_player(player: GamePlayer) -> void:
	_player_strip.set_visual_scale(EXPLOSION_PILL_SCALE)
	_player_strip.set_player(player)
	_layout_content()
	visible = true
	modulate.a = 0.0
	_headline.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_headline.scale = Vector2(0.92, 0.92)
	_player_strip.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_player_strip.scale = Vector2(0.84, 0.84)
	call_deferred("_start_reveal_animation")


func _start_reveal_animation() -> void:
	_player_strip.pivot_offset = _player_strip.size * 0.5
	_headline.pivot_offset = _headline.size * 0.5

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_headline, "modulate:a", 1.0, 0.24).set_delay(0.04)
	tween.parallel().tween_property(_headline, "scale", Vector2.ONE, 0.28).set_delay(0.04).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_player_strip, "modulate:a", 1.0, 0.26).set_delay(0.1)
	tween.parallel().tween_property(_player_strip, "scale", Vector2.ONE, 0.34).set_delay(0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func hide_overlay() -> void:
	visible = false
	modulate.a = 0.0
