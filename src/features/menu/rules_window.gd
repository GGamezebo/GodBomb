class_name RulesWindow
extends Control

signal onboarding_continue_pressed
signal tutorial_requested

const ModalScroll = preload("res://src/common/ui/modal_scroll.gd")
@export var rules_scroll: ScrollContainer
@export var rules_text: RichTextLabel
@export var close_button: StartActionButton
@export var tutorial_button: StartActionButton
@export var onboarding_skip_button: Button

var _layout_pending := false
var _onboarding_mode := false
var _layout_width := -1


func _ready() -> void:
	visible = false
	if not LocaleService.locale_changed.is_connected(refresh_localized):
		LocaleService.locale_changed.connect(refresh_localized)
	if rules_text:
		rules_text.text = LocaleService.get_rules_text()
		rules_text.scroll_active = false
		rules_text.fit_content = true
		rules_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rules_text.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		rules_text.bbcode_enabled = true
		rules_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if rules_scroll:
		ModalScroll.configure(rules_scroll)
		if not rules_scroll.resized.is_connected(_queue_rules_layout):
			rules_scroll.resized.connect(_queue_rules_layout)
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		UiSounds.bind_button(close_button)
	if tutorial_button:
		tutorial_button.pressed.connect(_on_tutorial_pressed)
		UiSounds.bind_button(tutorial_button, &"confirm")
	if onboarding_skip_button:
		onboarding_skip_button.pressed.connect(_on_onboarding_skip_pressed)
		UiSounds.bind_button(onboarding_skip_button)
	_apply_mode_ui()
	call_deferred("_update_modal_layer_visibility")
	call_deferred("_queue_rules_layout")
	refresh_localized()


func refresh_localized(_locale: String = "") -> void:
	if rules_text:
		rules_text.text = LocaleService.get_rules_text()
	var title := get_node_or_null("Panel/Margin/VBox/TitleBlock/TitleRules") as Label
	if title:
		title.text = LocaleService.text("RULES_TITLE")
	var subtitle := get_node_or_null("Panel/Margin/VBox/TitleBlock/TitleGame") as Label
	if subtitle:
		subtitle.text = LocaleService.text("RULES_GAME_NAME")
	if onboarding_skip_button:
		onboarding_skip_button.text = LocaleService.text("RULES_SKIP")
	if tutorial_button:
		tutorial_button.action_text = LocaleService.text("RULES_TUTORIAL")
	_apply_mode_ui()


func open() -> void:
	_onboarding_mode = false
	_apply_mode_ui()
	_open_common()


func open_for_onboarding() -> void:
	_onboarding_mode = true
	_apply_mode_ui()
	_open_common()


func _open_common() -> void:
	visible = true
	_show_modal_layer()
	_layout_width = -1
	if rules_scroll:
		ModalScroll.reset_position(rules_scroll)
	_queue_rules_layout()
	UiSounds.play_modal_open()


func close() -> void:
	_onboarding_mode = false
	_apply_mode_ui()
	visible = false
	_update_modal_layer_visibility()
	UiSounds.play_modal_close()


func _on_close_pressed() -> void:
	if _onboarding_mode:
		onboarding_continue_pressed.emit()
	close()


func _on_tutorial_pressed() -> void:
	close()
	tutorial_requested.emit()


func _on_onboarding_skip_pressed() -> void:
	close()
	var controller := OnboardingController.get_controller(get_tree())
	if controller:
		controller.skip_current_step()


func _apply_mode_ui() -> void:
	if close_button:
		close_button.action_text = (
			LocaleService.text("RULES_NEXT") if _onboarding_mode else LocaleService.text("RULES_CLOSE")
		)
		close_button.disabled = false
	if tutorial_button:
		tutorial_button.visible = not _onboarding_mode
	if onboarding_skip_button:
		onboarding_skip_button.visible = _onboarding_mode


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if _onboarding_mode:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and visible:
		_queue_rules_layout()


func _queue_rules_layout() -> void:
	if _layout_pending:
		return
	_layout_pending = true
	call_deferred("_sync_rules_text_layout")


func _sync_rules_text_layout() -> void:
	_layout_pending = false
	if rules_scroll == null or rules_text == null:
		return
	var width := int(floorf(rules_scroll.size.x))
	if width <= 1:
		return
	var text_width := maxi(width - 18, 1)
	if text_width == _layout_width:
		return
	_layout_width = text_width

	rules_text.fit_content = true
	rules_text.custom_minimum_size.x = text_width
	rules_text.custom_maximum_size.x = text_width
	await get_tree().process_frame
	if rules_scroll:
		ModalScroll.reset_position(rules_scroll)


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
