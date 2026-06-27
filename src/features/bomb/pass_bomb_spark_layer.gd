class_name PassBombSparkLayer
extends Node2D

@export var game_events: GameEvents

var listener: EventListener = EventListener.new()
var _additive_material: CanvasItemMaterial


func _ready() -> void:
	z_index = 7
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		listener.add(game_events.ev_touch_next_player, _on_touch_next_player)


func _exit_tree() -> void:
	listener.deinit()


func _on_touch_next_player(screen_position: Vector2) -> void:
	spawn_burst_at_screen(screen_position)


func spawn_burst_at_screen(screen_position: Vector2) -> void:
	var design_pos := _screen_to_design(screen_position)
	spawn_burst(design_pos)


func spawn_burst(design_position: Vector2) -> void:
	var host := Node2D.new()
	host.position = design_position
	add_child(host)

	var lifetime := 0.0
	for spec in _burst_specs():
		var particles := _create_burst_particles(spec)
		host.add_child(particles)
		lifetime = maxf(lifetime, particles.lifetime)

	host.set_meta(&"spark_burst", true)
	get_tree().create_timer(lifetime + 0.18).timeout.connect(host.queue_free)


func _screen_to_design(screen_position: Vector2) -> Vector2:
	var host := get_parent() as Control
	if host == null:
		return screen_position
	return host.get_global_transform_with_canvas().affine_inverse() * screen_position


func _burst_specs() -> Array[Dictionary]:
	return [
		{
			"name": &"ImpactFlash",
			"amount": 96,
			"lifetime": 0.34,
			"velocity_min": 180.0,
			"velocity_max": 420.0,
			"scale_min": 6.5,
			"scale_max": 14.0,
			"gradient": _make_flash_gradient(),
		},
		{
			"name": &"CoreSparks",
			"amount": 196,
			"lifetime": 0.52,
			"velocity_min": 440.0,
			"velocity_max": 980.0,
			"scale_min": 2.8,
			"scale_max": 7.8,
			"gradient": _make_core_gradient(),
		},
		{
			"name": &"FireDrops",
			"amount": 148,
			"lifetime": 0.68,
			"velocity_min": 300.0,
			"velocity_max": 760.0,
			"scale_min": 3.8,
			"scale_max": 10.5,
			"gradient": _make_drop_gradient(),
		},
		{
			"name": &"HotSpecks",
			"amount": 128,
			"lifetime": 0.38,
			"velocity_min": 680.0,
			"velocity_max": 1320.0,
			"scale_min": 1.6,
			"scale_max": 4.8,
			"gradient": _make_speck_gradient(),
		},
		{
			"name": &"EmberHalo",
			"amount": 112,
			"lifetime": 0.82,
			"velocity_min": 220.0,
			"velocity_max": 620.0,
			"scale_min": 4.5,
			"scale_max": 12.0,
			"gradient": _make_ember_gradient(),
		},
	]


func _create_burst_particles(spec: Dictionary) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = String(spec.get("name", "SparkBurst"))
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.randomness = 0.48
	particles.amount = int(spec.get("amount", 64))
	particles.lifetime = float(spec.get("lifetime", 0.4))
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	particles.direction = Vector2.RIGHT
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = float(spec.get("velocity_min", 300.0))
	particles.initial_velocity_max = float(spec.get("velocity_max", 600.0))
	particles.angular_velocity_min = -320.0
	particles.angular_velocity_max = 320.0
	particles.damping_min = 42.0
	particles.damping_max = 96.0
	particles.scale_amount_min = float(spec.get("scale_min", 2.0))
	particles.scale_amount_max = float(spec.get("scale_max", 5.0))
	particles.color = Color(1.42, 1.18, 0.88, 1.0)
	particles.color_ramp = spec.get("gradient") as Gradient
	particles.material = _get_additive_material()
	particles.emitting = true
	particles.restart()
	return particles


func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material


func _make_flash_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.65, 1.55, 1.25, 1.0))
	gradient.add_point(0.14, Color(1.45, 1.15, 0.55, 0.98))
	gradient.add_point(0.42, Color(1.15, 0.62, 0.08, 0.72))
	gradient.set_color(1, Color(0.55, 0.12, 0.02, 0.0))
	return gradient


func _make_core_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.48, 1.32, 1.05, 1.0))
	gradient.add_point(0.1, Color(1.28, 0.95, 0.32, 1.0))
	gradient.add_point(0.32, Color(1.08, 0.52, 0.06, 0.95))
	gradient.add_point(0.58, Color(0.82, 0.14, 0.02, 0.55))
	gradient.set_color(1, Color(0.42, 0.06, 0.01, 0.0))
	return gradient


func _make_drop_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.35, 0.88, 0.22, 1.0))
	gradient.add_point(0.18, Color(1.12, 0.48, 0.04, 0.98))
	gradient.add_point(0.48, Color(0.95, 0.22, 0.02, 0.72))
	gradient.add_point(0.72, Color(0.72, 0.1, 0.01, 0.35))
	gradient.set_color(1, Color(0.28, 0.04, 0.01, 0.0))
	return gradient


func _make_speck_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.55, 1.38, 1.08, 1.0))
	gradient.add_point(0.22, Color(1.22, 1.02, 0.58, 0.92))
	gradient.add_point(0.52, Color(1.05, 0.62, 0.12, 0.62))
	gradient.set_color(1, Color(0.92, 0.28, 0.04, 0.0))
	return gradient


func _make_ember_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.22, 0.72, 0.16, 0.98))
	gradient.add_point(0.28, Color(1.0, 0.38, 0.04, 0.78))
	gradient.add_point(0.62, Color(0.78, 0.12, 0.02, 0.42))
	gradient.set_color(1, Color(0.22, 0.03, 0.01, 0.0))
	return gradient
