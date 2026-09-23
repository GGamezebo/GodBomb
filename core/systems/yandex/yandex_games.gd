class_name YandexGames
extends Node

## Yandex Games SDK bridge. No-op in editor / Android / local web without /sdk.js.
## Web export injects `/sdk.js` via `export_presets.cfg` html/head_include.

const GROUP := "yandex_games"
const INIT_TIMEOUT_SEC := 20.0
const AD_TIMEOUT_SEC := 45.0

signal initialized
signal platform_pause_changed(paused: bool)
signal fullscreen_ad_closed(was_shown: bool)
signal _ad_js_closed(was_shown: bool)

@export var audio: Node
@export var game_events: GameEvents

var is_available: bool = false
var is_ready_sent: bool = false
var is_platform_paused: bool = false

var _interactive: bool = false
var _wanted_gameplay: bool = false
var _gameplay_reported: bool = false
var _events_bound: bool = false
var _focus_fallback: bool = false
var _init_elapsed: float = 0.0
var _init_done: bool = false
var _ad_busy: bool = false
var _paused_by_platform: bool = false
var _listener: EventListener = EventListener.new()
var _js_callbacks: Array = []


static func is_gameplay_state(state_name: String) -> bool:
	return state_name == "countdown" or state_name == "play"


func _ready() -> void:
	add_to_group(GROUP)
	if game_events == null:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		_listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
	if not _is_web():
		_init_done = true
		set_process(false)
		return
	set_process(true)


func _exit_tree() -> void:
	_listener.deinit()
	_js_callbacks.clear()


func _process(delta: float) -> void:
	if _init_done:
		set_process(false)
		return
	_init_elapsed += delta
	if _try_bind_sdk():
		_init_done = true
		set_process(false)
		return
	if _init_elapsed >= INIT_TIMEOUT_SEC:
		_init_done = true
		set_process(false)


func _notification(what: int) -> void:
	if not _focus_fallback:
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		_apply_platform_pause(true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		_apply_platform_pause(false)


func notify_interactive() -> void:
	_interactive = true
	_try_send_ready()


func on_left_game() -> void:
	_wanted_gameplay = false
	_sync_gameplay_api()


func maybe_show_fullscreen_on_menu_return(skip: bool) -> void:
	if skip or not is_available or _ad_busy:
		return
	await show_fullscreen_ad()


func show_fullscreen_ad() -> void:
	if not is_available or not _has_js() or _ad_busy:
		return
	_ad_busy = true
	_sync_gameplay_api()
	_set_audio_muted(true)

	var callback: Variant = _keep_callback(_on_js_ad_closed)
	var window: Variant = _js_window()
	if window != null:
		window.__godbombOnAdClose = callback
	_js_eval(
		"(function(){"
		+ "var y=window.ysdk;"
		+ "var done=function(shown){if(window.__godbombOnAdClose)window.__godbombOnAdClose(!!shown);};"
		+ "if(!y||!y.adv||!y.adv.showFullscreenAdv){done(false);return;}"
		+ "y.adv.showFullscreenAdv({callbacks:{"
		+ "onClose:function(wasShown){done(!!wasShown);},"
		+ "onError:function(){done(false);}"
		+ "}});"
		+ "})();"
	)

	var shown := await _await_ad_result()
	_ad_busy = false
	if not is_platform_paused:
		_set_audio_muted(false)
	_sync_gameplay_api()
	fullscreen_ad_closed.emit(shown)


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	_wanted_gameplay = is_gameplay_state(to_state)
	_sync_gameplay_api()


func _try_bind_sdk() -> bool:
	if not _has_js():
		return false
	if not bool(_js_eval("Boolean(window.ysdk)")):
		if bool(_js_eval("Boolean(window.YaGames)")):
			_js_eval(
				"if(!window.__godbombInitStarted&&window.YaGames){"
				+ "window.__godbombInitStarted=true;"
				+ "YaGames.init().then(function(y){window.ysdk=y;}).catch(function(){});"
				+ "}"
			)
		return false
	is_available = true
	_bind_pause_resume()
	_try_send_ready()
	initialized.emit()
	return true


func _try_send_ready() -> void:
	if is_ready_sent or not _interactive or not is_available:
		return
	_js_eval(
		"(function(){var y=window.ysdk;"
		+ "if(y&&y.features&&y.features.LoadingAPI&&y.features.LoadingAPI.ready){"
		+ "y.features.LoadingAPI.ready();}})();"
	)
	is_ready_sent = true


func _sync_gameplay_api() -> void:
	var should_report := _wanted_gameplay and not is_platform_paused and not _ad_busy
	if should_report == _gameplay_reported:
		return
	_gameplay_reported = should_report
	if not is_available:
		return
	if should_report:
		_js_eval(
			"(function(){var y=window.ysdk;"
			+ "if(y&&y.features&&y.features.GameplayAPI&&y.features.GameplayAPI.start){"
			+ "y.features.GameplayAPI.start();}})();"
		)
	else:
		_js_eval(
			"(function(){var y=window.ysdk;"
			+ "if(y&&y.features&&y.features.GameplayAPI&&y.features.GameplayAPI.stop){"
			+ "y.features.GameplayAPI.stop();}})();"
		)


func _bind_pause_resume() -> void:
	if _events_bound:
		return
	var window: Variant = _js_window()
	if window == null:
		_focus_fallback = true
		return
	var on_pause: Variant = _keep_callback(_on_js_pause)
	var on_resume: Variant = _keep_callback(_on_js_resume)
	window.__godbombOnPause = on_pause
	window.__godbombOnResume = on_resume
	var bound := bool(_js_eval(
		"(function(){var y=window.ysdk;if(!y||!y.on)return false;"
		+ "y.on('game_api_pause',window.__godbombOnPause);"
		+ "y.on('game_api_resume',window.__godbombOnResume);return true;})();"
	))
	_events_bound = bound
	_focus_fallback = not bound


func _on_js_pause(_args: Array) -> void:
	_apply_platform_pause(true)


func _on_js_resume(_args: Array) -> void:
	_apply_platform_pause(false)


func _on_js_ad_closed(args: Array) -> void:
	var shown := false
	if args.size() > 0:
		shown = bool(args[0])
	_ad_js_closed.emit(shown)


func _apply_platform_pause(paused: bool) -> void:
	if is_platform_paused == paused:
		return
	is_platform_paused = paused
	_set_audio_muted(paused)
	var game_manager := _find_game_manager()
	if paused:
		if game_manager and game_manager.has_method("set_paused"):
			game_manager.call("set_paused", true)
			_paused_by_platform = true
	elif _paused_by_platform:
		_paused_by_platform = false
		if game_manager and game_manager.has_method("set_paused") and not _is_emergency(game_manager):
			game_manager.call("set_paused", false)
	_sync_gameplay_api()
	platform_pause_changed.emit(paused)


func _await_ad_result() -> bool:
	var state := {"done": false, "shown": false}
	var on_js := func(was_shown: bool) -> void:
		if state["done"]:
			return
		state["done"] = true
		state["shown"] = was_shown
	_ad_js_closed.connect(on_js, CONNECT_ONE_SHOT)
	var tree := get_tree()
	if tree:
		var timer := tree.create_timer(AD_TIMEOUT_SEC)
		timer.timeout.connect(func() -> void:
			if state["done"]:
				return
			state["done"] = true
			state["shown"] = false
		, CONNECT_ONE_SHOT)
	while not state["done"]:
		if tree:
			await tree.process_frame
		else:
			break
	if _ad_js_closed.is_connected(on_js):
		_ad_js_closed.disconnect(on_js)
	return bool(state["shown"])


func _set_audio_muted(muted: bool) -> void:
	if audio and audio.has_method("set_platform_muted"):
		audio.call("set_platform_muted", muted)


func _find_game_manager() -> Node:
	var main := get_parent()
	if main == null:
		return null
	var ctx: Variant = main.get("current_context")
	if ctx == null:
		return null
	var game_manager: Variant = ctx.get("game_manager")
	if game_manager is Node:
		return game_manager
	return null


func _is_emergency(game_manager: Node) -> bool:
	if game_manager == null:
		return false
	var fsm: Variant = game_manager.get("fsm")
	if fsm == null or not fsm.has_method("get_current_state_name"):
		return false
	return str(fsm.get_current_state_name()) == "emergency"


func _keep_callback(method: Callable) -> Variant:
	if not _has_js():
		return null
	var callback: Variant = JavaScriptBridge.create_callback(method)
	_js_callbacks.append(callback)
	return callback


func _js_window() -> Variant:
	if not _has_js():
		return null
	return JavaScriptBridge.get_interface("window")


func _js_eval(code: String) -> Variant:
	if not _has_js():
		return null
	return JavaScriptBridge.eval(code, true)


func _is_web() -> bool:
	return OS.has_feature("web")


func _has_js() -> bool:
	return _is_web() and ClassDB.class_exists("JavaScriptBridge")
