class_name BattlePlayerLobbyOverlay
extends CanvasLayer

signal closed

const NEUTRAL_BG := Color(0, 0, 0, 1.0)
const LOBBY_BLUR_SHADER := preload("res://assets/shaders/bomb_background_blur.gdshader")
const LOBBY_BLUR_RADIUS := 5.0

@export var game_manager: GameManager
@export var game_config: GameConfig
@export var menu_events: MenuEvents
@export var account: PDataAccount
@export var pdata_controller: Node
@export var background_color: ColorRect
@export var layout_host: MenuBombLayout
@export var bomb_art: TextureRect
@export var player_selection_widget: PlayerSelectionWidget
@export var done_button: TextureButton

var listener: EventListener = EventListener.new()
var _menu_listeners_bound: bool = false
var _blur_material: ShaderMaterial


func _ready() -> void:
	layer = 12
	visible = false
	_setup_blur_material()
	_connect_layout()
	if bomb_art:
		bomb_art.visible = false
	if done_button:
		done_button.pressed.connect(_on_done_pressed)
	if player_selection_widget:
		player_selection_widget.set_battle_mode(true)
	_bind_menu_listeners()


func _exit_tree() -> void:
	_set_bomb_blur(false)
	listener.deinit()


func configure(data: Dictionary) -> void:
	var passed_controller: Node = data.get("pdata_controller")
	if passed_controller:
		pdata_controller = passed_controller
	var session_account: PDataAccount = data.get("account")
	if session_account:
		account = session_account
	_ensure_runtime_refs()
	_bind_widget_account()
	_bind_menu_listeners()


func open() -> void:
	_ensure_runtime_refs()
	_bind_widget_account()
	if background_color:
		background_color.color = NEUTRAL_BG
	if bomb_art:
		bomb_art.visible = false
	if player_selection_widget:
		player_selection_widget.reload_from_account()
	_sync_bomb_art_layout()
	_set_bomb_blur(false)
	visible = true


func close_overlay() -> void:
	if not visible:
		return
	_apply_roster_to_game()
	_set_bomb_blur(false)
	visible = false
	closed.emit()


func _ensure_runtime_refs() -> void:
	if not game_manager:
		var context := get_parent()
		if context:
			game_manager = context.get_node_or_null("GameManager") as GameManager


func _connect_layout() -> void:
	if layout_host and not layout_host.layout_applied.is_connected(_sync_bomb_art_layout):
		layout_host.layout_applied.connect(_sync_bomb_art_layout)
	call_deferred("_sync_bomb_art_layout")


func _sync_bomb_art_layout() -> void:
	if not bomb_art or not layout_host:
		return
	var scale_factor := layout_host.get_cover_scale()
	var scaled_size := MenuBombLayout.DESIGN_SIZE * scale_factor
	var offset := (layout_host.size - scaled_size) * 0.5
	bomb_art.scale = Vector2.ONE * scale_factor
	bomb_art.position = offset
	bomb_art.size = MenuBombLayout.DESIGN_SIZE


func _setup_blur_material() -> void:
	_blur_material = ShaderMaterial.new()
	_blur_material.shader = LOBBY_BLUR_SHADER
	_blur_material.set_shader_parameter("blur_radius", LOBBY_BLUR_RADIUS)
	if bomb_art and bomb_art.texture:
		_blur_material.set_shader_parameter("source_tex", bomb_art.texture)


func _set_bomb_blur(enabled: bool) -> void:
	if not bomb_art:
		return
	if enabled:
		if bomb_art.texture and _blur_material:
			_blur_material.set_shader_parameter("source_tex", bomb_art.texture)
		bomb_art.material = _blur_material
	else:
		bomb_art.material = null


func _bind_widget_account() -> void:
	var active_account := _resolve_account()
	if active_account:
		account = active_account
	if not player_selection_widget:
		return
	player_selection_widget.bind_account(account, pdata_controller)
	player_selection_widget.game_config = game_config
	player_selection_widget.menu_events = menu_events
	player_selection_widget.start_button = done_button


func _bind_menu_listeners() -> void:
	if _menu_listeners_bound or not menu_events:
		return
	_menu_listeners_bound = true
	listener.add(menu_events.ev_player_added, _on_roster_changed)
	listener.add(menu_events.ev_player_removed, _on_roster_changed)
	listener.add(menu_events.ev_player_modified, _on_roster_changed)
	listener.add(menu_events.ev_player_swapped, _on_roster_changed)


func _resolve_account() -> PDataAccount:
	var controller := _resolve_controller()
	if controller and "account" in controller and controller.account is PDataAccount:
		return controller.account
	return account


func _resolve_controller() -> Node:
	if pdata_controller:
		return pdata_controller
	return get_tree().get_first_node_in_group(PersistentDataController.PERSISTENCE_GROUP)


func _resolve_game_manager() -> GameManager:
	_ensure_runtime_refs()
	return game_manager


func _on_done_pressed() -> void:
	var min_players := game_config.min_players if game_config else 2
	if not player_selection_widget:
		return
	player_selection_widget.commit_roster_to_account()
	if player_selection_widget.get_roster_size() < min_players:
		return
	close_overlay()


func _on_roster_changed(..._args) -> void:
	if not visible:
		return
	_apply_roster_to_game()


func _apply_roster_to_game() -> void:
	if not player_selection_widget:
		return
	var roster_entries: Array = player_selection_widget.export_roster_entries()
	player_selection_widget.persist_account()
	var canonical := _resolve_account()
	if canonical:
		account = canonical
		player_selection_widget.bind_account(canonical, pdata_controller)
	var manager := _resolve_game_manager()
	if manager and not roster_entries.is_empty():
		manager.resync_players_from_entries(roster_entries)


func save_account() -> void:
	if player_selection_widget:
		player_selection_widget.persist_account()
