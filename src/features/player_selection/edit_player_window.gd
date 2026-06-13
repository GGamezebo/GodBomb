class_name EditPlayerWindow
extends Control

signal player_added(player_name: String, preset_id: int)
signal player_applied(index: int, player_name: String, preset_id: int)

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


func _ready() -> void:
	visible = false
	if ok_button:
		ok_button.pressed.connect(_on_ok_pressed)
	if apply_button:
		apply_button.pressed.connect(_on_apply_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	if name_edit:
		name_edit.text_changed.connect(_on_name_changed)
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
	if name_edit:
		name_edit.text = player_name
		name_edit.grab_focus()
	_update_color_availability()
	_on_name_changed(player_name)


func _build_color_buttons() -> void:
	if not colors_grid or not game_config:
		return
	for child in colors_grid.get_children():
		child.queue_free()
	_color_buttons.clear()

	for i in game_config.max_players:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(72, 72)
		btn.focus_mode = Control.FOCUS_NONE
		var tex := load("res://assets/color_icons/Ellipse %d.png" % (i + 1)) as Texture2D
		if tex:
			btn.icon = tex
			btn.expand_icon = true
		btn.pressed.connect(_on_color_pressed.bind(i))
		colors_grid.add_child(btn)
		_color_buttons.append(btn)


func _update_color_availability() -> void:
	for i in _color_buttons.size():
		var held := preset_storage and preset_storage.is_held(i) and i != _editable_preset_id
		_color_buttons[i].disabled = held
		_color_buttons[i].modulate = Color(0.45, 0.45, 0.45, 1) if held else Color.WHITE


func _select_first_available_preset() -> void:
	for i in _color_buttons.size():
		if not _color_buttons[i].disabled:
			_select_preset(i)
			return


func _select_preset(preset_id: int) -> void:
	_selected_preset_id = preset_id
	for i in _color_buttons.size():
		_color_buttons[i].button_pressed = i == preset_id
	if slime_preview:
		slime_preview.texture = load("res://assets/slimes/%d.png" % preset_id)


func _on_color_pressed(preset_id: int) -> void:
	if _color_buttons[preset_id].disabled:
		return
	_select_preset(preset_id)


func _on_name_changed(text: String) -> void:
	if ok_button:
		ok_button.disabled = text.strip_edges().is_empty()


func _on_ok_pressed() -> void:
	var player_name := name_edit.text.strip_edges() if name_edit else ""
	if player_name.is_empty():
		return
	visible = false
	player_added.emit(player_name, _selected_preset_id)


func _on_apply_pressed() -> void:
	var player_name := name_edit.text.strip_edges() if name_edit else ""
	if player_name.is_empty() or _player_index < 0:
		return
	visible = false
	player_applied.emit(_player_index, player_name, _selected_preset_id)


func _on_cancel_pressed() -> void:
	visible = false
