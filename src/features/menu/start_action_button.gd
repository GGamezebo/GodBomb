class_name StartActionButton
extends TextureButton

const PULSE_SCALE := Vector2(1.05, 1.05)
const PULSE_HALF_PERIOD := 0.5
const ENABLED_MODULATE := Color(1.02, 0.98, 0.94, 1.0)
const DISABLED_MODULATE := Color(0.78, 0.76, 0.74, 1.0)
# Vertical center of the painted face in start_active.svg (viewBox height 120, face center y=52).
const TEXT_PILL_CENTER_Y_RATIO := 52.0 / 120.0
const DESIGN_ACTION_SIZE := Vector2(660.0, 180.0)
const DESIGN_FONT_SIZE := 72
const MODAL_FONT_SIZE := 52

var _action_text: String = ""

@export var enable_pulse: bool = false
@export var action_text: String = "":
	get:
		return _action_text
	set(value):
		if _action_text == value:
			return
		_action_text = value
		_apply_action_text()

var _pulse_tween: Tween


var text: String:
	get:
		return _action_text
	set(value):
		set_action_text(value)


func _ready() -> void:
	clip_contents = false
	focus_mode = Control.FOCUS_NONE
	resized.connect(_on_resized)
	resized.connect(refresh_label_layout)
	_on_resized()
	_apply_action_text()
	call_deferred("refresh_label_layout")
	if not enable_pulse:
		set_pulse_active(not disabled)


func _on_resized() -> void:
	pivot_offset = size * 0.5


func set_action_text(value: String) -> void:
	if _action_text == value:
		return
	_action_text = value
	_apply_action_text()


func _apply_action_text() -> void:
	var label := _find_action_label()
	if not label:
		return
	if action_text.is_empty():
		return
	label.text = action_text
	call_deferred("refresh_label_layout")


func refresh_label_layout() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var target_y := size.y * TEXT_PILL_CENTER_Y_RATIO
	for child in get_children():
		if child is not Label:
			continue
		var label := child as Label
		label.layout_mode = 0
		label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var label_size := label.get_combined_minimum_size()
		if label_size.y <= 0.0:
			label_size.y = float(label.get_theme_font_size("font_size"))
		label.size = label_size
		label.position = Vector2(
			(size.x - label_size.x) * 0.5,
			target_y - label_size.y * 0.5
		)


func set_pulse_active(active: bool) -> void:
	_kill_pulse()
	scale = Vector2.ONE
	_apply_enabled_look(active)
	if active and enable_pulse:
		pivot_offset = size * 0.5
		_pulse_tween = create_tween().set_loops()
		_pulse_tween.tween_property(self, "scale", PULSE_SCALE, PULSE_HALF_PERIOD).set_trans(Tween.TRANS_SINE)
		_pulse_tween.tween_property(self, "scale", Vector2.ONE, PULSE_HALF_PERIOD).set_trans(Tween.TRANS_SINE)
	call_deferred("refresh_label_layout")


func _apply_enabled_look(active: bool) -> void:
	var label := _find_action_label()
	if active:
		modulate = ENABLED_MODULATE
		if label:
			label.add_theme_color_override("font_color", Color(1, 0.98, 0.94, 1))
			label.add_theme_color_override("font_outline_color", Color(0.12, 0.06, 0.02, 0.85))
			label.add_theme_constant_override("outline_size", 3)
	else:
		modulate = DISABLED_MODULATE
		if label:
			label.add_theme_color_override("font_color", Color(0.82, 0.8, 0.76, 1))
			label.add_theme_color_override("font_outline_color", Color(0.1, 0.08, 0.06, 0.55))
			label.add_theme_constant_override("outline_size", 2)


func _find_action_label() -> Label:
	var label := get_node_or_null("ActionLabel") as Label
	if label:
		return label
	label = get_node_or_null("StartLabel") as Label
	if label:
		return label
	return get_node_or_null("DoneLabel") as Label


func _kill_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null


static func viewport_cover_scale(viewport_size: Vector2) -> float:
	return maxf(
		viewport_size.x / MenuBombLayout.DESIGN_SIZE.x,
		viewport_size.y / MenuBombLayout.DESIGN_SIZE.y
	)


func apply_scaled_action_size(viewport_size: Vector2, use_design_font: bool = false) -> void:
	var scale := viewport_cover_scale(viewport_size)
	custom_minimum_size = Vector2(0.0, DESIGN_ACTION_SIZE.y * scale)
	var label := _find_action_label()
	if label:
		var font_size := DESIGN_FONT_SIZE if use_design_font else MODAL_FONT_SIZE
		label.add_theme_font_size_override("font_size", maxi(32, int(round(font_size * scale))))
	call_deferred("refresh_label_layout")
