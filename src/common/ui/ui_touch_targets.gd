class_name UiTouchTargets
extends RefCounted

const SLIDER_MIN_HEIGHT := 96.0
const SLIDER_GRABBER_INSET := 26.0

const _GRABBER_TOUCH := preload("res://assets/ui/theme/slider_grabber_touch.svg")


static func apply_invisible_button(button: BaseButton) -> void:
	var empty := StyleBoxEmpty.new()
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, empty)
	var transparent := Color(1.0, 1.0, 1.0, 0.0)
	button.add_theme_color_override("font_color", transparent)
	button.add_theme_color_override("font_hover_color", transparent)
	button.add_theme_color_override("font_pressed_color", transparent)
	button.add_theme_color_override("font_focus_color", transparent)
	button.add_theme_color_override("font_disabled_color", transparent)


static func configure_slider(slider: HSlider, grabber_inset: float = SLIDER_GRABBER_INSET) -> void:
	if slider == null:
		return
	slider.clip_contents = false
	var row := slider.get_parent() as Control
	if row:
		row.clip_contents = false
		row.custom_minimum_size.y = maxf(row.custom_minimum_size.y, SLIDER_MIN_HEIGHT)
	slider.custom_minimum_size.y = maxf(slider.custom_minimum_size.y, SLIDER_MIN_HEIGHT)
	slider.add_theme_icon_override("grabber", _GRABBER_TOUCH)
	slider.add_theme_icon_override("grabber_highlight", _GRABBER_TOUCH)
	slider.add_theme_icon_override("grabber_disabled", _GRABBER_TOUCH)
	for style_name: String in ["slider", "grabber_area", "grabber_area_highlight"]:
		var style := slider.get_theme_stylebox(style_name, &"HSlider")
		if style is StyleBoxFlat:
			var tuned := style.duplicate() as StyleBoxFlat
			tuned.content_margin_left = grabber_inset
			tuned.content_margin_right = grabber_inset
			tuned.content_margin_top = 6.0
			tuned.content_margin_bottom = 6.0
			slider.add_theme_stylebox_override(style_name, tuned)
