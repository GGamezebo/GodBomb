class_name ExitConfirmDialog
extends Control

signal confirmed
signal cancelled

const PANEL_SIDE_MARGIN := 32.0

@export var message_label: Label
@export var cancel_button: Button
@export var confirm_button: Button

var _panel: PanelContainer


func _ready() -> void:
	visible = false
	_panel = get_node_or_null("Panel") as PanelContainer
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_pressed)
	resized.connect(_apply_panel_layout)
	call_deferred("_apply_panel_layout")
	call_deferred("_update_modal_layer_visibility")


func open() -> void:
	_apply_panel_layout()
	visible = true
	_show_modal_layer()


func close() -> void:
	visible = false
	_update_modal_layer_visibility()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()
		get_viewport().set_input_as_handled()


func _on_cancel_pressed() -> void:
	close()
	cancelled.emit()


func _on_confirm_pressed() -> void:
	close()
	confirmed.emit()


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


func _apply_panel_layout() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if not _panel:
		return
	var viewport_size := get_viewport_rect().size
	var panel_size := maxf(320.0, viewport_size.x - PANEL_SIDE_MARGIN * 2.0)
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -panel_size * 0.5
	_panel.offset_top = -panel_size * 0.5
	_panel.offset_right = panel_size * 0.5
	_panel.offset_bottom = panel_size * 0.5
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
