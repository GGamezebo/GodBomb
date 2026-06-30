class_name LanguageFlagPicker
extends Control

signal language_selected(index: int)

const FLAG_ASPECT := 56.0 / 80.0
const IDEAL_FLAG_WIDTH := 152.0
const SELECTED_SCALE := 1.5
const NORMAL_SCALE := 1.0
const GRID_COLUMNS := 4
const ANIM_SEC := 0.22
const GLOW_COLOR := Color(0.98, 0.72, 0.38, 0.95)
const FALLBACK_WIDTH := 920.0
const UiTouchTargets = preload("res://src/common/ui/ui_touch_targets.gd")

var _center: CenterContainer
var _grid: GridContainer
var _slots: Array[Control] = []
var _glows: Array[Panel] = []
var _hit_buttons: Array[Button] = []
var _flag_visuals: Array[TextureRect] = []
var _selected_index := -1
var _block_signals := false
var _tweens: Dictionary = {}
var _metrics: Dictionary = {}
var _last_applied_width := -1.0


func _ready() -> void:
	_build_nodes()
	rebuild()


func rebuild() -> void:
	_clear_grid()
	_metrics = _compute_metrics(_get_available_width())
	_grid.add_theme_constant_override("h_separation", int(_metrics.gap))
	_grid.add_theme_constant_override("v_separation", int(_metrics.gap))
	_update_root_height()
	for i in LocaleCatalog.ORDER.size():
		var code := LocaleCatalog.ORDER[i]
		var slot := _create_slot(code, i)
		_grid.add_child(slot)
		_slots.append(slot)
	_selected_index = -1
	call_deferred("_sync_layout")


func set_selected_index(index: int, animate: bool = true) -> void:
	if index < 0 or index >= _slots.size():
		return
	if _selected_index == index:
		return
	var previous := _selected_index
	_selected_index = index
	if previous >= 0:
		_apply_slot_state(previous, false, animate)
	else:
		for i in _slots.size():
			if i != index:
				_apply_slot_state(i, false, false)
	_apply_slot_state(index, true, animate)


func get_selected_index() -> int:
	return _selected_index


func _build_nodes() -> void:
	_center = CenterContainer.new()
	_center.name = "Center"
	_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_center)

	_grid = GridContainer.new()
	_grid.name = "Grid"
	_grid.columns = GRID_COLUMNS
	_center.add_child(_grid)

	resized.connect(_sync_layout)
	call_deferred("_sync_layout")


func _sync_layout() -> void:
	if _center == null:
		return
	_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var avail_w := _get_available_width()
	if _slots.is_empty():
		_metrics = _compute_metrics(avail_w)
		_update_root_height()
		return
	if absf(avail_w - _last_applied_width) < 0.5 and not _metrics.is_empty():
		return

	_last_applied_width = avail_w
	_metrics = _compute_metrics(avail_w)
	_grid.add_theme_constant_override("h_separation", int(_metrics.gap))
	_grid.add_theme_constant_override("v_separation", int(_metrics.gap))
	_update_root_height()
	for i in _slots.size():
		_apply_metrics_to_slot(i)


func _get_available_width() -> float:
	if size.x > 1.0:
		return size.x
	var parent_ctrl := get_parent_control()
	if parent_ctrl and parent_ctrl.size.x > 1.0:
		return parent_ctrl.size.x
	var viewport := get_viewport()
	if viewport:
		return maxf(viewport.get_visible_rect().size.x - 160.0, 320.0)
	return FALLBACK_WIDTH


func _compute_metrics(available_width: float) -> Dictionary:
	var width := maxf(available_width, 280.0)
	var gap := clampf(width * 0.012, 8.0, 14.0)
	var slot_w := (width - gap * float(GRID_COLUMNS - 1)) / float(GRID_COLUMNS)
	slot_w = maxf(slot_w, 48.0)
	var margin := maxf(6.0, slot_w * 0.075)
	var flag_w := (slot_w - margin * 2.0) / SELECTED_SCALE
	var flag_h := flag_w * FLAG_ASPECT

	if flag_w > IDEAL_FLAG_WIDTH:
		flag_w = IDEAL_FLAG_WIDTH
		flag_h = flag_w * FLAG_ASPECT
		slot_w = flag_w * SELECTED_SCALE + margin * 2.0

	var slot_h := flag_h * SELECTED_SCALE + margin * 2.0
	return {
		"flag_size": Vector2(flag_w, flag_h),
		"slot_size": Vector2(slot_w, slot_h),
		"gap": gap,
		"margin": margin,
	}


func _update_root_height() -> void:
	var rows := ceili(float(LocaleCatalog.ORDER.size()) / float(GRID_COLUMNS))
	var gap: float = _metrics.get("gap", 12.0)
	var slot_h: float = _metrics.get("slot_size", Vector2.ZERO).y
	custom_minimum_size.y = slot_h * rows + gap * maxf(float(rows) - 1.0, 0.0) + 8.0


func _clear_grid() -> void:
	for tween in _tweens.values():
		if tween:
			(tween as Tween).kill()
	_tweens.clear()
	_slots.clear()
	_glows.clear()
	_hit_buttons.clear()
	_flag_visuals.clear()
	if _grid:
		for child in _grid.get_children():
			child.queue_free()


func _create_slot(locale_code: String, index: int) -> Control:
	var slot := Control.new()
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.clip_contents = false

	var glow := Panel.new()
	glow.name = "Glow"
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.visible = false
	var glow_style := StyleBoxFlat.new()
	glow_style.bg_color = Color(0.98, 0.72, 0.38, 0.22)
	glow_style.border_color = GLOW_COLOR
	glow_style.set_border_width_all(3)
	glow_style.set_corner_radius_all(16)
	glow_style.shadow_color = Color(0.98, 0.62, 0.28, 0.45)
	glow_style.shadow_size = 10
	glow.add_theme_stylebox_override("panel", glow_style)
	slot.add_child(glow)
	_glows.append(glow)

	var visual := TextureRect.new()
	visual.name = "FlagVisual"
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	visual.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	visual.texture = load(LocaleCatalog.flag_icon_path(locale_code)) as Texture2D
	visual.scale = Vector2.ONE * NORMAL_SCALE
	visual.modulate = Color(0.82, 0.8, 0.76, 1.0)
	slot.add_child(visual)
	_flag_visuals.append(visual)

	var hit := Button.new()
	hit.name = "Hit"
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	UiTouchTargets.apply_invisible_button(hit)
	hit.pressed.connect(_on_flag_pressed.bind(index))
	UiSounds.bind_button(hit)
	slot.add_child(hit)
	_hit_buttons.append(hit)

	_layout_slot_parts(slot, glow, hit, visual)
	return slot


func _layout_slot_parts(
	slot: Control,
	glow: Panel,
	hit: Button,
	visual: TextureRect
) -> void:
	if _metrics.is_empty():
		_metrics = _compute_metrics(_get_available_width())

	var flag_size: Vector2 = _metrics.flag_size
	var slot_size: Vector2 = _metrics.slot_size
	var margin: float = _metrics.margin

	slot.custom_minimum_size = slot_size
	slot.size = slot_size

	var glow_size := flag_size * SELECTED_SCALE + Vector2(margin, margin)
	glow.position = Vector2(
		(slot_size.x - glow_size.x) * 0.5,
		(slot_size.y - glow_size.y) * 0.5
	)
	glow.size = glow_size
	var glow_style := glow.get_theme_stylebox("panel") as StyleBoxFlat
	if glow_style:
		glow_style.set_corner_radius_all(maxi(10, int(flag_size.x * 0.1)))

	hit.custom_minimum_size = slot_size
	hit.size = slot_size
	hit.position = Vector2.ZERO

	visual.custom_minimum_size = flag_size
	visual.size = flag_size
	visual.position = Vector2(
		(slot_size.x - flag_size.x) * 0.5,
		(slot_size.y - flag_size.y) * 0.5
	)
	visual.pivot_offset = flag_size * 0.5


func _apply_metrics_to_slot(index: int) -> void:
	if index < 0 or index >= _slots.size() or _metrics.is_empty():
		return
	_layout_slot_parts(_slots[index], _glows[index], _hit_buttons[index], _flag_visuals[index])


func _on_flag_pressed(index: int) -> void:
	if _block_signals:
		return
	if index == _selected_index:
		return
	set_selected_index(index, true)
	language_selected.emit(index)


func _apply_slot_state(index: int, selected: bool, animate: bool) -> void:
	if index < 0 or index >= _flag_visuals.size():
		return
	var visual := _flag_visuals[index]
	var glow := _glows[index]
	glow.visible = selected
	var target_scale := SELECTED_SCALE if selected else NORMAL_SCALE
	var tween_key := visual.get_instance_id()
	if _tweens.has(tween_key):
		var old_tween: Tween = _tweens[tween_key]
		if old_tween:
			old_tween.kill()
	if not animate:
		visual.scale = Vector2.ONE * target_scale
		visual.modulate = Color.WHITE if selected else Color(0.82, 0.8, 0.76, 1.0)
		return
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tweens[tween_key] = tween
	tween.set_parallel(true)
	tween.tween_property(visual, "scale", Vector2.ONE * target_scale, ANIM_SEC)
	var target_modulate := Color.WHITE if selected else Color(0.82, 0.8, 0.76, 1.0)
	tween.tween_property(visual, "modulate", target_modulate, ANIM_SEC * 0.85)
