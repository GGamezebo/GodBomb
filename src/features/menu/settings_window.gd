class_name SettingsWindow
extends Control

@export var account: PDataAccount
@export var pdata_controller: Node
@export var menu_events: MenuEvents
@export var player_selection_widget: PlayerSelectionWidget
@export var language_option: OptionButton
@export var game_time_slider: HSlider
@export var game_time_label: Label
@export var music_check: CheckBox
@export var music_slider: HSlider
@export var music_value_label: Label
@export var sfx_slider: HSlider
@export var sfx_value_label: Label
@export var haptics_check: CheckBox
@export var haptics_slider: HSlider
@export var haptics_value_label: Label
@export var reset_button: StartActionButton
@export var close_button: StartActionButton
@export var game_config: GameConfig

const SLIDER_GRABBER_INSET := 26.0

var _awaiting_reset_confirm: bool = false


func _ready() -> void:
	visible = false
	_setup_language_option()
	if not LocaleService.locale_changed.is_connected(_on_locale_changed):
		LocaleService.locale_changed.connect(_on_locale_changed)
	if game_time_slider:
		game_time_slider.value_changed.connect(_on_game_time_changed)
		UiSounds.bind_slider(game_time_slider, 1.0)
		_configure_game_time_slider()
	if music_check:
		music_check.toggled.connect(_on_music_toggled)
		UiSounds.bind_checkbox(music_check)
	if music_slider:
		music_slider.value_changed.connect(_on_music_volume_changed)
		UiSounds.bind_slider(music_slider, 5.0)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
		UiSounds.bind_slider(sfx_slider, 5.0)
	if haptics_check:
		haptics_check.toggled.connect(_on_haptics_toggled)
		UiSounds.bind_checkbox(haptics_check)
	if haptics_slider:
		haptics_slider.value_changed.connect(_on_haptics_strength_changed)
		UiSounds.bind_slider(haptics_slider, 5.0)
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
		UiSounds.bind_button(reset_button)
	if close_button:
		close_button.pressed.connect(close)
		UiSounds.bind_button(close_button)
	call_deferred("_update_modal_layer_visibility")
	_refresh_static_labels()


func _setup_language_option() -> void:
	if language_option == null:
		return
	language_option.clear()
	for i in LocaleCatalog.ORDER.size():
		var code := LocaleCatalog.ORDER[i]
		language_option.add_item(LocaleCatalog.native_name(code), i)
	if not language_option.item_selected.is_connected(_on_language_selected):
		language_option.item_selected.connect(_on_language_selected)


func _on_locale_changed(_locale: String) -> void:
	_setup_language_option()
	_refresh_static_labels()
	_sync_language_option()


func _refresh_static_labels() -> void:
	var title := get_node_or_null("Panel/Margin/VBox/Title") as Label
	if title:
		title.text = LocaleService.text("SETTINGS_TITLE")
	var language_caption := get_node_or_null(
		"Panel/Margin/VBox/Scroll/Content/LanguageRow/LanguageCaption"
	) as Label
	if language_caption:
		language_caption.text = LocaleService.text("SETTINGS_LANGUAGE")
	if music_check:
		music_check.text = LocaleService.text("SETTINGS_MUSIC_MENU")
	var music_caption := get_node_or_null(
		"Panel/Margin/VBox/Scroll/Content/MusicRow/MusicCaption"
	) as Label
	if music_caption:
		music_caption.text = LocaleService.text("SETTINGS_MUSIC_VOLUME")
	var sfx_caption := get_node_or_null(
		"Panel/Margin/VBox/Scroll/Content/SfxRow/SfxCaption"
	) as Label
	if sfx_caption:
		sfx_caption.text = LocaleService.text("SETTINGS_SFX_VOLUME")
	if haptics_check:
		haptics_check.text = LocaleService.text("SETTINGS_HAPTICS")
	var haptics_caption := get_node_or_null(
		"Panel/Margin/VBox/Scroll/Content/HapticsRow/HapticsCaption"
	) as Label
	if haptics_caption:
		haptics_caption.text = LocaleService.text("SETTINGS_HAPTICS_STRENGTH")
	var reset_hint := get_node_or_null("Panel/Margin/VBox/Scroll/Content/ResetHint") as Label
	if reset_hint:
		reset_hint.text = LocaleService.text("SETTINGS_RESET_HINT")
	if close_button:
		close_button.action_text = LocaleService.text("SETTINGS_CLOSE")
	if reset_button and not _awaiting_reset_confirm:
		reset_button.text = LocaleService.text("SETTINGS_RESET")
	if game_time_slider:
		_update_game_time_label(int(game_time_slider.value))


func _sync_language_option() -> void:
	if language_option == null or account == null:
		return
	var idx := LocaleCatalog.ORDER.find(LocaleCatalog.normalize(account.get_language()))
	if idx < 0:
		idx = 0
	if language_option.selected != idx:
		language_option.set_block_signals(true)
		language_option.select(idx)
		language_option.set_block_signals(false)


func _on_language_selected(index: int) -> void:
	if index < 0 or index >= LocaleCatalog.ORDER.size():
		return
	var code := LocaleCatalog.ORDER[index]
	if LocaleService.get_locale() == code:
		return
	LocaleService.set_locale(code, true)
	if game_config:
		LocaleService.apply_cards_to(game_config)
	_save_account()
	if player_selection_widget:
		player_selection_widget.reload_from_account()


func _configure_game_time_slider() -> void:
	if game_time_slider == null:
		return
	game_time_slider.clip_contents = false
	var row := game_time_slider.get_parent() as Control
	if row:
		row.clip_contents = false
	var scroll := _find_scroll_container(game_time_slider)
	if scroll:
		scroll.clip_contents = false
	for style_name in ["slider", "grabber_area", "grabber_area_highlight"]:
		var style := game_time_slider.get_theme_stylebox(style_name, &"HSlider")
		if style is StyleBoxFlat:
			var tuned := style.duplicate() as StyleBoxFlat
			tuned.content_margin_left = SLIDER_GRABBER_INSET
			tuned.content_margin_right = SLIDER_GRABBER_INSET
			game_time_slider.add_theme_stylebox_override(style_name, tuned)


func _find_scroll_container(from: Node) -> ScrollContainer:
	var node: Node = from
	while node:
		if node is ScrollContainer:
			return node as ScrollContainer
		node = node.get_parent()
	return null


func open() -> void:
	_awaiting_reset_confirm = false
	if reset_button:
		reset_button.text = LocaleService.text("SETTINGS_RESET")
	_sync_language_option()
	_refresh_static_labels()
	_sync_from_account()
	if account and not account.changed.is_connected(_sync_from_account):
		account.changed.connect(_sync_from_account)
	visible = true
	_show_modal_layer()
	UiSounds.play_modal_open()


func close() -> void:
	visible = false
	_update_modal_layer_visibility()
	UiSounds.play_modal_close()


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
	if haptics_check:
		haptics_check.button_pressed = account.get_haptics_enabled()
	if haptics_slider:
		haptics_slider.value = account.get_haptics_strength() * 100.0
		_update_haptics_label(account.get_haptics_strength())
	_update_haptics_controls_enabled()


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


func _on_haptics_toggled(enabled: bool) -> void:
	if account:
		account.set_haptics_enabled(enabled)
	_update_haptics_controls_enabled()
	_save_account()


func _on_haptics_strength_changed(value: float) -> void:
	if not account:
		return
	var linear := clampf(value / 100.0, 0.0, 1.0)
	account.set_haptics_strength(linear)
	_update_haptics_label(linear)
	if account.get_haptics_enabled() and linear > 0.0:
		Haptics.preview_strength(account)
	_save_account()


func _on_reset_pressed() -> void:
	if not account:
		return
	if not _awaiting_reset_confirm:
		_awaiting_reset_confirm = true
		if reset_button:
			reset_button.text = LocaleService.text("SETTINGS_RESET_CONFIRM")
		return
	_awaiting_reset_confirm = false
	if reset_button:
		reset_button.text = LocaleService.text("SETTINGS_RESET")
	account.reset_progress()
	UiSounds.play_confirm()
	_sync_from_account()
	if menu_events:
		menu_events.ev_game_time_changed.emit(account.get_game_time_minutes())
	var audio := _get_audio_controller()
	if audio:
		audio.set_music_enabled(account.get_music_enabled())
		audio.set_music_volume(account.get_music_volume())
		audio.set_sfx_volume(account.get_sfx_volume())
	_save_account()
	if player_selection_widget:
		player_selection_widget.reload_from_account()


func _update_game_time_label(minutes: int) -> void:
	if game_time_label:
		game_time_label.text = LocaleService.text("SETTINGS_GAME_TIME") % minutes


func _update_music_label(linear: float) -> void:
	if music_value_label:
		music_value_label.text = "%d%%" % int(round(linear * 100.0))


func _update_sfx_label(linear: float) -> void:
	if sfx_value_label:
		sfx_value_label.text = "%d%%" % int(round(linear * 100.0))


func _update_haptics_label(linear: float) -> void:
	if haptics_value_label:
		haptics_value_label.text = "%d%%" % int(round(linear * 100.0))


func _update_haptics_controls_enabled() -> void:
	var enabled := account != null and account.get_haptics_enabled()
	if haptics_slider:
		haptics_slider.editable = enabled
		haptics_slider.modulate = Color.WHITE if enabled else Color(0.72, 0.72, 0.72, 1.0)
	if haptics_value_label:
		haptics_value_label.modulate = Color.WHITE if enabled else Color(0.72, 0.72, 0.72, 1.0)


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
