extends IContext

const DEFAULT_GAME_EVENTS := preload("res://src/common/game_events.tres")
const DEFAULT_GAME_CONFIG := preload("res://src/common/game_config_default.tres")
const DEFAULT_ACCOUNT := preload("res://src/contexts/main_context/account/pdata_account.tres")
const DEFAULT_MAIN_EVENTS := preload("res://src/contexts/main_context/main_events.tres")

@export var game_config: GameConfig
@export var account: PDataAccount
@export var main_events: MainEvents
@export var game_events: GameEvents
@export var game_manager: GameManager

var _initialized: bool = false


func _ready() -> void:
	if not _initialized:
		initialize({})


func initialize(data: Dictionary) -> void:
	if _initialized:
		return
	_initialized = true
	_ensure_runtime_resources()

	var session_account: PDataAccount = data.get("account", account)
	if game_manager and game_config and session_account:
		if not game_manager.game_events and game_events:
			game_manager.game_events = game_events
		game_manager.setup_session(game_config, session_account)


func deinit() -> void:
	pass


func _ensure_runtime_resources() -> void:
	if not game_events:
		game_events = DEFAULT_GAME_EVENTS.duplicate(true)
	if not game_config:
		game_config = DEFAULT_GAME_CONFIG.duplicate(true)
	if not account:
		account = DEFAULT_ACCOUNT.duplicate(true)
	if not main_events:
		main_events = DEFAULT_MAIN_EVENTS.duplicate(true)
