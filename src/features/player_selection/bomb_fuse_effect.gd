class_name BombFuseEffect
extends Control

const FUSE_TIP_DESIGN := Vector2(68.0, 20.0)
const DESIGN_SLIME_SIZE := 128.0
const BASE_SMOKE_GRAVITY := Vector2(0.0, -16.0)

var _fire: CPUParticles2D
var _embers: CPUParticles2D
var _smoke: CPUParticles2D
var _additive_material: CanvasItemMaterial
var _motion_velocity := Vector2.ZERO
var _time := 0.0
var _effect_scale := 1.0
var _track_global := Vector2.ZERO
var _has_track := false


static func attach_to(slime_rect: TextureRect) -> BombFuseEffect:
	if slime_rect == null:
		return null
	for child in slime_rect.get_children():
		if child is BombFuseEffect:
			var existing := child as BombFuseEffect
			existing.configure_for_slime(slime_rect.size)
			return existing
	var effect := BombFuseEffect.new()
	slime_rect.add_child(effect)
	effect.configure_for_slime(slime_rect.size)
	return effect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 6
	_build_layers()


func configure_for_slime(slime_size: Vector2) -> void:
	_effect_scale = slime_size.x / DESIGN_SLIME_SIZE
	var tip := FUSE_TIP_DESIGN * _effect_scale
	var box := 30.0 * _effect_scale
	size = Vector2(box, box)
	position = tip - size * 0.5
	_layout_particles()
	_update_particle_motion()


func set_motion_velocity(velocity: Vector2) -> void:
	_motion_velocity = velocity
	_update_particle_motion()


func _process(delta: float) -> void:
	_time += delta
	_update_motion_from_host(delta)
	queue_redraw()


func _update_motion_from_host(delta: float) -> void:
	var host := get_parent() as Control
	if host == null:
		return
	var global_center: Vector2 = host.get_global_transform_with_canvas() * (host.size * 0.5)
	if _has_track and delta > 0.0:
		var instant := (global_center - _track_global) / delta
		_motion_velocity = _motion_velocity.lerp(instant, clampf(delta * 14.0, 0.0, 1.0))
		_update_particle_motion()
	_track_global = global_center
	_has_track = true


func _draw() -> void:
	var center := size * 0.5
	var flicker := 0.84 + sin(_time * 13.5) * 0.08 + sin(_time * 21.0) * 0.05
	var speed := _motion_velocity.length()
	var lean := Vector2.ZERO
	if speed > 2.0:
		lean = -_motion_velocity.normalized() * clampf(speed * 0.014, 0.0, 9.0) * _effect_scale
	var glow_center := center + lean

	draw_circle(glow_center, 10.0 * _effect_scale * flicker, Color(1.0, 0.42, 0.06, 0.2))
	draw_circle(glow_center, 6.0 * _effect_scale * flicker, Color(1.0, 0.68, 0.16, 0.36))
	draw_circle(
		glow_center + Vector2(1.0, -1.4) * _effect_scale,
		3.0 * _effect_scale,
		Color(1.0, 0.94, 0.62, 0.78)
	)


func _build_layers() -> void:
	_smoke = _create_particles(
		"Smoke",
		14,
		1.9,
		BASE_SMOKE_GRAVITY,
		42.0,
		6.0,
		14.0,
		2.4,
		5.2,
		_make_smoke_gradient(),
		false
	)
	_fire = _create_particles(
		"Fire",
		10,
		0.32,
		Vector2(0.0, 18.0),
		34.0,
		18.0,
		42.0,
		1.6,
		3.0,
		_make_fire_gradient(),
		true
	)
	_embers = _create_particles(
		"Embers",
		8,
		0.55,
		Vector2(0.0, 24.0),
		52.0,
		24.0,
		58.0,
		0.9,
		1.8,
		_make_ember_gradient(),
		true
	)
	add_child(_smoke)
	add_child(_fire)
	add_child(_embers)


func _layout_particles() -> void:
	var center := size * 0.5
	for child in get_children():
		if child is CPUParticles2D:
			var particles := child as CPUParticles2D
			particles.position = center
			particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
			particles.emission_sphere_radius = 1.6 * _effect_scale


func _update_particle_motion() -> void:
	var speed := _motion_velocity.length()
	var norm := _motion_velocity.normalized() if speed > 1.0 else Vector2.ZERO
	var drag := -norm * clampf(speed * 0.42, 0.0, 140.0)
	var fire_tilt := norm * clampf(speed * 0.028, 0.0, 0.75)

	if _smoke:
		_smoke.gravity = BASE_SMOKE_GRAVITY + drag
		_smoke.direction = (Vector2(0.0, -1.0) + drag * 0.006).normalized()
		_smoke.initial_velocity_min = 7.0 + speed * 0.12
		_smoke.initial_velocity_max = 16.0 + speed * 0.28
		_smoke.spread = 36.0 + clampf(speed * 0.05, 0.0, 28.0)

	if _fire:
		_fire.direction = (Vector2(0.0, -1.0) + fire_tilt).normalized()
		_fire.spread = 24.0 + clampf(speed * 0.07, 0.0, 36.0)
		_fire.gravity = Vector2(0.0, 20.0) + drag * 0.25

	if _embers:
		_embers.direction = (Vector2(0.0, -1.0) + fire_tilt * 0.8).normalized()
		_embers.gravity = Vector2(0.0, 28.0) + drag * 0.35
		_embers.spread = 40.0 + clampf(speed * 0.06, 0.0, 32.0)


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
	color_ramp: Gradient,
	additive: bool
) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = node_name
	particles.emitting = true
	particles.amount = amount
	particles.lifetime = lifetime
	particles.preprocess = lifetime
	particles.explosiveness = 0.0
	particles.randomness = 0.82
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 1.6
	particles.direction = Vector2(0.0, -1.0)
	particles.spread = spread
	particles.gravity = gravity
	particles.initial_velocity_min = velocity_min
	particles.initial_velocity_max = velocity_max
	particles.angular_velocity_min = -120.0
	particles.angular_velocity_max = 120.0
	particles.damping_min = 6.0
	particles.damping_max = 18.0
	particles.scale_amount_min = scale_min
	particles.scale_amount_max = scale_max
	particles.color = Color(1.0, 1.0, 1.0, 1.0)
	particles.color_ramp = color_ramp
	if additive:
		particles.material = _get_additive_material()
	return particles


func _get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material


func _make_smoke_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.72, 0.7, 0.68, 0.0))
	gradient.set_color(1, Color(0.55, 0.53, 0.5, 0.0))
	gradient.add_point(0.2, Color(0.78, 0.76, 0.74, 0.22))
	gradient.add_point(0.55, Color(0.66, 0.64, 0.62, 0.14))
	return gradient


func _make_fire_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.95, 0.55, 1.0))
	gradient.set_color(1, Color(1.0, 0.35, 0.05, 0.0))
	gradient.add_point(0.45, Color(1.0, 0.72, 0.12, 0.95))
	return gradient


func _make_ember_gradient() -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.88, 0.35, 1.0))
	gradient.set_color(1, Color(1.0, 0.42, 0.08, 0.0))
	gradient.add_point(0.5, Color(1.0, 0.62, 0.1, 0.85))
	return gradient
