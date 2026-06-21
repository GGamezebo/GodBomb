extends Node2D

@export var game_events: GameEvents
@export var particles: CPUParticles2D

var listener: EventListener = EventListener.new()
var _additive_material: CanvasItemMaterial


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if particles:
		particles.emitting = false
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)


func _exit_tree() -> void:
	listener.deinit()


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	if to_state == FSMGameStates.EXPLOSION:
		_play_burst()


func _play_burst() -> void:
	if particles:
		particles.restart()
		particles.emitting = true

	var host := Node2D.new()
	add_child(host)

	var lifetime := 0.0
	for spec in _burst_specs():
		var burst := _create_burst_particles(spec)
		host.add_child(burst)
		lifetime = maxf(lifetime, burst.lifetime)

	get_tree().create_timer(lifetime + 0.2).timeout.connect(host.queue_free)


func _burst_specs() -> Array[Dictionary]:
	return [
		{
			"name": &"CoreBlast",
			"amount": 240,
			"lifetime": 0.72,
			"velocity_min": 520.0,
			"velocity_max": 1180.0,
			"scale_min": 3.2,
			"scale_max": 9.5,
			"gradient": _make_core_gradient(),
		},
		{
			"name": &"FireRing",
			"amount": 200,
			"lifetime": 0.85,
			"velocity_min": 360.0,
			"velocity_max": 920.0,
			"scale_min": 2.6,
			"scale_max": 8.0,
			"gradient": _make_fire_gradient(),
		},
		{
			"name": &"HotSpecks",
			"amount": 160,
			"lifetime": 0.48,
			"velocity_min": 760.0,
			"velocity_max": 1480.0,
			"scale_min": 1.4,
			"scale_max": 4.2,
			"gradient": _make_speck_gradient(),
		},
		{
			"name": &"EmberCloud",
			"amount": 140,
			"lifetime": 1.05,
			"velocity_min": 220.0,
			"velocity_max": 680.0,
			"scale_min": 4.0,
			"scale_max": 11.0,
			"gradient": _make_ember_gradient(),
		},
	]


func _create_burst_particles(spec: Dictionary) -> CPUParticles2D:
	var burst := CPUParticles2D.new()
	burst.name = String(spec.get("name", "ExplosionBurst"))
	burst.emitting = false
	burst.one_shot = true
	burst.explosiveness = 1.0
	burst.randomness = 0.42
	burst.amount = int(spec.get("amount", 128))
	burst.lifetime = float(spec.get("lifetime", 0.6))
	burst.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	burst.direction = Vector2.RIGHT
	burst.spread = 180.0
	burst.gravity = Vector2.ZERO
	burst.initial_velocity_min = float(spec.get("velocity_min", 400.0))
	burst.initial_velocity_max = float(spec.get("velocity_max", 900.0))
	burst.angular_velocity_min = -320.0
	burst.angular_velocity_max = 320.0
	burst.damping_min = 48.0
	burst.damping_max = 120.0
	burst.scale_amount_min = float(spec.get("scale_min", 2.0))
	burst.scale_amount_max = float(spec.get("scale_max", 6.0))
	burst.color = Color(1.2, 0.95, 0.72, 1.0)
	burst.color_ramp = spec.get("gradient") as Gradient
	burst.material = _get_additive_material()
	burst.emitting = true
	burst.restart()
	return burst


func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material


func _make_core_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.35, 1.22, 1.0, 1.0))
	gradient.add_point(0.12, Color(1.2, 0.92, 0.35, 1.0))
	gradient.add_point(0.38, Color(1.0, 0.48, 0.08, 0.92))
	gradient.add_point(0.72, Color(0.72, 0.12, 0.02, 0.35))
	gradient.set_color(1, Color(0.35, 0.05, 0.01, 0.0))
	return gradient


func _make_fire_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.25, 0.78, 0.18, 1.0))
	gradient.add_point(0.22, Color(1.0, 0.42, 0.05, 0.95))
	gradient.add_point(0.55, Color(0.88, 0.16, 0.02, 0.55))
	gradient.set_color(1, Color(0.22, 0.03, 0.01, 0.0))
	return gradient


func _make_speck_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.45, 1.28, 1.05, 1.0))
	gradient.add_point(0.28, Color(1.15, 0.95, 0.55, 0.85))
	gradient.add_point(0.62, Color(1.0, 0.55, 0.12, 0.45))
	gradient.set_color(1, Color(0.85, 0.22, 0.04, 0.0))
	return gradient


func _make_ember_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.1, 0.62, 0.14, 0.95))
	gradient.add_point(0.35, Color(0.95, 0.28, 0.04, 0.65))
	gradient.add_point(0.78, Color(0.55, 0.08, 0.02, 0.22))
	gradient.set_color(1, Color(0.18, 0.03, 0.01, 0.0))
	return gradient
