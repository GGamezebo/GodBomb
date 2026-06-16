class_name Haptics
extends RefCounted

static func vibrate(duration_ms: int, account: PDataAccount = null) -> void:
	if duration_ms <= 0:
		return
	var acc := account if account else _resolve_account()
	if acc and not acc.get_haptics_enabled():
		return
	if not _platform_supports():
		return
	Input.vibrate_handheld(duration_ms)


static func vibrate_ambient(account: PDataAccount = null) -> void:
	vibrate(24, account)


static func vibrate_alert_tick(account: PDataAccount = null) -> void:
	vibrate(50, account)


static func vibrate_strong(account: PDataAccount = null) -> void:
	vibrate(170, account)


static func vibrate_battle_start(account: PDataAccount = null) -> void:
	vibrate(220, account)


static func vibrate_lobby_action(account: PDataAccount = null) -> void:
	vibrate(115, account)


static func vibrate_hold_progress(progress: float, account: PDataAccount = null) -> void:
	var clamped := clampf(progress, 0.0, 1.0)
	var duration := int(lerpf(16.0, 42.0, clamped))
	vibrate(duration, account)


static func _resolve_account() -> PDataAccount:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var controllers := tree.get_nodes_in_group(PersistentDataController.PERSISTENCE_GROUP)
	if controllers.is_empty():
		return null
	var controller := controllers[0] as PersistentDataController
	return controller.account if controller else null


static func _platform_supports() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
