class_name PlayerIcon
extends Control

const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"
const ICON_SIZE := Vector2(110, 200)
const SLIME_SIZE := Vector2(104, 104)
const SLIME_POSITION := Vector2(3, 32)
const TOUCH_GRAB_RADIUS := 78.0
const HOLD_HOME_TOLERANCE := 36.0
const GRAB_RADIUS_BOOST := 1.12
const SEAT_RADIUS_SCALE := 0.58
const NAME_GAP := 6.0
const NAME_PLATE_PAD_X := 14.0
const NAME_FONT_MAX := 30
const NAME_FONT_MIN := 10
const NAME_PLATE_MIN_WIDTH := 72.0
const NAME_PLATE_MAX_WIDTH := 240.0
const NAME_NEIGHBOR_MARGIN := 0.86

signal drag_started
signal drag_ended
signal hold_edit_requested(index: int)
signal selection_pressed

enum DragState {
	NONE,
	RETURNING,
	SWAPPING,
}

@export var slime_rect: TextureRect
@export var name_label: Label

var _display_player_count: int = 0
var _player_info: PlayerInfo
@export var hold_time: float = 1.4
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
var _hold_haptic_timer: float = 0.0
var _drag_state: DragState = DragState.NONE
var _seat_offset: Vector2 = Vector2.ZERO
var _seat_offset_cached: bool = false
var _base_slime_scale: Vector2 = Vector2.ONE
var _motion_tween: Tween
var _edit_hint: Label
var _hold_progress_ring: HoldProgressRing
var _hold_idle_hint: HoldEditIdleHint
var _last_drag_local: Vector2 = Vector2.ZERO
var _release_slime_center: Vector2 = Vector2.ZERO
var _table_center_global: Vector2 = Vector2.ZERO
var _active_touch_index: int = -1
var selection_only: bool = false
var _selection_press_local: Vector2 = Vector2.ZERO


func _ready() -> void:
	if slime_rect:
		_base_slime_scale = slime_rect.scale
		call_deferred("_setup_slime_pivot")
	_setup_edit_hint()
	_setup_hold_overlays()
	call_deferred("_cache_seat_offset")


func _setup_slime_pivot() -> void:
	apply_fixed_layout()
	if slime_rect:
		slime_rect.pivot_offset = slime_rect.size * 0.5


func _setup_edit_hint() -> void:
	_edit_hint = Label.new()
	_edit_hint.text = "✎"
	_edit_hint.visible = false
	_edit_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_edit_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_edit_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_edit_hint.add_theme_font_size_override("font_size", 56)
	_edit_hint.add_theme_color_override("font_color", Color(0.95, 0.55, 0.2, 1))
	_edit_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_edit_hint.offset_top = -16.0
	add_child(_edit_hint)


func _setup_hold_overlays() -> void:
	_hold_progress_ring = HoldProgressRing.new()
	_hold_progress_ring.z_index = 4
	_hold_progress_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hold_progress_ring)

	_hold_idle_hint = HoldEditIdleHint.new()
	_hold_idle_hint.z_index = 5
	_hold_idle_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hold_idle_hint)


func set_idle_hold_hint_visible(show_hint: bool) -> void:
	if _hold_idle_hint:
		_hold_idle_hint.set_hint_visible(show_hint)


func _layout_hold_overlays() -> void:
	if not slime_rect:
		return
	var seat_anchor := _compute_seat_offset()
	if _hold_progress_ring:
		var ring_size := Vector2(244, 244)
		_hold_progress_ring.position = seat_anchor - ring_size * 0.5
		_hold_progress_ring.size = ring_size
	if _hold_idle_hint:
		_hold_idle_hint.position = slime_rect.position + Vector2(
			slime_rect.size.x - _hold_idle_hint.size.x - 8.0,
			12.0
		)


func get_drag_state() -> DragState:
	return _drag_state


func set_player_data(info: PlayerInfo, index: int, player_count: int = -1) -> void:
	_player_info = info
	player_index = index
	if player_count > 0:
		_display_player_count = player_count
	if name_label:
		name_label.text = info.name
	if slime_rect:
		slime_rect.texture = load(SLIME_PATH % info.preset_id)
	layout_name_plate(_table_center_global)


func get_player_info() -> PlayerInfo:
	return _player_info


func set_selection_only(enabled: bool) -> void:
	selection_only = enabled
	if enabled:
		stop_motion()
		_dragging = false
		_holding = false
		_active_touch_index = -1
		_reset_hold_feedback()
		z_index = 0
		_apply_drag_lift(false)
		set_idle_hold_hint_visible(false)


func set_order_index(index: int, player_count: int = -1) -> void:
	player_index = index
	if player_count > 0:
		_display_player_count = player_count


func layout_name_plate(table_center_global: Vector2 = Vector2.ZERO) -> void:
	if not slime_rect or not name_label:
		return
	var name_plate := name_label.get_parent() as Control
	if not name_plate:
		return

	if table_center_global != Vector2.ZERO:
		_table_center_global = table_center_global

	name_label.clip_text = false
	name_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	name_label.autowrap_mode = TextServer.AUTOWRAP_OFF

	var max_plate_width := _compute_max_plate_width()
	var font_size := _fit_name_font_size(max_plate_width)
	name_label.add_theme_font_size_override("font_size", font_size)

	var text_width := _measure_name_width(font_size)
	var plate_width := clampf(text_width + NAME_PLATE_PAD_X * 2.0, NAME_PLATE_MIN_WIDTH, max_plate_width)

	name_plate.z_index = 2
	name_plate.custom_minimum_size = Vector2(plate_width, 0)
	name_plate.reset_size()
	var plate_size := name_plate.get_combined_minimum_size()
	if plate_size.y <= 0.0:
		plate_size.y = float(font_size) + 12.0
	name_plate.size = plate_size

	var seat_anchor := _compute_seat_offset()
	var slime_bottom := slime_rect.position.y + slime_rect.size.y
	name_plate.position = Vector2(
		seat_anchor.x - plate_size.x * 0.5,
		slime_bottom + NAME_GAP
	)


func _compute_max_plate_width() -> float:
	var player_count := maxi(_display_player_count, 1)
	if player_count <= 1:
		return NAME_PLATE_MAX_WIDTH

	var seat_dist := 144.0
	if _table_center_global != Vector2.ZERO and home_position != Vector2.ZERO:
		seat_dist = get_home_global().distance_to(_table_center_global)
	elif slime_rect:
		seat_dist = maxf(seat_dist, _compute_seat_offset().distance_to(size * 0.5) + 40.0)

	var angle_step := TAU / float(player_count)
	var name_radius := seat_dist + slime_rect.size.y * 0.5 + NAME_GAP + float(NAME_FONT_MAX) * 0.55
	var chord := 2.0 * name_radius * sin(angle_step * 0.5)
	return clampf(chord * NAME_NEIGHBOR_MARGIN, NAME_PLATE_MIN_WIDTH, NAME_PLATE_MAX_WIDTH)


func _fit_name_font_size(max_plate_width: float) -> int:
	var available_text_width := maxf(max_plate_width - NAME_PLATE_PAD_X * 2.0, 24.0)
	for size in range(NAME_FONT_MAX, NAME_FONT_MIN - 1, -1):
		if _measure_name_width(size) <= available_text_width:
			return size
	return NAME_FONT_MIN


func _measure_name_width(font_size: int) -> float:
	if not name_label:
		return 0.0
	var text := name_label.text if not name_label.text.is_empty() else "Игрок"
	var font := name_label.get_theme_font("font")
	if font == null:
		return float(text.length()) * float(font_size) * 0.55
	return font.get_string_size(
		text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size
	).x


func refresh_seat_offset() -> void:
	_cache_seat_offset()


func apply_fixed_layout() -> void:
	custom_minimum_size = ICON_SIZE
	size = ICON_SIZE
	if slime_rect:
		slime_rect.layout_mode = 0
		slime_rect.set_anchors_preset(Control.PRESET_TOP_LEFT)
		slime_rect.position = SLIME_POSITION
		slime_rect.size = SLIME_SIZE
	_cache_seat_offset()
	layout_name_plate(_table_center_global)
	_layout_hold_overlays()


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


func get_home_global() -> Vector2:
	if home_position == Vector2.ZERO:
		return global_position + _compute_seat_offset()
	var parent := get_parent() as CanvasItem
	if parent:
		return parent.get_global_transform_with_canvas() * home_position
	return home_position


func _position_for_seat(seat_center: Vector2) -> Vector2:
	return seat_center - _seat_offset


func _apply_home_position() -> void:
	if not is_inside_tree():
		return
	position = _position_for_seat(home_position)


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
		if force:
			_apply_home_position()
		else:
			call_deferred("_apply_home_position")


func animate_arc_to(seat_center: Vector2, duration: float = 0.38) -> Tween:
	var start_pos := get_global_transform_with_canvas() * Vector2.ZERO
	home_position = seat_center
	_kill_motion_tween()
	stop_motion()
	_dragging = false
	_holding = false
	z_index = 5

	var end_pos := _global_position_for_seat(seat_center)
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

	var to_target := look_target_global - get_home_global()
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
	var xf := get_global_transform_with_canvas()
	var origin := xf * Vector2.ZERO
	var far_corner := xf * size
	return Rect2(origin, far_corner - origin)


func get_slime_center_global() -> Vector2:
	if _dragging or _drag_state != DragState.NONE:
		return get_global_transform_with_canvas() * _compute_seat_offset()
	return get_home_global()


func get_grab_radius() -> float:
	var scale_factor := 1.0
	if slime_rect:
		scale_factor = slime_rect.scale.x
	return SLIME_SIZE.x * 0.5 * scale_factor * GRAB_RADIUS_BOOST


func get_grab_radius_global() -> float:
	return get_grab_radius() * get_global_transform_with_canvas().get_scale().x


static func seat_interaction_radius(seat_size: Vector2) -> float:
	return maxf(seat_size.x, seat_size.y) * SEAT_RADIUS_SCALE


func has_moved_for_swap() -> bool:
	return get_slime_center_global().distance_to(get_home_global()) >= swap_activation_distance


func has_moved_for_swap_at(center: Vector2) -> bool:
	return center.distance_to(get_home_global()) >= swap_activation_distance


func is_slime_over_seat(other: PlayerIcon, seat_size: Vector2) -> bool:
	return is_slime_over_seat_at(other, seat_size, get_slime_center_global())


func is_slime_over_seat_at(other: PlayerIcon, seat_size: Vector2, center: Vector2) -> bool:
	if other == self:
		return false
	var seat_center := other.get_home_global()
	var seat_radius := seat_interaction_radius(seat_size) * other.get_global_transform_with_canvas().get_scale().x
	var grab_radius := get_grab_radius_global()
	return center.distance_to(seat_center) <= grab_radius + seat_radius


func get_release_slime_center() -> Vector2:
	return _release_slime_center


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
	if selection_only:
		_handle_selection_input(event)
		return
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			accept_event()
			_begin_drag_at_parent_local(_parent_local_from_event(mouse))
		else:
			accept_event()
			_end_drag()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			accept_event()
			_active_touch_index = touch.index
			_begin_drag_at_parent_local(_parent_local_from_event(touch))
		elif _active_touch_index < 0 or touch.index == _active_touch_index:
			accept_event()
			_end_drag()


func _handle_selection_input(event: InputEvent) -> void:
	const TAP_MAX_DISTANCE := 28.0
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			accept_event()
			_selection_press_local = _parent_local_from_event(mouse)
		else:
			accept_event()
			if _parent_local_from_event(mouse).distance_to(_selection_press_local) <= TAP_MAX_DISTANCE:
				selection_pressed.emit()
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			accept_event()
			_active_touch_index = touch.index
			_selection_press_local = _parent_local_from_event(touch)
		elif _active_touch_index < 0 or touch.index == _active_touch_index:
			accept_event()
			_active_touch_index = -1
			if _parent_local_from_event(touch).distance_to(_selection_press_local) <= TAP_MAX_DISTANCE:
				selection_pressed.emit()


func _input(event: InputEvent) -> void:
	if not _dragging:
		return
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _active_touch_index >= 0 and drag.index != _active_touch_index:
			return
		_apply_drag_motion(_parent_local_from_canvas(drag.position))
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		_apply_drag_motion(_parent_local_from_event(event as InputEventMouseMotion))
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and not event.pressed:
		if (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			_end_drag()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and not event.pressed:
		var touch := event as InputEventScreenTouch
		if _active_touch_index < 0 or touch.index == _active_touch_index:
			_end_drag()
			get_viewport().set_input_as_handled()


func _parent_local_from_event(event: InputEvent) -> Vector2:
	var canvas_point: Vector2
	if event is InputEventMouse:
		canvas_point = (event as InputEventMouse).global_position
	else:
		canvas_point = get_global_transform_with_canvas() * event.position
	return _parent_local_from_canvas(canvas_point)


func _parent_local_from_canvas(canvas_point: Vector2) -> Vector2:
	var parent := get_parent() as CanvasItem
	if parent:
		return parent.get_global_transform_with_canvas().affine_inverse() * canvas_point
	return canvas_point


func _process(delta: float) -> void:
	if _holding and _dragging:
		_hold_timer += delta
		if _hold_timer >= hold_time:
			_holding = false
			var was_dragging := _dragging
			_dragging = false
			_active_touch_index = -1
			_reset_hold_feedback()
			hold_edit_requested.emit(player_index)
			set_drag_state(DragState.RETURNING)
			if was_dragging:
				z_index = 0
				_apply_drag_lift(false)
				drag_ended.emit()
			return
		_update_hold_visuals(delta)
		_update_drag_stretch()
		return

	if _dragging:
		_update_drag_stretch()
		return

	match _drag_state:
		DragState.SWAPPING:
			_lerp_towards(_swap_preview_target(), delta)
		DragState.RETURNING:
			var target := _position_for_seat(home_position)
			if _lerp_towards(target, delta):
				stop_motion()
				_reset_slime_visuals()


func _is_hold_active_at_home() -> bool:
	return (
		_holding
		and _dragging
		and get_slime_center_global().distance_to(get_home_global()) <= HOLD_HOME_TOLERANCE
	)


func _get_hold_progress() -> float:
	if not _is_hold_active_at_home():
		return 0.0
	return clampf(_hold_timer / hold_time, 0.0, 1.0)


func _reset_hold_feedback() -> void:
	_hold_timer = 0.0
	_hold_haptic_timer = 0.0
	if _hold_progress_ring:
		_hold_progress_ring.progress = 0.0
		_hold_progress_ring.visible_ring = false
	if _edit_hint:
		_edit_hint.visible = false
	if slime_rect:
		slime_rect.modulate = Color.WHITE


func _update_hold_visuals(delta: float = 0.0) -> void:
	if not _is_hold_active_at_home():
		if _hold_progress_ring and _hold_progress_ring.visible_ring:
			_reset_hold_feedback()
		return

	var progress := _get_hold_progress()
	if _hold_progress_ring:
		_hold_progress_ring.visible_ring = true
		_hold_progress_ring.progress = progress

	if _edit_hint:
		_edit_hint.visible = progress > 0.35
		_edit_hint.modulate.a = clampf((progress - 0.35) / 0.65, 0.0, 1.0)
		_edit_hint.scale = Vector2.ONE * (0.85 + progress * 0.35)

	if slime_rect:
		if progress >= 0.75:
			var glow := clampf((progress - 0.75) / 0.25, 0.0, 1.0)
			slime_rect.modulate = Color(1.0, 1.0, 1.0, 1.0).lerp(
				Color(1.14, 1.08, 0.82, 1.0),
				glow
			)
		else:
			slime_rect.modulate = Color.WHITE

	_update_hold_haptics(progress, delta)


func _update_hold_haptics(progress: float, delta: float) -> void:
	if progress <= 0.05:
		return
	_hold_haptic_timer -= delta
	if _hold_haptic_timer > 0.0:
		return
	Haptics.vibrate_hold_progress(progress)
	_hold_haptic_timer = lerpf(0.22, 0.08, progress)


func _update_drag_stretch() -> void:
	if not _dragging or not slime_rect:
		return
	if _is_hold_active_at_home():
		slime_rect.scale = _base_slime_scale * 1.08
		return
	var velocity := position - _last_drag_local
	_last_drag_local = position
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
	position = position.lerp(target, t)
	return position.distance_to(target) <= 1.0


func _begin_drag_at_parent_local(parent_local: Vector2) -> void:
	stop_motion()
	_kill_motion_tween()
	_dragging = true
	_holding = true
	_hold_timer = 0.0
	_hold_haptic_timer = 0.0
	_drag_offset = parent_local - position
	_last_drag_local = position
	z_index = 10
	_apply_drag_lift(true)
	Haptics.vibrate_drag_pickup()
	drag_started.emit()


func _end_drag() -> void:
	if not _dragging:
		return
	_release_slime_center = get_slime_center_global()
	_dragging = false
	_holding = false
	_active_touch_index = -1
	z_index = 0
	_apply_drag_lift(false)
	_reset_hold_feedback()
	drag_ended.emit()


func _apply_drag_lift(active: bool) -> void:
	if not slime_rect:
		return
	if active:
		slime_rect.scale = _base_slime_scale * 1.08
	elif _drag_state == DragState.NONE:
		slime_rect.scale = _base_slime_scale


func _apply_drag_motion(parent_local: Vector2) -> void:
	position = parent_local - _drag_offset
	_check_hold_cancel()


func _check_hold_cancel() -> void:
	if get_slime_center_global().distance_to(get_home_global()) > HOLD_HOME_TOLERANCE:
		if _holding:
			_holding = false
			_reset_hold_feedback()


func _apply_arc_position(t: float, start_pos: Vector2, control_point: Vector2, end_pos: Vector2) -> void:
	var inv := 1.0 - t
	var global_pos := inv * inv * start_pos + 2.0 * inv * t * control_point + t * t * end_pos
	var parent := get_parent() as CanvasItem
	if parent:
		position = parent.get_global_transform_with_canvas().affine_inverse() * global_pos
	else:
		position = global_pos
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
	slime_rect.modulate = Color.WHITE
	_reset_hold_feedback()


func _global_position_for_seat(seat_center: Vector2) -> Vector2:
	var parent := get_parent() as CanvasItem
	if parent:
		return parent.get_global_transform_with_canvas() * _position_for_seat(seat_center)
	return _position_for_seat(seat_center)


func _has_point(point: Vector2) -> bool:
	var grab_center := _compute_seat_offset()
	return point.distance_to(grab_center) <= TOUCH_GRAB_RADIUS


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		apply_fixed_layout()
		if home_position != Vector2.ZERO and not _dragging and _drag_state == DragState.NONE:
			_apply_home_position()
