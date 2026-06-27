extends CanvasLayer

@export var progress_bar: ProgressBar
@export var status_label: Label
@export var percent_label: Label
@export var panel: PanelContainer
@export var root: Control

const FADE_OUT_SEC := 0.38
const BG_COLOR := Color(0.16, 0.03, 0.02, 1.0)
const PANEL_BG := Color(0.2, 0.16, 0.13, 0.96)
const PANEL_BORDER := Color(0.9, 0.55, 0.32, 0.98)
const PANEL_SHADOW := Color(0.04, 0.02, 0.01, 0.42)
const TEXT_COLOR := Color(0.99, 0.96, 0.9, 1.0)
const TEXT_OUTLINE := Color(0.1, 0.06, 0.04, 0.82)
const PROGRESS_BG := Color(0.1, 0.08, 0.06, 0.72)
const PROGRESS_FILL := Color(1.0, 0.42, 0.29, 1.0)
const PROGRESS_BORDER := Color(0.72, 0.42, 0.2, 0.85)


func _ready() -> void:
	layer = 100
	if root == null:
		root = get_node_or_null("Root") as Control
	if root:
		root.modulate.a = 1.0
	_apply_styles()
	call_deferred("_sync_layout")


func present() -> void:
	if root == null:
		root = get_node_or_null("Root") as Control
	if root:
		root.modulate.a = 1.0
	update_progress(0.0)


func _sync_layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if panel:
		panel.custom_minimum_size.x = minf(760.0, viewport_size.x - 96.0)


func _apply_styles() -> void:
	if panel:
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = PANEL_BG
		panel_style.border_color = PANEL_BORDER
		panel_style.set_border_width_all(4)
		panel_style.set_corner_radius_all(24)
		panel_style.shadow_color = PANEL_SHADOW
		panel_style.shadow_size = 16
		panel_style.shadow_offset = Vector2(0, 8)
		panel_style.content_margin_left = 36.0
		panel_style.content_margin_top = 28.0
		panel_style.content_margin_right = 36.0
		panel_style.content_margin_bottom = 28.0
		panel.add_theme_stylebox_override("panel", panel_style)

	if status_label:
		status_label.add_theme_font_size_override("font_size", 54)
		status_label.add_theme_color_override("font_color", TEXT_COLOR)
		status_label.add_theme_color_override("font_outline_color", TEXT_OUTLINE)
		status_label.add_theme_constant_override("outline_size", 4)

	if percent_label:
		percent_label.add_theme_font_size_override("font_size", 34)
		percent_label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.78, 1))
		percent_label.add_theme_color_override("font_outline_color", TEXT_OUTLINE)
		percent_label.add_theme_constant_override("outline_size", 2)

	if progress_bar:
		progress_bar.custom_minimum_size = Vector2(680, 28)
		progress_bar.show_percentage = false
		var bg := StyleBoxFlat.new()
		bg.bg_color = PROGRESS_BG
		bg.border_color = PROGRESS_BORDER
		bg.set_border_width_all(2)
		bg.set_corner_radius_all(12)
		bg.content_margin_left = 4.0
		bg.content_margin_top = 4.0
		bg.content_margin_right = 4.0
		bg.content_margin_bottom = 4.0
		var fill := StyleBoxFlat.new()
		fill.bg_color = PROGRESS_FILL
		fill.set_corner_radius_all(8)
		progress_bar.add_theme_stylebox_override("background", bg)
		progress_bar.add_theme_stylebox_override("fill", fill)


func update_progress(value: float) -> void:
	var clamped := clampf(value, 0.0, 1.0)
	if progress_bar:
		progress_bar.value = clamped * 100.0
	if percent_label:
		percent_label.text = "%d%%" % int(round(clamped * 100.0))


func fade_out() -> void:
	if root == null:
		root = get_node_or_null("Root") as Control
	if not root:
		queue_free()
		return
	var tween := create_tween()
	tween.tween_property(root, "modulate:a", 0.0, FADE_OUT_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(queue_free)
