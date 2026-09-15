class_name BattleSplashOverlay
extends PanelContainer

signal finished

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const CONTENT_WIDTH_MARGIN := 200.0
const CONTENT_ANCHOR := Vector2(540.0, 930.0)
const PLAYER_PILL_SCALE := 1.45
const BOARD_TOP := 168.0
const BOARD_BOTTOM := 232.0
const CONTINUE_BUTTON_SIZE := Vector2(660.0, 180.0)
const CONTINUE_BOTTOM_MARGIN := 72.0
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
var _content_col: VBoxContainer
var _margin_host: MarginContainer
var _position_host: Control
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
	size = DESIGN_SIZE
	_build_ui()
	resized.connect(_layout_content)
	call_deferred("_layout_content")


func _build_ui() -> void:
	var backdrop := StyleBoxFlat.new()
	backdrop.bg_color = Color(0.08, 0.03, 0.01, 0.88)
	add_theme_stylebox_override("panel", backdrop)

	var stack := Control.new()
	stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stack)

	_margin_host = MarginContainer.new()
	_margin_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_margin_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(_margin_host)

	_position_host = Control.new()
	_position_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_position_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_margin_host.add_child(_position_host)

	_content_col = VBoxContainer.new()
	_content_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_content_col.add_theme_constant_override("separation", 24)
	_position_host.add_child(_content_col)

	_elimination_block = VBoxContainer.new()
	_elimination_block.alignment = BoxContainer.ALIGNMENT_CENTER
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
	_build_continue_button()


func _build_elimination_block(host: VBoxContainer) -> void:
	var headline_wrap := MarginContainer.new()
	headline_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	headline_wrap.add_theme_constant_override("margin_left", 12)
	headline_wrap.add_theme_constant_override("margin_right", 12)
	host.add_child(headline_wrap)

	_headline = Label.new()
	_headline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_headline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_headline.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_headline.clip_contents = true
	_headline.add_theme_font_size_override("font_size", 64)
	_headline.add_theme_color_override("font_color", Color(0.99, 0.96, 0.9, 1.0))
	_headline.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.88))
	_headline.add_theme_constant_override("outline_size", 8)
	headline_wrap.add_child(_headline)

	_pill_host = CenterContainer.new()
	_pill_host.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_pill_host.visible = false
	host.add_child(_pill_host)

	_player_strip = GamePlayerStrip.new()
	_player_strip.set_visual_scale(PLAYER_PILL_SCALE)
	_pill_host.add_child(_player_strip)

	var body_wrap := MarginContainer.new()
	body_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_wrap.add_theme_constant_override("margin_left", 16)
	body_wrap.add_theme_constant_override("margin_right", 16)
	host.add_child(body_wrap)

	_body = Label.new()
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_font_size_override("font_size", 36)
	_body.add_theme_color_override("font_color", Color(0.96, 0.9, 0.82, 1.0))
	_body.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.04, 0.82))
	_body.add_theme_constant_override("outline_size", 4)
	body_wrap.add_child(_body)


func _build_board_block(host: VBoxContainer) -> void:
	_board_title = Label.new()
	_board_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_board_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_board_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board_title.add_theme_font_size_override("font_size", 52)
	_board_title.add_theme_color_override("font_color", Color(0.99, 0.96, 0.9, 1.0))
	_board_title.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.88))
	_board_title.add_theme_constant_override("outline_size", 7)
	host.add_child(_board_title)

	_board_body = Label.new()
	_board_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_board_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_board_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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

	var lists := VBoxContainer.new()
	lists.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lists.add_theme_constant_override("separation", 22)
	_board_scroll.add_child(lists)

	var remaining_section := VBoxContainer.new()
	remaining_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	remaining_section.add_theme_constant_override("separation", 12)
	lists.add_child(remaining_section)

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
	lists.add_child(_eliminated_section)

	_eliminated_title = GameResultOverlay.build_section_title(LocaleService.text("OVERTIME_OUT"))
	_eliminated_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_eliminated_section.add_child(_eliminated_title)

	_eliminated_list = VBoxContainer.new()
	_eliminated_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_eliminated_list.add_theme_constant_override("separation", 14)
	_eliminated_section.add_child(_eliminated_list)


func _build_continue_button() -> void:
	_continue_host = Control.new()
	_continue_host.custom_minimum_size = CONTINUE_BUTTON_SIZE
	_continue_host.size = CONTINUE_BUTTON_SIZE
	_continue_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_continue_host.z_index = 4
	add_child(_continue_host)

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
	continue_label.text = LocaleService.text("EMERGENCY_CONTINUE")
	continue_label.theme_type_variation = &"Hero"
	continue_label.add_theme_font_size_override("font_size", 72)
	continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	continue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	continue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_continue_button.add_child(continue_label)
	_continue_button.action_text = LocaleService.text("EMERGENCY_CONTINUE")
	_continue_button.set_pulse_active(false)
	call_deferred("_layout_continue_button")


func _on_continue_pressed() -> void:
	_finish()


func show_splash(title: String, body: String, player: GamePlayer = null) -> void:
	_board_mode = false
	_elimination_block.visible = true
	_board_block.visible = false
	_content_col.alignment = BoxContainer.ALIGNMENT_CENTER
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
	_content_col.alignment = BoxContainer.ALIGNMENT_BEGIN
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
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if not highlight:
			row.modulate = Color(0.78, 0.78, 0.78, 1.0)
		host.add_child(row)


func _present() -> void:
	_closing = false
	_token += 1
	size = get_parent().size if get_parent() is Control else DESIGN_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	modulate.a = 0.0
	if _continue_button:
		_continue_button.action_text = LocaleService.text("EMERGENCY_CONTINUE")
		_continue_button.set_pulse_active(true)
		_continue_button.call_deferred("refresh_label_layout")
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


func _get_side_margin() -> int:
	var half_margin := CONTENT_WIDTH_MARGIN * 0.5
	var min_side := 72.0
	var proportional := size.x * 0.1
	return int(round(maxf(half_margin, maxf(min_side, proportional))))


func _get_content_width() -> float:
	return maxf(size.x - float(_get_side_margin()) * 2.0, 280.0)


func _layout_content() -> void:
	if not _content_col or not _position_host or not _margin_host:
		return
	var side_margin := _get_side_margin()
	_margin_host.add_theme_constant_override("margin_left", side_margin)
	_margin_host.add_theme_constant_override("margin_right", side_margin)
	var content_width := _get_content_width()
	_content_col.custom_minimum_size.x = content_width
	_content_col.size.x = content_width
	if _board_mode:
		_margin_host.add_theme_constant_override("margin_top", int(BOARD_TOP))
		_margin_host.add_theme_constant_override("margin_bottom", int(BOARD_BOTTOM))
		var host_size := _position_host.size
		_content_col.position = Vector2((host_size.x - content_width) * 0.5, 0.0)
		_content_col.size = Vector2(content_width, host_size.y)
		_content_col.custom_minimum_size = Vector2(content_width, host_size.y)
		_fit_board_rows(content_width)
	else:
		_margin_host.add_theme_constant_override("margin_top", 0)
		_margin_host.add_theme_constant_override("margin_bottom", int(BOARD_BOTTOM))
		_content_col.reset_size()
		var col_size := _content_col.get_combined_minimum_size()
		col_size.x = content_width
		_content_col.size = col_size
		_content_col.position = Vector2(
			(_position_host.size.x - content_width) * 0.5,
			CONTENT_ANCHOR.y - col_size.y * 0.48
		)
	_layout_continue_button()


func _layout_continue_button() -> void:
	if _continue_host == null:
		return
	var host_size := size if size.x > 0.0 else DESIGN_SIZE
	_continue_host.size = CONTINUE_BUTTON_SIZE
	_continue_host.position = Vector2(
		(host_size.x - CONTINUE_BUTTON_SIZE.x) * 0.5,
		host_size.y - CONTINUE_BUTTON_SIZE.y - CONTINUE_BOTTOM_MARGIN
	)
	if _continue_button:
		_continue_button.size = CONTINUE_BUTTON_SIZE
		_continue_button.call_deferred("refresh_label_layout")


func _fit_board_rows(content_width: float) -> void:
	if _board_scroll and _board_scroll.get_child_count() > 0:
		var lists := _board_scroll.get_child(0) as Control
		if lists:
			lists.custom_minimum_size.x = content_width
			lists.size.x = content_width
	for host in [_remaining_list, _eliminated_list]:
		if host == null:
			continue
		for child in host.get_children():
			var row := child as Control
			if row:
				row.custom_minimum_size.x = content_width
				row.size.x = content_width
