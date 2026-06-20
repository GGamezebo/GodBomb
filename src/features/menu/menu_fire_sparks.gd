class_name MenuFireSparks
extends Control

const DESIGN_SIZE := Vector2(1080.0, 1920.0)

var _additive_material: CanvasItemMaterial


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_layers()
	resized.connect(_update_emission_extents)
	call_deferred("_update_emission_extents")


func _build_layers() -> void:
	var embers := _create_particles(
		"Embers",
		130,
		4.2,
		Vector2(0.0, -22.0),
		180.0,
		24.0,
		150.0,
		0.9,
		5.2,
		_make_ember_gradient()
	)
	var sparks := _create_particles(
		"Sparks",
		90,
		2.8,
		Vector2(0.0, -10.0),
		180.0,
		35.0,
		190.0,
		0.55,
		3.2,
		_make_spark_gradient()
	)
	var glow := _create_particles(
		"GlowDust",
		55,
		5.5,
		Vector2(0.0, -6.0),
		180.0,
		10.0,
		65.0,
		1.6,
		7.2,
		_make_glow_gradient()
	)
	add_child(embers)
	add_child(sparks)
	add_child(glow)


func _create_particles(
	node_name: String,
	amount: int,
	lifetime: float,
	gravity: Vector2,
	spread: float,
	velocity_min: float,
	velocity_max: float,
	scale_min: float,
	scale_max: float,
	color_ramp: Gradient
) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = node_name
	particles.emitting = true
	particles.amount = amount
	particles.lifetime = lifetime
	particles.preprocess = lifetime
	particles.explosiveness = 0.0
	particles.randomness = 0.85
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.direction = Vector2(0.0, -1.0)
	particles.spread = spread
	particles.gravity = gravity
	particles.initial_velocity_min = velocity_min
	particles.initial_velocity_max = velocity_max
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max = 180.0
	particles.damping_min = 8.0
	particles.damping_max = 28.0
	particles.scale_amount_min = scale_min
	particles.scale_amount_max = scale_max
	particles.color = Color(1.15, 1.05, 0.92, 1.0)
	particles.color_ramp = color_ramp
	particles.material = _get_additive_material()
	particles.position = DESIGN_SIZE * 0.5
	return particles


func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material


func _make_ember_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.98, 0.82, 0.0))
	gradient.set_color(1, Color(1.0, 0.5, 0.1, 1.0))
	gradient.add_point(0.35, Color(1.0, 0.78, 0.22, 1.0))
	gradient.add_point(0.75, Color(1.0, 0.35, 0.05, 0.75))
	return gradient


func _make_spark_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 1.0, 0.96, 1.0))
	gradient.set_color(1, Color(1.0, 0.62, 0.12, 0.0))
	gradient.add_point(0.45, Color(1.0, 0.88, 0.35, 1.0))
	return gradient


func _make_glow_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.52, 0.1, 0.0))
	gradient.set_color(1, Color(1.0, 0.42, 0.08, 0.38))
	gradient.add_point(0.5, Color(1.0, 0.62, 0.15, 0.5))
	return gradient


func _update_emission_extents() -> void:
	var area_size := size
	if area_size.x <= 1.0 or area_size.y <= 1.0:
		area_size = get_viewport_rect().size
	if area_size.x <= 1.0 or area_size.y <= 1.0:
		area_size = DESIGN_SIZE
	var half := area_size * 0.5
	var center := half
	for child in get_children():
		if child is CPUParticles2D:
			var particles := child as CPUParticles2D
			particles.position = center
			particles.emission_rect_extents = half
