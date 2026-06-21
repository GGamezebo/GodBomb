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
@export var emergency_button: TextureButton
@export var player_lobby_overlay: BattlePlayerLobbyOverlay
@export var emergency_overlay: BattleEmergencyOverlay
@export var exit_confirm_dialog: ExitConfirmDialog

var listener: EventListener = EventListener.new()
var _players_overlay_open: bool = false
var _exit_dialog_open: bool = false
var _pending_configure_data: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	size = MenuBombLayout.DESIGN_SIZE
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)
	if players_button:
		players_button.pressed.connect(_on_players_pressed)
	if emergency_button:
		emergency_button.button_down.connect(_on_emergency_pressed)
		emergency_button.visible = false
		UiSounds.bind_button(emergency_button)
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
	call_deferred("_apply_configure")


func _exit_tree() -> void:
	listener.deinit()
	_set_players_overlay(false)
	_close_exit_dialog()


func configure(data: Dictionary) -> void:
	_pending_configure_data = data.duplicate()
	call_deferred("_apply_configure")


func _apply_configure() -> void:
	if player_lobby_overlay:
		player_lobby_overlay.game_manager = game_manager
		player_lobby_overlay.game_config = game_config
		player_lobby_overlay.menu_events = menu_events
		player_lobby_overlay._bind_menu_listeners()
		if not _pending_configure_data.is_empty():
			player_lobby_overlay.configure(_pending_configure_data)
	if emergency_overlay:
		emergency_overlay.game_manager = game_manager
		emergency_overlay.game_events = game_events
		if not _pending_configure_data.is_empty():
			emergency_overlay.configure(_pending_configure_data)


func _sync_top_bar_from_fsm() -> void:
	if game_manager and game_manager.fsm:
		_on_game_state_changed("", game_manager.fsm.get_current_state_name())


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	var show_top_bar := (
		to_state == FSMGameStates.READY_TO_START
		or to_state == FSMGameStates.PLAY
	)
	_set_top_bar_mode(to_state, show_top_bar)


func _set_top_bar_mode(state: String, bar_visible: bool) -> void:
	if top_bar:
		top_bar.visible = bar_visible
	if exit_button:
		exit_button.visible = bar_visible and state == FSMGameStates.READY_TO_START
	if players_button:
		players_button.visible = bar_visible and state == FSMGameStates.READY_TO_START
	if emergency_button:
		emergency_button.visible = bar_visible and state == FSMGameStates.PLAY
	if not bar_visible or state != FSMGameStates.READY_TO_START:
		_set_players_overlay(false)
		_close_exit_dialog()


func _on_emergency_pressed() -> void:
	if not game_manager:
		return
	game_manager.enter_emergency()


func is_pass_blocked_at(global_pos: Vector2) -> bool:
	if not top_bar or not top_bar.visible:
		return false
	return top_bar.get_global_rect().has_point(global_pos)


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
	var emergency_active := (
		game_manager.fsm != null
		and game_manager.fsm.get_current_state_name() == FSMGameStates.EMERGENCY
	)
	game_manager.set_paused(_players_overlay_open or _exit_dialog_open or emergency_active)


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
	if game_hud and game_hud.has_method("sync_from_session"):
		game_hud.sync_from_session()
	elif game_hud and game_hud.has_method("set_lobby_overlay_active"):
		game_hud.set_lobby_overlay_active(false)


func _save_account() -> void:
	if player_lobby_overlay:
		player_lobby_overlay.save_account()
