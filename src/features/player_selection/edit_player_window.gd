class_name EditPlayerWindow
extends Control

signal player_added(player_name: String, preset_id: int)
signal player_applied(index: int, player_name: String, preset_id: int)

const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"
const SWATCH_SIZE := 120
const NAME_CHIP_HEIGHT := 84
const NAME_CHIP_FONT_SIZE := 48
const GRID_SEPARATION := 18
const NAME_CHIP_CORNER_RADIUS := 30
const NAME_CHIP_MARGIN_H := 27
const NAME_CHIP_MARGIN_V := 15
const LOCK_FONT_SIZE := 66

@export var account: PDataAccount
@export var name_edit: LineEdit
@export var name_history_grid: GridContainer
@export var slime_preview: TextureRect
@export var ok_button: PillStretchButton
@export var apply_button: PillStretchButton
@export var cancel_button: PillStretchButton
@export var colors_grid: GridContainer
@export var preset_storage: PlayerPresetStorage
@export var game_config: GameConfig

var _player_index: int = -1
var _editable_preset_id: int = -1
var _selected_preset_id: int = 0
var _color_buttons: Array[Button] = []
var _lock_labels: Array[Label] = []


func _ready() -> void:
	visible = false
	if get_parent() is CanvasLayer:
		(get_parent() as CanvasLayer).visible = false
	if ok_button:
		ok_button.pressed.connect(_on_ok_pressed)
	if apply_button:
		apply_button.pressed.connect(_on_apply_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	if name_edit:
		name_edit.max_length = PlayerInfo.MAX_NAME_LENGTH
		name_edit.text_changed.connect(_on_name_changed)
		name_edit.text_submitted.connect(_on_name_submitted)
	resized.connect(_sync_action_button_sizes)
	call_deferred("_sync_action_button_sizes")
	_build_color_buttons()


func _sync_action_button_sizes() -> void:
	var viewport_size := get_viewport_rect().size
	if cancel_button:
		cancel_button.apply_scaled_action_size(viewport_size, true)
	if ok_button:
		ok_button.apply_scaled_action_size(viewport_size, true)
	if apply_button:
		apply_button.apply_scaled_action_size(viewport_size, true)


func open_add_window() -> void:
	_player_index = -1
	_editable_preset_id = -1
	if ok_button:
		ok_button.visible = true
	if apply_button:
		apply_button.visible = false
	_open_window()
	_set_name_field(_pick_default_history_name(), false)
	_select_first_available_preset()
	_refresh_name_history()
	_sync_confirm_buttons()


func open_edit_window(index: int, player_name: String, preset_id: int) -> void:
	_player_index = index
	_editable_preset_id = preset_id
	if ok_button:
		ok_button.visible = false
	if apply_button:
		apply_button.visible = true
	_open_window()
	_set_name_field(player_name, false)
	_select_first_available_preset()
	_refresh_name_history()
	_sync_confirm_buttons()


func _open_window() -> void:
	_sync_action_button_sizes()
	visible = true
	z_index = 1
	if get_parent() is CanvasLayer:
		(get_parent() as CanvasLayer).visible = true
	UiSounds.play_modal_open()
	_refresh_all_swatches()
	_sort_color_grid()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		if key_event.keycode == KEY_ESCAPE:
			_on_cancel_pressed()
			get_viewport().set_input_as_handled()
		elif key_event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			if _try_confirm():
				get_viewport().set_input_as_handled()


func _on_name_submitted(_text: String) -> void:
	_try_confirm()


func _refresh_name_history() -> void:
	if not name_history_grid:
		return
	for child in name_history_grid.get_children():
		child.queue_free()
	if not account:
		return

	var chip_style := StyleBoxFlat.new()
	chip_style.bg_color = Color(0.16, 0.13, 0.11, 1)
	chip_style.border_color = Color(0.42, 0.34, 0.27, 1)
	chip_style.set_border_width_all(2)
	chip_style.set_corner_radius_all(NAME_CHIP_CORNER_RADIUS)
	chip_style.content_margin_left = NAME_CHIP_MARGIN_H
	chip_style.content_margin_right = NAME_CHIP_MARGIN_H
	chip_style.content_margin_top = NAME_CHIP_MARGIN_V
	chip_style.content_margin_bottom = NAME_CHIP_MARGIN_V

	var selected_style := chip_style.duplicate()
	selected_style.border_color = Color(1.0, 0.72, 0.35, 1.0)
	selected_style.set_border_width_all(6)

	var current_name := _get_name_field_text()

	for player_name in account.get_recent_names_for_display():
		var btn := Button.new()
		btn.text = player_name
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(0, NAME_CHIP_HEIGHT)
		btn.theme_type_variation = &"ModalButton"
		btn.add_theme_font_size_override("font_size", NAME_CHIP_FONT_SIZE)
		btn.add_theme_color_override("font_color", Color(0.96, 0.91, 0.84, 1))
		var is_selected := player_name == current_name
		var btn_style := selected_style.duplicate() if is_selected else chip_style.duplicate()
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_stylebox_override("hover", btn_style.duplicate())
		btn.add_theme_stylebox_override("pressed", btn_style.duplicate())
		btn.pressed.connect(_on_history_name_pressed.bind(player_name))
		name_history_grid.add_child(btn)


func _on_history_name_pressed(player_name: String) -> void:
	_set_name_field(player_name, false)
	_refresh_name_history()
	_sync_confirm_buttons()


func _build_color_buttons() -> void:
	if not colors_grid or not game_config:
		return
	for child in colors_grid.get_children():
		child.queue_free()
	_color_buttons.clear()
	_lock_labels.clear()

	for i in game_config.max_players:
		var cell := VBoxContainer.new()
		cell.custom_minimum_size = Vector2(SWATCH_SIZE, SWATCH_SIZE)
		colors_grid.add_child(cell)

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(SWATCH_SIZE, SWATCH_SIZE)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_color_pressed.bind(i))
		cell.add_child(btn)
		_color_buttons.append(btn)

		var lock := Label.new()
		lock.text = "✕"
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lock.add_theme_font_size_override("font_size", LOCK_FONT_SIZE)
		lock.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock.visible = false
		btn.add_child(lock)
		_lock_labels.append(lock)

	_refresh_all_swatches()


func _get_preset_holder(preset_id: int) -> String:
	if not account:
		return ""
	for i in account.get_players().size():
		if _player_index >= 0 and i == _player_index:
			continue
		var entry: Dictionary = account.get_players()[i]
		if int(entry.get("preset_id", 0)) == preset_id:
			return str(entry.get("name", ""))
	return ""


func _is_preset_held(preset_id: int) -> bool:
	return not _get_preset_holder(preset_id).is_empty()


func _make_swatch_style(preset_id: int, selected: bool, held: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(int(SWATCH_SIZE * 0.5))
	var color := SlimeColors.get_color(preset_id)
	if held:
		color = color.darkened(0.35)
		color.a = 0.45
	style.bg_color = color
	var border := 9 if selected else 5
	style.set_border_width_all(border)
	style.border_color = Color.WHITE if selected else Color("#2A2118")
	style.shadow_size = 6 if selected else 3
	style.shadow_color = Color(0, 0, 0, 0.25)
	return style


func _refresh_all_swatches() -> void:
	for i in _color_buttons.size():
		_apply_swatch(i)


func _apply_swatch(preset_id: int) -> void:
	if preset_id < 0 or preset_id >= _color_buttons.size():
		return
	var btn := _color_buttons[preset_id]
	var holder_name := _get_preset_holder(preset_id)
	var held := not holder_name.is_empty()
	var selected := preset_id == _selected_preset_id and not held
	var style := _make_swatch_style(preset_id, selected, held)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style.duplicate())
	btn.add_theme_stylebox_override("pressed", style.duplicate())
	btn.add_theme_stylebox_override("disabled", style.duplicate())
	btn.disabled = held
	btn.button_pressed = selected
	btn.tooltip_text = SlimeColors.get_color_name(preset_id)
	if preset_id < _lock_labels.size():
		_lock_labels[preset_id].visible = held


func _sort_color_grid() -> void:
	if not colors_grid:
		return
	var free_ids: Array[int] = []
	var held_ids: Array[int] = []
	for preset_id in _color_buttons.size():
		if _is_preset_held(preset_id):
			held_ids.append(preset_id)
		else:
			free_ids.append(preset_id)

	var ordered := free_ids + held_ids
	var cells: Array[Node] = []
	for preset_id in ordered:
		cells.append(_color_buttons[preset_id].get_parent())

	for cell in cells:
		colors_grid.remove_child(cell)
	for cell in cells:
		colors_grid.add_child(cell)


func _select_first_available_preset() -> void:
	for i in _color_buttons.size():
		if not _is_preset_held(i):
			_select_preset(i)
			return


func _select_preset(preset_id: int) -> void:
	if _is_preset_held(preset_id):
		return
	_selected_preset_id = preset_id
	_refresh_all_swatches()
	if slime_preview:
		slime_preview.texture = load(SLIME_PATH % preset_id)


func _on_color_pressed(preset_id: int) -> void:
	if _is_preset_held(preset_id):
		return
	UiSounds.play_click()
	_select_preset(preset_id)


func _on_name_changed(_text: String) -> void:
	_refresh_name_history()
	_sync_confirm_buttons()


func _set_name_field(player_name: String, grab_focus: bool) -> void:
	if not name_edit:
		return
	var safe_name := PlayerInfo.sanitize_name(player_name)
	name_edit.text = safe_name
	name_edit.caret_column = safe_name.length()
	if grab_focus:
		name_edit.grab_focus()
	else:
		name_edit.release_focus()


func _get_name_field_text() -> String:
	if not name_edit:
		return ""
	return PlayerInfo.sanitize_name(name_edit.text)


func _sync_confirm_buttons() -> void:
	var has_name := not _read_player_name().is_empty()
	var color_taken := _is_preset_held(_selected_preset_id)
	var can_confirm := has_name and not color_taken
	if ok_button:
		ok_button.disabled = not can_confirm
	if apply_button:
		apply_button.disabled = not can_confirm


func _pick_default_history_name() -> String:
	if not account:
		return ""
	var names := account.get_recent_names_for_display()
	if names.is_empty():
		return ""
	return names[0]


func _try_confirm() -> bool:
	if _is_preset_held(_selected_preset_id):
		return false
	if ok_button and ok_button.visible and not ok_button.disabled:
		_on_ok_pressed()
		return true
	if apply_button and apply_button.visible and not apply_button.disabled:
		_on_apply_pressed()
		return true
	return false


func _close_window(play_close_sound: bool = false) -> void:
	visible = false
	if get_parent() is CanvasLayer:
		(get_parent() as CanvasLayer).visible = false
	if play_close_sound:
		UiSounds.play_modal_close()


func _on_ok_pressed() -> void:
	var player_name := _read_player_name()
	if player_name.is_empty() or _is_preset_held(_selected_preset_id):
		return
	_consume_history_name_if_needed(player_name)
	UiSounds.play_confirm()
	_close_window(false)
	player_added.emit(player_name, _selected_preset_id)


func _on_apply_pressed() -> void:
	var player_name := _read_player_name()
	if player_name.is_empty() or _player_index < 0 or _is_preset_held(_selected_preset_id):
		return
	_consume_history_name_if_needed(player_name)
	UiSounds.play_confirm()
	_close_window(false)
	player_applied.emit(_player_index, player_name, _selected_preset_id)


func _read_player_name() -> String:
	return _get_name_field_text()


func _on_cancel_pressed() -> void:
	_close_window(true)


func _consume_history_name_if_needed(player_name: String) -> void:
	if not account:
		return
	var recent := account.get_recent_names()
	if recent.has(player_name):
		account.consume_recent_name(player_name)
