class_name ExitConfirmDialog
extends Control

signal confirmed
signal cancelled

@export var message_label: Label
@export var cancel_button: Button
@export var confirm_button: Button


func _ready() -> void:
	visible = false
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_pressed)
	call_deferred("_update_modal_layer_visibility")


func open() -> void:
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
