class_name OnboardingOverlay
extends CanvasLayer

signal skip_pressed
signal continue_pressed

const DIM_COLOR := Color(0.04, 0.03, 0.025, 0.78)
const PANEL_BG := Color(0.14, 0.1, 0.08, 0.96)
const PANEL_BORDER := Color(0.78, 0.48, 0.28, 0.92)
const NOTICE_BG := Color(0.2, 0.1, 0.08, 0.94)
const NOTICE_BORDER := Color(0.92, 0.42, 0.28, 0.95)
const TITLE_COLOR := Color(0.99, 0.96, 0.9, 1.0)
const BODY_COLOR := Color(0.92, 0.88, 0.82, 0.95)
const NOTICE_COLOR := Color(0.98, 0.86, 0.72, 1.0)
const SIDE_MARGIN := 24.0
const BOTTOM_MARGIN := 20.0
const PANEL_GAP := 12.0
const SPOTLIGHT_PAD := 18.0
const SPOTLIGHT_MIN_RADIUS := 56.0
const START_ACTIVE_TEXTURE := preload("res://assets/party_kitchen/buttons/start_active.svg")
const START_INACTIVE_TEXTURE := preload("res://assets/party_kitchen/buttons/start_inactive.svg")
const SPOTLIGHT_SHADER := preload("res://assets/shaders/onboarding_spotlight.gdshader")

const DEFAULT_SKIP_LABEL := "Пропустить"
const SKIP_BUTTON_SIZE_SCALE := 0.9

var _root: Control
var _full_dim: ColorRect
var _dim_top: ColorRect
var _dim_bottom: ColorRect
var _dim_left: ColorRect
var _dim_right: ColorRect
var _spotlight_visual: ColorRect
var _spotlight_material: ShaderMaterial
var _bottom_margin: MarginContainer
var _bottom_dock: VBoxContainer
var _notice_panel: PanelContainer
var _notice_label: Label
var _coach: PanelContainer
var _body_scroll: ScrollContainer
var _title: Label
var _body: Label
var _skip_button: StartActionButton
var _continue_button: StartActionButton
var _spotlight_center := Vector2.ZERO
var _spotlight_radius := 0.0
var _spotlight_hole := Rect2()
var _use_spotlight := false
var _focus_control: Control
var _pass_through := false


func _ready() -> void:
	layer = 50
	visible = false
	_build_ui()
	get_viewport().size_changed.connect(_on_viewport_resized)


func _on_viewport_resized() -> void:
	if visible:
		_layout_dim()
		_layout_bottom_panel()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_full_dim = _make_dim_rect()
	_full_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(_full_dim)

	for name in ["Top", "Bottom", "Left", "Right"]:
		var dim := _make_dim_rect()
		dim.name = "Dim%s" % name
		dim.visible = false
		dim.mouse_filter = Control.MOUSE_FILTER_STOP
		_root.add_child(dim)
		match name:
			"Top":
				_dim_top = dim
			"Bottom":
				_dim_bottom = dim
			"Left":
				_dim_left = dim
			"Right":
				_dim_right = dim

	_spotlight_material = ShaderMaterial.new()
	_spotlight_material.shader = SPOTLIGHT_SHADER
	_spotlight_material.set_shader_parameter("dim_color", DIM_COLOR)
	_spotlight_visual = ColorRect.new()
	_spotlight_visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_spotlight_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spotlight_visual.material = _spotlight_material
	_spotlight_visual.visible = false
	_root.add_child(_spotlight_visual)

	_bottom_margin = MarginContainer.new()
	_bottom_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bottom_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_bottom_margin)

	var bottom_anchor := Control.new()
	bottom_anchor.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bottom_anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bottom_margin.add_child(bottom_anchor)

	_bottom_dock = VBoxContainer.new()
	_bottom_dock.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bottom_dock.add_theme_constant_override("separation", int(PANEL_GAP))
	_bottom_dock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_anchor.add_child(_bottom_dock)

	_notice_panel = PanelContainer.new()
	_notice_panel.visible = false
	_notice_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var notice_style := StyleBoxFlat.new()
	notice_style.bg_color = NOTICE_BG
	notice_style.border_color = NOTICE_BORDER
	notice_style.set_border_width_all(2)
	notice_style.set_corner_radius_all(14)
	notice_style.content_margin_left = 20.0
	notice_style.content_margin_top = 14.0
	notice_style.content_margin_right = 20.0
	notice_style.content_margin_bottom = 14.0
	_notice_panel.add_theme_stylebox_override("panel", notice_style)
	_bottom_dock.add_child(_notice_panel)

	_notice_label = Label.new()
	_notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice_label.add_theme_font_size_override("font_size", 30)
	_notice_label.add_theme_color_override("font_color", NOTICE_COLOR)
	_notice_panel.add_child(_notice_label)

	_coach = PanelContainer.new()
	_coach.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_BG
	style.border_color = PANEL_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.content_margin_left = 20.0
	style.content_margin_top = 16.0
	style.content_margin_right = 20.0
	style.content_margin_bottom = 16.0
	_coach.add_theme_stylebox_override("panel", style)
	_bottom_dock.add_child(_coach)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	_coach.add_child(col)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_font_size_override("font_size", 40)
	_title.add_theme_color_override("font_color", TITLE_COLOR)
	col.add_child(_title)

	_body_scroll = ScrollContainer.new()
	_body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(_body_scroll)

	_body = Label.new()
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_theme_font_size_override("font_size", 30)
	_body.add_theme_color_override("font_color", BODY_COLOR)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body_scroll.add_child(_body)

	_skip_button = _create_start_style_button(DEFAULT_SKIP_LABEL)
	_skip_button.pressed.connect(_on_skip_pressed)
	_bottom_dock.add_child(_skip_button)

	_continue_button = _create_start_style_button("Понятно")
	_continue_button.visible = false
	_continue_button.pressed.connect(_on_continue_pressed)
	_bottom_dock.add_child(_continue_button)

	_layout_bottom_panel()


func _create_start_style_button(action_label: String) -> StartActionButton:
	var button := StartActionButton.new()
	button.texture_normal = START_ACTIVE_TEXTURE
	button.texture_disabled = START_INACTIVE_TEXTURE
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.clip_contents = false
	button.enable_pulse = false
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var label := Label.new()
	label.name = "StartLabel"
	label.theme_type_variation = &"Hero"
	label.add_theme_font_size_override("font_size", StartActionButton.DESIGN_FONT_SIZE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)
	button.action_text = action_label
	UiSounds.bind_button(button, &"confirm")
	return button


func _apply_start_style_button_layout(
	button: StartActionButton,
	viewport_size: Vector2,
	size_scale: float = 1.0
) -> void:
	if button == null:
		return
	var scale := StartActionButton.viewport_cover_scale(viewport_size)
	var button_size := StartActionButton.DESIGN_ACTION_SIZE * scale * size_scale
	button.custom_minimum_size = button_size
	button.size = button_size
	var label := button.get_node_or_null("StartLabel") as Label
	if label:
		label.add_theme_font_size_override(
			"font_size",
			maxi(32, int(round(StartActionButton.DESIGN_FONT_SIZE * scale * size_scale)))
		)
	button.refresh_label_layout()
	button.set_pulse_active(button.visible and not button.disabled)


func _make_dim_rect() -> ColorRect:
	var dim := ColorRect.new()
	dim.color = DIM_COLOR
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return dim


func show_step(title: String, body: String, show_skip: bool = true) -> void:
	show_step_with_notice(title, body, "", show_skip)


func show_step_with_notice(title: String, body: String, notice: String, show_skip: bool = true) -> void:
	_title.text = title
	_body.text = body
	_set_notice(notice)
	_skip_button.action_text = DEFAULT_SKIP_LABEL
	_skip_button.visible = show_skip
	_continue_button.visible = false
	visible = true
	call_deferred("_layout_bottom_panel")
	_layout_dim()


func _set_notice(notice: String) -> void:
	var trimmed := notice.strip_edges()
	_notice_label.text = trimmed
	_notice_panel.visible = not trimmed.is_empty()


func set_pass_through(enabled: bool) -> void:
	_pass_through = enabled
	if enabled:
		_use_spotlight = false
		_focus_control = null
	_layout_dim()


func hide_overlay() -> void:
	visible = false
	_use_spotlight = false
	_pass_through = false
	_continue_button.visible = false
	_focus_control = null
	_set_notice("")


func set_spotlight_control(target: Control, padding: float = SPOTLIGHT_PAD) -> void:
	_focus_control = target
	if target == null or not is_instance_valid(target):
		clear_spotlight()
		return
	_apply_spotlight_from_rect(target.get_global_rect(), padding)
	call_deferred("_refresh_focus_spotlight")


func set_spotlight_circle(center: Vector2, radius: float) -> void:
	_focus_control = null
	_apply_spotlight_from_circle(center, radius)


func set_spotlight_controls(targets: Array, padding: float = SPOTLIGHT_PAD) -> void:
	_focus_control = null
	var merged := Rect2()
	var has_rect := false
	for target in targets:
		if target == null or not is_instance_valid(target):
			continue
		var rect: Rect2 = target.get_global_rect()
		if not has_rect:
			merged = rect
			has_rect = true
		else:
			merged = merged.merge(rect)
	if not has_rect:
		clear_spotlight()
		return
	_apply_spotlight_from_rect(merged, padding)
	call_deferred("_refresh_focus_spotlight")


func _refresh_focus_spotlight() -> void:
	if not visible or _focus_control == null or not is_instance_valid(_focus_control):
		return
	_apply_spotlight_from_rect(_focus_control.get_global_rect(), SPOTLIGHT_PAD)


func _process(_delta: float) -> void:
	if not visible or not _use_spotlight or _focus_control == null:
		return
	if not is_instance_valid(_focus_control):
		return
	_apply_spotlight_from_rect(_focus_control.get_global_rect(), SPOTLIGHT_PAD)


func _apply_spotlight_from_rect(rect: Rect2, padding: float) -> void:
	var center := rect.get_center()
	var half := rect.size * 0.5
	var radius := maxf(half.length() + padding, SPOTLIGHT_MIN_RADIUS)
	_apply_spotlight_from_circle(center, radius)


func _apply_spotlight_from_circle(center: Vector2, radius: float) -> void:
	_spotlight_center = center
	_spotlight_radius = maxf(radius, SPOTLIGHT_MIN_RADIUS)
	_spotlight_hole = Rect2(
		center - Vector2.ONE * _spotlight_radius,
		Vector2.ONE * _spotlight_radius * 2.0
	)
	_use_spotlight = true
	_layout_dim()


func clear_spotlight() -> void:
	_focus_control = null
	_use_spotlight = false
	_layout_dim()


func set_continue_visible(show: bool, label: String = "Понятно") -> void:
	_continue_button.action_text = label
	_continue_button.visible = show
	if show:
		_skip_button.visible = false
	else:
		_skip_button.action_text = DEFAULT_SKIP_LABEL
	call_deferred("_layout_bottom_panel")


func set_bottom_action(label: String, visible: bool = true) -> void:
	_skip_button.action_text = label
	_skip_button.visible = visible
	_continue_button.visible = false
	call_deferred("_layout_bottom_panel")


func _layout_bottom_panel() -> void:
	if not is_inside_tree():
		return
	var viewport := get_viewport().get_visible_rect()
	var scale := StartActionButton.viewport_cover_scale(viewport.size)
	var side := int(SIDE_MARGIN * scale)
	var bottom := int(BOTTOM_MARGIN * scale)
	_bottom_margin.add_theme_constant_override("margin_left", side)
	_bottom_margin.add_theme_constant_override("margin_right", side)
	_bottom_margin.add_theme_constant_override("margin_bottom", bottom)

	_apply_start_style_button_layout(_skip_button, viewport.size, SKIP_BUTTON_SIZE_SCALE)
	if _continue_button.visible:
		_apply_start_style_button_layout(_continue_button, viewport.size)

	var text_width := maxi(int(viewport.size.x) - side * 2 - 48, 120)
	_body.custom_minimum_size = Vector2(text_width, 0.0)
	_body.size.x = text_width
	call_deferred("_finish_bottom_panel_layout", viewport, side)


func _finish_bottom_panel_layout(viewport: Rect2, side: int) -> void:
	if not visible:
		return
	var max_dock_h := viewport.size.y * 0.42
	_bottom_dock.custom_minimum_size = Vector2.ZERO
	var dock_h := minf(_bottom_dock.get_minimum_size().y, max_dock_h)
	if dock_h < 1.0:
		dock_h = max_dock_h
	_bottom_dock.custom_minimum_size.y = dock_h
	_bottom_dock.offset_top = -dock_h
	var content_h := _measure_body_height(_body.custom_minimum_size.x)
	var max_body_h := maxf(72.0, dock_h * 0.42)
	var scroll_h := minf(maxf(content_h, 1.0), max_body_h)
	_body.custom_minimum_size.y = content_h
	_body_scroll.custom_minimum_size = Vector2(0.0, scroll_h)


func _measure_body_height(text_width: float) -> float:
	if _body.text.is_empty() or text_width <= 0.0:
		return 0.0
	var font: Font = _body.get_theme_font(&"font")
	if font == null:
		font = ThemeDB.fallback_font
	var font_size := _body.get_theme_font_size(&"font_size")
	return font.get_multiline_string_size(
		_body.text,
		_body.horizontal_alignment,
		text_width,
		font_size,
		TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	).y


func _layout_dim() -> void:
	if not visible:
		return
	if _pass_through:
		_full_dim.visible = false
		_hide_spotlight_layers()
		return
	if not _use_spotlight:
		_full_dim.visible = true
		_hide_spotlight_layers()
		return

	_full_dim.visible = false
	_spotlight_visual.visible = true
	_dim_top.visible = true
	_dim_bottom.visible = true
	_dim_left.visible = true
	_dim_right.visible = true

	var viewport := get_viewport().get_visible_rect()
	var hole := _spotlight_hole
	hole.position = hole.position - viewport.position

	_dim_top.position = Vector2.ZERO
	_dim_top.size = Vector2(viewport.size.x, maxf(0.0, hole.position.y))

	_dim_bottom.position = Vector2(0.0, hole.end.y)
	_dim_bottom.size = Vector2(viewport.size.x, maxf(0.0, viewport.size.y - hole.end.y))

	_dim_left.position = Vector2(0.0, hole.position.y)
	_dim_left.size = Vector2(maxf(0.0, hole.position.x), hole.size.y)

	_dim_right.position = Vector2(hole.end.x, hole.position.y)
	_dim_right.size = Vector2(maxf(0.0, viewport.size.x - hole.end.x), hole.size.y)

	var center := _spotlight_center - viewport.position
	_spotlight_material.set_shader_parameter("viewport_size", viewport.size)
	_spotlight_material.set_shader_parameter("hole_center_px", center)
	_spotlight_material.set_shader_parameter("hole_radius_px", _spotlight_radius)


func _hide_spotlight_layers() -> void:
	_spotlight_visual.visible = false
	_dim_top.visible = false
	_dim_bottom.visible = false
	_dim_left.visible = false
	_dim_right.visible = false


func _on_skip_pressed() -> void:
	skip_pressed.emit()


func _on_continue_pressed() -> void:
	continue_pressed.emit()
