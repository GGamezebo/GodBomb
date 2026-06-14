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
