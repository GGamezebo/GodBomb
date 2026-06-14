extends IContext

@export var main_events: MainEvents
@export var game_config: GameConfig
@export var account: PDataAccount
@export var pdata_controller: Node
@export var menu_events: MenuEvents
@export var start_button: BaseButton
@export var player_selection_widget: PlayerSelectionWidget
@export var game_time_slider: HSlider
@export var game_time_label: Label

var listener: EventListener = EventListener.new()


func _ready() -> void:
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if game_time_slider:
		game_time_slider.value_changed.connect(_on_game_time_changed)
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

	if player_selection_widget:
		player_selection_widget.account = account
		player_selection_widget.game_config = game_config
		player_selection_widget.start_button = start_button
		if passed_controller:
			player_selection_widget.pdata_controller = passed_controller
		player_selection_widget.reload_from_account()

	_load_game_time_from_account()
	_update_start_button()


func _on_player_list_changed(..._args) -> void:
	_update_start_button()


func deinit() -> void:
	pass


func _load_game_time_from_account() -> void:
	if not account or not game_time_slider:
		return
	game_time_slider.min_value = 1
	game_time_slider.max_value = 30
	game_time_slider.value = account.get_game_time_minutes()
	_update_game_time_label(int(game_time_slider.value))


func _on_game_time_changed(value: float) -> void:
	if not account:
		return
	var minutes := int(value)
	account.set_game_time_minutes(minutes)
	_update_game_time_label(minutes)
	menu_events.ev_game_time_changed.emit(minutes)
	var controller := pdata_controller
	if not controller:
		controller = get_tree().get_first_node_in_group("account_persistence")
	if controller and controller.has_method("save_account"):
		controller.save_account()


func _update_game_time_label(minutes: int) -> void:
	if game_time_label:
		game_time_label.text = "Длительность: %d мин" % minutes


func _update_start_button() -> void:
	if not start_button:
		return
	var min_players := game_config.min_players if game_config else 2
	var count := account.get_players().size() if account else 0
	start_button.disabled = count < min_players


func _on_start_pressed() -> void:
	if not account or account.get_players().size() < game_config.min_players:
		return
	main_events.ev_start_game.emit({})
