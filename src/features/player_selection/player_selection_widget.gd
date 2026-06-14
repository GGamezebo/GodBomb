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
@export var min_players_for_remove: int = 0
@export var table_radius_coeff: float = 0.45
@export var chair_size: Vector2 = Vector2(100, 100)
@export var chair_facing_offset: float = -PI * 0.5

const SWAP_HINT_MIN_PLAYERS := 3
const HINT_SWAP_IDLE := "Перетащи на другое место — поменяетесь"
const HINT_SWAP_DRAG := "Отпусти — поменяетесь местами"
const HINT_REMOVE := "Отпусти — игрок будет удалён"
const HINT_MIN_PLAYERS := "Для игры нужно минимум 2 игрока"
const HINT_HOLD_EDIT := "Удержи 2 сек — изменить имя и цвет"
const HINT_BATTLE_EDIT := "Здесь можно редактировать состав игры, не заканчивая партию."
const HOLD_EDIT_HINT_DURATION := 5.0
const SWAP_IDLE_HINT_DURATION := 5.0
const BADGE_GAP_AFTER_ARROWS := 16.0
const BADGE_MIN_FROM_SEAT := 72.0
const DRAG_ORDER_ALPHA := 0.75
const REMOVE_BUTTON_ACTIVE_MODULATE := Color(1.18, 1.14, 0.92, 1.0)

var _player_icons: Array[PlayerIcon] = []
var _chairs: Array[TextureRect] = []
var _chair_rings: Array[ChairSwapRing] = []
var _is_remove_mode: bool = false
var _dragging_icon: PlayerIcon
var _highlighted_chair_index: int = -1
var _start_pulse_tween: Tween
var _add_pulse_tween: Tween
var _is_start_preview_playing: bool = false
var _turn_order_arrows: TurnOrderArrowsLayer
var _order_badges_layer: Control
var _order_badges: Array[SeatOrderBadge] = []
var _remove_button_ring: ChairSwapRing
var _table_hint_banner: TableHintBanner
var _swap_drag_hint_active: bool = false
var _remove_hint_active: bool = false
var _swap_idle_intro_played: bool = false
var _swap_idle_hint_showing: bool = false
var _hold_edit_hint_showing: bool = false
var _battle_mode: bool = false
var listener: EventListener = EventListener.new()


func _ready() -> void:
	_setup_turn_order_arrows()
	_setup_order_badges()
	_setup_remove_button_ring()
	_setup_swap_hints()
	if add_player_button:
		add_player_button.pressed.connect(_on_add_player_button_pressed)
	if edit_player_window:
		edit_player_window.player_added.connect(_on_player_added_from_window)
		edit_player_window.player_applied.connect(_on_player_applied_from_window)
	_sync_edit_window_refs()
	reload_from_account()
	_apply_add_button_texture()
	_connect_bomb_layout()


func set_battle_mode(enabled: bool) -> void:
	_battle_mode = enabled
	min_players_for_remove = 2 if enabled else 0
	if enabled and _is_remove_mode:
		_set_remove_mode(false)
	_update_add_button()
	_update_start_button()
	_refresh_table_hint()


func _connect_bomb_layout() -> void:
	var layout := _find_layout_host()
	if not layout:
		return
	if not layout.layout_applied.is_connected(_on_bomb_layout_applied):
		layout.layout_applied.connect(_on_bomb_layout_applied)
	_on_bomb_layout_applied()


func _on_bomb_layout_applied() -> void:
	_schedule_position_update()
	_update_hint_banner_layout()
	_apply_remove_ring_radius()
	_layout_remove_button_ring()


func _find_layout_host() -> Node:
	var node: Node = self
	while node:
		if node.has_signal("layout_applied") and node.has_method("get_hint_marker_design_position"):
			return node
		node = node.get_parent()
	return null


func _get_hint_anchor_design_position() -> Vector2:
	var layout := _find_layout_host()
	if layout:
		return layout.get_hint_marker_design_position()
	if table_area:
		return Vector2(table_area.position.x + table_area.size.x * 0.5, table_area.position.y - 48.0)
	return Vector2(size.x * 0.5, 160.0)


func _apply_add_button_texture() -> void:
	if not add_player_button:
		return
	if _is_remove_mode and remove_player_texture:
		add_player_button.texture_normal = remove_player_texture
	elif add_player_texture:
		add_player_button.texture_normal = add_player_texture


func _sync_edit_window_refs() -> void:
	if not edit_player_window:
		return
	edit_player_window.account = account
	edit_player_window.preset_storage = preset_storage


func bind_account(p_account: PDataAccount, p_controller: Node = null) -> void:
	if p_account:
		account = p_account
	if p_controller:
		pdata_controller = p_controller
	_sync_edit_window_refs()


func get_roster_size() -> int:
	return _player_icons.size()


func commit_roster_to_account() -> void:
	if not account:
		return
	var players: Array = []
	for icon in _player_icons:
		var info := icon.get_player_info()
		if info == null:
			continue
		players.append(account.dict_from_player_info(info))
	account.set_players(players)
	if preset_storage:
		preset_storage.rebuild_locks(players)


func export_roster_entries() -> Array:
	commit_roster_to_account()
	if not account:
		return []
	return account.get_players()


func persist_account() -> void:
	commit_roster_to_account()
	_save_account()


func _exit_tree() -> void:
	_kill_start_pulse_tween()
	_kill_add_pulse_tween()
	listener.deinit()


func _setup_remove_button_ring() -> void:
	if not table_area or not add_player_button:
		return
	_remove_button_ring = ChairSwapRing.new()
	_remove_button_ring.ring_color = ChairSwapRing.DEFAULT_RING_COLOR
	_remove_button_ring.z_index = 4
	_remove_button_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	table_area.add_child(_remove_button_ring)
	_apply_remove_ring_radius()
	_layout_remove_button_ring()


func _apply_remove_ring_radius() -> void:
	if not _remove_button_ring or not add_player_button:
		return
	var button_half := minf(add_player_button.size.x, add_player_button.size.y) * 0.5
	var chair_half := chair_size.x * 0.5
	_remove_button_ring.set_ring_radius(ChairSwapRing.radius_for_half_extent(button_half, chair_half))


func _layout_remove_button_ring() -> void:
	if not _remove_button_ring or not add_player_button or not table_area:
		return
	var button_center := add_player_button.global_position + add_player_button.size * 0.5
	var local_center := table_area.get_global_transform_with_canvas().affine_inverse() * button_center
	var ring_radius := _remove_button_ring.ring_radius
	_remove_button_ring.position = local_center - Vector2(ring_radius, ring_radius)


func _remove_ring_radius() -> float:
	if _remove_button_ring:
		return _remove_button_ring.ring_radius
	return ChairSwapRing.DEFAULT_RING_RADIUS


func _get_remove_button_center_global() -> Vector2:
	if not add_player_button:
		return Vector2.ZERO
	return add_player_button.global_position + add_player_button.size * 0.5


func _is_slime_center_in_remove_ring(slime_center: Vector2) -> bool:
	if not add_player_button or not add_player_button.visible:
		return false
	if add_player_button.disabled:
		return false
	var ring_center := _get_remove_button_center_global()
	return slime_center.distance_to(ring_center) <= _remove_ring_radius()


func _is_icon_in_remove_ring(icon: PlayerIcon) -> bool:
	if not _is_remove_mode:
		return false
	return _is_slime_center_in_remove_ring(icon.get_slime_center_global())


func _update_remove_button_highlight(in_zone: bool) -> void:
	if not add_player_button or not _is_remove_mode:
		return
	add_player_button.modulate = REMOVE_BUTTON_ACTIVE_MODULATE if in_zone else Color.WHITE


func _update_remove_button_ring(dragging: PlayerIcon) -> void:
	if not _remove_button_ring:
		return
	_apply_remove_ring_radius()
	_layout_remove_button_ring()
	var in_zone := dragging != null and _is_icon_in_remove_ring(dragging)
	_remove_button_ring.visible_ring = in_zone
	_update_remove_button_highlight(in_zone)


func _setup_turn_order_arrows() -> void:
	if not table_area:
		return
	_turn_order_arrows = TurnOrderArrowsLayer.new()
	_turn_order_arrows.z_index = 3
	table_area.add_child(_turn_order_arrows)


func _setup_order_badges() -> void:
	if not table_area:
		return
	_order_badges_layer = Control.new()
	_order_badges_layer.name = "OrderBadgesLayer"
	_order_badges_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_order_badges_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_order_badges_layer.z_index = 2
	table_area.add_child(_order_badges_layer)


func _setup_swap_hints() -> void:
	_table_hint_banner = TableHintBanner.new()
	_table_hint_banner.z_index = 12
	add_child(_table_hint_banner)
	_update_hint_banner_layout()


func reload_from_account() -> void:
	_sync_edit_window_refs()
	_clear_icons()
	_swap_idle_intro_played = false
	_swap_idle_hint_showing = false
	_hold_edit_hint_showing = false
	_remove_hint_active = false
	_swap_drag_hint_active = false
	_load_from_account()
	if _battle_mode:
		call_deferred("_show_battle_edit_hint")
	else:
		call_deferred("_play_swap_hint_intro_if_needed")
		call_deferred("_play_hold_edit_hint_if_needed")


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
	for badge in _order_badges:
		badge.queue_free()
	_player_icons.clear()
	_chairs.clear()
	_chair_rings.clear()
	_order_badges.clear()


func _create_player_icon(info: PlayerInfo) -> PlayerIcon:
	var icon: PlayerIcon = player_icon_scene.instantiate()
	icon.lobby_phase_offset = randf() * TAU
	icon.set_player_data(info, _player_icons.size(), _player_icons.size() + 1)
	icon.drag_started.connect(_on_icon_drag_started.bind(icon))
	icon.drag_ended.connect(_on_icon_drag_ended.bind(icon))
	icon.hold_edit_requested.connect(_on_icon_hold_edit)
	icons_layer.add_child(icon)
	_player_icons.append(icon)

	var chair := TextureRect.new()
	chair.texture = load("res://assets/party_kitchen/chair.svg")
	chair.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chair.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chair.custom_minimum_size = chair_size
	chair.size = chair_size
	chair.pivot_offset = chair_size * 0.5
	chair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chairs_layer.add_child(chair)
	_chairs.append(chair)

	var ring := ChairSwapRing.new()
	ring.position = chair_size * 0.5 - Vector2(ring.ring_radius, ring.ring_radius)
	chair.add_child(ring)
	_chair_rings.append(ring)

	return icon


func _schedule_position_update() -> void:
	if is_inside_tree():
		call_deferred("_update_positions")


func _seat_local_for_index(index: int, player_count: int) -> Vector2:
	var center := table_area.size * 0.5
	var radius := minf(table_area.size.x, table_area.size.y) * table_radius_coeff
	var angle := index * TAU / player_count
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
	if not table_area:
		return
	const TABLE_SIZE := Vector2(640, 640)
	table_area.custom_minimum_size = TABLE_SIZE
	table_area.size = TABLE_SIZE
	if _player_icons.is_empty():
		_sync_order_badges(0)
		_update_hint_banner_layout()
		_refresh_turn_order()
		_refresh_table_hint()
		_sync_hold_idle_hints()
		return
	if _chairs.size() != _player_icons.size():
		return

	var player_count := _player_icons.size()

	for i in player_count:
		var seat_local := _seat_local_for_index(i, player_count)
		var seat_global := table_area.global_position + seat_local
		_apply_chair_transform(_chairs[i], seat_local)
		_player_icons[i].set_order_index(i, player_count)
		_player_icons[i].apply_fixed_layout()
		_player_icons[i].reset_home_position(seat_global, true)

	call_deferred("_layout_table_order_badges")

	_update_hint_banner_layout()
	_refresh_turn_order()
	_refresh_table_hint()
	_sync_hold_idle_hints()


func _center_button_radius() -> float:
	var button_radius := 72.0
	if add_player_button:
		button_radius = maxf(add_player_button.size.x, add_player_button.size.y) * 0.5
	return button_radius


func _set_order_markers_drag_dimmed(dimmed: bool) -> void:
	var alpha := DRAG_ORDER_ALPHA if dimmed else 1.0
	if _turn_order_arrows:
		_turn_order_arrows.set_drag_alpha(alpha)
	if _order_badges_layer:
		_order_badges_layer.modulate = Color(1, 1, 1, alpha)


func _seat_badge_local_for_index(index: int, player_count: int) -> Vector2:
	var center := table_area.size * 0.5
	var seat_local := _seat_local_for_index(index, player_count)
	var outward := (seat_local - center).normalized()
	var seat_dist := center.distance_to(seat_local)
	var min_radius := TurnOrderArrowsLayer.min_clearance_radius(_center_button_radius()) + BADGE_GAP_AFTER_ARROWS
	var max_radius := seat_dist - BADGE_MIN_FROM_SEAT
	var badge_radius := min_radius + 10.0
	if max_radius > min_radius:
		badge_radius = clampf(badge_radius, min_radius, max_radius)
	else:
		badge_radius = (min_radius + max_radius) * 0.5
	return center + outward * badge_radius


func _sync_order_badges(player_count: int) -> void:
	while _order_badges.size() < player_count:
		var badge := SeatOrderBadge.new()
		_order_badges_layer.add_child(badge)
		_order_badges.append(badge)
	while _order_badges.size() > player_count:
		var badge: SeatOrderBadge = _order_badges.pop_back()
		badge.queue_free()


func _layout_table_order_badges() -> void:
	if not table_area or not _order_badges_layer:
		return
	var player_count := _player_icons.size()
	_sync_order_badges(player_count)
	var table_center_global := table_area.global_position + table_area.size * 0.5
	for i in player_count:
		var badge := _order_badges[i]
		var badge_local := _seat_badge_local_for_index(i, player_count)
		badge.set_number(i + 1)
		badge.position = badge_local - badge.size * 0.5
	for icon in _player_icons:
		icon.layout_name_plate(table_center_global)


func _update_hint_banner_layout() -> void:
	if not _table_hint_banner:
		return
	var anchor := _get_hint_anchor_design_position()
	var banner_width := maxf(TableHintBanner.MIN_WIDTH, minf(table_area.size.x - 96.0, 920.0) if table_area else 920.0)
	_table_hint_banner.custom_minimum_size = Vector2(banner_width, 0)
	_table_hint_banner.reset_size()
	var banner_size := _table_hint_banner.get_combined_minimum_size()
	_table_hint_banner.size = banner_size
	_table_hint_banner.position = anchor - banner_size * 0.5


func _refresh_turn_order() -> void:
	if not _turn_order_arrows or not table_area:
		return
	var min_players := game_config.min_players if game_config else 2
	var count := _player_icons.size()
	var can_start := count >= min_players
	var button_radius := _center_button_radius()
	_turn_order_arrows.update_state(table_area.size, can_start, count >= 2, button_radius)


func _should_show_swap_hints() -> bool:
	return account != null and account.should_show_swap_hints()


func _min_players_required() -> int:
	return game_config.min_players if game_config else 2


func _needs_min_players_hint() -> bool:
	if _battle_mode:
		return false
	return _player_icons.size() < _min_players_required() and _dragging_icon == null


func _refresh_table_hint() -> void:
	if not _table_hint_banner:
		return
	if _remove_hint_active:
		_table_hint_banner.show_message(HINT_REMOVE, false, true)
		return
	if _swap_drag_hint_active:
		_table_hint_banner.show_message(HINT_SWAP_DRAG, false, true)
		return
	if _swap_idle_hint_showing:
		return
	if _hold_edit_hint_showing:
		return
	if _battle_mode:
		_update_hint_banner_layout()
		_table_hint_banner.show_message(HINT_BATTLE_EDIT, true, false)
		return
	if _needs_min_players_hint():
		_update_hint_banner_layout()
		_table_hint_banner.show_message(HINT_MIN_PLAYERS, true, false)
		return
	_table_hint_banner.hide_message()


func _show_battle_edit_hint() -> void:
	if not _battle_mode or not _table_hint_banner:
		return
	_update_hint_banner_layout()
	_table_hint_banner.show_message(HINT_BATTLE_EDIT, true, false)


func _play_swap_hint_intro_if_needed() -> void:
	if _battle_mode:
		return
	if _swap_idle_intro_played:
		return
	if not _should_show_swap_hints() or _player_icons.size() < SWAP_HINT_MIN_PLAYERS:
		return
	_swap_idle_intro_played = true
	_swap_idle_hint_showing = true
	_update_hint_banner_layout()
	_table_hint_banner.show_message(HINT_SWAP_IDLE, true, false)
	get_tree().create_timer(SWAP_IDLE_HINT_DURATION).timeout.connect(_on_swap_idle_hint_timeout, CONNECT_ONE_SHOT)


func _on_swap_idle_hint_timeout() -> void:
	if _dragging_icon or _swap_drag_hint_active or _remove_hint_active:
		return
	_dismiss_swap_idle_hint()


func _dismiss_swap_idle_hint(animate: bool = true) -> void:
	if not _swap_idle_hint_showing:
		return
	_swap_idle_hint_showing = false
	if _table_hint_banner:
		_table_hint_banner.hide_message(animate)


func _play_hold_edit_hint_if_needed() -> void:
	if _battle_mode:
		_sync_hold_idle_hints()
		return
	if not account or not account.should_show_hold_edit_hint() or _player_icons.is_empty():
		_sync_hold_idle_hints()
		return
	account.increment_hold_edit_hint_views()
	_save_account()
	if not _swap_idle_hint_showing:
		_hold_edit_hint_showing = true
		_update_hint_banner_layout()
		_table_hint_banner.show_message(HINT_HOLD_EDIT, true, false)
		get_tree().create_timer(HOLD_EDIT_HINT_DURATION).timeout.connect(_on_hold_edit_hint_timeout, CONNECT_ONE_SHOT)
	_sync_hold_idle_hints()


func _on_hold_edit_hint_timeout() -> void:
	if _dragging_icon or _remove_hint_active or _swap_drag_hint_active:
		return
	_dismiss_hold_edit_hint()


func _dismiss_hold_edit_hint(animate: bool = true) -> void:
	if not _hold_edit_hint_showing:
		_sync_hold_idle_hints()
		return
	_hold_edit_hint_showing = false
	if _table_hint_banner:
		_table_hint_banner.hide_message(animate)
	_sync_hold_idle_hints()


func _sync_hold_idle_hints() -> void:
	var show_corner := (
		not _battle_mode
		and account != null
		and account.should_show_hold_edit_hint()
		and _dragging_icon == null
	)
	for i in _player_icons.size():
		_player_icons[i].set_idle_hold_hint_visible(show_corner and i == 0)


func _mark_hold_edit_learned() -> void:
	if not account or account.has_edited_player():
		return
	account.mark_has_edited_player()
	_save_account()
	_dismiss_hold_edit_hint(false)
	for icon in _player_icons:
		icon.set_idle_hold_hint_visible(false)


func _update_add_button() -> void:
	if not add_player_button or not game_config:
		return
	var count := _player_icons.size()
	var at_max := count >= game_config.max_players
	add_player_button.visible = _is_remove_mode or not at_max
	if _is_remove_mode:
		add_player_button.disabled = count <= min_players_for_remove
		_kill_add_pulse_tween()
		if add_player_button:
			add_player_button.scale = Vector2.ONE
			add_player_button.modulate = Color.WHITE
	else:
		add_player_button.disabled = count >= game_config.max_players
		_update_add_button_animation(_player_icons.size() < _min_players_required())
	_apply_add_button_texture()
	_refresh_table_hint()


func _update_start_button() -> void:
	if _battle_mode:
		_refresh_turn_order()
		if start_button:
			var count := _player_icons.size()
			start_button.visible = true
			start_button.disabled = count < _min_players_required()
			_kill_start_pulse_tween()
			start_button.scale = Vector2.ONE
			start_button.modulate = Color.WHITE if not start_button.disabled else Color(0.88, 0.88, 0.88, 1)
			var label := start_button.get_node_or_null("StartLabel") as Label
			if not label:
				label = start_button.get_node_or_null("DoneLabel") as Label
			if label:
				label.text = "ГОТОВО"
				label.add_theme_color_override(
					"font_color",
					Color(1, 1, 1, 1) if not start_button.disabled else Color(0.94, 0.92, 0.9, 1)
				)
		return
	if not start_button:
		return
	var min_players := game_config.min_players if game_config else 2
	var count := _player_icons.size()
	start_button.disabled = count < min_players
	_update_start_button_animation(count >= min_players)
	_refresh_turn_order()


func _update_start_button_animation(can_start: bool) -> void:
	if not start_button:
		return
	_kill_start_pulse_tween()
	start_button.scale = Vector2.ONE
	var label := start_button.get_node_or_null("StartLabel") as Label
	if can_start:
		start_button.modulate = Color(1.05, 1.02, 0.95, 1)
		if label:
			label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		start_button.pivot_offset = start_button.size * 0.5
		_start_pulse_tween = create_tween().set_loops()
		_start_pulse_tween.tween_property(start_button, "scale", Vector2(1.05, 1.05), 0.5).set_trans(Tween.TRANS_SINE)
		_start_pulse_tween.tween_property(start_button, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
	else:
		start_button.modulate = Color(0.88, 0.88, 0.88, 1)
		if label:
			label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.9, 1))


func _update_add_button_animation(need_more_players: bool) -> void:
	if not add_player_button:
		return
	_kill_add_pulse_tween()
	add_player_button.modulate = Color.WHITE
	add_player_button.pivot_offset = add_player_button.size * 0.5
	add_player_button.scale = Vector2.ONE
	if _battle_mode:
		return
	if need_more_players and not _is_remove_mode:
		_add_pulse_tween = create_tween().set_loops()
		_add_pulse_tween.tween_property(add_player_button, "scale", Vector2(1.12, 1.12), 0.55).set_trans(Tween.TRANS_SINE)
		_add_pulse_tween.tween_property(add_player_button, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_SINE)


func _kill_start_pulse_tween() -> void:
	if _start_pulse_tween:
		_start_pulse_tween.kill()
		_start_pulse_tween = null


func _kill_add_pulse_tween() -> void:
	if _add_pulse_tween:
		_add_pulse_tween.kill()
		_add_pulse_tween = null


func _set_remove_mode(enabled: bool) -> void:
	_is_remove_mode = enabled
	if enabled:
		_kill_add_pulse_tween()
		if add_player_button:
			add_player_button.scale = Vector2.ONE
			add_player_button.modulate = Color.WHITE
		if menu_events:
			menu_events.ev_player_move_begin.emit()
	else:
		if menu_events:
			menu_events.ev_player_move_end.emit()
	_update_add_button()


func _on_add_player_button_pressed() -> void:
	if _is_remove_mode:
		return
	if preset_storage and account:
		preset_storage.rebuild_locks(account.get_players())
	if edit_player_window:
		edit_player_window.open_add_window()


func _on_icon_drag_started(icon: PlayerIcon) -> void:
	_dragging_icon = icon
	_dismiss_hold_edit_hint()
	for player_icon in _player_icons:
		player_icon.set_idle_hold_hint_visible(false)
	_set_remove_mode(true)
	_dismiss_swap_idle_hint()
	_refresh_table_hint()
	_set_order_markers_drag_dimmed(true)
	for other in _player_icons:
		if other != icon:
			other.swap_target = null
			if other.get_drag_state() != PlayerIcon.DragState.NONE:
				other.set_drag_state(PlayerIcon.DragState.RETURNING)


func _process(delta: float) -> void:
	if _dragging_icon:
		_update_swap_preview(_dragging_icon)
	else:
		_update_lobby_animations(delta)


func _update_lobby_animations(delta: float) -> void:
	if _player_icons.is_empty() or not table_area:
		return
	var min_players := game_config.min_players if game_config else 2
	var can_start := _player_icons.size() >= min_players
	var table_center := _get_table_center_global()
	for i in _player_icons.size():
		var icon := _player_icons[i]
		var look_target := table_center
		if can_start and _player_icons.size() > 1:
			var next_index := (i + 1) % _player_icons.size()
			look_target = _player_icons[next_index].home_position
		icon.update_lobby_visuals(delta, look_target, can_start)


func _get_table_center_global() -> Vector2:
	if table_area:
		return table_area.global_position + table_area.size * 0.5
	return Vector2.ZERO


func _get_add_button_center_global() -> Vector2:
	return _get_table_center_global()


func _set_chair_highlight(index: int, enabled: bool) -> void:
	if index < 0 or index >= _chairs.size():
		return
	var chair := _chairs[index]
	chair.modulate = Color(1.2, 1.1, 0.72, 1) if enabled else Color.WHITE
	chair.scale = Vector2(1.08, 1.08) if enabled else Vector2.ONE
	if index < _chair_rings.size():
		_chair_rings[index].visible_ring = enabled


func _clear_chair_highlights() -> void:
	for i in _chairs.size():
		_set_chair_highlight(i, false)
	_highlighted_chair_index = -1


func _is_icon_over_remove_button(icon: PlayerIcon) -> bool:
	return _is_icon_in_remove_ring(icon)


func _update_swap_preview(dragging: PlayerIcon) -> void:
	_update_remove_button_ring(dragging)

	if _is_icon_in_remove_ring(dragging):
		for other in _player_icons:
			if other != dragging and other.swap_target == dragging:
				other.cancel_swap_preview()
		_clear_chair_highlights()
		_remove_hint_active = true
		_swap_drag_hint_active = false
		_refresh_table_hint()
		return

	_remove_hint_active = false

	if not dragging.has_moved_for_swap():
		for other in _player_icons:
			if other != dragging and other.swap_target == dragging:
				other.cancel_swap_preview()
		_clear_chair_highlights()
		_swap_drag_hint_active = false
		_refresh_table_hint()
		return

	var overlap_target: PlayerIcon = null
	var overlap_index := -1
	for i in _player_icons.size():
		var other := _player_icons[i]
		if other != dragging and dragging.is_slime_over_seat(other, chair_size):
			overlap_target = other
			overlap_index = i
			break

	if overlap_index != _highlighted_chair_index:
		_clear_chair_highlights()
		if overlap_index >= 0:
			_set_chair_highlight(overlap_index, true)
			_highlighted_chair_index = overlap_index

	_swap_drag_hint_active = overlap_index >= 0

	for other in _player_icons:
		if other == dragging:
			continue
		if other == overlap_target:
			other.swap_target = dragging
			other.set_drag_state(PlayerIcon.DragState.SWAPPING)
		elif other.swap_target == dragging:
			other.cancel_swap_preview()

	_refresh_table_hint()


func _on_icon_drag_ended(icon: PlayerIcon) -> void:
	var should_remove := (
		icon == _dragging_icon
		and _is_slime_center_in_remove_ring(icon.get_release_slime_center())
	)

	_set_remove_mode(false)
	_remove_hint_active = false
	_swap_drag_hint_active = false
	_set_order_markers_drag_dimmed(false)
	_refresh_turn_order()
	_clear_chair_highlights()
	if _remove_button_ring:
		_remove_button_ring.visible_ring = false
	_update_remove_button_highlight(false)

	if should_remove:
		_remove_player(icon)
		_dragging_icon = null
		_refresh_table_hint()
		return

	var release_center := icon.get_release_slime_center()
	for other in _player_icons:
		if other != icon and icon.has_moved_for_swap_at(release_center) and icon.is_slime_over_seat_at(other, chair_size, release_center):
			for reset_icon in _player_icons:
				if reset_icon != icon:
					reset_icon.stop_motion()
			_swap_players(icon, other)
			icon.stop_motion()
			_dragging_icon = null
			_refresh_table_hint()
			return

	for other in _player_icons:
		if other.swap_target == icon:
			other.cancel_swap_preview()

	icon.set_drag_state(PlayerIcon.DragState.RETURNING)
	_dragging_icon = null
	_refresh_table_hint()


func _on_icon_hold_edit(index: int) -> void:
	_mark_hold_edit_learned()
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
	_mark_hold_edit_learned()
	var players := account.get_players()
	if index < 0 or index >= players.size():
		return
	var info := PlayerInfo.new(player_name, preset_id)
	players[index] = account.dict_from_player_info(info)
	account.set_players(players)
	_player_icons[index].set_player_data(info, index, _player_icons.size())
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
	account.remember_removed_player(info.name)

	icon.queue_free()
	_chairs[index].queue_free()
	_player_icons.remove_at(index)
	_chairs.remove_at(index)
	_chair_rings.remove_at(index)

	for i in _player_icons.size():
		var player_info := account.player_info_from_dict(players[i])
		_player_icons[i].set_player_data(player_info, i, _player_icons.size())

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
	for i in _player_icons.size():
		_player_icons[i].set_order_index(i, _player_icons.size())
	_refresh_turn_order()
	_play_swap_whoosh(icon_a, icon_b, index_a, index_b)
	_refresh_table_hint()
	_update_start_button()


func _play_swap_whoosh(icon_a: PlayerIcon, icon_b: PlayerIcon, index_a: int, index_b: int) -> void:
	if not table_area:
		return
	var player_count := _player_icons.size()
	for i in player_count:
		var seat_local := _seat_local_for_index(i, player_count)
		_apply_chair_transform(_chairs[i], seat_local)

	var seat_a := table_area.global_position + _seat_local_for_index(index_b, player_count)
	var seat_b := table_area.global_position + _seat_local_for_index(index_a, player_count)
	icon_a.animate_arc_to(seat_a)
	icon_b.animate_arc_to(seat_b)

	for i in player_count:
		if _player_icons[i] == icon_a or _player_icons[i] == icon_b:
			continue
		var seat_global := table_area.global_position + _seat_local_for_index(i, player_count)
		_player_icons[i].reset_home_position(seat_global, true)

	call_deferred("_layout_table_order_badges")


func play_start_preview(on_complete: Callable) -> void:
	if _is_start_preview_playing:
		return

	_is_start_preview_playing = true
	if _turn_order_arrows:
		_turn_order_arrows.play_start_pulse()

	var tween := create_tween()
	tween.tween_interval(0.45)
	tween.tween_callback(func() -> void:
		_is_start_preview_playing = false
		on_complete.call()
	)


func _rect_overlaps(icon: PlayerIcon, button: Control) -> bool:
	return icon.get_world_rect().intersects(Rect2(button.global_position, button.size))


func _save_account() -> void:
	if not account:
		return
	var controller := _resolve_pdata_controller()
	if controller and "account" in controller:
		var persistent: PDataAccount = controller.account
		if persistent and persistent != account:
			ResourceUtils.update_resource(persistent, account)
			account = persistent
			_sync_edit_window_refs()
	if controller and controller.has_method("save_account"):
		controller.save_account()


func _resolve_pdata_controller() -> Node:
	if pdata_controller:
		return pdata_controller
	return get_tree().get_first_node_in_group("account_persistence")


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_schedule_position_update()
		_update_hint_banner_layout()
		_apply_remove_ring_radius()
		_layout_remove_button_ring()
