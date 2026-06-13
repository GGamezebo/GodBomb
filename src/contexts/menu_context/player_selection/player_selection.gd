extends Control

@export var account: PDataAccount
@export var pdata_controller: Node
@export var game_config: GameConfig
@export var menu_events: MenuEvents
@export var player_list: ItemList
@export var name_edit: LineEdit
@export var preset_option: OptionButton
@export var game_time_slider: HSlider
@export var game_time_label: Label
@export var start_button: Button

var listener: EventListener = EventListener.new()
var _selected_index: int = -1


func _ready() -> void:
	_setup_preset_options()
	_load_from_account()
	_connect_ui()
	listener.add(menu_events.ev_player_added, _on_players_changed)
	listener.add(menu_events.ev_player_removed, _on_players_changed_untyped)
	listener.add(menu_events.ev_player_modified, _on_players_changed_untyped)
	listener.add(menu_events.ev_player_swapped, _on_players_swapped)


func _exit_tree() -> void:
	listener.deinit()


func reload_from_account() -> void:
	_load_from_account()


func _connect_ui() -> void:
	if player_list:
		player_list.item_selected.connect(_on_player_selected)
	var add_btn := get_node_or_null("%AddPlayerButton") as Button
	if add_btn:
		add_btn.pressed.connect(_on_add_player_pressed)
	var remove_btn := get_node_or_null("%RemovePlayerButton") as Button
	if remove_btn:
		remove_btn.pressed.connect(_on_remove_player_pressed)
	var save_btn := get_node_or_null("%SavePlayerButton") as Button
	if save_btn:
		save_btn.pressed.connect(_on_save_player_pressed)
	if game_time_slider:
		game_time_slider.value_changed.connect(_on_game_time_changed)


func _setup_preset_options() -> void:
	if not preset_option:
		return
	preset_option.clear()
	for i in game_config.max_players:
		preset_option.add_item("Слайм %d" % (i + 1), i)


func _load_from_account() -> void:
	if game_time_slider:
		game_time_slider.min_value = 1
		game_time_slider.max_value = 30
		game_time_slider.value = account.get_game_time_minutes()
		_update_game_time_label(int(game_time_slider.value))
	_refresh_player_list()
	_update_start_button()


func _refresh_player_list() -> void:
	if not player_list:
		return
	player_list.clear()
	for entry in account.get_players():
		var info := account.player_info_from_dict(entry)
		player_list.add_item("%s (слайм %d)" % [info.name, info.preset_id + 1])


func _update_start_button() -> void:
	if start_button:
		start_button.disabled = account.get_players().size() < game_config.min_players


func _save_account() -> void:
	if pdata_controller and pdata_controller.has_method("save_account"):
		pdata_controller.save_account()


func _on_player_selected(index: int) -> void:
	_selected_index = index
	var players := account.get_players()
	if index < 0 or index >= players.size():
		return
	var info := account.player_info_from_dict(players[index])
	if name_edit:
		name_edit.text = info.name
	if preset_option:
		preset_option.select(info.preset_id)


func _on_add_player_pressed() -> void:
	var players := account.get_players()
	if players.size() >= game_config.max_players:
		return
	var name := name_edit.text.strip_edges() if name_edit else ""
	if name.is_empty():
		name = "Игрок %d" % (players.size() + 1)
	var preset_id := preset_option.selected if preset_option else players.size() % game_config.max_players
	var info := PlayerInfo.new(name, preset_id)
	players.append(account.dict_from_player_info(info))
	account.set_players(players)
	menu_events.ev_player_added.emit(info)
	_refresh_player_list()
	_save_account()
	_update_start_button()


func _on_remove_player_pressed() -> void:
	if _selected_index < 0:
		return
	var players := account.get_players()
	if _selected_index >= players.size():
		return
	var info := account.player_info_from_dict(players[_selected_index])
	players.remove_at(_selected_index)
	account.set_players(players)
	menu_events.ev_player_removed.emit(info, _selected_index)
	_selected_index = -1
	_refresh_player_list()
	_save_account()
	_update_start_button()


func _on_save_player_pressed() -> void:
	if _selected_index < 0:
		return
	var players := account.get_players()
	if _selected_index >= players.size():
		return
	var name := name_edit.text.strip_edges() if name_edit else ""
	if name.is_empty():
		return
	var preset_id := preset_option.selected if preset_option else 0
	var info := PlayerInfo.new(name, preset_id)
	players[_selected_index] = account.dict_from_player_info(info)
	account.set_players(players)
	menu_events.ev_player_modified.emit(info, _selected_index)
	_refresh_player_list()
	_save_account()


func _on_game_time_changed(value: float) -> void:
	var minutes := int(value)
	account.set_game_time_minutes(minutes)
	_update_game_time_label(minutes)
	menu_events.ev_game_time_changed.emit(minutes)
	_save_account()


func _update_game_time_label(minutes: int) -> void:
	if game_time_label:
		game_time_label.text = "Длительность: %d мин" % minutes


func _on_players_changed(_info: PlayerInfo) -> void:
	_update_start_button()


func _on_players_changed_untyped(_a = null, _b = null) -> void:
	_update_start_button()


func _on_players_swapped(_a: int, _b: int) -> void:
	_refresh_player_list()
