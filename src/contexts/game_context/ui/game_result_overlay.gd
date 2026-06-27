class_name GameResultOverlay
extends Control

signal return_to_menu_requested

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"
const START_ACTIVE_TEXTURE := "res://assets/party_kitchen/buttons/start_active.svg"
const WINNER_PILL_SCALE := 1.42
const MENU_BUTTON_SIZE := Vector2(660.0, 180.0)
const MENU_REVEAL_SEC := 10.0
const HAPTIC_PULSE_INTERVAL := 0.55
const CONTENT_WIDTH_MARGIN := 200.0
const WINNER_RANKING_GAP := 36.0
const TOP_MARGIN := 188.0
const BUTTON_BOTTOM_MARGIN := 212.0

var _winner_bg: ColorRect
var _celebration: ResultCelebrationLayer
var _root_layout: VBoxContainer
var _winner_host: CenterContainer
var _scroll: ScrollContainer
var _rank_list: VBoxContainer
var _ranking_title: Label
var _winner_frame: PanelContainer
var _winner_strip_host: CenterContainer
var _winner_strip: GamePlayerStrip
var _winner_title: Label
var _winner_subtitle: Label
var _menu_button: StartActionButton
var _menu_button_reveal: Control
var _main_events: MainEvents
var _menu_reveal_tween: Tween
var _haptic_tween: Tween
var _menu_button_ready := false
var _haptic_pulse_index := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	modulate.a = 0.0
	z_index = 100
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_main_events = load("res://src/contexts/main_context/main_events.tres") as MainEvents
	_build_ui()
	resized.connect(_on_resized)


func _on_resized() -> void:
	if is_node_ready() and visible:
		call_deferred("_sync_section_sizes")


func _get_content_width() -> float:
	return maxf(size.x - CONTENT_WIDTH_MARGIN, DESIGN_SIZE.x - CONTENT_WIDTH_MARGIN)


func _fit_control_size(control: Control) -> void:
	if control == null:
		return
	control.reset_size()
	var fitted := Vector2(_get_content_width(), control.get_combined_minimum_size().y)
	control.custom_minimum_size = fitted
	control.size = fitted


func _build_ui() -> void:
	_winner_bg = ColorRect.new()
	_winner_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_winner_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_winner_bg.color = Color(0.06, 0.05, 0.04, 1.0)
	add_child(_winner_bg)

	_celebration = ResultCelebrationLayer.new()
	_celebration.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_celebration)

	var content_host := MarginContainer.new()
	content_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_host.add_theme_constant_override("margin_top", int(TOP_MARGIN))
	content_host.add_theme_constant_override("margin_bottom", int(BUTTON_BOTTOM_MARGIN))
	content_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content_host)

	_root_layout = VBoxContainer.new()
	_root_layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_root_layout.add_theme_constant_override("separation", 0)
	content_host.add_child(_root_layout)

	_winner_host = CenterContainer.new()
	_winner_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_winner_host.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_root_layout.add_child(_winner_host)
	_winner_host.add_child(_build_winner_frame())

	var winner_gap := Control.new()
	winner_gap.custom_minimum_size = Vector2(0.0, WINNER_RANKING_GAP)
	winner_gap.size = winner_gap.custom_minimum_size
	_root_layout.add_child(winner_gap)

	_ranking_title = _build_section_title("РЕЙТИНГ")
	_ranking_title.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_root_layout.add_child(_ranking_title)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.custom_minimum_size.y = 180.0
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_root_layout.add_child(_scroll)

	var rank_host := CenterContainer.new()
	rank_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(rank_host)

	_rank_list = VBoxContainer.new()
	_rank_list.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_rank_list.add_theme_constant_override("separation", 14)
	rank_host.add_child(_rank_list)

	var button_host := CenterContainer.new()
	button_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_host.size_flags_vertical = Control.SIZE_SHRINK_END
	_root_layout.add_child(button_host)

	_menu_button_reveal = Control.new()
	_menu_button_reveal.custom_minimum_size = MENU_BUTTON_SIZE
	_menu_button_reveal.size = MENU_BUTTON_SIZE
	_menu_button_reveal.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_menu_button_reveal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_host.add_child(_menu_button_reveal)

	_menu_button = StartActionButton.new()
	_menu_button.name = "MenuButton"
	_menu_button.custom_minimum_size = MENU_BUTTON_SIZE
	_menu_button.size = MENU_BUTTON_SIZE
	_menu_button.texture_normal = load(START_ACTIVE_TEXTURE) as Texture2D
	_menu_button.ignore_texture_size = true
	_menu_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_menu_button.clip_contents = false
	_menu_button.disabled = true
	_menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_menu_button.pressed.connect(_on_menu_button_pressed)
	UiSounds.bind_button(_menu_button, &"confirm")
	_menu_button_reveal.add_child(_menu_button)

	var menu_label := Label.new()
	menu_label.name = "StartLabel"
	menu_label.text = "В МЕНЮ"
	menu_label.theme_type_variation = &"Hero"
	menu_label.add_theme_font_size_override("font_size", 72)
	menu_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	menu_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_menu_button.add_child(menu_label)
	call_deferred("_refresh_menu_button_layout")


func _build_winner_frame() -> PanelContainer:
	_winner_frame = PanelContainer.new()
	_winner_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(1.0, 0.99, 0.97, 0.36)
	frame_style.border_color = Color(1.0, 1.0, 1.0, 0.34)
	frame_style.set_border_width_all(3)
	frame_style.set_corner_radius_all(40)
	frame_style.shadow_color = Color(0.05, 0.03, 0.02, 0.2)
	frame_style.shadow_size = 14
	frame_style.shadow_offset = Vector2(0.0, 6.0)
	_winner_frame.add_theme_stylebox_override("panel", frame_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	_winner_frame.add_child(margin)

	var inner := VBoxContainer.new()
	inner.alignment = BoxContainer.ALIGNMENT_CENTER
	inner.add_theme_constant_override("separation", 22)
	margin.add_child(inner)

	_winner_title = Label.new()
	_winner_title.text = "ПОБЕДИТЕЛЬ"
	_winner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_winner_title.add_theme_font_size_override("font_size", 68)
	_winner_title.add_theme_color_override("font_color", Color.WHITE)
	_winner_title.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.88))
	_winner_title.add_theme_constant_override("outline_size", 7)
	inner.add_child(_winner_title)

	_winner_strip_host = CenterContainer.new()
	inner.add_child(_winner_strip_host)

	_winner_strip = GamePlayerStrip.new()
	_winner_strip.set_visual_scale(WINNER_PILL_SCALE)
	_winner_strip_host.add_child(_winner_strip)

	_winner_subtitle = Label.new()
	_winner_subtitle.text = "МЕНЬШЕ ШТРАФОВ"
	_winner_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_winner_subtitle.add_theme_font_size_override("font_size", 72)
	_winner_subtitle.add_theme_color_override("font_color", Color.WHITE)
	_winner_subtitle.add_theme_color_override("font_outline_color", Color(0.88, 0.62, 0.38, 0.85))
	_winner_subtitle.add_theme_constant_override("outline_size", 6)
	inner.add_child(_winner_subtitle)

	return _winner_frame


func _build_section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 34)
	label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.78, 0.92))
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.03, 0.02, 0.45))
	label.add_theme_constant_override("outline_size", 2)
	return label


static func _winner_background_color(preset_id: int) -> Color:
	return SlimeColors.get_color(preset_id).darkened(0.32)


func _sync_section_sizes() -> void:
	_fit_control_size(_winner_frame)
	_fit_control_size(_ranking_title)
	_fit_control_size(_rank_list)
	for child in _rank_list.get_children():
		_fit_control_size(child as Control)
	_refresh_menu_button_layout()


func _refresh_menu_button_layout() -> void:
	if _menu_button:
		_menu_button.refresh_label_layout()


func show_results(sorted_players: Array[GamePlayer]) -> void:
	if sorted_players.is_empty():
		return
	if not is_node_ready():
		await ready

	_kill_timers()
	_menu_button_ready = false
	_haptic_pulse_index = 0
	_clear_rank_rows()

	var winner := sorted_players[0]
	_winner_bg.color = _winner_background_color(winner.info.preset_id)
	_winner_strip.set_visual_scale(WINNER_PILL_SCALE)
	_winner_strip.set_player(winner)

	for i in sorted_players.size():
		_rank_list.add_child(_build_rank_row(i + 1, sorted_players[i], i == 0))

	_menu_button.disabled = true
	_menu_button.set_pulse_active(false)
	_reset_menu_button_reveal()

	call_deferred("_sync_section_sizes")

	_celebration.start()
	visible = true
	modulate.a = 0.0
	_winner_frame.modulate.a = 0.0
	_ranking_title.modulate.a = 0.0
	_winner_strip.scale = Vector2(0.86, 0.86)
	call_deferred("_play_reveal")
	call_deferred("_start_menu_button_reveal")


func _reset_menu_button_reveal() -> void:
	if _menu_button_reveal:
		_menu_button_reveal.modulate = Color(1.0, 1.0, 1.0, 0.0)


func _clear_rank_rows() -> void:
	for child in _rank_list.get_children():
		child.queue_free()


func _build_rank_row(rank: int, player: GamePlayer, is_winner: bool) -> PanelContainer:
	var row_panel := PanelContainer.new()
	row_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.99, 0.97, 0.34 if is_winner else 0.28)
	style.border_color = Color(0.88, 0.62, 0.38, 0.55) if is_winner else Color(1.0, 1.0, 1.0, 0.22)
	style.set_border_width_all(2)
	style.set_corner_radius_all(28)
	style.shadow_color = Color(0.05, 0.03, 0.02, 0.16)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0.0, 3.0)
	row_panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 10)
	row_panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	margin.add_child(row)

	var rank_badge := PanelContainer.new()
	rank_badge.custom_minimum_size = Vector2(56.0, 56.0)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(0.88, 0.62, 0.38, 0.92 if is_winner else 0.82)
	badge_style.set_corner_radius_all(28)
	rank_badge.add_theme_stylebox_override("panel", badge_style)
	var badge_center := CenterContainer.new()
	badge_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rank_badge.add_child(badge_center)
	var rank_label := Label.new()
	rank_label.text = str(rank)
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rank_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rank_label.add_theme_font_size_override("font_size", 28)
	rank_label.add_theme_color_override("font_color", Color.WHITE)
	badge_center.add_child(rank_label)
	row.add_child(rank_badge)

	var avatar := TextureRect.new()
	avatar.custom_minimum_size = Vector2(56.0, 56.0)
	avatar.size = Vector2(56.0, 56.0)
	avatar.texture = load(SLIME_PATH % player.info.preset_id) as Texture2D
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(avatar)
	BombFuseEffect.attach_to(avatar)

	var name_label := Label.new()
	name_label.text = player.info.name.to_upper()
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 34)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.45))
	name_label.add_theme_constant_override("outline_size", 2)
	row.add_child(name_label)

	var score_label := Label.new()
	score_label.text = str(player.score)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.add_theme_font_size_override("font_size", 32)
	score_label.add_theme_color_override("font_color", Color(0.96, 0.9, 0.82, 0.92))
	row.add_child(score_label)

	row_panel.modulate.a = 0.0
	return row_panel


func _play_reveal() -> void:
	_sync_section_sizes()
	_winner_strip.pivot_offset = _winner_strip.size * 0.5
	_winner_title.pivot_offset = _winner_title.size * 0.5
	_winner_subtitle.pivot_offset = _winner_subtitle.size * 0.5
	_winner_frame.pivot_offset = _winner_frame.size * 0.5

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_winner_frame, "modulate:a", 1.0, 0.28).set_delay(0.05)
	tween.parallel().tween_property(_ranking_title, "modulate:a", 1.0, 0.22).set_delay(0.16)
	tween.parallel().tween_property(_winner_strip, "scale", Vector2.ONE, 0.34).set_delay(0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	for i in _rank_list.get_child_count():
		var row := _rank_list.get_child(i) as Control
		tween.parallel().tween_property(row, "modulate:a", 1.0, 0.22).set_delay(0.24 + float(i) * 0.07)


func _start_menu_button_reveal() -> void:
	_kill_menu_reveal_timers()
	_refresh_menu_button_layout()
	_pulse_celebration_haptic()

	_haptic_tween = create_tween()
	var pulse_count := maxi(1, int(MENU_REVEAL_SEC / HAPTIC_PULSE_INTERVAL))
	for i in pulse_count:
		if i > 0:
			_haptic_tween.tween_interval(HAPTIC_PULSE_INTERVAL)
		_haptic_tween.tween_callback(_pulse_celebration_haptic)

	_menu_reveal_tween = create_tween()
	_menu_reveal_tween.tween_property(_menu_button_reveal, "modulate:a", 1.0, MENU_REVEAL_SEC).set_trans(Tween.TRANS_SINE)
	_menu_reveal_tween.tween_callback(_enable_menu_button)


func _pulse_celebration_haptic() -> void:
	_haptic_pulse_index += 1
	match _haptic_pulse_index % 3:
		0:
			Haptics.vibrate_strong()
		1:
			Haptics.vibrate_lobby_action()
		_:
			Haptics.vibrate_alert_tick()


func _enable_menu_button() -> void:
	_menu_button_ready = true
	_menu_button.disabled = false
	if _menu_button_reveal:
		_menu_button_reveal.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_menu_button.set_pulse_active(true)
	_refresh_menu_button_layout()


func _on_menu_button_pressed() -> void:
	if not _menu_button_ready:
		return
	return_to_menu_requested.emit()
	if _main_events:
		_main_events.ev_return_to_menu.emit()


func _kill_menu_reveal_timers() -> void:
	if _menu_reveal_tween:
		_menu_reveal_tween.kill()
		_menu_reveal_tween = null
	if _haptic_tween:
		_haptic_tween.kill()
		_haptic_tween = null


func _kill_timers() -> void:
	_kill_menu_reveal_timers()


func hide_overlay() -> void:
	_kill_timers()
	_menu_button_ready = false
	if not is_node_ready():
		visible = false
		modulate.a = 0.0
		return
	if _menu_button:
		_menu_button.set_pulse_active(false)
		_menu_button.disabled = true
	_reset_menu_button_reveal()
	if _celebration:
		_celebration.stop()
	visible = false
	modulate.a = 0.0
