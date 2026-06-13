extends Node

@export var account: PDataAccount
@export var account_default: PDataAccount
@export var game_config: GameConfig


func _ready() -> void:
	_load_account()


func save_account() -> void:
	account.data["version"] = PDataAccount.CURRENT_VERSION
	ResourceUtils.save_resource_to_disk(account, PDataAccount.SAVE_PATH)


func _load_account() -> void:
	if ResourceLoader.exists(PDataAccount.SAVE_PATH):
		var saved_res: PDataAccount = ResourceLoader.load(PDataAccount.SAVE_PATH)
		if saved_res:
			ResourceUtils.update_resource(account, saved_res)
			print("Account loaded from ", PDataAccount.SAVE_PATH)
			return

	if OS.has_feature("editor") and game_config and account.get_players().is_empty():
		var players: Array = []
		var defaults: Array = [
			["Игрок 1", 0], ["Игрок 2", 1], ["Игрок 3", 2], ["Игрок 4", 3],
		]
		for entry in defaults:
			players.append(account.dict_from_player_info(PlayerInfo.new(entry[0], entry[1])))
		account.set_players(players)

	if OS.has_feature("editor") and game_config and not game_config.dev_players.is_empty():
		var players: Array = []
		for info in game_config.dev_players:
			players.append(account.dict_from_player_info(info))
		account.set_players(players)

	save_account()
