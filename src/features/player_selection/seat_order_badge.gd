class_name SeatOrderBadge
extends Control

const BADGE_SIZE := Vector2(48, 48)

var _label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = BADGE_SIZE
	size = BADGE_SIZE

	_label = Label.new()
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 30)
	_label.add_theme_color_override("font_color", Color(0.96, 0.5, 0.2, 1))
	_label.add_theme_color_override("font_outline_color", Color(0.2, 0.11, 0.06, 0.9))
	_label.add_theme_constant_override("outline_size", 6)
	add_child(_label)


func set_number(order: int) -> void:
	_label.text = str(order)
	visible = order > 0
	queue_redraw()


func play_flash(flash_duration: float = 0.14) -> void:
	scale = Vector2.ONE
	modulate = Color.WHITE
	var tween := create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(1.24, 1.24), flash_duration * 0.45).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(self, "modulate", Color(0.78, 0.76, 0.74, 1), flash_duration * 0.45)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, flash_duration * 0.55).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, flash_duration * 0.55)


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.44
	draw_arc(center, radius + 2.5, 0.0, TAU, 48, Color(0.1, 0.06, 0.04, 0.14), 4.5, true)
	draw_arc(center, radius, 0.0, TAU, 48, Color(0.93, 0.52, 0.28, 0.95), 3.0, true)
	draw_arc(center, radius - 2.0, 0.0, TAU, 48, Color(1.0, 0.84, 0.58, 0.6), 1.5, true)
