extends IContext

@export var main_events: MainEvents
@export var game_config: GameConfig
@export var account: PDataAccount
@export var pdata_controller: Node
@export var menu_events: MenuEvents
@export var start_button: BaseButton
@export var player_selection_widget: PlayerSelectionWidget
@export var settings_button: BaseButton
@export var music_button: TextureButton
@export var rules_button: BaseButton
@export var settings_window: SettingsWindow
@export var rules_window: RulesWindow
@export var music_on_texture: Texture2D
@export var music_off_texture: Texture2D

var listener: EventListener = EventListener.new()


func _ready() -> void:
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if music_button:
		music_button.pressed.connect(_on_music_pressed)
	if rules_button:
		rules_button.pressed.connect(_on_rules_pressed)
	if menu_events:
		listener.add(menu_events.ev_player_added, _on_player_list_changed)
		listener.add(menu_events.ev_player_removed, _on_player_list_changed)
		listener.add(menu_events.ev_player_swapped, _on_player_list_changed)


func _exit_tree() -> void:
	listener.deinit()


func initialize(data: Dictionary) -> void:
	var passed_account: PDataAccount = data.get("account")
	if passed_account:
		account = passed_account

	var passed_controller: Node = data.get("pdata_controller")
	if passed_controller:
		pdata_controller = passed_controller

	if settings_window:
		settings_window.account = account
		settings_window.pdata_controller = pdata_controller
		settings_window.menu_events = menu_events
		settings_window.player_selection_widget = player_selection_widget

	if player_selection_widget:
		player_selection_widget.account = account
		player_selection_widget.game_config = game_config
		player_selection_widget.start_button = start_button
		if passed_controller:
			player_selection_widget.pdata_controller = passed_controller
		player_selection_widget.reload_from_account()

	_update_music_button_icon()
	_update_start_button()
	if account and not account.changed.is_connected(_update_music_button_icon):
		account.changed.connect(_update_music_button_icon)


func _on_player_list_changed(..._args) -> void:
	_update_start_button()


func deinit() -> void:
	pass


func _on_settings_pressed() -> void:
	if settings_window:
		settings_window.open()


func _on_rules_pressed() -> void:
	if rules_window:
		rules_window.open()


func _on_music_pressed() -> void:
	var audio := _get_audio_controller()
	if not audio or not account:
		return
	var enabled := audio.toggle_music()
	_update_music_button_icon()
	_save_account()


func _update_music_button_icon() -> void:
	if not music_button or not account:
		return
	var enabled := account.get_music_enabled()
	if enabled and music_on_texture:
		music_button.texture_normal = music_on_texture
	elif music_off_texture:
		music_button.texture_normal = music_off_texture


func _get_audio_controller() -> GameAudioController:
	return get_tree().get_first_node_in_group(GameAudioController.GROUP) as GameAudioController


func _save_account() -> void:
	var controller := pdata_controller
	if not controller:
		controller = get_tree().get_first_node_in_group(PersistentDataController.PERSISTENCE_GROUP)
	if controller and controller.has_method("save_account"):
		controller.save_account()


func _update_start_button() -> void:
	if not start_button:
		return
	var min_players := game_config.min_players if game_config else 2
	var count := account.get_players().size() if account else 0
	start_button.disabled = count < min_players


func _on_start_pressed() -> void:
	if not account or account.get_players().size() < game_config.min_players:
		return
	if start_button:
		start_button.disabled = true
	if player_selection_widget:
		player_selection_widget.play_start_preview(_begin_game)
	else:
		_begin_game()


func _begin_game() -> void:
	main_events.ev_start_game.emit({})
