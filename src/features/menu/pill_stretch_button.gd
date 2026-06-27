class_name PillStretchButton
extends Button

## Same imported bitmap as res://.godot/imported/start_active.svg-*.ctex — use the source path.
const DEFAULT_FACE_TEXTURE := preload("res://assets/party_kitchen/buttons/start_active.svg")
const DEFAULT_DISABLED_TEXTURE := preload("res://assets/party_kitchen/buttons/start_inactive.svg")

const REF_TEXTURE_SIZE := Vector2(440.0, 120.0)
const REF_PATCH_MARGINS := Vector4i(44, 34, 44, 34)
const FACE_CENTER_Y_RATIO := 52.0 / 120.0
const CONTENT_MARGIN_H := 28.0
const CONTENT_MARGIN_MIN := 8.0

@export var height_scale: float = 0.675
@export var face_texture: Texture2D = DEFAULT_FACE_TEXTURE:
	set(value):
		face_texture = value if value else DEFAULT_FACE_TEXTURE
		if is_node_ready():
			_rebuild_styles()
@export var disabled_texture: Texture2D = DEFAULT_DISABLED_TEXTURE:
	set(value):
		disabled_texture = value if value else DEFAULT_DISABLED_TEXTURE
		if is_node_ready():
			_rebuild_styles()
@export var action_text: String = "":
	get:
		return text
	set(value):
		if text == value:
			return
		text = value

var _sync_queued := false
var _style_normal: StyleBoxTexture
var _style_hover: StyleBoxTexture
var _style_focus: StyleBoxTexture
var _style_pressed: StyleBoxTexture
var _style_disabled: StyleBoxTexture


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	alignment = HORIZONTAL_ALIGNMENT_CENTER
	clip_contents = false
	_rebuild_styles()
	resized.connect(_queue_sync_content_margins)
	call_deferred("_queue_sync_content_margins")


func apply_scaled_action_size(viewport_size: Vector2, use_design_font: bool = true) -> void:
	var cover_scale := StartActionButton.viewport_cover_scale(viewport_size)
	custom_minimum_size = Vector2(
		0.0,
		StartActionButton.DESIGN_ACTION_SIZE.y * cover_scale * height_scale
	)
	var font_size := StartActionButton.DESIGN_FONT_SIZE if use_design_font else StartActionButton.MODAL_FONT_SIZE
	var font_scale := cover_scale * height_scale / 1.35
	add_theme_font_size_override("font_size", maxi(24, int(round(font_size * font_scale))))
	_queue_sync_content_margins()


func _rebuild_styles() -> void:
	_style_normal = _make_patch_style(face_texture)
	_style_pressed = _make_patch_style(face_texture)
	_style_pressed.modulate_color = Color(0.88, 0.84, 0.8, 1.0)
	_style_disabled = _make_patch_style(disabled_texture)
	_apply_state_styles()
	_queue_sync_content_margins()


func _patch_margins_for(texture: Texture2D) -> Vector4i:
	var tex_size := texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return REF_PATCH_MARGINS
	return Vector4i(
		maxi(1, int(round(float(REF_PATCH_MARGINS.x) * tex_size.x / REF_TEXTURE_SIZE.x))),
		maxi(1, int(round(float(REF_PATCH_MARGINS.y) * tex_size.y / REF_TEXTURE_SIZE.y))),
		maxi(1, int(round(float(REF_PATCH_MARGINS.z) * tex_size.x / REF_TEXTURE_SIZE.x))),
		maxi(1, int(round(float(REF_PATCH_MARGINS.w) * tex_size.y / REF_TEXTURE_SIZE.y)))
	)


func _make_patch_style(texture: Texture2D) -> StyleBoxTexture:
	var margins := _patch_margins_for(texture)
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.region_rect = Rect2(Vector2.ZERO, texture.get_size())
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_STRETCH
	style.texture_margin_left = margins.x
	style.texture_margin_top = margins.y
	style.texture_margin_right = margins.z
	style.texture_margin_bottom = margins.w
	style.content_margin_left = CONTENT_MARGIN_H
	style.content_margin_right = CONTENT_MARGIN_H
	return style


func _apply_state_styles() -> void:
	_style_hover = _style_normal.duplicate()
	_style_focus = _style_normal.duplicate()
	add_theme_stylebox_override("normal", _style_normal)
	add_theme_stylebox_override("hover", _style_hover)
	add_theme_stylebox_override("focus", _style_focus)
	add_theme_stylebox_override("pressed", _style_pressed)
	add_theme_stylebox_override("disabled", _style_disabled)
	add_theme_color_override("font_color", Color(1, 0.98, 0.94, 1))
	add_theme_color_override("font_hover_color", Color(1, 0.98, 0.94, 1))
	add_theme_color_override("font_pressed_color", Color(1, 0.96, 0.92, 1))
	add_theme_color_override("font_disabled_color", Color(0.82, 0.8, 0.76, 1))
	add_theme_color_override("font_outline_color", Color(0.12, 0.06, 0.02, 0.85))
	add_theme_constant_override("outline_size", 3)


func _queue_sync_content_margins() -> void:
	if _sync_queued:
		return
	_sync_queued = true
	call_deferred("_sync_content_margins")


func _sync_content_margins() -> void:
	_sync_queued = false
	if size.y <= 0.0:
		return
	var bottom_margin := CONTENT_MARGIN_MIN + size.y * (1.0 - 2.0 * FACE_CENTER_Y_RATIO)
	for style in [_style_normal, _style_hover, _style_focus, _style_pressed, _style_disabled]:
		if style == null:
			continue
		style.content_margin_top = CONTENT_MARGIN_MIN
		style.content_margin_bottom = bottom_margin
