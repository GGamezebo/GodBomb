class_name BattlePlayerLobbyOverlay
extends CanvasLayer

signal closed

const NEUTRAL_BG := Color(0.06, 0.05, 0.04, 1.0)
const LOBBY_BLUR_SHADER := preload("res://assets/shaders/bomb_background_blur.gdshader")
const LOBBY_BLUR_STRENGTH := 1.25

@export var game_manager: GameManager
@export var game_config: GameConfig
@export var menu_events: MenuEvents
@export var account: PDataAccount
@export var pdata_controller: Node
@export var background_color: ColorRect
@export var background_bomb: TextureRect
@export var player_selection_widget: PlayerSelectionWidget
@export var done_button: TextureButton

var listener: EventListener = EventListener.new()
var _menu_listeners_bound: bool = false
var _blur_material: ShaderMaterial


func _ready() -> void:
	layer = 12
	visible = false
	_setup_blur_material()
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
	_bind_widget_account()
	_bind_menu_listeners()


func open() -> void:
	_bind_widget_account()
	if background_color:
		background_color.color = NEUTRAL_BG
	if player_selection_widget:
		player_selection_widget.reload_from_account()
	_set_bomb_blur(true)
	visible = true


func close_overlay() -> void:
	if not visible:
		return
	_apply_roster_to_game()
	_set_bomb_blur(false)
	visible = false
	closed.emit()


func _setup_blur_material() -> void:
	_blur_material = ShaderMaterial.new()
	_blur_material.shader = LOBBY_BLUR_SHADER
	_blur_material.set_shader_parameter("blur_strength", LOBBY_BLUR_STRENGTH)


func _set_bomb_blur(enabled: bool) -> void:
	if not background_bomb:
		return
	background_bomb.material = _blur_material if enabled else null


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
	player_selection_widget.commit_roster_to_account()
	player_selection_widget.persist_account()
	var canonical := _resolve_account()
	if not canonical:
		return
	account = canonical
	player_selection_widget.bind_account(canonical, pdata_controller)
	if game_manager:
		game_manager.resync_players_from_account(canonical)


func save_account() -> void:
	if player_selection_widget:
		player_selection_widget.persist_account()
