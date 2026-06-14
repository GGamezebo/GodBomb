class_name TableHintBanner
extends PanelContainer

const FADE_IN := 0.38
const FADE_OUT := 0.28
const MIN_WIDTH := 420.0

var _label: Label
var _fade_tween: Tween
var _current_text: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	modulate.a = 0.0
	_apply_panel_style()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size = Vector2(MIN_WIDTH, 0)
	_label.add_theme_font_size_override("font_size", 22)
	_label.add_theme_color_override("font_color", Color(0.18, 0.13, 0.1, 1))
	_label.add_theme_color_override("font_outline_color", Color(1, 0.99, 0.97, 0.85))
	_label.add_theme_constant_override("outline_size", 3)
	margin.add_child(_label)


func show_message(text: String, animate: bool = true, emphasis: bool = false) -> void:
	if text.is_empty():
		hide_message(animate)
		return

	_kill_fade_tween()
	var same_text := text == _current_text
	_current_text = text
	_label.text = text

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
		)
		_fade_tween.tween_property(self, "modulate:a", 1.0, FADE_IN).set_trans(Tween.TRANS_SINE)
	else:
		_label.text = text
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
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 0.99, 0.96, 0.94)
	style.border_color = Color(0.88, 0.62, 0.38, 0.55)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.14, 0.08, 0.04, 0.18)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 3)
	add_theme_stylebox_override("panel", style)
