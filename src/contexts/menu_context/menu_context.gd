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


func _ready() -> void:
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if game_time_slider:
		game_time_slider.value_changed.connect(_on_game_time_changed)


func initialize(data: Dictionary) -> void:
	var passed_account: PDataAccount = data.get("account")
	if passed_account and account:
		ResourceUtils.update_resource(account, passed_account)
	if player_selection_widget:
		player_selection_widget.reload_from_account()
	_load_game_time_from_account()


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
	if pdata_controller and pdata_controller.has_method("save_account"):
		pdata_controller.save_account()


func _update_game_time_label(minutes: int) -> void:
	if game_time_label:
		game_time_label.text = "Длительность: %d мин" % minutes


func _on_start_pressed() -> void:
	if not account or account.get_players().size() < game_config.min_players:
		return
	main_events.ev_start_game.emit({})
