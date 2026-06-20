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
	get_tree().create_timer(lifetime + 0.12).timeout.connect(host.queue_free)


func _screen_to_design(screen_position: Vector2) -> Vector2:
	var host := get_parent() as Control
	if host == null:
		return screen_position
	return host.get_global_transform_with_canvas().affine_inverse() * screen_position


func _burst_specs() -> Array[Dictionary]:
	return [
		{
			"name": &"CoreSparks",
			"amount": 88,
			"lifetime": 0.42,
			"velocity_min": 360.0,
			"velocity_max": 760.0,
			"scale_min": 1.8,
			"scale_max": 5.2,
			"gradient": _make_core_gradient(),
		},
		{
			"name": &"FireDrops",
			"amount": 56,
			"lifetime": 0.55,
			"velocity_min": 240.0,
			"velocity_max": 540.0,
			"scale_min": 2.8,
			"scale_max": 7.5,
			"gradient": _make_drop_gradient(),
		},
		{
			"name": &"HotSpecks",
			"amount": 40,
			"lifetime": 0.28,
			"velocity_min": 520.0,
			"velocity_max": 980.0,
			"scale_min": 1.0,
			"scale_max": 2.8,
			"gradient": _make_speck_gradient(),
		},
	]


func _create_burst_particles(spec: Dictionary) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = String(spec.get("name", "SparkBurst"))
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.randomness = 0.35
	particles.amount = int(spec.get("amount", 64))
	particles.lifetime = float(spec.get("lifetime", 0.4))
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	particles.direction = Vector2.RIGHT
	particles.spread = 180.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = float(spec.get("velocity_min", 300.0))
	particles.initial_velocity_max = float(spec.get("velocity_max", 600.0))
	particles.angular_velocity_min = -240.0
	particles.angular_velocity_max = 240.0
	particles.damping_min = 72.0
	particles.damping_max = 140.0
	particles.scale_amount_min = float(spec.get("scale_min", 2.0))
	particles.scale_amount_max = float(spec.get("scale_max", 5.0))
	particles.color = Color(1.15, 1.05, 0.92, 1.0)
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


func _make_core_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.25, 1.18, 0.98, 1.0))
	gradient.add_point(0.18, Color(1.0, 0.82, 0.28, 1.0))
	gradient.add_point(0.45, Color(1.0, 0.45, 0.08, 0.85))
	gradient.set_color(1, Color(0.45, 0.08, 0.02, 0.0))
	return gradient


func _make_drop_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.1, 0.72, 0.18, 1.0))
	gradient.add_point(0.25, Color(1.0, 0.42, 0.05, 0.95))
	gradient.add_point(0.62, Color(0.85, 0.18, 0.02, 0.45))
	gradient.set_color(1, Color(0.25, 0.04, 0.01, 0.0))
	return gradient


func _make_speck_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.35, 1.2, 1.0, 1.0))
	gradient.add_point(0.35, Color(1.0, 0.9, 0.45, 0.75))
	gradient.set_color(1, Color(1.0, 0.55, 0.12, 0.0))
	return gradient
