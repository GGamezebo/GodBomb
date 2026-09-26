class_name YandexBackend
extends PlatformBackend

## Yandex Games (export feature `yandex`). Talks to the `YandexGames` autoload.

var _ready_sent: bool = false


func get_id() -> String:
	return "yandex"


## Yandex moderation forbids external links; the portal shows its own policy.
func privacy_policy_url() -> String:
	return ""


func _yg() -> Node:
	if host == null:
		return null
	return host.get_node_or_null("/root/YandexGames")


func boot() -> void:
	var yg := _yg()
	if yg == null:
		push_warning("YandexBackend: YandexGames autoload missing")
		return
	if yg.has_signal("sdk_initialized") and not yg.sdk_initialized.is_connected(_on_sdk_initialized):
		yg.sdk_initialized.connect(_on_sdk_initialized)
	if yg.has_signal("history_back_requested") and host.has_method("_on_history_back"):
		if not yg.history_back_requested.is_connected(host._on_history_back):
			yg.history_back_requested.connect(host._on_history_back)
	if yg.has_method("ensure_initialized"):
		var ok: bool = await yg.ensure_initialized()
		if ok:
			_on_sdk_initialized({})
	else:
		_notify_game_ready()


func _on_sdk_initialized(_data: Dictionary = {}) -> void:
	_sync_locale_from_sdk()
	_notify_game_ready()


func _sync_locale_from_sdk() -> void:
	## Requirement 2.14: apply environment.i18n.lang at startup, before gameplay.
	var yg := _yg()
	if yg == null or not ("environment" in yg):
		return
	var lang: String = ""
	if yg.environment and yg.environment.has_method("get_lang"):
		lang = str(yg.environment.get_lang())
	if lang.is_empty():
		return
	if LocaleService:
		LocaleService.set_locale(lang, true)


func _notify_game_ready() -> void:
	if _ready_sent:
		return
	var yg := _yg()
	if yg == null or not yg.has_method("game_ready"):
		return
	yg.game_ready()
	_ready_sent = true


func set_gameplay_active(active: bool) -> void:
	var yg := _yg()
	if yg == null:
		return
	if active and yg.has_method("gameplay_start"):
		yg.gameplay_start()
	elif not active and yg.has_method("gameplay_stop"):
		yg.gameplay_stop()


func on_match_finished_return_to_menu() -> void:
	var yg := _yg()
	if yg == null or not ("ads" in yg):
		return
	if yg.ads and yg.ads.has_method("show_interstitial_if_available"):
		await yg.ads.show_interstitial_if_available()
	elif yg.has_method("show_interstitial"):
		await yg.show_interstitial()
