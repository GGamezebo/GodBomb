class_name SwapArrowsLayer
extends Control

@export var arrow_color: Color = Color(0.92, 0.62, 0.28, 0.55)
@export var pulse_speed: float = 2.5

var _seat_locals: Array[Vector2] = []
var _arrow_labels: Array[Label] = []
var _enabled: bool = false
var _intro_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	visible = enabled and _seat_locals.size() >= 2
	if not visible:
		for label in _arrow_labels:
			label.visible = false


func update_seats(seat_locals: Array[Vector2]) -> void:
	_seat_locals = seat_locals.duplicate()
	_rebuild_arrows()
	set_enabled(_enabled)


func play_intro() -> void:
	if not _enabled or _arrow_labels.is_empty():
		return
	if _intro_tween:
		_intro_tween.kill()
	for label in _arrow_labels:
		label.visible = true
		label.scale = Vector2(0.35, 0.35)
		label.modulate.a = 0.0
	_intro_tween = create_tween()
	for label in _arrow_labels:
		_intro_tween.parallel().tween_property(label, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK)
		_intro_tween.parallel().tween_property(label, "modulate:a", 0.85, 0.35)


func _rebuild_arrows() -> void:
	for label in _arrow_labels:
		label.queue_free()
	_arrow_labels.clear()

	if _seat_locals.size() < 2:
		return

	for i in _seat_locals.size():
		var next_i := (i + 1) % _seat_locals.size()
		var mid := (_seat_locals[i] + _seat_locals[next_i]) * 0.5
		var label := Label.new()
		label.text = "↔"
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 28)
		label.add_theme_color_override("font_color", arrow_color)
		label.custom_minimum_size = Vector2(40, 40)
		label.size = label.custom_minimum_size
		label.position = mid - label.size * 0.5
		add_child(label)
		_arrow_labels.append(label)


func _process(_delta: float) -> void:
	if not _enabled or _arrow_labels.is_empty():
		return
	if _intro_tween and _intro_tween.is_running():
		return
	var pulse := 0.45 + sin(Time.get_ticks_msec() * 0.001 * pulse_speed) * 0.25
	for label in _arrow_labels:
		label.modulate.a = pulse
