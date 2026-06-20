class_name StartActionButton
extends TextureButton

const PULSE_SCALE := Vector2(1.05, 1.05)
const PULSE_HALF_PERIOD := 0.5
const ENABLED_MODULATE := Color(1.05, 1.02, 0.95, 1.0)
const DISABLED_MODULATE := Color(0.88, 0.88, 0.88, 1.0)

var _pulse_tween: Tween


func _ready() -> void:
	clip_contents = false
	resized.connect(_on_resized)
	_on_resized()
	call_deferred("_sync_label_layout")


func _on_resized() -> void:
	pivot_offset = size * 0.5


func _sync_label_layout() -> void:
	for child in get_children():
		if child is Label:
			var label := child as Label
			label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func set_pulse_active(active: bool) -> void:
	_kill_pulse()
	scale = Vector2.ONE
	var label := get_node_or_null("StartLabel") as Label
	if not label:
		label = get_node_or_null("DoneLabel") as Label
	if active:
		modulate = ENABLED_MODULATE
		if label:
			label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		pivot_offset = size * 0.5
		_pulse_tween = create_tween().set_loops()
		_pulse_tween.tween_property(self, "scale", PULSE_SCALE, PULSE_HALF_PERIOD).set_trans(Tween.TRANS_SINE)
		_pulse_tween.tween_property(self, "scale", Vector2.ONE, PULSE_HALF_PERIOD).set_trans(Tween.TRANS_SINE)
	else:
		modulate = DISABLED_MODULATE
		if label:
			label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.9, 1))


func _kill_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
