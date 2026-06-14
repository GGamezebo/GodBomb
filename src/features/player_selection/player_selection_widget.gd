class_name PlayerSelectionWidget
extends Control

@export var account: PDataAccount
@export var pdata_controller: Node
@export var game_config: GameConfig
@export var menu_events: MenuEvents
@export var preset_storage: PlayerPresetStorage
@export var player_icon_scene: PackedScene
@export var start_button: BaseButton

@export var table_area: Control
@export var icons_layer: Control
@export var chairs_layer: Control
@export var add_player_button: TextureButton
@export var edit_player_window: EditPlayerWindow

@export var add_player_texture: Texture2D
@export var remove_player_texture: Texture2D
@export var min_players_for_remove: int = 1
@export var table_radius_coeff: float = 0.45
@export var chair_size: Vector2 = Vector2(80, 80)
@export var chair_facing_offset: float = -PI * 0.5

var _player_icons: Array[PlayerIcon] = []
var _chairs: Array[TextureRect] = []
var _is_remove_mode: bool = false
var _dragging_icon: PlayerIcon
var listener: EventListener = EventListener.new()


func _ready() -> void:
	if add_player_button:
		add_player_button.pressed.connect(_on_add_player_button_pressed)
	if edit_player_window:
		edit_player_window.player_added.connect(_on_player_added_from_window)
		edit_player_window.player_applied.connect(_on_player_applied_from_window)
	_load_from_account()


func _exit_tree() -> void:
	listener.deinit()


func reload_from_account() -> void:
	_clear_icons()
	_load_from_account()


func _load_from_account() -> void:
	if not account:
		return
	for entry in account.get_players():
		var info := account.player_info_from_dict(entry)
		_create_player_icon(info)
	if preset_storage:
		preset_storage.rebuild_locks(account.get_players())
	_schedule_position_update()
	_update_add_button()
	_update_start_button()


func _clear_icons() -> void:
	for icon in _player_icons:
		icon.queue_free()
	for chair in _chairs:
		chair.queue_free()
	_player_icons.clear()
	_chairs.clear()


func _create_player_icon(info: PlayerInfo) -> PlayerIcon:
	var icon: PlayerIcon = player_icon_scene.instantiate()
	icon.set_player_data(info, _player_icons.size())
	icon.drag_started.connect(_on_icon_drag_started.bind(icon))
	icon.drag_ended.connect(_on_icon_drag_ended.bind(icon))
	icon.hold_edit_requested.connect(_on_icon_hold_edit)
	icons_layer.add_child(icon)
	_player_icons.append(icon)

	var chair := TextureRect.new()
	chair.texture = load("res://assets/sprites/Chair.png")
	chair.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chair.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chair.custom_minimum_size = chair_size
	chair.size = chair_size
	chair.pivot_offset = chair_size * 0.5
	chair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chairs_layer.add_child(chair)
	_chairs.append(chair)

	return icon


func _schedule_position_update() -> void:
	if is_inside_tree():
		call_deferred("_update_positions")


func _seat_local_for_index(index: int, player_count: int) -> Vector2:
	var center := table_area.size * 0.5
	var radius := minf(table_area.size.x, table_area.size.y) * table_radius_coeff
	var angle := -index * TAU / player_count
	return center + Vector2(cos(angle), sin(angle)) * radius


func _chair_rotation_for_seat(seat_local: Vector2) -> float:
	var to_center := table_area.size * 0.5 - seat_local
	if to_center.length_squared() < 0.001:
		return 0.0
	return to_center.angle() + chair_facing_offset


func _apply_chair_transform(chair: TextureRect, seat_local: Vector2) -> void:
	chair.custom_minimum_size = chair_size
	chair.size = chair_size
	chair.pivot_offset = chair_size * 0.5
	chair.rotation = _chair_rotation_for_seat(seat_local)
	chair.position = seat_local - chair_size * 0.5


func _update_positions() -> void:
	if _player_icons.is_empty() or not table_area:
		return
	if _chairs.size() != _player_icons.size():
		return

	var player_count := _player_icons.size()

	for i in player_count:
		var seat_local := _seat_local_for_index(i, player_count)
		var seat_global := table_area.global_position + seat_local
		_apply_chair_transform(_chairs[i], seat_local)
		_player_icons[i].reset_home_position(seat_global, true)


func _update_add_button() -> void:
	if not add_player_button or not game_config:
		return
	var count := account.get_players().size() if account else 0
	if _is_remove_mode:
		add_player_button.disabled = count <= min_players_for_remove
	else:
		add_player_button.disabled = count >= game_config.max_players


func _update_start_button() -> void:
	if not start_button:
		return
	var min_players := game_config.min_players if game_config else 2
	var count := _player_icons.size()
	start_button.disabled = count < min_players


func _set_remove_mode(enabled: bool) -> void:
	_is_remove_mode = enabled
	if add_player_button:
		add_player_button.texture_normal = remove_player_texture if enabled else add_player_texture
	if enabled:
		menu_events.ev_player_move_begin.emit()
	else:
		menu_events.ev_player_move_end.emit()
	_update_add_button()


func _on_add_player_button_pressed() -> void:
	if _is_remove_mode:
		return
	if edit_player_window:
		edit_player_window.open_add_window()


func _on_icon_drag_started(icon: PlayerIcon) -> void:
	_dragging_icon = icon
	_set_remove_mode(true)
	for other in _player_icons:
		if other != icon:
			other.swap_target = null
			if other.get_drag_state() != PlayerIcon.DragState.NONE:
				other.set_drag_state(PlayerIcon.DragState.RETURNING)


func _process(_delta: float) -> void:
	if _dragging_icon:
		_update_swap_preview(_dragging_icon)


func _update_swap_preview(dragging: PlayerIcon) -> void:
	var overlap_target: PlayerIcon = null
	for other in _player_icons:
		if other != dragging and dragging.overlaps_icon(other):
			overlap_target = other
			break

	for other in _player_icons:
		if other == dragging:
			continue
		if other == overlap_target:
			other.swap_target = dragging
			other.set_drag_state(PlayerIcon.DragState.SWAPPING)
		elif other.swap_target == dragging:
			other.cancel_swap_preview()


func _on_icon_drag_ended(icon: PlayerIcon) -> void:
	_set_remove_mode(false)

	if add_player_button and _rect_overlaps(icon, add_player_button) and icon == _dragging_icon:
		_remove_player(icon)
		_dragging_icon = null
		return

	for other in _player_icons:
		if other != icon and icon.overlaps_icon(other):
			for reset_icon in _player_icons:
				if reset_icon != icon:
					reset_icon.stop_motion()
			_swap_players(icon, other)
			icon.stop_motion()
			_dragging_icon = null
			return

	for other in _player_icons:
		if other.swap_target == icon:
			other.cancel_swap_preview()

	icon.set_drag_state(PlayerIcon.DragState.RETURNING)
	_dragging_icon = null


func _on_icon_hold_edit(index: int) -> void:
	_set_remove_mode(false)
	for icon in _player_icons:
		icon.set_drag_state(PlayerIcon.DragState.RETURNING)
	if not edit_player_window or not account:
		return
	if preset_storage:
		preset_storage.rebuild_locks(account.get_players())
	var players := account.get_players()
	if index < 0 or index >= players.size():
		return
	var info := account.player_info_from_dict(players[index])
	edit_player_window.open_edit_window(index, info.name, info.preset_id)


func _on_player_added_from_window(player_name: String, preset_id: int) -> void:
	var info := PlayerInfo.new(player_name, preset_id)
	var players := account.get_players()
	players.append(account.dict_from_player_info(info))
	account.set_players(players)
	_create_player_icon(info)
	_schedule_position_update()
	if preset_storage:
		preset_storage.rebuild_locks(players)
	menu_events.ev_player_added.emit(info)
	_save_account()
	_update_add_button()
	_update_start_button()


func _on_player_applied_from_window(index: int, player_name: String, preset_id: int) -> void:
	var players := account.get_players()
	if index < 0 or index >= players.size():
		return
	var info := PlayerInfo.new(player_name, preset_id)
	players[index] = account.dict_from_player_info(info)
	account.set_players(players)
	_player_icons[index].set_player_data(info, index)
	if preset_storage:
		preset_storage.rebuild_locks(players)
	menu_events.ev_player_modified.emit(info, index)
	_save_account()


func _remove_player(icon: PlayerIcon) -> void:
	var index := _player_icons.find(icon)
	if index < 0:
		return
	var players := account.get_players()
	var info := account.player_info_from_dict(players[index])
	players.remove_at(index)
	account.set_players(players)

	icon.queue_free()
	_chairs[index].queue_free()
	_player_icons.remove_at(index)
	_chairs.remove_at(index)

	for i in _player_icons.size():
		var player_info := account.player_info_from_dict(players[i])
		_player_icons[i].set_player_data(player_info, i)

	_schedule_position_update()
	if preset_storage:
		preset_storage.rebuild_locks(players)
	menu_events.ev_player_removed.emit(info, index)
	_save_account()
	_update_add_button()
	_update_start_button()


func _swap_players(icon_a: PlayerIcon, icon_b: PlayerIcon) -> void:
	var index_a := _player_icons.find(icon_a)
	var index_b := _player_icons.find(icon_b)
	if index_a < 0 or index_b < 0:
		return

	var temp_icon := _player_icons[index_a]
	_player_icons[index_a] = _player_icons[index_b]
	_player_icons[index_b] = temp_icon
	var players := account.get_players()
	var temp_entry = players[index_a]
	players[index_a] = players[index_b]
	players[index_b] = temp_entry
	account.set_players(players)

	if preset_storage:
		preset_storage.rebuild_locks(players)
	menu_events.ev_player_swapped.emit(index_a, index_b)
	_save_account()
	_schedule_position_update()
	_update_start_button()


func _rect_overlaps(icon: PlayerIcon, button: Control) -> bool:
	return icon.get_world_rect().intersects(Rect2(button.global_position, button.size))


func _save_account() -> void:
	var controller := _resolve_pdata_controller()
	if controller and controller.has_method("save_account"):
		controller.save_account()


func _resolve_pdata_controller() -> Node:
	if pdata_controller:
		return pdata_controller
	return get_tree().get_first_node_in_group("account_persistence")


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_schedule_position_update()
