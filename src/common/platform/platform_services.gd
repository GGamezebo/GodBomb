extends Node

## Cross-platform facade. Yandex Games hooks run only with export feature `yandex`.
## Android / plain Web remain unaffected.

const GAME_EVENTS_PATH := "res://src/common/game_events.tres"

var _game_events: GameEvents
var _listener: EventListener = EventListener.new()
var _gameplay_active: bool = false
var _ready_sent: bool = false
var _pending_menu_ad: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not is_yandex():
		return
	_game_events = load(GAME_EVENTS_PATH) as GameEvents
	if _game_events:
		_listener.add(_game_events.ev_game_state_changed, _on_game_state_changed)
	call_deferred("_boot_yandex")


func _exit_tree() -> void:
	_listener.deinit()


func is_yandex() -> bool:
	return OS.has_feature("yandex")


func _yg() -> Node:
	return get_node_or_null("/root/YandexGames")


func _boot_yandex() -> void:
	var yg := _yg()
	if yg == null:
		push_warning("PlatformServices: YandexGames autoload missing")
		return
	if yg.has_signal("sdk_initialized") and not yg.sdk_initialized.is_connected(_on_sdk_initialized):
		yg.sdk_initialized.connect(_on_sdk_initialized)
	if yg.has_signal("history_back_requested") and not yg.history_back_requested.is_connected(_on_history_back):
		yg.history_back_requested.connect(_on_history_back)
	if yg.has_method("ensure_initialized"):
		var ok: bool = await yg.ensure_initialized()
		if ok:
			await _on_sdk_initialized({})
	else:
		await _notify_game_ready()


func _on_sdk_initialized(_data: Dictionary = {}) -> void:
	_sync_locale_from_sdk()
	await _notify_game_ready()


func _sync_locale_from_sdk() -> void:
	var yg := _yg()
	if yg == null or not ("environment" in yg):
		return
	var lang: String = ""
	if yg.environment and yg.environment.has_method("get_lang"):
		lang = str(yg.environment.get_lang())
	if lang.is_empty():
		return
	if LocaleService:
		LocaleService.set_locale(lang, false)


func _notify_game_ready() -> void:
	if _ready_sent:
		return
	_ready_sent = true
	# Wait until the lobby is in the tree and interactive (LoadingAPI.ready must not be timer-based).
	await get_tree().process_frame
	var yg := _yg()
	if yg == null or not yg.has_method("game_ready"):
		return
	yg.game_ready()


func _on_game_state_changed(_from: String, to_state: String) -> void:
	if to_state == FSMGameStates.PLAY:
		_set_gameplay_active(true)
	else:
		_set_gameplay_active(false)
	if to_state == FSMGameStates.RESULT:
		_pending_menu_ad = true


func _set_gameplay_active(active: bool) -> void:
	if active == _gameplay_active:
		return
	_gameplay_active = active
	var yg := _yg()
	if yg == null:
		return
	if active and yg.has_method("gameplay_start"):
		yg.gameplay_start()
	elif not active and yg.has_method("gameplay_stop"):
		yg.gameplay_stop()


func on_left_battle_context() -> void:
	_set_gameplay_active(false)


## Call before returning to menu after a finished match. Shows interstitial when allowed.
func await_return_to_menu_gate() -> void:
	if not is_yandex() or not _pending_menu_ad:
		_pending_menu_ad = false
		return
	_pending_menu_ad = false
	_set_gameplay_active(false)
	var yg := _yg()
	if yg == null or not ("ads" in yg):
		return
	if yg.ads and yg.ads.has_method("show_interstitial_if_available"):
		await yg.ads.show_interstitial_if_available()
	elif yg.has_method("show_interstitial"):
		await yg.show_interstitial()


func _on_history_back() -> void:
	# Smart TV / browser back — stop gameplay markup; exit confirm is product-specific.
	_set_gameplay_active(false)
