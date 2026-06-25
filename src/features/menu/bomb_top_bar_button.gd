class_name BombTopBarButton
extends TextureButton

const HOVER_BOOST := 0.12

@export var glow_tint: Color = Color(0.92, 0.58, 0.28, 1.0)
@export var alert_glow: bool = false

var _glow: BombIconGlow
var _hovered := false


func _ready() -> void:
	clip_contents = false
	focus_mode = Control.FOCUS_NONE
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
	_layout_glow()


func _layout_glow() -> void:
	if not _glow:
		return
	_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_glow.size = size
	_glow.glow_tint = glow_tint
	_glow.alert_glow = alert_glow


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
