class_name BattleSplashOverlay
extends PanelContainer

signal finished

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const CONTENT_WIDTH_MARGIN := 200.0
const CONTENT_ANCHOR := Vector2(540.0, 930.0)
const SHOW_DURATION := 3.5
const PLAYER_PILL_SCALE := 1.45

var _headline: Label
var _body: Label
var _player_strip: GamePlayerStrip
var _pill_host: CenterContainer
var _content_col: VBoxContainer
var _margin_host: MarginContainer
var _position_host: Control
var _token: int = 0
var _closing: bool = false


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
	_content_col.add_theme_constant_override("separation", 28)
	_position_host.add_child(_content_col)

	var headline_wrap := MarginContainer.new()
	headline_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	headline_wrap.add_theme_constant_override("margin_left", 12)
	headline_wrap.add_theme_constant_override("margin_right", 12)
	_content_col.add_child(headline_wrap)

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
	_content_col.add_child(_pill_host)

	_player_strip = GamePlayerStrip.new()
	_player_strip.set_visual_scale(PLAYER_PILL_SCALE)
	_pill_host.add_child(_player_strip)

	var body_wrap := MarginContainer.new()
	body_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_wrap.add_theme_constant_override("margin_left", 16)
	body_wrap.add_theme_constant_override("margin_right", 16)
	_content_col.add_child(body_wrap)

	_body = Label.new()
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.add_theme_font_size_override("font_size", 36)
	_body.add_theme_color_override("font_color", Color(0.96, 0.9, 0.82, 1.0))
	_body.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.04, 0.82))
	_body.add_theme_constant_override("outline_size", 4)
	body_wrap.add_child(_body)


func _gui_input(event: InputEvent) -> void:
	if not visible or _closing:
		return
	var tapped := false
	if event is InputEventScreenTouch:
		tapped = (event as InputEventScreenTouch).pressed
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		tapped = mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
	if tapped:
		accept_event()
		_finish()


func show_splash(title: String, body: String, player: GamePlayer = null) -> void:
	_closing = false
	_token += 1
	var token := _token
	_headline.text = title
	_body.text = body
	_body.visible = not body.is_empty()
	if player != null:
		_player_strip.set_visual_scale(PLAYER_PILL_SCALE)
		_player_strip.set_player(player)
		_pill_host.visible = true
	else:
		_pill_host.visible = false
	size = get_parent().size if get_parent() is Control else DESIGN_SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true
	modulate.a = 0.0
	_layout_content()
	call_deferred("_layout_content")
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.16).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	var tree := get_tree()
	if tree:
		tree.create_timer(SHOW_DURATION).timeout.connect(
			func() -> void:
				if token == _token:
					_finish(),
			CONNECT_ONE_SHOT
		)


func hide_overlay() -> void:
	_token += 1
	_closing = false
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
	_content_col.reset_size()
	var col_size := _content_col.get_combined_minimum_size()
	col_size.x = content_width
	_content_col.size = col_size
	_content_col.position = Vector2(
		(_position_host.size.x - content_width) * 0.5,
		CONTENT_ANCHOR.y - col_size.y * 0.48
	)
