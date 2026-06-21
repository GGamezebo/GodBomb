class_name ResultCelebrationLayer
extends Control

const DESIGN_SIZE := Vector2(1080.0, 1920.0)

var _active := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size = DESIGN_SIZE


func start() -> void:
	if _active:
		return
	_active = true
	for child in get_children():
		child.queue_free()

	add_child(_create_bubble_layer())
	add_child(_create_confetti_rain_layer())
	add_child(_create_confetti_fountain_layer())
	add_child(_create_sparkle_layer())
	add_child(_create_glow_drift_layer())
	_spawn_burst(Vector2(DESIGN_SIZE.x * 0.5, 420.0), 1.35)
	_spawn_burst(Vector2(220.0, 760.0), 0.95)
	_spawn_burst(Vector2(860.0, 820.0), 0.95)


func stop() -> void:
	_active = false
	for child in get_children():
		child.queue_free()


func _spawn_burst(origin: Vector2, scale: float) -> void:
	var host := Node2D.new()
	host.position = origin
	add_child(host)
	for spec in _burst_specs(scale):
		host.add_child(_create_burst_particles(spec))
	get_tree().create_timer(1.4).timeout.connect(host.queue_free)


func _burst_specs(scale: float) -> Array[Dictionary]:
	return [
		{
			"amount": int(72 * scale),
			"lifetime": 0.95,
			"velocity_min": 180.0 * scale,
			"velocity_max": 420.0 * scale,
			"scale_min": 2.4 * scale,
			"scale_max": 6.5 * scale,
			"gradient": _make_burst_gradient(),
		},
		{
			"amount": int(48 * scale),
			"lifetime": 1.1,
			"velocity_min": 120.0 * scale,
			"velocity_max": 280.0 * scale,
			"scale_min": 4.0 * scale,
			"scale_max": 9.0 * scale,
			"gradient": _make_soft_glow_gradient(),
		},
	]


func _create_burst_particles(spec: Dictionary) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.randomness = 0.55
	particles.amount = int(spec.get("amount", 64))
	particles.lifetime = float(spec.get("lifetime", 0.8))
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	particles.direction = Vector2.RIGHT
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = float(spec.get("velocity_min", 200.0))
	particles.initial_velocity_max = float(spec.get("velocity_max", 420.0))
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max = 180.0
	particles.damping_min = 40.0
	particles.damping_max = 100.0
	particles.scale_amount_min = float(spec.get("scale_min", 2.0))
	particles.scale_amount_max = float(spec.get("scale_max", 5.0))
	particles.color = Color(1.15, 1.05, 0.95, 1.0)
	particles.color_ramp = spec.get("gradient") as Gradient
	particles.emitting = true
	particles.restart()
	return particles


func _create_bubble_layer() -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = "SoftBubbles"
	particles.emitting = true
	particles.amount = 52
	particles.lifetime = 7.0
	particles.preprocess = 3.0
	particles.explosiveness = 0.0
	particles.randomness = 0.72
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(DESIGN_SIZE.x * 0.5, DESIGN_SIZE.y * 0.5)
	particles.position = DESIGN_SIZE * 0.5
	particles.direction = Vector2(0.0, -1.0)
	particles.spread = 42.0
	particles.gravity = Vector2(0.0, -24.0)
	particles.initial_velocity_min = 22.0
	particles.initial_velocity_max = 88.0
	particles.angular_velocity_min = -24.0
	particles.angular_velocity_max = 24.0
	particles.damping_min = 3.0
	particles.damping_max = 10.0
	particles.scale_amount_min = 8.0
	particles.scale_amount_max = 18.0
	particles.color = Color(1.0, 0.96, 0.98, 0.48)
	particles.color_ramp = _make_bubble_gradient()
	return particles


func _create_confetti_rain_layer() -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = "ConfettiRain"
	particles.emitting = true
	particles.amount = 120
	particles.lifetime = 5.2
	particles.preprocess = 2.0
	particles.explosiveness = 0.0
	particles.randomness = 0.92
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(DESIGN_SIZE.x * 0.5, 140.0)
	particles.position = Vector2(DESIGN_SIZE.x * 0.5, 120.0)
	particles.direction = Vector2(0.0, 1.0)
	particles.spread = 68.0
	particles.gravity = Vector2(0.0, 48.0)
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 130.0
	particles.angular_velocity_min = -160.0
	particles.angular_velocity_max = 160.0
	particles.damping_min = 5.0
	particles.damping_max = 16.0
	particles.scale_amount_min = 2.4
	particles.scale_amount_max = 6.0
	particles.color = Color(1.0, 0.96, 0.88, 0.95)
	particles.color_ramp = _make_confetti_gradient()
	return particles


func _create_confetti_fountain_layer() -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = "ConfettiFountain"
	particles.emitting = true
	particles.amount = 88
	particles.lifetime = 4.6
	particles.preprocess = 1.6
	particles.explosiveness = 0.0
	particles.randomness = 0.88
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(DESIGN_SIZE.x * 0.42, 80.0)
	particles.position = Vector2(DESIGN_SIZE.x * 0.5, DESIGN_SIZE.y - 220.0)
	particles.direction = Vector2(0.0, -1.0)
	particles.spread = 54.0
	particles.gravity = Vector2(0.0, -36.0)
	particles.initial_velocity_min = 90.0
	particles.initial_velocity_max = 210.0
	particles.angular_velocity_min = -140.0
	particles.angular_velocity_max = 140.0
	particles.damping_min = 8.0
	particles.damping_max = 20.0
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 5.5
	particles.color = Color(1.0, 0.94, 0.82, 0.92)
	particles.color_ramp = _make_confetti_gradient()
	return particles


func _create_sparkle_layer() -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = "SparkleTwinkle"
	particles.emitting = true
	particles.amount = 64
	particles.lifetime = 2.8
	particles.preprocess = 1.2
	particles.explosiveness = 0.0
	particles.randomness = 1.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(DESIGN_SIZE.x * 0.48, DESIGN_SIZE.y * 0.42)
	particles.position = Vector2(DESIGN_SIZE.x * 0.5, DESIGN_SIZE.y * 0.42)
	particles.direction = Vector2(0.0, -1.0)
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = 8.0
	particles.initial_velocity_max = 36.0
	particles.angular_velocity_min = -90.0
	particles.angular_velocity_max = 90.0
	particles.damping_min = 2.0
	particles.damping_max = 8.0
	particles.scale_amount_min = 1.2
	particles.scale_amount_max = 3.2
	particles.color = Color(1.35, 1.22, 1.0, 0.95)
	particles.color_ramp = _make_sparkle_gradient()
	return particles


func _create_glow_drift_layer() -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = "GlowDrift"
	particles.emitting = true
	particles.amount = 36
	particles.lifetime = 5.8
	particles.preprocess = 2.4
	particles.explosiveness = 0.0
	particles.randomness = 0.8
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(DESIGN_SIZE.x * 0.46, DESIGN_SIZE.y * 0.5)
	particles.position = DESIGN_SIZE * 0.5
	particles.direction = Vector2(0.0, -1.0)
	particles.spread = 28.0
	particles.gravity = Vector2(0.0, -12.0)
	particles.initial_velocity_min = 14.0
	particles.initial_velocity_max = 42.0
	particles.scale_amount_min = 10.0
	particles.scale_amount_max = 22.0
	particles.color = Color(1.0, 0.98, 0.92, 0.28)
	particles.color_ramp = _make_soft_glow_gradient()
	return particles


func _make_bubble_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.92, 0.98, 0.62))
	gradient.add_point(0.35, Color(0.82, 0.94, 1.0, 0.48))
	gradient.add_point(0.72, Color(1.0, 0.9, 0.96, 0.22))
	gradient.set_color(1, Color(1.0, 0.96, 0.88, 0.0))
	return gradient


func _make_confetti_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.72, 0.86, 0.98))
	gradient.add_point(0.18, Color(0.72, 0.92, 1.0, 0.95))
	gradient.add_point(0.42, Color(1.0, 0.9, 0.55, 0.92))
	gradient.add_point(0.66, Color(0.78, 1.0, 0.72, 0.86))
	gradient.add_point(0.88, Color(0.95, 0.78, 1.0, 0.4))
	gradient.set_color(1, Color(1.0, 0.96, 0.88, 0.0))
	return gradient


func _make_sparkle_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.45, 1.3, 1.05, 1.0))
	gradient.add_point(0.35, Color(1.15, 0.98, 0.72, 0.85))
	gradient.add_point(0.7, Color(1.0, 0.82, 0.98, 0.35))
	gradient.set_color(1, Color(1.0, 0.94, 0.86, 0.0))
	return gradient


func _make_burst_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.35, 1.18, 0.98, 1.0))
	gradient.add_point(0.2, Color(1.0, 0.86, 0.42, 0.95))
	gradient.add_point(0.55, Color(0.95, 0.55, 0.95, 0.7))
	gradient.set_color(1, Color(1.0, 0.96, 0.88, 0.0))
	return gradient


func _make_soft_glow_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.1, 1.0, 0.88, 0.55))
	gradient.add_point(0.45, Color(1.0, 0.92, 0.98, 0.28))
	gradient.set_color(1, Color(1.0, 0.96, 0.88, 0.0))
	return gradient
