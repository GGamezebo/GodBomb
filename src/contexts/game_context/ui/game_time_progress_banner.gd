class_name GameTimeProgressBanner
extends PanelContainer

const SHOW_DURATION := 5
const FADE_IN := 0.34
const FADE_OUT := 0.28
const BANNER_WIDTH := TableHintBanner.TABLE_HINT_WIDTH
const BANNER_HEIGHT := TableHintBanner.TABLE_HINT_HEIGHT
const BAR_HEIGHT := 22.0

const TEXT_COLOR := Color(0.99, 0.96, 0.9, 1.0)
const TEXT_OUTLINE := Color(0.1, 0.06, 0.04, 0.82)
const PROGRESS_BG := Color(0.1, 0.08, 0.06, 0.55)
const PROGRESS_FILL := Color(0.45, 0.78, 0.98, 0.92)
const PROGRESS_BORDER := Color(0.72, 0.42, 0.2, 0.72)

var _label: Label
var _progress_bar: ProgressBar
var _fade_tween: Tween
var _layout_anchor := Vector2.ZERO
var _layout_bounds := Rect2()
var _layout_max_width := BANNER_WIDTH
var _layout_ready := false
var _banner_width := BANNER_WIDTH


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	modulate.a = 1.0
	clip_contents = true
	TableHintBanner.apply_panel_style(self)
	_build_content()
	_set_fade_alpha(0.0)


func _build_content() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", TableHintBanner.PANEL_MARGIN_H)
	margin.add_theme_constant_override("margin_top", TableHintBanner.PANEL_MARGIN_V)
	margin.add_theme_constant_override("margin_right", TableHintBanner.PANEL_MARGIN_H)
	margin.add_theme_constant_override("margin_bottom", TableHintBanner.PANEL_MARGIN_V)
	add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(row)

	_label = Label.new()
	_label.text = "До конца партии"
	_label.theme_type_variation = &"Hero"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 30)
	_label.add_theme_color_override("font_color", TEXT_COLOR)
	_label.add_theme_color_override("font_outline_color", TEXT_OUTLINE)
	_label.add_theme_constant_override("outline_size", 3)
	row.add_child(_label)

	_progress_bar = ProgressBar.new()
	_progress_bar.custom_minimum_size = Vector2(420.0, BAR_HEIGHT)
	_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_progress_bar.show_percentage = false
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 100.0
	_apply_bar_style()
	row.add_child(_progress_bar)


func _apply_bar_style() -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = PROGRESS_BG
	bg.border_color = PROGRESS_BORDER
	bg.set_border_width_all(2)
	bg.set_corner_radius_all(10)
	bg.content_margin_left = 3.0
	bg.content_margin_top = 3.0
	bg.content_margin_right = 3.0
	bg.content_margin_bottom = 3.0
	var fill := StyleBoxFlat.new()
	fill.bg_color = PROGRESS_FILL
	fill.set_corner_radius_all(6)
	_progress_bar.add_theme_stylebox_override("background", bg)
	_progress_bar.add_theme_stylebox_override("fill", fill)


func fit_layout(anchor: Vector2, max_width: float = BANNER_WIDTH, bounds: Rect2 = Rect2()) -> void:
	_layout_ready = true
	_layout_anchor = anchor
	_layout_bounds = bounds
	_layout_max_width = max_width

	var side_margin := TableHintBanner.SCREEN_MARGIN
	var available_width := max_width
	if bounds.size.x > 0.0:
		available_width = minf(max_width, bounds.size.x - side_margin * 2.0)
	_banner_width = clampf(available_width, TableHintBanner.TABLE_HINT_MIN_WIDTH, BANNER_WIDTH)

	var center_x := anchor.x
	if bounds.size.x > 0.0:
		center_x = bounds.position.x + bounds.size.x * 0.5

	_lock_banner_size()

	var banner_size := Vector2(_banner_width, BANNER_HEIGHT)
	var pos := Vector2(center_x, anchor.y) - banner_size * 0.5
	if bounds.size.x > 0.0:
		pos.x = clampf(
			pos.x,
			bounds.position.x + side_margin,
			bounds.position.x + bounds.size.x - banner_size.x - side_margin
		)
	position = pos


func _lock_banner_size() -> void:
	var banner_size := Vector2(_banner_width, BANNER_HEIGHT)
	custom_minimum_size = banner_size
	custom_maximum_size = banner_size
	size = banner_size


func show_progress(remaining_ratio: float, animate: bool = true) -> void:
	_kill_fade_tween()
	_progress_bar.value = clampf(remaining_ratio, 0.0, 1.0) * 100.0
	if _layout_ready:
		_lock_banner_size()

	visible = true
	_set_fade_alpha(0.0)
	if animate:
		_fade_tween = create_tween()
		_fade_tween.tween_method(_set_fade_alpha, 0.0, 1.0, FADE_IN).set_trans(Tween.TRANS_SINE)
	else:
		_set_fade_alpha(1.0)


func hide_progress(animate: bool = true) -> void:
	if not visible:
		return
	_kill_fade_tween()
	if animate:
		_fade_tween = create_tween()
		_fade_tween.tween_method(_set_fade_alpha, _fade_alpha(), 0.0, FADE_OUT).set_trans(Tween.TRANS_SINE)
		_fade_tween.tween_callback(_finish_hide)
	else:
		_finish_hide()


func _finish_hide() -> void:
	visible = false
	_set_fade_alpha(0.0)


func _fade_alpha() -> float:
	return modulate.a if visible else 0.0


func _set_fade_alpha(alpha: float) -> void:
	modulate.a = alpha


func _kill_fade_tween() -> void:
	if _fade_tween:
		_fade_tween.kill()
		_fade_tween = null
