extends Node2D

const AFTERSHOCK_DELAY := 0.09

@export var game_events: GameEvents
@export var particles: CPUParticles2D

var listener: EventListener = EventListener.new()
var _additive_material: CanvasItemMaterial


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if particles:
		particles.emitting = false
		_configure_scene_particles()
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

	_spawn_burst_layers(_primary_burst_specs(), Vector2.ZERO)
	get_tree().create_timer(AFTERSHOCK_DELAY).timeout.connect(
		_spawn_burst_layers.bind(_aftershock_burst_specs(), Vector2.ZERO), CONNECT_ONE_SHOT
	)


func _spawn_burst_layers(specs: Array[Dictionary], offset: Vector2) -> void:
	var host := Node2D.new()
	host.position = offset
	add_child(host)

	var lifetime := 0.0
	for spec in specs:
		var burst := _create_burst_particles(spec)
		host.add_child(burst)
		lifetime = maxf(lifetime, burst.lifetime)

	get_tree().create_timer(lifetime + 0.28).timeout.connect(host.queue_free)


func _configure_scene_particles() -> void:
	particles.amount = 320
	particles.lifetime = 1.05
	particles.initial_velocity_min = 680.0
	particles.initial_velocity_max = 1520.0
	particles.scale_amount_min = 5.0
	particles.scale_amount_max = 16.0
	particles.color = Color(1.55, 1.12, 0.62, 1.0)
	particles.color_ramp = _make_core_gradient()
	particles.material = _get_additive_material()


func _primary_burst_specs() -> Array[Dictionary]:
	return [
		{
			"name": &"ImpactFlash",
			"amount": 220,
			"lifetime": 0.42,
			"velocity_min": 240.0,
			"velocity_max": 620.0,
			"scale_min": 8.5,
			"scale_max": 22.0,
			"gradient": _make_flash_gradient(),
		},
		{
			"name": &"CoreBlast",
			"amount": 420,
			"lifetime": 0.88,
			"velocity_min": 620.0,
			"velocity_max": 1480.0,
			"scale_min": 4.8,
			"scale_max": 14.5,
			"gradient": _make_core_gradient(),
		},
		{
			"name": &"FireRing",
			"amount": 360,
			"lifetime": 1.02,
			"velocity_min": 420.0,
			"velocity_max": 1180.0,
			"scale_min": 3.8,
			"scale_max": 12.0,
			"gradient": _make_fire_gradient(),
		},
		{
			"name": &"HotSpecks",
			"amount": 320,
			"lifetime": 0.58,
			"velocity_min": 920.0,
			"velocity_max": 1880.0,
			"scale_min": 2.0,
			"scale_max": 6.2,
			"gradient": _make_speck_gradient(),
		},
		{
			"name": &"EmberCloud",
			"amount": 280,
			"lifetime": 1.28,
			"velocity_min": 260.0,
			"velocity_max": 860.0,
			"scale_min": 5.5,
			"scale_max": 16.0,
			"gradient": _make_ember_gradient(),
		},
		{
			"name": &"ShockwaveDust",
			"amount": 240,
			"lifetime": 1.45,
			"velocity_min": 180.0,
			"velocity_max": 520.0,
			"scale_min": 7.0,
			"scale_max": 20.0,
			"gradient": _make_shockwave_gradient(),
		},
	]


func _aftershock_burst_specs() -> Array[Dictionary]:
	return [
		{
			"name": &"AfterFlash",
			"amount": 96,
			"lifetime": 0.32,
			"velocity_min": 160.0,
			"velocity_max": 420.0,
			"scale_min": 6.0,
			"scale_max": 14.0,
			"gradient": _make_flash_gradient(),
		},
		{
			"name": &"AfterCore",
			"amount": 180,
			"lifetime": 0.62,
			"velocity_min": 380.0,
			"velocity_max": 920.0,
			"scale_min": 3.2,
			"scale_max": 9.5,
			"gradient": _make_core_gradient(),
		},
		{
			"name": &"AfterEmbers",
			"amount": 160,
			"lifetime": 0.95,
			"velocity_min": 220.0,
			"velocity_max": 680.0,
			"scale_min": 4.5,
			"scale_max": 12.5,
			"gradient": _make_ember_gradient(),
		},
	]


func _create_burst_particles(spec: Dictionary) -> CPUParticles2D:
	var burst := CPUParticles2D.new()
	burst.name = String(spec.get("name", "ExplosionBurst"))
	burst.emitting = false
	burst.one_shot = true
	burst.explosiveness = 1.0
	burst.randomness = 0.52
	burst.amount = int(spec.get("amount", 128))
	burst.lifetime = float(spec.get("lifetime", 0.6))
	burst.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
	burst.direction = Vector2.RIGHT
	burst.spread = 180.0
	burst.gravity = Vector2.ZERO
	burst.initial_velocity_min = float(spec.get("velocity_min", 400.0))
	burst.initial_velocity_max = float(spec.get("velocity_max", 900.0))
	burst.angular_velocity_min = -420.0
	burst.angular_velocity_max = 420.0
	burst.damping_min = 32.0
	burst.damping_max = 88.0
	burst.scale_amount_min = float(spec.get("scale_min", 2.0))
	burst.scale_amount_max = float(spec.get("scale_max", 6.0))
	burst.color = Color(1.58, 1.22, 0.78, 1.0)
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


func _make_flash_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.85, 1.72, 1.35, 1.0))
	gradient.add_point(0.1, Color(1.55, 1.18, 0.48, 0.98))
	gradient.add_point(0.34, Color(1.22, 0.58, 0.06, 0.78))
	gradient.set_color(1, Color(0.62, 0.1, 0.02, 0.0))
	return gradient


func _make_core_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.72, 1.48, 1.12, 1.0))
	gradient.add_point(0.08, Color(1.45, 1.05, 0.38, 1.0))
	gradient.add_point(0.28, Color(1.18, 0.55, 0.05, 0.98))
	gradient.add_point(0.58, Color(0.88, 0.16, 0.02, 0.62))
	gradient.add_point(0.82, Color(0.58, 0.08, 0.01, 0.28))
	gradient.set_color(1, Color(0.32, 0.04, 0.01, 0.0))
	return gradient


func _make_fire_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.52, 0.92, 0.22, 1.0))
	gradient.add_point(0.16, Color(1.18, 0.48, 0.04, 0.98))
	gradient.add_point(0.42, Color(0.98, 0.22, 0.02, 0.78))
	gradient.add_point(0.72, Color(0.72, 0.1, 0.01, 0.38))
	gradient.set_color(1, Color(0.24, 0.03, 0.01, 0.0))
	return gradient


func _make_speck_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.72, 1.48, 1.12, 1.0))
	gradient.add_point(0.18, Color(1.32, 1.05, 0.62, 0.95))
	gradient.add_point(0.48, Color(1.08, 0.62, 0.12, 0.68))
	gradient.add_point(0.78, Color(0.92, 0.28, 0.04, 0.32))
	gradient.set_color(1, Color(0.78, 0.16, 0.02, 0.0))
	return gradient


func _make_ember_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.35, 0.72, 0.16, 0.98))
	gradient.add_point(0.22, Color(1.05, 0.38, 0.04, 0.82))
	gradient.add_point(0.52, Color(0.82, 0.16, 0.02, 0.52))
	gradient.add_point(0.82, Color(0.52, 0.08, 0.01, 0.22))
	gradient.set_color(1, Color(0.16, 0.02, 0.01, 0.0))
	return gradient


func _make_shockwave_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.28, 0.82, 0.24, 0.92))
	gradient.add_point(0.24, Color(0.95, 0.32, 0.04, 0.62))
	gradient.add_point(0.58, Color(0.62, 0.12, 0.02, 0.28))
	gradient.set_color(1, Color(0.18, 0.03, 0.01, 0.0))
	return gradient
