extends IContext

@export var game_config: GameConfig
@export var account: PDataAccount
@export var main_events: MainEvents
@export var game_events: GameEvents
@export var game_manager: GameManager


func initialize(data: Dictionary) -> void:
	var session_account: PDataAccount = data.get("account", account)
	if game_manager and game_config and session_account:
		game_manager.setup_session(game_config, session_account)


func deinit() -> void:
	pass
