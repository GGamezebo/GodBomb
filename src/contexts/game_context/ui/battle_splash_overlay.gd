class_name BattleSplashOverlay
extends Control

signal finished

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const SIDE_MARGIN := 72
const TOP_MARGIN := 160
const BUTTON_BOTTOM_MARGIN := 200
const PLAYER_PILL_SCALE := 1.45
const CONTINUE_BUTTON_SIZE := Vector2(660.0, 180.0)
const RANK_ROW_MIN_HEIGHT := 76.0
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
var _continue_button: StartActionButton
var _closing: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	modulate.a = 0.0
	z_index = 50
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.color = Color(0.08, 0.03, 0.01, 0.92)
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", SIDE_MARGIN)
	margin.add_theme_constant_override("margin_right", SIDE_MARGIN)
	margin.add_theme_constant_override("margin_top", TOP_MARGIN)
	margin.add_theme_constant_override("margin_bottom", BUTTON_BOTTOM_MARGIN)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 20)
	margin.add_child(root)

	_elimination_block = VBoxContainer.new()
	_elimination_block.alignment = BoxContainer.ALIGNMENT_CENTER
	_elimination_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_elimination_block.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_elimination_block.add_theme_constant_override("separation", 28)
	root.add_child(_elimination_block)

	_headline = _make_label(64, true)
	_elimination_block.add_child(_headline)

	_pill_host = CenterContainer.new()
	_pill_host.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_pill_host.visible = false
	_elimination_block.add_child(_pill_host)

	_player_strip = GamePlayerStrip.new()
	_player_strip.set_visual_scale(PLAYER_PILL_SCALE)
	_pill_host.add_child(_player_strip)

	_body = _make_label(36, false)
	_elimination_block.add_child(_body)

	_board_block = VBoxContainer.new()
	_board_block.visible = false
	_board_block.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_board_block.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_board_block.add_theme_constant_override("separation", 16)
	root.add_child(_board_block)

	_board_title = _make_label(52, true)
	_board_block.add_child(_board_title)

	_board_body = _make_label(30, false)
	_board_block.add_child(_board_body)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0.0, 280.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_board_block.add_child(scroll)

	var lists := VBoxContainer.new()
	lists.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lists.add_theme_constant_override("separation", 22)
	scroll.add_child(lists)

	var remaining_section := VBoxContainer.new()
	remaining_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	remaining_section.add_theme_constant_override("separation", 12)
	lists.add_child(remaining_section)

	_remaining_title = GameResultOverlay.build_section_title("")
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

	_eliminated_title = GameResultOverlay.build_section_title("")
	_eliminated_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_eliminated_section.add_child(_eliminated_title)

	_eliminated_list = VBoxContainer.new()
	_eliminated_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_eliminated_list.add_theme_constant_override("separation", 14)
	_eliminated_section.add_child(_eliminated_list)

	var button_host := CenterContainer.new()
	button_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_host.size_flags_vertical = Control.SIZE_SHRINK_END
	root.add_child(button_host)
	_build_continue_button(button_host)


func _make_label(font_size: int, is_title: bool) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.clip_contents = false
	label.add_theme_font_size_override("font_size", font_size)
	if is_title:
		label.add_theme_color_override("font_color", Color(0.99, 0.96, 0.9, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.88))
		label.add_theme_constant_override("outline_size", 8)
	else:
		label.add_theme_color_override("font_color", Color(0.96, 0.9, 0.82, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.04, 0.82))
		label.add_theme_constant_override("outline_size", 4)
	return label


func _build_continue_button(button_host: CenterContainer) -> void:
	var host := Control.new()
	host.custom_minimum_size = CONTINUE_BUTTON_SIZE
	host.size = CONTINUE_BUTTON_SIZE
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_host.add_child(host)

	_continue_button = StartActionButton.new()
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
	host.add_child(_continue_button)

	var continue_label := Label.new()
	continue_label.name = "ContinueLabel"
	continue_label.theme_type_variation = &"Hero"
	continue_label.add_theme_font_size_override("font_size", 72)
	continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	continue_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	continue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_continue_button.add_child(continue_label)
	_continue_button.set_pulse_active(false)


func _apply_continue_label() -> void:
	if _continue_button == null:
		return
	var text := LocaleService.text("EMERGENCY_CONTINUE")
	_continue_button.action_text = text
	var label := _continue_button.get_node_or_null("ContinueLabel") as Label
	if label:
		label.text = text
	_continue_button.refresh_label_layout()


func _on_continue_pressed() -> void:
	_finish()


func show_splash(title: String, body: String, player: GamePlayer = null) -> void:
	if not is_node_ready():
		await ready
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
	if not is_node_ready():
		await ready
	_elimination_block.visible = false
	_board_block.visible = true
	_board_title.text = title
	_board_body.text = body
	_board_body.visible = not body.is_empty()
	_remaining_title.text = LocaleService.text("OVERTIME_STILL_IN")
	_eliminated_title.text = LocaleService.text("OVERTIME_OUT")
	_eliminated_section.visible = not eliminated.is_empty()
	# Show chrome first so a row-build error can't leave a blank screen.
	_present()
	_rebuild_rank_list(_remaining_list, remaining, 1, true)
	_rebuild_rank_list(_eliminated_list, eliminated, remaining.size() + 1, false)


func _rebuild_rank_list(
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
		row.custom_minimum_size = Vector2(0.0, RANK_ROW_MIN_HEIGHT)
		if not highlight:
			row.modulate = Color(0.78, 0.78, 0.78, 1.0)
		host.add_child(row)


func _present() -> void:
	_closing = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if get_parent():
		get_parent().move_child(self, -1)
	visible = true
	modulate.a = 0.0
	_apply_continue_label()
	if _continue_button:
		_continue_button.set_pulse_active(true)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.16).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func hide_overlay() -> void:
	_closing = false
	if _continue_button:
		_continue_button.set_pulse_active(false)
	visible = false
	modulate.a = 0.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func relayout() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _finish() -> void:
	if _closing or not visible:
		return
	_closing = true
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
