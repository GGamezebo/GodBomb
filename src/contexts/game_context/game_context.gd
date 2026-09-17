extends IContext

const DEFAULT_GAME_EVENTS := preload("res://src/common/game_events.tres")
const DEFAULT_GAME_CONFIG := preload("res://src/common/game_config_default.tres")
const DEFAULT_ACCOUNT := preload("res://src/contexts/main_context/account/pdata_account.tres")
const DEFAULT_MAIN_EVENTS := preload("res://src/contexts/main_context/main_events.tres")
const DEFAULT_MENU_EVENTS := preload("res://src/common/menu_events.tres")

@export var game_config: GameConfig
@export var account: PDataAccount
@export var main_events: MainEvents
@export var menu_events: MenuEvents
@export var game_events: GameEvents
@export var game_manager: GameManager
@export var battle_chrome: GameBattleChrome

var _session_configured: bool = false
var _game_time_listener: EventListener = EventListener.new()


func _ready() -> void:
	if not _session_configured:
		initialize({})


func initialize(data: Dictionary) -> void:
	_ensure_runtime_resources()

	var session_account: PDataAccount = data.get("account", account)
	if session_account:
		account = session_account

	if game_manager and game_config and account:
		if not game_manager.game_events and game_events:
			game_manager.game_events = game_events
		LocaleService.apply_cards_to(game_config)
		game_manager.setup_session(game_config, account)
		_session_configured = true
		_bind_game_time_listener()

	if battle_chrome:
		battle_chrome.game_manager = game_manager
		battle_chrome.game_events = game_events
		var chrome_data := data.duplicate()
		if account and not chrome_data.has("account"):
			chrome_data["account"] = account
		battle_chrome.configure(chrome_data)
	var onboarding: OnboardingController = data.get("onboarding_controller")
	if onboarding:
		onboarding.bind_game(self)


func deinit() -> void:
	_game_time_listener.deinit()


func _bind_game_time_listener() -> void:
	if not menu_events:
		return
	_game_time_listener.deinit()
	_game_time_listener.add(menu_events.ev_game_time_changed, _on_game_time_changed)


func _on_game_time_changed(_minutes: int) -> void:
	if not game_manager or not account:
		return
	game_manager.refresh_session_account(account)


func _ensure_runtime_resources() -> void:
	if not game_events:
		game_events = DEFAULT_GAME_EVENTS.duplicate(true)
	if not game_config:
		game_config = DEFAULT_GAME_CONFIG.duplicate(true)
	if not account:
		account = DEFAULT_ACCOUNT.duplicate(true)
	if not main_events:
		main_events = DEFAULT_MAIN_EVENTS.duplicate(true)
	if not menu_events:
		menu_events = DEFAULT_MENU_EVENTS.duplicate(true)
