class_name SettingsWindow
extends Control

@export var account: PDataAccount
@export var pdata_controller: Node
@export var menu_events: MenuEvents
@export var player_selection_widget: PlayerSelectionWidget
@export var game_time_slider: HSlider
@export var game_time_label: Label
@export var music_check: CheckBox
@export var music_slider: HSlider
@export var music_value_label: Label
@export var sfx_slider: HSlider
@export var sfx_value_label: Label
@export var reset_button: Button
@export var close_button: Button

var _awaiting_reset_confirm: bool = false


func _ready() -> void:
	visible = false
	if game_time_slider:
		game_time_slider.value_changed.connect(_on_game_time_changed)
	if music_check:
		music_check.toggled.connect(_on_music_toggled)
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	if close_button:
		close_button.pressed.connect(close)
	call_deferred("_update_modal_layer_visibility")


func open() -> void:
	_awaiting_reset_confirm = false
	if reset_button:
		reset_button.text = "Сбросить прогресс"
	_sync_from_account()
	if account and not account.changed.is_connected(_sync_from_account):
		account.changed.connect(_sync_from_account)
	visible = true
	_show_modal_layer()


func close() -> void:
	visible = false
	_update_modal_layer_visibility()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _sync_from_account() -> void:
	if not account:
		return
	if game_time_slider:
		game_time_slider.min_value = 1
		game_time_slider.max_value = 30
		game_time_slider.value = account.get_game_time_minutes()
		_update_game_time_label(int(game_time_slider.value))
	if music_check:
		music_check.button_pressed = account.get_music_enabled()
	if music_slider:
		music_slider.value = account.get_music_volume() * 100.0
		_update_music_label(account.get_music_volume())
	if sfx_slider:
		sfx_slider.value = account.get_sfx_volume() * 100.0
		_update_sfx_label(account.get_sfx_volume())


func _on_game_time_changed(value: float) -> void:
	if not account:
		return
	var minutes := int(value)
	account.set_game_time_minutes(minutes)
	_update_game_time_label(minutes)
	if menu_events:
		menu_events.ev_game_time_changed.emit(minutes)
	_save_account()


func _on_music_toggled(enabled: bool) -> void:
	var audio := _get_audio_controller()
	if audio:
		audio.set_music_enabled(enabled)
	_save_account()


func _on_music_volume_changed(value: float) -> void:
	var linear := clampf(value / 100.0, 0.0, 1.0)
	var audio := _get_audio_controller()
	if audio:
		audio.set_music_volume(linear)
	_update_music_label(linear)
	_save_account()


func _on_sfx_volume_changed(value: float) -> void:
	var linear := clampf(value / 100.0, 0.0, 1.0)
	var audio := _get_audio_controller()
	if audio:
		audio.set_sfx_volume(linear)
	_update_sfx_label(linear)
	_save_account()


func _on_reset_pressed() -> void:
	if not account:
		return
	if not _awaiting_reset_confirm:
		_awaiting_reset_confirm = true
		if reset_button:
			reset_button.text = "Точно сбросить?"
		return
	_awaiting_reset_confirm = false
	if reset_button:
		reset_button.text = "Сбросить прогресс"
	account.reset_progress()
	_save_account()
	if player_selection_widget:
		player_selection_widget.reload_from_account()


func _update_game_time_label(minutes: int) -> void:
	if game_time_label:
		game_time_label.text = "Длительность партии: %d мин" % minutes


func _update_music_label(linear: float) -> void:
	if music_value_label:
		music_value_label.text = "%d%%" % int(round(linear * 100.0))


func _update_sfx_label(linear: float) -> void:
	if sfx_value_label:
		sfx_value_label.text = "%d%%" % int(round(linear * 100.0))


func _get_audio_controller() -> GameAudioController:
	return get_tree().get_first_node_in_group(GameAudioController.GROUP) as GameAudioController


func _save_account() -> void:
	var controller := pdata_controller
	if not controller:
		controller = get_tree().get_first_node_in_group(PersistentDataController.PERSISTENCE_GROUP)
	if controller and controller.has_method("save_account"):
		controller.save_account()


func _show_modal_layer() -> void:
	if get_parent() is CanvasLayer:
		(get_parent() as CanvasLayer).visible = true


func _update_modal_layer_visibility() -> void:
	var layer := get_parent() as CanvasLayer
	if not layer:
		return
	for child in layer.get_children():
		if child is Control and child.visible:
			layer.visible = true
			return
	layer.visible = false
