class_name BombTopBarButton
extends TextureButton

const PULSE_PERIOD := 2.6
const BASE_GLOW_ALPHA := 0.14
const PULSE_GLOW_ALPHA := 0.26
const HOVER_BOOST := 0.1

@export var glow_tint: Color = Color(0.92, 0.58, 0.28, 1.0)
@export var alert_glow: bool = false

var _glow: _GlowRing
var _hovered := false


func _ready() -> void:
	clip_contents = false
	focus_mode = Control.FOCUS_NONE
	_glow = _GlowRing.new()
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.show_behind_parent = true
	add_child(_glow)
	move_child(_glow, 0)
	resized.connect(_layout_glow)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	_glow.configure(_get_glow_color(), alert_glow)
	_layout_glow()


func _layout_glow() -> void:
	if not _glow:
		return
	_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_glow.size = size


func _on_mouse_entered() -> void:
	_hovered = true
	_glow.set_hover_boost(HOVER_BOOST)


func _on_mouse_exited() -> void:
	_hovered = false
	_glow.set_hover_boost(0.0)
	modulate = Color.WHITE


func _on_button_down() -> void:
	modulate = Color(1.08, 1.02, 0.96, 1.0)


func _on_button_up() -> void:
	modulate = Color(1.04, 1.0, 0.96, 1.0) if _hovered else Color.WHITE


func _get_glow_color() -> Color:
	if alert_glow:
		return Color(0.95, 0.42, 0.28, 1.0)
	return glow_tint


class _GlowRing extends Control:
	const PULSE_PERIOD := 2.6
	const BASE_GLOW_ALPHA := 0.14
	const PULSE_GLOW_ALPHA := 0.26

	var _hover_boost := 0.0
	var _phase := 0.0
	var _tint := Color(0.92, 0.58, 0.28, 1.0)
	var _alert := false

	func _ready() -> void:
		set_process(true)

	func configure(tint: Color, alert: bool) -> void:
		_tint = tint
		_alert = alert

	func set_hover_boost(boost: float) -> void:
		_hover_boost = boost

	func _process(delta: float) -> void:
		var parent := get_parent() as BombTopBarButton
		if parent:
			_tint = parent._get_glow_color()
			_alert = parent.alert_glow
		_phase += delta
		queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		var base_radius := minf(size.x, size.y) * 0.47
		var pulse := 0.5 + 0.5 * sin(_phase * TAU / PULSE_PERIOD)
		var alpha := BASE_GLOW_ALPHA + pulse * PULSE_GLOW_ALPHA + _hover_boost
		if _alert:
			alpha += 0.04
		var ring := Color(_tint.r, _tint.g, _tint.b, alpha)
		draw_arc(center, base_radius, 0.0, TAU, 72, ring, 4.5)
		var outer := Color(_tint.r, _tint.g, _tint.b, alpha * 0.35)
		draw_arc(center, base_radius + 7.0, 0.0, TAU, 72, outer, 2.0)
