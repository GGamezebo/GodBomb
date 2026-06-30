class_name ModalScroll
extends RefCounted

const SCROLL_TRACK := Color(0.08, 0.06, 0.05, 0.42)
const SCROLL_GRABBER := Color(0.78, 0.48, 0.28, 0.9)
const SCROLL_GRABBER_HI := Color(0.94, 0.6, 0.34, 0.98)


static func configure(scroll: ScrollContainer) -> void:
	if scroll == null:
		return
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 16
	scroll.scroll_vertical_custom_step = 80.0
	scroll.scroll_hint_mode = ScrollContainer.SCROLL_HINT_MODE_DISABLED
	scroll.clip_contents = true
	_style_vertical_scroll_bar(scroll.get_v_scroll_bar())


static func reset_position(scroll: ScrollContainer) -> void:
	if scroll:
		scroll.scroll_vertical = 0


static func _style_vertical_scroll_bar(bar: VScrollBar) -> void:
	if bar == null:
		return
	bar.custom_minimum_size.x = 12
	var track := StyleBoxFlat.new()
	track.bg_color = SCROLL_TRACK
	track.set_corner_radius_all(6)
	track.content_margin_top = 6.0
	track.content_margin_bottom = 6.0
	track.content_margin_left = 2.0
	track.content_margin_right = 2.0
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = SCROLL_GRABBER
	grabber.set_corner_radius_all(6)
	var grabber_hi := grabber.duplicate() as StyleBoxFlat
	grabber_hi.bg_color = SCROLL_GRABBER_HI
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("grabber", grabber)
	bar.add_theme_stylebox_override("grabber_highlight", grabber_hi)
	bar.add_theme_constant_override("minimum_grabber_size", 64)
