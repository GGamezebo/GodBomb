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

var home_position: Vector2 = Vector2.ZERO
var player_index: int = -1
var swap_target: PlayerIcon

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _hold_timer: float = 0.0
var _holding: bool = false
var _drag_state: DragState = DragState.NONE
var _move_tween: Tween


func set_player_data(info: PlayerInfo, index: int) -> void:
	player_index = index
	if name_label:
		name_label.text = info.name
	if slime_rect:
		slime_rect.texture = load("res://assets/slimes/%d.png" % info.preset_id)


func reset_home_position(center: Vector2) -> void:
	home_position = center
	if not _dragging and _drag_state == DragState.NONE:
		global_position = center - size * 0.5


func get_world_rect() -> Rect2:
	return Rect2(global_position, size)


func overlaps_icon(other: PlayerIcon) -> bool:
	return get_world_rect().intersects(other.get_home_rect())


func get_home_rect() -> Rect2:
	return Rect2(home_position - size * 0.5, size)


func set_drag_state(state: DragState) -> void:
	_drag_state = state
	if state == DragState.RETURNING or state == DragState.SWAPPING:
		_animate_to_target()


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
	if global_position.distance_to(home_position - size * 0.5) > 8.0:
		_holding = false


func _animate_to_target() -> void:
	if _move_tween:
		_move_tween.kill()
	_move_tween = create_tween()
	var target := home_position - size * 0.5
	if _drag_state == DragState.SWAPPING and swap_target:
		target = swap_target.home_position - size * 0.5
	_move_tween.tween_property(self, "global_position", target, 0.2).set_trans(Tween.TRANS_QUAD)
	_move_tween.finished.connect(func() -> void:
		if _drag_state == DragState.SWAPPING:
			global_position = home_position - size * 0.5
		_drag_state = DragState.NONE
		swap_target = null
	)
