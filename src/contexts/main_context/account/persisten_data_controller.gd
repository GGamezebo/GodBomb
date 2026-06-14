class_name PersistentDataController
extends Node

const PERSISTENCE_GROUP := "account_persistence"

@export var account: PDataAccount
@export var account_default: PDataAccount


func _ready() -> void:
	add_to_group(PERSISTENCE_GROUP)
	_load_account()


func _exit_tree() -> void:
	save_account()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_account()


func save_account() -> void:
	if not account:
		return
	account.data["version"] = PDataAccount.CURRENT_VERSION
	account.emit_changed()
	ResourceUtils.save_resource_to_disk(account, PDataAccount.SAVE_PATH)


func _load_account() -> void:
	if ResourceLoader.exists(PDataAccount.SAVE_PATH):
		var saved_res: PDataAccount = ResourceLoader.load(PDataAccount.SAVE_PATH)
		if saved_res:
			ResourceUtils.update_resource(account, saved_res)
			return

	if account_default:
		ResourceUtils.update_resource(account, account_default)

	save_account()
