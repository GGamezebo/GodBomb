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

## Skip pill is pinned to the top-right corner on every step (design px, × cover scale).
const SKIP_PILL_SIZE := Vector2(300.0, 84.0)
const SKIP_PILL_MARGIN := Vector2(28.0, 36.0)
const TOP_DOCK_GAP := 24.0
## Max share of the screen height the coach dock may take.
const MAX_DOCK_SHARE := 0.36
## Extra clearance around the spotlight hole (covers the breathing ring).
const HOLE_CLEARANCE := 28.0
const COACH_ICON_SIZE := 84.0
const PROGRESS_DONE := Color(0.88, 0.62, 0.38, 1.0)
const PROGRESS_TODO := Color(1.0, 1.0, 1.0, 0.18)
const PROGRESS_DOT := 18.0

var _root: Control
var _full_dim: ColorRect
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
var _progress_row: HBoxContainer
var _progress_dots: HBoxContainer
var _progress_label: Label
var _progress_current := 0
var _progress_total := 0
var _coach_tween: Tween
var _dock_on_top := false
var _gesture: OnboardingGestureHint
var _coach_icon: OnboardingGestureHint
var _skip_button: Button
var _continue_button: StartActionButton
var _spotlight_center := Vector2.ZERO
var _spotlight_radius := 0.0
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

	_spotlight_material = ShaderMaterial.new()
	_spotlight_material.shader = SPOTLIGHT_SHADER
	_spotlight_material.set_shader_parameter("dim_color", DIM_COLOR)
	_spotlight_visual = ColorRect.new()
	_spotlight_visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_spotlight_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spotlight_visual.material = _spotlight_material
	_spotlight_visual.visible = false
	_root.add_child(_spotlight_visual)

	_gesture = OnboardingGestureHint.new()
	_gesture.visible = false
	_root.add_child(_gesture)

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

	_progress_row = HBoxContainer.new()
	_progress_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_progress_row.add_theme_constant_override("separation", 14)
	_progress_row.visible = false
	col.add_child(_progress_row)
	_progress_dots = HBoxContainer.new()
	_progress_dots.add_theme_constant_override("separation", 8)
	_progress_row.add_child(_progress_dots)
	_progress_label = Label.new()
	_progress_label.add_theme_font_size_override("font_size", 30)
	_progress_label.add_theme_color_override("font_color", Color(PROGRESS_DONE, 0.9))
	_progress_row.add_child(_progress_label)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 12)
	col.add_child(title_row)
	_coach_icon = OnboardingGestureHint.new()
	_coach_icon.icon_mode = true
	_coach_icon.custom_minimum_size = Vector2(COACH_ICON_SIZE, COACH_ICON_SIZE)
	_coach_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	title_row.add_child(_coach_icon)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.add_theme_font_size_override("font_size", 40)
	_title.add_theme_color_override("font_color", TITLE_COLOR)
	title_row.add_child(_title)
	# Mirror of the icon so the title stays centered.
	var title_balance := Control.new()
	title_balance.custom_minimum_size = Vector2(COACH_ICON_SIZE, 0.0)
	title_row.add_child(title_balance)

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

	_skip_button = _create_skip_pill()
	_skip_button.pressed.connect(_on_skip_pressed)
	_root.add_child(_skip_button)

	_continue_button = _create_start_style_button(LocaleService.text("ONBOARDING_GOT_IT"))
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


func _create_skip_pill() -> Button:
	var button := Button.new()
	button.name = "SkipPill"
	button.text = LocaleService.text("ONBOARDING_SKIP")
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	button.add_theme_color_override("font_color", TITLE_COLOR)
	button.add_theme_color_override("font_hover_color", TITLE_COLOR)
	button.add_theme_color_override("font_pressed_color", NOTICE_COLOR)
	button.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.7))
	button.add_theme_constant_override("outline_size", 3)
	for state in ["normal", "hover", "pressed", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(PANEL_BG, 0.92 if state != "pressed" else 1.0)
		style.border_color = Color(PANEL_BORDER, 0.75 if state == "normal" else 1.0)
		style.set_border_width_all(2)
		style.set_corner_radius_all(42)
		style.content_margin_left = 24.0
		style.content_margin_right = 24.0
		style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
		style.shadow_size = 6
		button.add_theme_stylebox_override(state, style)
	UiSounds.bind_button(button)
	return button


func _apply_start_style_button_layout(
	button: StartActionButton,
	viewport_size: Vector2,
	size_scale: float = 1.0
) -> void:
	if button == null:
		return
	var cover_scale := StartActionButton.viewport_cover_scale(viewport_size)
	var button_size := StartActionButton.DESIGN_ACTION_SIZE * cover_scale * size_scale
	button.custom_minimum_size = button_size
	button.size = button_size
	var label := button.get_node_or_null("StartLabel") as Label
	if label:
		label.add_theme_font_size_override(
			"font_size",
			maxi(32, int(round(StartActionButton.DESIGN_FONT_SIZE * cover_scale * size_scale)))
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


## Step counter above the title; total <= 0 hides it.
func set_progress(current: int, total: int) -> void:
	_progress_current = current
	_progress_total = total
	_progress_row.visible = total > 0
	if total <= 0:
		return
	for child in _progress_dots.get_children():
		_progress_dots.remove_child(child)
		child.queue_free()
	for i in total:
		var dot := Panel.new()
		var active := i == current - 1
		dot.custom_minimum_size = Vector2(PROGRESS_DOT * (2.2 if active else 1.0), PROGRESS_DOT)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var style := StyleBoxFlat.new()
		style.bg_color = PROGRESS_DONE if i < current else PROGRESS_TODO
		style.set_corner_radius_all(int(PROGRESS_DOT * 0.5))
		dot.add_theme_stylebox_override("panel", style)
		_progress_dots.add_child(dot)
	_progress_label.text = LocaleService.textf("ONBOARDING_STEP", [current, total])


func show_step_with_notice(title: String, body: String, notice: String, show_skip: bool = true) -> void:
	var is_new_step := not visible or _title.text != title
	if is_new_step:
		set_gesture(OnboardingGestureHint.Gesture.NONE)
	_title.text = title
	_body.text = body
	_set_notice(notice)
	_skip_button.text = LocaleService.text("ONBOARDING_SKIP")
	_skip_button.visible = show_skip
	_continue_button.visible = false
	visible = true
	call_deferred("_layout_bottom_panel")
	_layout_dim()
	if is_new_step:
		_play_coach_entrance()


func _play_coach_entrance() -> void:
	if _coach_tween:
		_coach_tween.kill()
	_coach.modulate.a = 0.0
	_title.scale = Vector2(0.92, 0.92)
	_title.pivot_offset = Vector2(_title.size.x * 0.5, _title.size.y * 0.5)
	_coach_tween = create_tween().set_parallel()
	_coach_tween.tween_property(_coach, "modulate:a", 1.0, 0.24).set_trans(Tween.TRANS_SINE)
	_coach_tween.tween_property(_title, "scale", Vector2.ONE, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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


## Animated hint over `from` (tap / hold) or `from`→`to` (drag); `point` when no control.
## The coach card shows the same gesture as a small icon.
func set_gesture(
	kind: OnboardingGestureHint.Gesture,
	from: Control = null,
	to: Control = null,
	point: Vector2 = Vector2.INF
) -> void:
	var on_screen := kind in [OnboardingGestureHint.Gesture.TAP, OnboardingGestureHint.Gesture.HOLD, OnboardingGestureHint.Gesture.DRAG]
	if on_screen and from == null and not point.is_finite():
		on_screen = false
	_gesture.show_gesture(kind if on_screen else OnboardingGestureHint.Gesture.NONE, from, to, point)
	_coach_icon.show_gesture(kind)
	_coach_icon.visible = true
	_coach_icon.modulate.a = 1.0 if kind != OnboardingGestureHint.Gesture.NONE else 0.0


## The big action button in the coach dock (for pointing a gesture at it).
func action_button() -> Control:
	return _continue_button


func hide_overlay() -> void:
	_gesture.clear()
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
	_use_spotlight = true
	_layout_dim()
	_update_dock_side()


func _input(event: InputEvent) -> void:
	if not visible or _pass_through or not _use_spotlight:
		return
	if not _is_spotlight_blocking_event(event):
		return
	var pos := _event_global_position(event)
	if pos.distance_to(_spotlight_center) <= _spotlight_radius:
		return
	if _is_overlay_chrome_click(pos):
		return
	get_viewport().set_input_as_handled()


func _is_overlay_chrome_click(pos: Vector2) -> bool:
	if _bottom_dock.get_global_rect().has_point(pos):
		return true
	if _skip_button.visible and _skip_button.get_global_rect().has_point(pos):
		return true
	return false


func _is_spotlight_blocking_event(event: InputEvent) -> bool:
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).pressed
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).pressed
	return false


func _event_global_position(event: InputEvent) -> Vector2:
	if event is InputEventMouseButton:
		return (event as InputEventMouseButton).global_position
	if event is InputEventMouseMotion:
		return (event as InputEventMouseMotion).global_position
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).position
	if event is InputEventScreenDrag:
		return (event as InputEventScreenDrag).position
	return Vector2.ZERO


func clear_spotlight() -> void:
	_focus_control = null
	_use_spotlight = false
	_layout_dim()
	_update_dock_side()


func set_continue_visible(continue_visible: bool, label: String = "") -> void:
	_continue_button.action_text = label if not label.is_empty() else LocaleService.text("ONBOARDING_GOT_IT")
	_continue_button.visible = continue_visible
	if continue_visible:
		_skip_button.visible = false
	else:
		_skip_button.text = LocaleService.text("ONBOARDING_SKIP")
	call_deferred("_layout_bottom_panel")


## Big action in the coach dock (e.g. «To menu» on results); replaces the skip pill.
func set_bottom_action(label: String, action_visible: bool = true) -> void:
	_continue_button.action_text = label
	_continue_button.visible = action_visible
	_skip_button.visible = not action_visible
	call_deferred("_layout_bottom_panel")


func _layout_bottom_panel() -> void:
	if not is_inside_tree():
		return
	var viewport := get_viewport().get_visible_rect()
	var cover_scale := StartActionButton.viewport_cover_scale(viewport.size)
	var side := int(SIDE_MARGIN * cover_scale)
	var bottom := int(BOTTOM_MARGIN * cover_scale)
	_bottom_margin.add_theme_constant_override("margin_left", side)
	_bottom_margin.add_theme_constant_override("margin_right", side)
	_bottom_margin.add_theme_constant_override("margin_bottom", bottom)

	_layout_skip_pill(cover_scale)
	if _continue_button.visible:
		_apply_start_style_button_layout(_continue_button, viewport.size)

	var text_width := maxi(int(viewport.size.x) - side * 2 - 48, 120)
	_body.custom_minimum_size = Vector2(text_width, 0.0)
	_body.size.x = text_width
	call_deferred("_finish_bottom_panel_layout", viewport)


func _layout_skip_pill(cover_scale: float) -> void:
	var pill := SKIP_PILL_SIZE * cover_scale
	var margin := SKIP_PILL_MARGIN * cover_scale
	_skip_button.add_theme_font_size_override("font_size", maxi(26, int(round(34.0 * cover_scale))))
	_skip_button.custom_minimum_size = pill
	_skip_button.offset_left = -margin.x - pill.x
	_skip_button.offset_right = -margin.x
	_skip_button.offset_top = margin.y
	_skip_button.offset_bottom = margin.y + pill.y


func _finish_bottom_panel_layout(viewport: Rect2) -> void:
	if not visible:
		return
	var max_dock_h := viewport.size.y * MAX_DOCK_SHARE
	# Small slack: measured wrap height can be a few px short of the Label's own.
	var content_h := _measure_body_height(_body.custom_minimum_size.x) + 8.0
	_body.custom_minimum_size.y = content_h
	_body_scroll.custom_minimum_size = Vector2(0.0, maxf(content_h, 1.0))
	_body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_bottom_dock.custom_minimum_size = Vector2.ZERO
	var dock_h := _bottom_dock.get_minimum_size().y
	if dock_h > max_dock_h:
		# Too tall: let the body scroll instead of growing past the cap.
		_body_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		_body_scroll.custom_minimum_size.y = maxf(72.0, content_h - (dock_h - max_dock_h))
		dock_h = max_dock_h
	_bottom_dock.custom_minimum_size.y = dock_h
	_apply_dock_side(viewport, dock_h)


## Coach goes to the top when the spotlight hole would sit under the bottom dock.
func _update_dock_side() -> void:
	if not visible or not is_inside_tree():
		return
	var viewport := get_viewport().get_visible_rect()
	var dock_h := maxf(_bottom_dock.custom_minimum_size.y, _bottom_dock.size.y)
	var on_top := _wants_top_dock(viewport, dock_h)
	if on_top != _dock_on_top:
		_apply_dock_side(viewport, dock_h)


func _wants_top_dock(viewport: Rect2, dock_h: float) -> bool:
	if not _use_spotlight or _pass_through:
		return false
	var cover_scale := StartActionButton.viewport_cover_scale(viewport.size)
	var bottom_edge := viewport.size.y - BOTTOM_MARGIN * cover_scale
	var dock_top := bottom_edge - dock_h
	var hole_bottom := _spotlight_center.y - viewport.position.y + _spotlight_radius + HOLE_CLEARANCE
	return hole_bottom > dock_top


func _apply_dock_side(viewport: Rect2, dock_h: float) -> void:
	_dock_on_top = _wants_top_dock(viewport, dock_h)
	if _dock_on_top:
		var cover_scale := StartActionButton.viewport_cover_scale(viewport.size)
		var top := (SKIP_PILL_MARGIN.y + SKIP_PILL_SIZE.y + TOP_DOCK_GAP) * cover_scale
		_bottom_dock.set_anchors_preset(Control.PRESET_TOP_WIDE)
		_bottom_dock.offset_top = top
		_bottom_dock.offset_bottom = top + dock_h
	else:
		_bottom_dock.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_bottom_dock.offset_top = -dock_h
		_bottom_dock.offset_bottom = 0.0


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
		_spotlight_visual.visible = false
		return
	if not _use_spotlight:
		_full_dim.visible = true
		_spotlight_visual.visible = false
		return

	_full_dim.visible = false
	_spotlight_visual.visible = true

	var viewport := get_viewport().get_visible_rect()
	var center := _spotlight_center - viewport.position
	_spotlight_material.set_shader_parameter("viewport_size", viewport.size)
	_spotlight_material.set_shader_parameter("hole_center_px", center)
	_spotlight_material.set_shader_parameter("hole_radius_px", _spotlight_radius)


func _on_skip_pressed() -> void:
	skip_pressed.emit()


func _on_continue_pressed() -> void:
	continue_pressed.emit()
