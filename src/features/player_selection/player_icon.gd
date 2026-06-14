class_name PlayerIcon
extends Control

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

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _hold_timer: float = 0.0
var _holding: bool = false
var _drag_state: DragState = DragState.NONE
var _seat_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	call_deferred("refresh_seat_offset")


func get_drag_state() -> DragState:
	return _drag_state


func set_player_data(info: PlayerInfo, index: int) -> void:
	player_index = index
	if name_label:
		name_label.text = info.name
	if slime_rect:
		slime_rect.texture = load("res://assets/slimes/%d.png" % info.preset_id)


func refresh_seat_offset() -> void:
	_seat_offset = _compute_seat_offset()


func _compute_seat_offset() -> Vector2:
	if slime_rect:
		return slime_rect.global_position + slime_rect.size * 0.5 - global_position
	return size * 0.5


func _position_for_seat(seat_center: Vector2) -> Vector2:
	return seat_center - _seat_offset


func _apply_home_position() -> void:
	if not is_inside_tree():
		return
	refresh_seat_offset()
	global_position = _position_for_seat(home_position)


func reset_home_position(seat_center: Vector2, force: bool = false) -> void:
	home_position = seat_center
	if force:
		stop_motion()
		_dragging = false
		_holding = false
		z_index = 0
	if force or (not _dragging and _drag_state == DragState.NONE):
		call_deferred("_apply_home_position")


func get_world_rect() -> Rect2:
	return Rect2(global_position, size)


func get_slime_center_global() -> Vector2:
	if slime_rect and is_inside_tree():
		return slime_rect.global_position + slime_rect.size * 0.5
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
		global_position = motion.global_position - _drag_offset
		_check_hold_cancel()
	elif event is InputEventScreenDrag and _dragging:
		var drag := event as InputEventScreenDrag
		global_position = drag.position - _drag_offset
		_check_hold_cancel()


func _process(delta: float) -> void:
	if _holding:
		_hold_timer += delta
		if _hold_timer >= hold_time:
			_holding = false
			_dragging = false
			hold_edit_requested.emit(player_index)
			set_drag_state(DragState.RETURNING)

	match _drag_state:
		DragState.SWAPPING:
			_lerp_towards(_swap_preview_target(), delta)
		DragState.RETURNING:
			var target := _position_for_seat(home_position)
			if _lerp_towards(target, delta):
				stop_motion()


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
	_drag_offset = global_point - global_position
	z_index = 10
	drag_started.emit()


func _end_drag() -> void:
	if not _dragging:
		return
	_dragging = false
	_holding = false
	z_index = 0
	drag_ended.emit()


func _check_hold_cancel() -> void:
	if global_position.distance_to(_position_for_seat(home_position)) > 8.0:
		_holding = false
