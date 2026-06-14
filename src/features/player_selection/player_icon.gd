class_name PlayerIcon
extends Control

const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"

signal drag_started
signal drag_ended
signal hold_edit_requested(index: int)

enum DragState {
	NONE,
	RETURNING,
	SWAPPING,
}

@export var slime_rect: TextureRect
@export var name_label: Label
@export var hold_time: float = 2.0
@export var move_lerp_speed: float = 12.0
@export var swap_activation_distance: float = 24.0

var home_position: Vector2 = Vector2.ZERO
var player_index: int = -1
var swap_target: PlayerIcon
var lobby_phase_offset: float = 0.0

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _hold_timer: float = 0.0
var _holding: bool = false
var _hold_vibrated: bool = false
var _drag_state: DragState = DragState.NONE
var _seat_offset: Vector2 = Vector2.ZERO
var _seat_offset_cached: bool = false
var _base_slime_scale: Vector2 = Vector2.ONE
var _motion_tween: Tween
var _edit_hint: Label
var _last_drag_global: Vector2 = Vector2.ZERO


func _ready() -> void:
	if slime_rect:
		_base_slime_scale = slime_rect.scale
		call_deferred("_setup_slime_pivot")
	_setup_edit_hint()
	call_deferred("_cache_seat_offset")


func _setup_slime_pivot() -> void:
	if not slime_rect:
		return
	slime_rect.pivot_offset = slime_rect.size * 0.5
	_cache_seat_offset()


func _setup_edit_hint() -> void:
	_edit_hint = Label.new()
	_edit_hint.text = "✎"
	_edit_hint.visible = false
	_edit_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_edit_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_edit_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_edit_hint.add_theme_font_size_override("font_size", 28)
	_edit_hint.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2, 1))
	_edit_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_edit_hint.offset_top = -8.0
	add_child(_edit_hint)


func get_drag_state() -> DragState:
	return _drag_state


func set_player_data(info: PlayerInfo, index: int) -> void:
	player_index = index
	if name_label:
		name_label.text = info.name
	if slime_rect:
		slime_rect.texture = load(SLIME_PATH % info.preset_id)


func refresh_seat_offset() -> void:
	_cache_seat_offset()


func _cache_seat_offset() -> void:
	if not slime_rect:
		_seat_offset = size * 0.5
	else:
		_seat_offset = slime_rect.position + slime_rect.size * 0.5
	_seat_offset_cached = true


func _compute_seat_offset() -> Vector2:
	if not _seat_offset_cached:
		_cache_seat_offset()
	return _seat_offset


func _position_for_seat(seat_center: Vector2) -> Vector2:
	return seat_center - _seat_offset


func _apply_home_position() -> void:
	if not is_inside_tree():
		return
	global_position = _position_for_seat(home_position)


func reset_home_position(seat_center: Vector2, force: bool = false) -> void:
	home_position = seat_center
	if force:
		_kill_motion_tween()
		stop_motion()
		_dragging = false
		_holding = false
		z_index = 0
		_reset_slime_visuals()
	if force or (not _dragging and _drag_state == DragState.NONE):
		call_deferred("_apply_home_position")


func animate_arc_to(seat_center: Vector2, duration: float = 0.38) -> Tween:
	home_position = seat_center
	_kill_motion_tween()
	stop_motion()
	_dragging = false
	_holding = false
	z_index = 5

	var start_pos := global_position
	var end_pos := _position_for_seat(seat_center)
	var arc_lift := start_pos.distance_to(end_pos) * 0.22 + 48.0
	var control_point := (start_pos + end_pos) * 0.5 + Vector2(0, -arc_lift)

	_motion_tween = create_tween()
	_motion_tween.tween_method(
		_apply_arc_position.bind(start_pos, control_point, end_pos),
		0.0,
		1.0,
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_motion_tween.finished.connect(_on_arc_finished)
	return _motion_tween


func update_lobby_visuals(delta: float, look_target_global: Vector2, can_start: bool) -> void:
	if _dragging or _drag_state != DragState.NONE:
		return
	if not slime_rect:
		return

	var to_target := look_target_global - home_position
	if to_target.length_squared() > 64.0:
		var look_angle := clampf(to_target.angle() + PI * 0.5, -0.35, 0.35)
		slime_rect.rotation = lerp(slime_rect.rotation, look_angle, clampf(delta * 4.0, 0.0, 1.0))
	else:
		slime_rect.rotation = lerp(slime_rect.rotation, 0.0, clampf(delta * 4.0, 0.0, 1.0))

	var breath_speed := 2.0 if can_start else 1.4
	var breath_amount := 0.025 if can_start else 0.035
	var breath := 1.0 + sin(Time.get_ticks_msec() * 0.001 * breath_speed + lobby_phase_offset) * breath_amount
	slime_rect.scale = _base_slime_scale * breath


func get_world_rect() -> Rect2:
	return Rect2(global_position, size)


func get_slime_center_global() -> Vector2:
	if _dragging or _drag_state != DragState.NONE:
		return global_position + _compute_seat_offset()
	return home_position


func has_moved_for_swap() -> bool:
	return get_slime_center_global().distance_to(home_position) >= swap_activation_distance


func is_slime_over_seat(other: PlayerIcon, seat_size: Vector2) -> bool:
	if other == self:
		return false
	var seat_rect := Rect2(other.home_position - seat_size * 0.5, seat_size)
	return seat_rect.has_point(get_slime_center_global())


func set_drag_state(state: DragState) -> void:
	if _drag_state == state:
		return
	_drag_state = state
	if state == DragState.NONE:
		swap_target = null


func cancel_swap_preview() -> void:
	if _drag_state == DragState.SWAPPING:
		swap_target = null
		set_drag_state(DragState.RETURNING)


func stop_motion() -> void:
	_drag_state = DragState.NONE
	swap_target = null


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_begin_drag(mouse.global_position)
		else:
			_end_drag()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_begin_drag(touch.position)
		else:
			_end_drag()
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		_apply_drag_motion(motion.global_position)
	elif event is InputEventScreenDrag and _dragging:
		var drag := event as InputEventScreenDrag
		_apply_drag_motion(drag.position)


func _process(delta: float) -> void:
	if _holding:
		_hold_timer += delta
		if _hold_timer >= hold_time:
			_holding = false
			_dragging = false
			hold_edit_requested.emit(player_index)
			set_drag_state(DragState.RETURNING)

	_update_hold_visuals()
	_update_drag_stretch()

	match _drag_state:
		DragState.SWAPPING:
			_lerp_towards(_swap_preview_target(), delta)
		DragState.RETURNING:
			var target := _position_for_seat(home_position)
			if _lerp_towards(target, delta):
				stop_motion()
				_reset_slime_visuals()


func _update_hold_visuals() -> void:
	if not _edit_hint:
		return
	if not _holding or not _dragging:
		_edit_hint.visible = false
		return
	if global_position.distance_to(_position_for_seat(home_position)) > 8.0:
		_edit_hint.visible = false
		return

	var progress := clampf(_hold_timer / hold_time, 0.0, 1.0)
	_edit_hint.visible = progress > 0.15
	_edit_hint.modulate.a = progress
	_edit_hint.scale = Vector2.ONE * (0.85 + progress * 0.35)

	if progress >= 0.75 and not _hold_vibrated:
		_hold_vibrated = true
		Input.vibrate_handheld(18)


func _update_drag_stretch() -> void:
	if not _dragging or not slime_rect:
		return
	var velocity := global_position - _last_drag_global
	_last_drag_global = global_position
	if velocity.length_squared() < 0.5:
		return
	var stretch_x := 1.0 + clampf(abs(velocity.x) * 0.004, 0.0, 0.12)
	var stretch_y := 1.0 + clampf(abs(velocity.y) * 0.004, 0.0, 0.12)
	slime_rect.scale = Vector2(stretch_x, stretch_y) * _base_slime_scale


func _swap_preview_target() -> Vector2:
	if swap_target:
		return _position_for_seat(swap_target.home_position)
	return _position_for_seat(home_position)


func _lerp_towards(target: Vector2, delta: float) -> bool:
	var t := clampf(delta * move_lerp_speed, 0.0, 1.0)
	global_position = global_position.lerp(target, t)
	return global_position.distance_to(target) <= 1.0


func _begin_drag(global_point: Vector2) -> void:
	_dragging = true
	_holding = true
	_hold_timer = 0.0
	_hold_vibrated = false
	_drag_offset = global_point - global_position
	_last_drag_global = global_position
	z_index = 10
	drag_started.emit()


func _end_drag() -> void:
	if not _dragging:
		return
	_dragging = false
	_holding = false
	z_index = 0
	if _edit_hint:
		_edit_hint.visible = false
	drag_ended.emit()


func _apply_drag_motion(global_point: Vector2) -> void:
	global_position = global_point - _drag_offset
	_check_hold_cancel()


func _check_hold_cancel() -> void:
	if global_position.distance_to(_position_for_seat(home_position)) > 8.0:
		_holding = false
		if _edit_hint:
			_edit_hint.visible = false


func _apply_arc_position(t: float, start_pos: Vector2, control_point: Vector2, end_pos: Vector2) -> void:
	var inv := 1.0 - t
	global_position = inv * inv * start_pos + 2.0 * inv * t * control_point + t * t * end_pos
	if slime_rect:
		slime_rect.rotation = lerp(slime_rect.rotation, 0.0, t)


func _on_arc_finished() -> void:
	z_index = 0
	_apply_home_position()
	_reset_slime_visuals()


func _kill_motion_tween() -> void:
	if _motion_tween:
		_motion_tween.kill()
		_motion_tween = null


func _reset_slime_visuals() -> void:
	if not slime_rect:
		return
	slime_rect.scale = _base_slime_scale
	slime_rect.rotation = 0.0
