class_name BombTableActionButton
extends TextureButton

var _glow: BombIconGlow


func _ready() -> void:
	clip_contents = false
	focus_mode = Control.FOCUS_NONE
	_glow = BombIconGlow.new()
	_glow.shape_profile = BombIconGlow.ShapeProfile.TABLE_144
	_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow.show_behind_parent = true
	add_child(_glow)
	move_child(_glow, 0)
	resized.connect(_layout_glow)
	_layout_glow()
	set_glow_active(false)


func _layout_glow() -> void:
	if not _glow:
		return
	_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_glow.size = size


func set_glow_active(active: bool) -> void:
	if _glow:
		_glow.set_glow_enabled(active)


func set_alert_glow(alert: bool) -> void:
	if _glow:
		_glow.alert_glow = alert


func set_zone_boost(in_zone: bool) -> void:
	if _glow:
		_glow.set_extra_boost(0.14 if in_zone else 0.0)
