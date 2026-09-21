class_name BattleSplashOverlay
extends Control

signal finished

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const CONTENT_WIDTH_MARGIN := 200.0
const PLAYER_PILL_SCALE := 1.45
const CONTINUE_BUTTON_SIZE := Vector2(660.0, 180.0)
const TOP_MARGIN := 188.0
const BUTTON_BOTTOM_MARGIN := 212.0
const START_ACTIVE_TEXTURE := "res://assets/party_kitchen/buttons/start_active.svg"

var _headline: Label
var _body: Label
var _player_strip: GamePlayerStrip
var _pill_host: CenterContainer
var _elimination_block: VBoxContainer
var _board_block: VBoxContainer
var _board_title: Label
var _board_body: Label
var _remaining_title: Label
var _eliminated_title: Label
var _remaining_list: VBoxContainer
var _eliminated_list: VBoxContainer
var _eliminated_section: VBoxContainer
var _board_scroll: ScrollContainer
var _board_lists: VBoxContainer
var _content_col: VBoxContainer
var _margin_host: MarginContainer
var _token: int = 0
var _closing: bool = false
var _board_mode: bool = false
var _continue_host: Control
var _continue_button: StartActionButton


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	modulate.a = 0.0
	z_index = 12
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	resized.connect(_layout_content)
	call_deferred("_layout_content")


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.color = Color(0.08, 0.03, 0.01, 0.88)
	add_child(backdrop)

	_margin_host = MarginContainer.new()
	_margin_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margin_host.add_theme_constant_override("margin_top", int(TOP_MARGIN))
	_margin_host.add_theme_constant_override("margin_bottom", int(BUTTON_BOTTOM_MARGIN))
	_margin_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_margin_host)

	_content_col = VBoxContainer.new()
	_content_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_col.add_theme_constant_override("separation", 24)
	_margin_host.add_child(_content_col)

	_elimination_block = VBoxContainer.new()
	_elimination_block.alignment = BoxContainer.ALIGNMENT_CENTER
	_elimination_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_elimination_block.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_elimination_block.add_theme_constant_override("separation", 28)
	_content_col.add_child(_elimination_block)
	_build_elimination_block(_elimination_block)

	_board_block = VBoxContainer.new()
	_board_block.visible = false
	_board_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board_block.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board_block.add_theme_constant_override("separation", 18)
	_content_col.add_child(_board_block)
	_build_board_block(_board_block)

	var button_host := CenterContainer.new()
	button_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_host.size_flags_vertical = Control.SIZE_SHRINK_END
	_content_col.add_child(button_host)
	_build_continue_button(button_host)


func _build_elimination_block(host: VBoxContainer) -> void:
	_headline = Label.new()
	_headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_headline.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_headline.clip_contents = true
	_headline.add_theme_font_size_override("font_size", 64)
	_headline.add_theme_color_override("font_color", Color(0.99, 0.96, 0.9, 1.0))
	_headline.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.88))
	_headline.add_theme_constant_override("outline_size", 8)
	host.add_child(_headline)

	_pill_host = CenterContainer.new()
	_pill_host.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_pill_host.visible = false
	host.add_child(_pill_host)

	_player_strip = GamePlayerStrip.new()
	_player_strip.set_visual_scale(PLAYER_PILL_SCALE)
	_pill_host.add_child(_player_strip)

	_body = Label.new()
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_body.add_theme_font_size_override("font_size", 36)
	_body.add_theme_color_override("font_color", Color(0.96, 0.9, 0.82, 1.0))
	_body.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.04, 0.82))
	_body.add_theme_constant_override("outline_size", 4)
	host.add_child(_body)


func _build_board_block(host: VBoxContainer) -> void:
	_board_title = Label.new()
	_board_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_board_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_board_title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_board_title.add_theme_font_size_override("font_size", 52)
	_board_title.add_theme_color_override("font_color", Color(0.99, 0.96, 0.9, 1.0))
	_board_title.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.88))
	_board_title.add_theme_constant_override("outline_size", 7)
	host.add_child(_board_title)

	_board_body = Label.new()
	_board_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_board_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_board_body.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_board_body.add_theme_font_size_override("font_size", 30)
	_board_body.add_theme_color_override("font_color", Color(0.96, 0.9, 0.82, 1.0))
	_board_body.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.04, 0.82))
	_board_body.add_theme_constant_override("outline_size", 4)
	host.add_child(_board_body)

	_board_scroll = ScrollContainer.new()
	_board_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_board_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	host.add_child(_board_scroll)

	var lists_host := CenterContainer.new()
	lists_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board_scroll.add_child(lists_host)

	_board_lists = VBoxContainer.new()
	_board_lists.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_board_lists.add_theme_constant_override("separation", 22)
	lists_host.add_child(_board_lists)

	var remaining_section := VBoxContainer.new()
	remaining_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	remaining_section.add_theme_constant_override("separation", 12)
	_board_lists.add_child(remaining_section)

	_remaining_title = GameResultOverlay.build_section_title(LocaleService.text("OVERTIME_STILL_IN"))
	_remaining_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	remaining_section.add_child(_remaining_title)

	_remaining_list = VBoxContainer.new()
	_remaining_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_remaining_list.add_theme_constant_override("separation", 14)
	remaining_section.add_child(_remaining_list)

	_eliminated_section = VBoxContainer.new()
	_eliminated_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_eliminated_section.add_theme_constant_override("separation", 12)
	_board_lists.add_child(_eliminated_section)

	_eliminated_title = GameResultOverlay.build_section_title(LocaleService.text("OVERTIME_OUT"))
	_eliminated_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_eliminated_section.add_child(_eliminated_title)

	_eliminated_list = VBoxContainer.new()
	_eliminated_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_eliminated_list.add_theme_constant_override("separation", 14)
	_eliminated_section.add_child(_eliminated_list)


func _build_continue_button(button_host: CenterContainer) -> void:
	_continue_host = Control.new()
	_continue_host.custom_minimum_size = CONTINUE_BUTTON_SIZE
	_continue_host.size = CONTINUE_BUTTON_SIZE
	_continue_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_host.add_child(_continue_host)

	_continue_button = StartActionButton.new()
	_continue_button.name = "ContinueButton"
	_continue_button.custom_minimum_size = CONTINUE_BUTTON_SIZE
	_continue_button.size = CONTINUE_BUTTON_SIZE
	_continue_button.texture_normal = load(START_ACTIVE_TEXTURE) as Texture2D
	_continue_button.ignore_texture_size = true
	_continue_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_continue_button.clip_contents = false
	_continue_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_continue_button.enable_pulse = true
	_continue_button.pressed.connect(_on_continue_pressed)
	UiSounds.bind_button(_continue_button, &"confirm")
	_continue_host.add_child(_continue_button)

	var continue_label := Label.new()
	continue_label.name = "ContinueLabel"
	continue_label.theme_type_variation = &"Hero"
	continue_label.add_theme_font_size_override("font_size", 72)
	continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	continue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	continue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_continue_button.add_child(continue_label)
	_apply_continue_label()
	_continue_button.set_pulse_active(false)
	call_deferred("_refresh_continue_button_layout")


func _apply_continue_label() -> void:
	if _continue_button == null:
		return
	var text := LocaleService.text("EMERGENCY_CONTINUE")
	_continue_button.action_text = text
	var label := _continue_button.get_node_or_null("ContinueLabel") as Label
	if label:
		label.text = text


func _refresh_continue_button_layout() -> void:
	if _continue_button:
		_continue_button.refresh_label_layout()


func _on_continue_pressed() -> void:
	_finish()


func show_splash(title: String, body: String, player: GamePlayer = null) -> void:
	_board_mode = false
	_elimination_block.visible = true
	_board_block.visible = false
	_headline.text = title
	_body.text = body
	_body.visible = not body.is_empty()
	if player != null:
		_player_strip.set_visual_scale(PLAYER_PILL_SCALE)
		_player_strip.set_player(player)
		_pill_host.visible = true
	else:
		_pill_host.visible = false
	_present()


func show_overtime_board(
	title: String,
	body: String,
	remaining: Array[GamePlayer],
	eliminated: Array[GamePlayer]
) -> void:
	_board_mode = true
	_elimination_block.visible = false
	_board_block.visible = true
	_board_title.text = title
	_board_body.text = body
	_board_body.visible = not body.is_empty()
	_remaining_title.text = LocaleService.text("OVERTIME_STILL_IN")
	_eliminated_title.text = LocaleService.text("OVERTIME_OUT")
	_fill_rank_list(_remaining_list, remaining, 1, true)
	_fill_rank_list(_eliminated_list, eliminated, remaining.size() + 1, false)
	_eliminated_section.visible = not eliminated.is_empty()
	_present()


func _fill_rank_list(
	host: VBoxContainer,
	players: Array[GamePlayer],
	start_rank: int,
	highlight: bool
) -> void:
	for child in host.get_children():
		child.queue_free()
	for i in players.size():
		var row := GameResultOverlay.build_rank_row(start_rank + i, players[i], highlight, true)
		row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		if not highlight:
			row.modulate = Color(0.78, 0.78, 0.78, 1.0)
		host.add_child(row)


func _present() -> void:
	_closing = false
	_token += 1
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	modulate.a = 0.0
	_apply_continue_label()
	if _continue_button:
		_continue_button.set_pulse_active(true)
	_layout_content()
	call_deferred("_layout_content")
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.16).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func hide_overlay() -> void:
	_token += 1
	_closing = false
	if _continue_button:
		_continue_button.set_pulse_active(false)
	visible = false
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func relayout() -> void:
	_layout_content()


func _finish() -> void:
	if _closing or not visible:
		return
	_closing = true
	_token += 1
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _continue_button:
		_continue_button.set_pulse_active(false)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.14).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_emit_finished)


func _emit_finished() -> void:
	visible = false
	modulate.a = 0.0
	_closing = false
	finished.emit()


func _get_content_width() -> float:
	return maxf(size.x - CONTENT_WIDTH_MARGIN, DESIGN_SIZE.x - CONTENT_WIDTH_MARGIN)


func _fit_control_size(control: Control) -> void:
	if control == null:
		return
	control.reset_size()
	var fitted := Vector2(_get_content_width(), control.get_combined_minimum_size().y)
	control.custom_minimum_size = fitted
	control.size = fitted


func _layout_content() -> void:
	if not _content_col or not _margin_host:
		return
	_margin_host.add_theme_constant_override("margin_left", 0)
	_margin_host.add_theme_constant_override("margin_right", 0)
	_margin_host.add_theme_constant_override("margin_top", int(TOP_MARGIN))
	_margin_host.add_theme_constant_override("margin_bottom", int(BUTTON_BOTTOM_MARGIN))
	if _board_mode:
		_sync_board_sizes()
	else:
		_sync_elimination_sizes()
	_refresh_continue_button_layout()


func _sync_elimination_sizes() -> void:
	_fit_control_size(_headline)
	_fit_control_size(_body)


func _sync_board_sizes() -> void:
	for host in [_remaining_list, _eliminated_list]:
		if host == null:
			continue
		for child in host.get_children():
			_fit_control_size(child as Control)
	_fit_control_size(_remaining_list)
	_fit_control_size(_eliminated_list)
	_fit_control_size(_remaining_title)
	_fit_control_size(_eliminated_title)
	_fit_control_size(_board_lists)
	_fit_control_size(_board_title)
	_fit_control_size(_board_body)
