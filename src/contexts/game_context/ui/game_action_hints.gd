class_name GameActionHints
extends Control

const ACCENT := TurnOrderArrowsLayer.ACCENT

@export var game_events: GameEvents

var listener: EventListener = EventListener.new()
var _tap_label: Label
var _ripple: Control


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(920, 96)
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		listener.add(game_events.ev_touch_next_player, _on_tap_next)

	var col := VBoxContainer.new()
	col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(col)

	_tap_label = Label.new()
	_tap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tap_label.text = "Нажми экран — передай бомбу"
	_tap_label.add_theme_font_size_override("font_size", 37)
	_tap_label.add_theme_color_override("font_color", Color(0.96, 0.9, 0.82, 0.92))
	_tap_label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.02, 0.75))
	_tap_label.add_theme_constant_override("outline_size", 3)
	col.add_child(_tap_label)

	_ripple = _Ripple.new()
	_ripple.visible = false
	_ripple.set_anchors_preset(Control.PRESET_CENTER)
	_ripple.custom_minimum_size = Vector2(120, 120)
	add_child(_ripple)


func _exit_tree() -> void:
	listener.deinit()


func _on_tap_next(_touch_position: Vector2 = Vector2.ZERO) -> void:
	_flash_label(_tap_label)
	_play_ripple()


func _flash_label(label: Label) -> void:
	var tween := create_tween()
	tween.tween_property(label, "modulate", Color(1.4, 1.1, 0.95, 1.0), 0.06)
	tween.tween_property(label, "modulate", Color.WHITE, 0.18)


func _play_ripple() -> void:
	_ripple.visible = true
	_ripple.modulate.a = 0.7
	_ripple.scale = Vector2(0.4, 0.4)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_ripple, "scale", Vector2(1.6, 1.6), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_ripple, "modulate:a", 0.0, 0.35)
	tween.chain().tween_callback(func() -> void: _ripple.visible = false)


class _Ripple extends Control:
	func _draw() -> void:
		var center := size * 0.5
		draw_arc(center, minf(size.x, size.y) * 0.42, 0.0, TAU, 48, ACCENT.lightened(0.2), 4.0)
