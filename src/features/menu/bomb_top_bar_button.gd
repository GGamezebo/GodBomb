class_name BombTopBarButton
extends TextureButton

const HOVER_BOOST := 0.12
const ALERT_SPARKLE_MODULATE := Color(1.1, 1.02, 0.98, 1.0)

@export var glow_tint: Color = Color(0.92, 0.58, 0.28, 1.0)
@export var alert_glow: bool = false

var _glow: BombIconGlow
var _hovered := false
var _pressed := false
var _base_scale := Vector2.ONE


func _ready() -> void:
	clip_contents = false
	focus_mode = Control.FOCUS_NONE
	pivot_offset = size * 0.5
	_glow = BombIconGlow.new()
	_glow.shape_profile = BombIconGlow.ShapeProfile.TOP_BAR_120
	_glow.glow_tint = glow_tint
	_glow.alert_glow = alert_glow
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.show_behind_parent = true
	add_child(_glow)
	move_child(_glow, 0)
	resized.connect(_layout_glow)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	call_deferred("_layout_glow")
	set_process(alert_glow)


func _process(_delta: float) -> void:
	if not alert_glow or _glow == null:
		return
	_apply_alert_presence(_glow.get_alert_sparkle_amount())


func _layout_glow() -> void:
	if not _glow:
		return
	_glow.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_glow.position = Vector2.ZERO
	if size.x > 0.0 and size.y > 0.0:
		_glow.size = size
		pivot_offset = size * 0.5
	_glow.glow_tint = glow_tint
	_glow.alert_glow = alert_glow
	set_process(alert_glow)


func _apply_alert_presence(sparkle: float) -> void:
	if _pressed:
		return
	var warmth := 1.0 + sparkle * 0.08
	var lift := Color(warmth, 1.0 + sparkle * 0.03, 0.98 + sparkle * 0.02, 1.0)
	if _hovered:
		modulate = ALERT_SPARKLE_MODULATE * lift
	else:
		modulate = lift
	scale = _base_scale * (1.0 + sparkle * 0.028)


func _on_mouse_entered() -> void:
	_hovered = true
	_glow.set_hover_boost(HOVER_BOOST)
	if not alert_glow:
		modulate = Color(1.04, 1.0, 0.96, 1.0)


func _on_mouse_exited() -> void:
	_hovered = false
	_glow.set_hover_boost(0.0)
	if not alert_glow:
		modulate = Color.WHITE
		scale = _base_scale


func _on_button_down() -> void:
	_pressed = true
	modulate = Color(1.08, 1.02, 0.96, 1.0)
	scale = _base_scale * 0.97


func _on_button_up() -> void:
	_pressed = false
	scale = _base_scale
	if alert_glow:
		_apply_alert_presence(_glow.get_alert_sparkle_amount() if _glow else 0.0)
	else:
		modulate = Color(1.04, 1.0, 0.96, 1.0) if _hovered else Color.WHITE
