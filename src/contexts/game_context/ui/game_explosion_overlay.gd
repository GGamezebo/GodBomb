class_name GameExplosionOverlay
extends PanelContainer

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const CONTENT_WIDTH_MARGIN := 200.0
const CONTENT_ANCHOR := Vector2(540.0, 930.0)
const EXPLOSION_PILL_SCALE := 1.65

var _headline: Label
var _player_strip: GamePlayerStrip
var _content_col: VBoxContainer
var _margin_host: MarginContainer
var _position_host: Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	modulate.a = 0.0
	z_index = 9
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size = DESIGN_SIZE
	_build_ui()
	resized.connect(_layout_content)
	call_deferred("_layout_content")


func _build_ui() -> void:
	var backdrop := StyleBoxFlat.new()
	backdrop.bg_color = Color(0.08, 0.03, 0.01, 0.82)
	add_theme_stylebox_override("panel", backdrop)

	var stack := Control.new()
	stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stack)

	_margin_host = MarginContainer.new()
	_margin_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margin_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(_margin_host)

	_position_host = Control.new()
	_position_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_position_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_margin_host.add_child(_position_host)

	_content_col = VBoxContainer.new()
	_content_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_content_col.add_theme_constant_override("separation", 36)
	_position_host.add_child(_content_col)

	var headline_wrap := MarginContainer.new()
	headline_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	headline_wrap.add_theme_constant_override("margin_left", 12)
	headline_wrap.add_theme_constant_override("margin_right", 12)
	_content_col.add_child(headline_wrap)

	_headline = Label.new()
	_headline.text = LocaleService.text("EXPLOSION_BOOM")
	_headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_headline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_headline.clip_contents = true
	_headline.add_theme_font_size_override("font_size", 92)
	_headline.add_theme_color_override("font_color", Color.WHITE)
	_headline.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.88))
	_headline.add_theme_constant_override("outline_size", 8)
	headline_wrap.add_child(_headline)

	var pill_host := CenterContainer.new()
	pill_host.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_content_col.add_child(pill_host)

	_player_strip = GamePlayerStrip.new()
	_player_strip.set_visual_scale(EXPLOSION_PILL_SCALE)
	pill_host.add_child(_player_strip)


func _get_side_margin() -> int:
	var half_margin := CONTENT_WIDTH_MARGIN * 0.5
	var min_side := 72.0
	var proportional := size.x * 0.1
	return int(round(maxf(half_margin, maxf(min_side, proportional))))


func _get_content_width() -> float:
	return maxf(size.x - float(_get_side_margin()) * 2.0, 280.0)


func _sync_horizontal_margins() -> void:
	if not _margin_host:
		return
	var side_margin := _get_side_margin()
	_margin_host.add_theme_constant_override("margin_left", side_margin)
	_margin_host.add_theme_constant_override("margin_right", side_margin)


func _layout_content() -> void:
	if not _content_col or not _position_host:
		return
	_sync_horizontal_margins()
	var content_width := _get_content_width()
	_content_col.custom_minimum_size.x = content_width
	_content_col.size.x = content_width
	_content_col.reset_size()
	var col_size := _content_col.get_combined_minimum_size()
	col_size.x = content_width
	_content_col.size = col_size
	_content_col.position = Vector2(
		(_position_host.size.x - content_width) * 0.5,
		CONTENT_ANCHOR.y - col_size.y * 0.48
	)


func show_for_player(player: GamePlayer) -> void:
	_player_strip.set_visual_scale(EXPLOSION_PILL_SCALE)
	_player_strip.set_player(player)
	size = get_parent().size if get_parent() is Control else DESIGN_SIZE
	_layout_content()
	visible = true
	modulate.a = 0.0
	_headline.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_headline.scale = Vector2(0.78, 0.78)
	_player_strip.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_player_strip.scale = Vector2(0.72, 0.72)
	call_deferred("_layout_content")
	call_deferred("_start_reveal_animation")


func _start_reveal_animation() -> void:
	_layout_content()
	_player_strip.pivot_offset = _player_strip.size * 0.5
	_headline.pivot_offset = _headline.size * 0.5

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_headline, "modulate:a", 1.0, 0.2).set_delay(0.05)
	tween.parallel().tween_property(_headline, "scale", Vector2(1.05, 1.05), 0.22).set_delay(0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_headline, "scale", Vector2.ONE, 0.16).set_delay(0.27).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_player_strip, "modulate:a", 1.0, 0.24).set_delay(0.12)
	tween.parallel().tween_property(_player_strip, "scale", Vector2(1.06, 1.06), 0.28).set_delay(0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_player_strip, "scale", Vector2.ONE, 0.18).set_delay(0.4).set_trans(Tween.TRANS_SINE)


func relayout() -> void:
	_layout_content()


func hide_overlay() -> void:
	visible = false
	modulate.a = 0.0
