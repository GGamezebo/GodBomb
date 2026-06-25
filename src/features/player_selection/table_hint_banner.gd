class_name TableHintBanner
extends PanelContainer

const FADE_IN := 0.38
const FADE_OUT := 0.28
const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const TABLE_HINT_WIDTH := 920.0
const TABLE_HINT_HEIGHT := 102.0
const TABLE_HINT_MIN_WIDTH := 280.0
const SCREEN_MARGIN := 32.0
const PANEL_MARGIN_H := 24
const PANEL_MARGIN_V := 9
const PANEL_BORDER_INSET := 9.0
const MAX_FONT_SIZE := 51
const MIN_FONT_SIZE := 30

var _label: Label
var _margin: MarginContainer
var _fade_tween: Tween
var _current_text: String = ""
var _layout_anchor := Vector2.ZERO
var _layout_bounds := Rect2()
var _layout_max_width := TABLE_HINT_WIDTH
var _layout_ready := false
var _banner_width := TABLE_HINT_WIDTH


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	modulate.a = 0.0
	clip_contents = true
	_apply_panel_style()

	_margin = MarginContainer.new()
	_margin.add_theme_constant_override("margin_left", PANEL_MARGIN_H)
	_margin.add_theme_constant_override("margin_top", PANEL_MARGIN_V)
	_margin.add_theme_constant_override("margin_right", PANEL_MARGIN_H)
	_margin.add_theme_constant_override("margin_bottom", PANEL_MARGIN_V)
	add_child(_margin)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.clip_contents = true
	_label.add_theme_font_size_override("font_size", MAX_FONT_SIZE)
	_label.add_theme_color_override("font_color", Color(0.18, 0.13, 0.1, 1))
	_label.add_theme_color_override("font_outline_color", Color(1, 0.99, 0.97, 0.85))
	_label.add_theme_constant_override("outline_size", 4)
	_margin.add_child(_label)


func fit_layout(anchor: Vector2, max_width: float = TABLE_HINT_WIDTH, bounds: Rect2 = Rect2()) -> void:
	_layout_ready = true
	_layout_anchor = anchor
	_layout_bounds = bounds
	_layout_max_width = max_width

	var side_margin := SCREEN_MARGIN
	var available_width := max_width
	if bounds.size.x > 0.0:
		available_width = minf(max_width, bounds.size.x - side_margin * 2.0)
	_banner_width = clampf(available_width, TABLE_HINT_MIN_WIDTH, TABLE_HINT_WIDTH)

	var center_x := anchor.x
	if bounds.size.x > 0.0:
		center_x = bounds.position.x + bounds.size.x * 0.5

	_lock_banner_size()
	_apply_text_fit()

	var banner_size := Vector2(_banner_width, TABLE_HINT_HEIGHT)
	var pos := Vector2(center_x, anchor.y) - banner_size * 0.5
	if bounds.size.x > 0.0:
		pos.x = clampf(
			pos.x,
			bounds.position.x + side_margin,
			bounds.position.x + bounds.size.x - banner_size.x - side_margin
		)
	position = pos


func _lock_banner_size() -> void:
	var banner_size := Vector2(_banner_width, TABLE_HINT_HEIGHT)
	custom_minimum_size = banner_size
	custom_maximum_size = banner_size
	size = banner_size


func _text_area_size() -> Vector2:
	var text_width := maxf(_banner_width - PANEL_MARGIN_H * 2.0, 0.0)
	var text_height := maxf(
		TABLE_HINT_HEIGHT - PANEL_MARGIN_V * 2.0 - PANEL_BORDER_INSET,
		0.0
	)
	return Vector2(text_width, text_height)


func _apply_text_fit() -> void:
	var area := _text_area_size()
	_label.custom_minimum_size = area
	_label.custom_maximum_size = area
	_label.size = area

	var chosen_font := MIN_FONT_SIZE
	for font_size in range(MAX_FONT_SIZE, MIN_FONT_SIZE - 1, -1):
		if _measure_wrapped_text_height(_label.text, area.x, font_size) <= area.y:
			chosen_font = font_size
			break
	_label.add_theme_font_size_override("font_size", chosen_font)
	_label.add_theme_constant_override(
		"outline_size",
		maxi(2, int(round(float(chosen_font) / 10.0)))
	)


func _measure_wrapped_text_height(text: String, text_width: float, font_size: int) -> float:
	if text.is_empty() or text_width <= 0.0:
		return 0.0
	var font: Font = _label.get_theme_font(&"font")
	if font == null:
		font = ThemeDB.fallback_font
	return font.get_multiline_string_size(
		text,
		HORIZONTAL_ALIGNMENT_CENTER,
		text_width,
		font_size,
		TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	).y


func _sync_layout_if_ready() -> void:
	if not _layout_ready:
		return
	fit_layout(_layout_anchor, _layout_max_width, _layout_bounds)


func show_message(text: String, animate: bool = true, emphasis: bool = false) -> void:
	if text.is_empty():
		hide_message(animate)
		return

	_kill_fade_tween()
	var same_text := text == _current_text
	_current_text = text
	_label.text = text
	if _layout_ready:
		_lock_banner_size()
		_apply_text_fit()
	else:
		_sync_layout_if_ready()

	if emphasis:
		visible = true
		modulate.a = 1.0
		return

	if visible and modulate.a > 0.95 and same_text:
		return

	if not visible or modulate.a < 0.05:
		visible = true
		modulate.a = 0.0
		if animate:
			_fade_tween = create_tween()
			_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_IN).set_trans(Tween.TRANS_SINE)
		else:
			modulate.a = 1.0
		return

	if same_text:
		return

	if animate:
		_fade_tween = create_tween()
		_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT * 0.55).set_trans(Tween.TRANS_SINE)
		_fade_tween.tween_callback(func() -> void:
			_label.text = text
			if _layout_ready:
				_lock_banner_size()
				_apply_text_fit()
		)
		_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_IN).set_trans(Tween.TRANS_SINE)
	else:
		_label.text = text
		if _layout_ready:
			_lock_banner_size()
			_apply_text_fit()
		modulate.a = 1.0


func hide_message(animate: bool = true) -> void:
	if not visible:
		return

	_kill_fade_tween()
	_current_text = ""

	if animate:
		_fade_tween = create_tween()
		_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT).set_trans(Tween.TRANS_SINE)
		_fade_tween.tween_callback(_finish_hide)
	else:
		_finish_hide()


func _finish_hide() -> void:
	visible = false
	modulate.a = 0.0
	_label.text = ""


func _kill_fade_tween() -> void:
	if _fade_tween:
		_fade_tween.kill()
		_fade_tween = null


func _apply_panel_style() -> void:
	apply_panel_style(self)


static func visible_design_rect(
	host_size: Vector2,
	design_size: Vector2 = DESIGN_SIZE
) -> Rect2:
	if host_size.x <= 0.0 or host_size.y <= 0.0:
		return Rect2(Vector2.ZERO, design_size)
	var scale_factor := maxf(host_size.x / design_size.x, host_size.y / design_size.y)
	var offset := (host_size - design_size * scale_factor) * 0.5
	return Rect2(-offset / scale_factor, host_size / scale_factor)


static func apply_panel_style(panel: PanelContainer) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.99, 0.96, 0.94)
	style.border_color = Color(0.88, 0.62, 0.38, 0.55)
	style.set_border_width_all(4)
	style.set_corner_radius_all(27)
	style.shadow_color = Color(0.14, 0.08, 0.04, 0.16)
	style.shadow_size = 9
	style.shadow_offset = Vector2(0, 4)
	panel.add_theme_stylebox_override("panel", style)


static func place_centered_at(
	banner: PanelContainer,
	anchor: Vector2,
	bounds: Rect2 = Rect2(),
	max_width: float = TABLE_HINT_WIDTH
) -> void:
	if banner is TableHintBanner:
		(banner as TableHintBanner).fit_layout(anchor, max_width, bounds)
	elif banner:
		var banner_size := Vector2(max_width, TABLE_HINT_HEIGHT)
		banner.custom_minimum_size = banner_size
		banner.custom_maximum_size = banner_size
		banner.size = banner_size
		var center_x := anchor.x
		if bounds.size.x > 0.0:
			center_x = bounds.position.x + bounds.size.x * 0.5
		var pos := Vector2(center_x, anchor.y) - banner_size * 0.5
		if bounds.size.x > 0.0:
			pos.x = clampf(
				pos.x,
				bounds.position.x + SCREEN_MARGIN,
				bounds.position.x + bounds.size.x - banner_size.x - SCREEN_MARGIN
			)
		banner.position = pos
