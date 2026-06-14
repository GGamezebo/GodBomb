class_name EditPlayerWindow
extends Control

signal player_added(player_name: String, preset_id: int)
signal player_applied(index: int, player_name: String, preset_id: int)

const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"
const SWATCH_SIZE := 72

@export var name_edit: LineEdit
@export var slime_preview: TextureRect
@export var ok_button: Button
@export var apply_button: Button
@export var cancel_button: Button
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
		name_edit.text_changed.connect(_on_name_changed)
		name_edit.text_submitted.connect(_on_name_submitted)
	_build_color_buttons()


func open_add_window() -> void:
	_player_index = -1
	_editable_preset_id = -1
	_show_window("")
	if ok_button:
		ok_button.visible = true
	if apply_button:
		apply_button.visible = false
	_select_first_available_preset()


func open_edit_window(index: int, player_name: String, preset_id: int) -> void:
	_player_index = index
	_editable_preset_id = preset_id
	_show_window(player_name)
	if ok_button:
		ok_button.visible = false
	if apply_button:
		apply_button.visible = true
	_select_preset(preset_id)


func _show_window(player_name: String) -> void:
	visible = true
	z_index = 1
	if get_parent() is CanvasLayer:
		(get_parent() as CanvasLayer).visible = true
	if name_edit:
		name_edit.text = player_name
		name_edit.grab_focus()
	_refresh_all_swatches()
	_on_name_changed(player_name)


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


func _build_color_buttons() -> void:
	if not colors_grid or not game_config:
		return
	for child in colors_grid.get_children():
		child.queue_free()
	_color_buttons.clear()
	_lock_labels.clear()

	for i in game_config.max_players:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(SWATCH_SIZE, SWATCH_SIZE)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_color_pressed.bind(i))
		colors_grid.add_child(btn)
		_color_buttons.append(btn)

		var lock := Label.new()
		lock.text = "✕"
		lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		lock.add_theme_font_size_override("font_size", 36)
		lock.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
		lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lock.visible = false
		btn.add_child(lock)
		_lock_labels.append(lock)

	_refresh_all_swatches()


func _is_preset_held(preset_id: int) -> bool:
	return preset_storage != null and preset_storage.is_held(preset_id) and preset_id != _editable_preset_id


func _make_swatch_style(preset_id: int, selected: bool, held: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(int(SWATCH_SIZE * 0.5))
	var color := SlimeColors.get_color(preset_id)
	if held:
		color = color.darkened(0.35)
		color.a = 0.45
	style.bg_color = color
	var border := 6 if selected else 3
	style.set_border_width_all(border)
	style.border_color = Color.WHITE if selected else Color("#2A2118")
	style.shadow_size = 4 if selected else 2
	style.shadow_color = Color(0, 0, 0, 0.25)
	return style


func _refresh_all_swatches() -> void:
	for i in _color_buttons.size():
		_apply_swatch(i)


func _apply_swatch(preset_id: int) -> void:
	if preset_id < 0 or preset_id >= _color_buttons.size():
		return
	var btn := _color_buttons[preset_id]
	var held := _is_preset_held(preset_id)
	var selected := preset_id == _selected_preset_id
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


func _update_color_availability() -> void:
	_refresh_all_swatches()


func _select_first_available_preset() -> void:
	for i in _color_buttons.size():
		if not _is_preset_held(i):
			_select_preset(i)
			return


func _select_preset(preset_id: int) -> void:
	_selected_preset_id = preset_id
	_refresh_all_swatches()
	if slime_preview:
		slime_preview.texture = load(SLIME_PATH % preset_id)


func _on_color_pressed(preset_id: int) -> void:
	if _is_preset_held(preset_id):
		return
	_select_preset(preset_id)


func _on_name_changed(text: String) -> void:
	var is_empty := text.strip_edges().is_empty()
	if ok_button:
		ok_button.disabled = is_empty
	if apply_button:
		apply_button.disabled = is_empty


func _try_confirm() -> bool:
	if ok_button and ok_button.visible and not ok_button.disabled:
		_on_ok_pressed()
		return true
	if apply_button and apply_button.visible and not apply_button.disabled:
		_on_apply_pressed()
		return true
	return false


func _close_window() -> void:
	visible = false
	if get_parent() is CanvasLayer:
		(get_parent() as CanvasLayer).visible = false


func _on_ok_pressed() -> void:
	var player_name := name_edit.text.strip_edges() if name_edit else ""
	if player_name.is_empty():
		return
	_close_window()
	player_added.emit(player_name, _selected_preset_id)


func _on_apply_pressed() -> void:
	var player_name := name_edit.text.strip_edges() if name_edit else ""
	if player_name.is_empty() or _player_index < 0:
		return
	_close_window()
	player_applied.emit(_player_index, player_name, _selected_preset_id)


func _on_cancel_pressed() -> void:
	_close_window()
