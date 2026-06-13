extends IContext

@export var main_events: MainEvents
@export var game_config: GameConfig
@export var account: PDataAccount
@export var start_button: Button
@export var player_selection: Control

var listener: EventListener = EventListener.new()


func _ready() -> void:
	if start_button:
		start_button.pressed.connect(_on_start_pressed)


func initialize(data: Dictionary) -> void:
	var passed_account: PDataAccount = data.get("account")
	if passed_account and account:
		ResourceUtils.update_resource(account, passed_account)
	if player_selection and player_selection.has_method("reload_from_account"):
		player_selection.reload_from_account()


func deinit() -> void:
	pass


func _on_start_pressed() -> void:
	if account.get_players().size() < game_config.min_players:
		return
	main_events.ev_start_game.emit({})
