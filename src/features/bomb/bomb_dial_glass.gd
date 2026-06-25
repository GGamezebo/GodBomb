class_name BombDialGlass
extends ColorRect

const GLASS_SHADER := preload("res://assets/shaders/bomb_dial_glass.gdshader")

@export var glass_alpha: float = 0.1
@export var rim_strength: float = 0.48
@export var spec_strength: float = 0.36
@export var glass_tint: Color = Color(0.9, 0.95, 1.0, 1.0)

var _material: ShaderMaterial


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color.WHITE
	_material = ShaderMaterial.new()
	_material.shader = GLASS_SHADER
	material = _material
	_apply_shader_params()


func _apply_shader_params() -> void:
	if not _material:
		return
	_material.set_shader_parameter("glass_alpha", glass_alpha)
	_material.set_shader_parameter("rim_strength", rim_strength)
	_material.set_shader_parameter("spec_strength", spec_strength)
	_material.set_shader_parameter("tint_color", glass_tint)
