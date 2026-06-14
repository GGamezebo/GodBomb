class_name GameBattleChrome
extends Control

const PLAYERS_ACTIVE_MODULATE := Color(1.12, 1.08, 0.94, 1.0)

@export var main_events: MainEvents
@export var menu_events: MenuEvents
@export var game_events: GameEvents
@export var game_manager: GameManager
@export var game_hud: Control
@export var game_config: GameConfig
@export var top_bar: Control
@export var exit_button: TextureButton
@export var players_button: TextureButton
@export var player_lobby_overlay: BattlePlayerLobbyOverlay
@export var exit_confirm_dialog: ExitConfirmDialog

var listener: EventListener = EventListener.new()
var _players_overlay_open: bool = false
var _exit_dialog_open: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = MenuBombLayout.DESIGN_SIZE
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	if players_button:
		players_button.pressed.connect(_on_players_pressed)
	if top_bar:
		top_bar.visible = false
	if player_lobby_overlay:
		player_lobby_overlay.closed.connect(_on_player_lobby_closed)
	if menu_events and player_lobby_overlay:
		player_lobby_overlay.menu_events = menu_events
		player_lobby_overlay._bind_menu_listeners()
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
	if exit_confirm_dialog:
		exit_confirm_dialog.confirmed.connect(_on_exit_confirmed)
		exit_confirm_dialog.cancelled.connect(_on_exit_cancelled)
	call_deferred("_sync_top_bar_from_fsm")


func _exit_tree() -> void:
	listener.deinit()
	_set_players_overlay(false)
	_close_exit_dialog()


func configure(data: Dictionary) -> void:
	if player_lobby_overlay:
		player_lobby_overlay.game_manager = game_manager
		player_lobby_overlay.game_config = game_config
		player_lobby_overlay.menu_events = menu_events
		player_lobby_overlay._bind_menu_listeners()
		player_lobby_overlay.configure(data)


func _sync_top_bar_from_fsm() -> void:
	if game_manager and game_manager.fsm:
		_on_game_state_changed("", game_manager.fsm.get_current_state_name())


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	_set_top_bar_visible(to_state == FSMGameStates.READY_TO_START)


func _set_top_bar_visible(visible: bool) -> void:
	if top_bar:
		top_bar.visible = visible
	if not visible:
		_set_players_overlay(false)
		_close_exit_dialog()


func _on_exit_pressed() -> void:
	_set_players_overlay(false)
	if exit_confirm_dialog:
		_open_exit_dialog()
	else:
		_finish_exit_to_menu()


func _open_exit_dialog() -> void:
	_exit_dialog_open = true
	if game_manager:
		game_manager.set_paused(true)
	exit_confirm_dialog.open()


func _close_exit_dialog() -> void:
	if not _exit_dialog_open:
		return
	_exit_dialog_open = false
	if exit_confirm_dialog:
		exit_confirm_dialog.close()
	_sync_pause_state()


func _on_exit_confirmed() -> void:
	_exit_dialog_open = false
	_finish_exit_to_menu()


func _on_exit_cancelled() -> void:
	_exit_dialog_open = false
	_sync_pause_state()


func _sync_pause_state() -> void:
	if not game_manager:
		return
	game_manager.set_paused(_players_overlay_open or _exit_dialog_open)


func _finish_exit_to_menu() -> void:
	if player_lobby_overlay:
		player_lobby_overlay.close_overlay()
	_save_account()
	if main_events:
		main_events.ev_return_to_menu.emit()


func _on_players_pressed() -> void:
	_set_players_overlay(not _players_overlay_open)


func _set_players_overlay(open: bool) -> void:
	if open == _players_overlay_open:
		return
	_players_overlay_open = open
	if player_lobby_overlay:
		if open:
			player_lobby_overlay.open()
		else:
			player_lobby_overlay.close_overlay()
	if players_button:
		players_button.modulate = PLAYERS_ACTIVE_MODULATE if open else Color.WHITE
	_sync_pause_state()
	if game_hud and game_hud.has_method("set_lobby_overlay_active"):
		game_hud.set_lobby_overlay_active(open)


func _on_player_lobby_closed() -> void:
	_players_overlay_open = false
	if players_button:
		players_button.modulate = Color.WHITE
	_sync_pause_state()
	if game_hud and game_hud.has_method("set_lobby_overlay_active"):
		game_hud.set_lobby_overlay_active(false)


func _save_account() -> void:
	if player_lobby_overlay:
		player_lobby_overlay.save_account()
