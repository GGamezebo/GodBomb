class_name GameResultStatsPanel
extends Control
## Full-screen match report opened from the result screen: summary, per-player cards, timeline.

signal closed

const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"
const START_ACTIVE_TEXTURE := "res://assets/party_kitchen/buttons/start_active.svg"
const BACK_BUTTON_SIZE := Vector2(520.0, 140.0)
const MAX_BOOM_DOTS := 10
const TOP_MARGIN := 300
const SLIDE_IN_OFFSET := 60.0
const ACCENT := Color(0.88, 0.62, 0.38, 1.0)
const TEXT_MUTED := Color(0.96, 0.9, 0.82, 0.78)
const TAG_COLORS := {
	&"boom": Color(0.86, 0.3, 0.18, 0.95),
	&"join": Color(0.32, 0.62, 0.36, 0.95),
	&"leave": Color(0.45, 0.42, 0.4, 0.95),
	&"out": Color(0.55, 0.12, 0.12, 0.95),
}

var _background: ColorRect
var _content: VBoxContainer
var _summary_row: HBoxContainer
var _list: VBoxContainer
var _title: Label
var _back_button: StartActionButton
var _tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	z_index = 10
	_build_ui()


func _build_ui() -> void:
	_background = ColorRect.new()
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background.color = Color(0.06, 0.05, 0.04, 1.0)
	add_child(_background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 64)
	margin.add_theme_constant_override("margin_right", 64)
	# Clear of the camera cutout / status bar on phones.
	margin.add_theme_constant_override("margin_top", TOP_MARGIN)
	margin.add_theme_constant_override("margin_bottom", 170)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 28)
	margin.add_child(_content)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 64)
	_title.add_theme_color_override("font_color", Color.WHITE)
	_title.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.88))
	_title.add_theme_constant_override("outline_size", 7)
	_content.add_child(_title)

	_summary_row = HBoxContainer.new()
	_summary_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_summary_row.add_theme_constant_override("separation", 16)
	_content.add_child(_summary_row)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ModalScroll.configure(scroll)
	_content.add_child(scroll)

	var list_margin := MarginContainer.new()
	list_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_margin.add_theme_constant_override("margin_right", 22)
	scroll.add_child(list_margin)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 14)
	list_margin.add_child(_list)

	var button_host := CenterContainer.new()
	_content.add_child(button_host)
	_back_button = StartActionButton.new()
	_back_button.custom_minimum_size = BACK_BUTTON_SIZE
	_back_button.size = BACK_BUTTON_SIZE
	_back_button.texture_normal = load(START_ACTIVE_TEXTURE) as Texture2D
	_back_button.ignore_texture_size = true
	_back_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	_back_button.pressed.connect(close)
	UiSounds.bind_button(_back_button, &"modal_close")
	button_host.add_child(_back_button)
	var back_label := Label.new()
	back_label.name = "StartLabel"
	back_label.theme_type_variation = &"Hero"
	back_label.add_theme_font_size_override("font_size", 56)
	_back_button.add_child(back_label)


func show_stats(session: GameSession, background: Color) -> void:
	if not is_node_ready():
		await ready
	_background.color = background.darkened(0.25)
	_title.text = LocaleService.text("STATS_TITLE")
	_back_button.set_action_text(LocaleService.text("STATS_BACK"))
	_fill_summary(session)
	_fill_list(session)

	visible = true
	modulate.a = 0.0
	# Slide the whole panel (not `_content`: it lives in a MarginContainer that owns its position).
	position.y = SLIDE_IN_OFFSET
	_kill_tween()
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "modulate:a", 1.0, 0.22).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "position:y", 0.0, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_back_button.set_pulse_active(true)
	for i in _list.get_child_count():
		var row := _list.get_child(i) as Control
		row.modulate.a = 0.0
		_tween.tween_property(row, "modulate:a", 1.0, 0.2).set_delay(0.12 + minf(float(i) * 0.04, 0.8))


func close() -> void:
	if not visible:
		return
	_kill_tween()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.16)
	_tween.tween_callback(func() -> void:
		visible = false
		_back_button.set_pulse_active(false)
		closed.emit()
	)


func _kill_tween() -> void:
	if _tween:
		_tween.kill()
		_tween = null


# --- Summary ---------------------------------------------------------------

func _fill_summary(session: GameSession) -> void:
	_clear(_summary_row)
	var overtime_rounds := 0
	for entry in session.explosion_log:
		if bool(entry.get("overtime", false)):
			overtime_rounds += 1
	_summary_row.add_child(_build_chip(str(session.rounds_played), LocaleService.text("STATS_ROUNDS")))
	_summary_row.add_child(_build_chip(format_time(session.match_elapsed_seconds), LocaleService.text("STATS_DURATION")))
	_summary_row.add_child(_build_chip(str(session.explosion_log.size()), LocaleService.text("STATS_BOOMS")))
	if overtime_rounds > 0:
		_summary_row.add_child(_build_chip(str(overtime_rounds), LocaleService.text("STATS_OVERTIME")))


func _build_chip(value: String, caption: String) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(196.0, 0.0)
	chip.add_theme_stylebox_override("panel", _card_style(0.3, 26, Color(1.0, 1.0, 1.0, 0.26)))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	chip.add_child(box)
	box.add_child(_label(value, 56, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 4))
	box.add_child(_label(caption, 26, TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	return chip


# --- Players + timeline ----------------------------------------------------

func _fill_list(session: GameSession) -> void:
	_clear(_list)
	_list.add_child(GameResultOverlay.build_section_title(LocaleService.text("STATS_PLAYERS")))
	var players := session.get_stats_players()
	var max_booms := 1
	for player in players:
		max_booms = maxi(max_booms, player.explosions)
	var rank := 0
	for player in players:
		var departed := player.left_reason == GameSession.LEFT_REMOVED
		if not departed:
			rank += 1
		_list.add_child(_build_player_card(player, rank if not departed else 0, session))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 12.0)
	_list.add_child(spacer)
	_list.add_child(GameResultOverlay.build_section_title(LocaleService.text("STATS_TIMELINE")))
	var events := build_timeline(session)
	if events.is_empty():
		_list.add_child(_label(LocaleService.text("STATS_NO_EVENTS"), 30, TEXT_MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	for event in events:
		_list.add_child(_build_timeline_row(event))
	# Rows must not swallow touches, otherwise a drag that starts on a row never scrolls.
	pass_touches_through(_list)


func _build_player_card(player: GamePlayer, rank: int, session: GameSession) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _card_style(0.34 if rank == 1 else 0.26, 30,
		Color(ACCENT, 0.6) if rank == 1 else Color(1.0, 1.0, 1.0, 0.22)))
	if rank == 0:
		card.self_modulate = Color(1.0, 1.0, 1.0, 0.7)
	var margin := _margin(20, 14)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	margin.add_child(row)

	row.add_child(_rank_badge("%d" % rank if rank > 0 else "–"))
	row.add_child(_avatar(player.info.preset_id, 80.0))

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	row.add_child(info)
	info.add_child(_label(player.info.name.to_upper(), 38, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 2))
	info.add_child(_label(_entry_text(player), 25, TEXT_MUTED))
	info.add_child(_label(_exit_text(player), 25, TEXT_MUTED))
	info.add_child(_boom_dots(player.explosions))

	var points := _label(LocaleService.textf("STATS_POINTS", [player.score]), 40, Color(1.0, 0.86, 0.62, 1.0), HORIZONTAL_ALIGNMENT_RIGHT, 3)
	points.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(points)
	return card


func _entry_text(player: GamePlayer) -> String:
	if player.joined_round <= 0 and player.joined_sec <= 0.0:
		return LocaleService.text("STATS_IN_START")
	return LocaleService.textf("STATS_IN_AT", [player.joined_round + 1, format_time(player.joined_sec)])


func _exit_text(player: GamePlayer) -> String:
	match player.left_reason:
		GameSession.LEFT_REMOVED:
			return LocaleService.textf("STATS_OUT_AT", [player.left_round + 1, format_time(player.left_sec)])
		GameSession.LEFT_ELIMINATED:
			return LocaleService.textf("STATS_OUT_KNOCKED", [maxi(player.left_round, 1)])
	return LocaleService.text("STATS_OUT_END")


func _boom_dots(count: int) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.add_child(_label(LocaleService.textf("STATS_EXPLOSIONS", [count]), 25, TEXT_MUTED))
	for i in mini(count, MAX_BOOM_DOTS):
		var dot := Panel.new()
		dot.custom_minimum_size = Vector2(22.0, 22.0)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var style := StyleBoxFlat.new()
		style.bg_color = TAG_COLORS[&"boom"]
		style.border_color = Color(1.0, 0.8, 0.5, 0.9)
		style.set_border_width_all(2)
		style.set_corner_radius_all(11)
		dot.add_theme_stylebox_override("panel", style)
		box.add_child(dot)
	if count > MAX_BOOM_DOTS:
		box.add_child(_label("+%d" % (count - MAX_BOOM_DOTS), 25, TEXT_MUTED))
	return box


## Sorted events: {key, round, sec, name, preset_id, kind}. Join/leave sit between rounds.
static func build_timeline(session: GameSession) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for entry in session.explosion_log:
		var r := int(entry["round"])
		events.append({"key": r * 10, "round": r, "sec": float(entry["sec"]),
			"name": str(entry["name"]), "preset_id": int(entry["preset_id"]), "kind": &"boom"})
	for player in session.get_stats_players():
		if player.joined_round > 0 or player.joined_sec > 0.0:
			events.append({"key": player.joined_round * 10 + 5, "round": player.joined_round + 1,
				"sec": player.joined_sec, "name": player.info.name, "preset_id": player.info.preset_id, "kind": &"join"})
		if player.left_reason == GameSession.LEFT_REMOVED:
			events.append({"key": player.left_round * 10 + 6, "round": player.left_round + 1,
				"sec": player.left_sec, "name": player.info.name, "preset_id": player.info.preset_id, "kind": &"leave"})
		elif player.left_reason == GameSession.LEFT_ELIMINATED:
			events.append({"key": player.left_round * 10 + 1, "round": maxi(player.left_round, 1),
				"sec": player.left_sec, "name": player.info.name, "preset_id": player.info.preset_id, "kind": &"out"})
	events.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["key"]) < int(b["key"]))
	return events


func _build_timeline_row(event: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _card_style(0.18, 22, Color(1.0, 1.0, 1.0, 0.14)))
	var margin := _margin(16, 8)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	row.add_child(_rank_badge(LocaleService.textf("STATS_ROUND_SHORT", [int(event["round"])]), Vector2(84.0, 48.0)))
	var time_label := _label(format_time(float(event["sec"])), 28, TEXT_MUTED)
	time_label.custom_minimum_size.x = 96.0
	row.add_child(time_label)
	row.add_child(_avatar(int(event["preset_id"]), 48.0))
	var name_label := _label(str(event["name"]).to_upper(), 30, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 2)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	row.add_child(_tag(event["kind"]))
	return panel


func _tag(kind: StringName) -> PanelContainer:
	var tag := PanelContainer.new()
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style := StyleBoxFlat.new()
	style.bg_color = TAG_COLORS.get(kind, Color.GRAY)
	style.set_corner_radius_all(18)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	tag.add_theme_stylebox_override("panel", style)
	var keys := {&"boom": "STATS_TAG_BOOM", &"join": "STATS_TAG_JOIN", &"leave": "STATS_TAG_LEAVE", &"out": "STATS_TAG_OUT"}
	tag.add_child(_label(LocaleService.text(keys.get(kind, "STATS_TAG_BOOM")), 24, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 2))
	return tag


# --- Helpers ---------------------------------------------------------------

## Makes `node` and its whole subtree ignore pointer input so the parent ScrollContainer gets drags.
static func pass_touches_through(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		pass_touches_through(child)


static func format_time(seconds: float) -> String:
	var total := maxi(int(seconds), 0)
	return "%02d:%02d" % [total / 60, total % 60]


func _card_style(alpha: float, radius: int, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.99, 0.97, alpha)
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.shadow_color = Color(0.05, 0.03, 0.02, 0.16)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0.0, 3.0)
	return style


func _margin(horizontal: int, vertical: int) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", horizontal)
	margin.add_theme_constant_override("margin_right", horizontal)
	margin.add_theme_constant_override("margin_top", vertical)
	margin.add_theme_constant_override("margin_bottom", vertical)
	return margin


func _label(text: String, font_size: int, color: Color,
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, outline: int = 0) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if outline > 0:
		label.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.5))
		label.add_theme_constant_override("outline_size", outline)
	return label


func _rank_badge(text: String, badge_size: Vector2 = Vector2(60.0, 60.0)) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.custom_minimum_size = badge_size
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var style := StyleBoxFlat.new()
	style.bg_color = Color(ACCENT, 0.88)
	style.set_corner_radius_all(int(badge_size.y * 0.5))
	badge.add_theme_stylebox_override("panel", style)
	badge.add_child(_label(text, 26, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER))
	return badge


func _avatar(preset_id: int, side: float) -> TextureRect:
	var avatar := TextureRect.new()
	avatar.custom_minimum_size = Vector2(side, side)
	avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	avatar.texture = load(SLIME_PATH % preset_id) as Texture2D
	avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return avatar


func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
