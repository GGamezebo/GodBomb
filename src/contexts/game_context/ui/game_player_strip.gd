class_name GamePlayerStrip
extends Control

const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"
const DIAL_TABLE_SIZE := 640.0
const DIAL_TABLE_RADIUS := DIAL_TABLE_SIZE * 0.5
const TABLE_CENTER := Vector2(540.0, 960.0)
const WORD_BELOW_OFFSET := 118.0

const FRAME_HEIGHT := 120.0
const AVATAR_RING_SIZE := 112.0
const SLIME_SIZE := 96.0
const MARGIN_LEFT := 4.0
const MARGIN_RIGHT := 14.0
const MARGIN_V := 4.0
const NAME_GAP := 10.0
const NAME_FONT_MAX := 54
const NAME_FONT_MIN := 30
const MAX_PILL_WIDTH := 580.0

const NAME_TEXT_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const NAME_OUTLINE_COLOR := Color(0.04, 0.03, 0.02, 0.5)

var _frame: PanelContainer
var _avatar_ring: PanelContainer
var _slime: TextureRect
var _name_label: Label
var _built: bool = false
var _visual_scale := 1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 3
	_build_content()


func set_visual_scale(visual_scale: float) -> void:
	if is_equal_approx(_visual_scale, visual_scale):
		return
	_visual_scale = visual_scale
	for child in get_children():
		child.queue_free()
	_frame = null
	_avatar_ring = null
	_slime = null
	_name_label = null
	_built = false
	_build_content()


func _vx(value: float) -> float:
	return value * _visual_scale


func _vi(value: float) -> int:
	return int(roundf(value * _visual_scale))


static func create_name_pill_style(
	plate_height: float,
	pad_h: float = 0.0,
	pad_v: float = 0.0,
	border_width: int = 2,
	shadow_size: int = 10,
	lobby: bool = false
) -> StyleBoxFlat:
	var pill := StyleBoxFlat.new()
	if lobby:
		pill.bg_color = Color(1.0, 1.0, 1.0, 0.1)
		pill.border_color = Color(1.0, 1.0, 1.0, 0.26)
		pill.set_border_width_all(maxi(border_width, 1))
		pill.set_corner_radius_all(maxi(4, int(plate_height * 0.5)))
		pill.shadow_size = 0
	else:
		pill.bg_color = Color(1.0, 0.99, 0.97, 0.44)
		pill.border_color = Color(1.0, 1.0, 1.0, 0.34)
		pill.set_border_width_all(maxi(border_width, 2))
		pill.set_corner_radius_all(maxi(4, int(plate_height * 0.5)))
		pill.shadow_color = Color(0.05, 0.03, 0.02, 0.28)
		pill.shadow_size = shadow_size
		pill.shadow_offset = Vector2(0.0, maxf(2.0, plate_height * 0.033))
	pill.content_margin_left = pad_h
	pill.content_margin_top = pad_v
	pill.content_margin_right = pad_h
	pill.content_margin_bottom = pad_v
	pill.anti_aliasing = false
	return pill


static func apply_name_label_style(label: Label, font_size: int, outline_size: int = -1, crisp: bool = false) -> void:
	var outline := outline_size
	if outline < 0:
		outline = 2 if crisp else maxi(2, int(round(float(font_size) / 10.0)))
	label.add_theme_color_override("font_color", NAME_TEXT_COLOR)
	label.add_theme_color_override(
		"font_outline_color",
		Color(0.02, 0.02, 0.02, 0.92) if crisp else NAME_OUTLINE_COLOR
	)
	label.add_theme_constant_override("outline_size", outline)
	label.modulate = Color.WHITE


func _build_content() -> void:
	if _built:
		return
	_built = true

	var frame_height := _vx(FRAME_HEIGHT)
	var avatar_size := _vx(AVATAR_RING_SIZE)
	var slime_size := _vx(SLIME_SIZE)

	_frame = PanelContainer.new()
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_theme_stylebox_override(
		"panel",
		create_name_pill_style(frame_height, 0.0, 0.0, max(_vi(2.0), 2), _vi(10.0))
	)
	add_child(_frame)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _vi(MARGIN_LEFT))
	margin.add_theme_constant_override("margin_top", _vi(MARGIN_V))
	margin.add_theme_constant_override("margin_right", _vi(MARGIN_RIGHT))
	margin.add_theme_constant_override("margin_bottom", _vi(MARGIN_V))
	_frame.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", _vi(NAME_GAP))
	margin.add_child(row)

	_avatar_ring = PanelContainer.new()
	_avatar_ring.custom_minimum_size = Vector2(avatar_size, avatar_size)
	var ring := StyleBoxFlat.new()
	ring.bg_color = Color(1.0, 1.0, 1.0, 0.22)
	ring.border_color = Color(1.0, 1.0, 1.0, 0.72)
	ring.set_border_width_all(max(_vi(3.0), 3))
	ring.set_corner_radius_all(int(avatar_size * 0.5))
	ring.shadow_color = Color(1.0, 0.98, 0.92, 0.35)
	ring.shadow_size = _vi(6.0)
	_avatar_ring.add_theme_stylebox_override("panel", ring)
	row.add_child(_avatar_ring)

	var avatar_pad := MarginContainer.new()
	var avatar_inset := _vi(8.0)
	avatar_pad.add_theme_constant_override("margin_left", avatar_inset)
	avatar_pad.add_theme_constant_override("margin_top", avatar_inset)
	avatar_pad.add_theme_constant_override("margin_right", avatar_inset)
	avatar_pad.add_theme_constant_override("margin_bottom", avatar_inset)
	_avatar_ring.add_child(avatar_pad)

	_slime = TextureRect.new()
	_slime.custom_minimum_size = Vector2(slime_size, slime_size)
	_slime.size = Vector2(slime_size, slime_size)
	_slime.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_slime.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_pad.add_child(_slime)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_name_label.clip_text = false
	_name_label.add_theme_font_size_override("font_size", _vi(NAME_FONT_MAX))
	apply_name_label_style(_name_label, _vi(NAME_FONT_MAX), max(_vi(2.0), 2))
	row.add_child(_name_label)


func _pill_width_for_name(name_width: float) -> float:
	return _vx(MARGIN_LEFT + AVATAR_RING_SIZE + NAME_GAP) + name_width + _vx(MARGIN_RIGHT)


func _measure_name_width(text: String, font_size: int) -> float:
	var font := _name_label.get_theme_font(&"font")
	if font == null:
		return float(text.length()) * float(font_size) * 0.58
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x


func _fit_name_layout() -> void:
	var display := _name_label.text
	var font_min := _vi(NAME_FONT_MIN)
	var font_max := _vi(NAME_FONT_MAX)
	var avatar_size := _vx(AVATAR_RING_SIZE)
	var frame_height := _vx(FRAME_HEIGHT)
	var max_width := _vx(MAX_PILL_WIDTH)

	var chosen_size := font_min
	var chosen_width := _measure_name_width(display, font_min)
	for font_size in range(font_max, font_min - 1, -2):
		var name_width := _measure_name_width(display, font_size)
		if _pill_width_for_name(name_width) <= max_width:
			chosen_size = font_size
			chosen_width = name_width
			break
	_name_label.add_theme_font_size_override("font_size", chosen_size)
	apply_name_label_style(_name_label, chosen_size, max(_vi(2.0), 2))
	_name_label.custom_minimum_size = Vector2(chosen_width, avatar_size)
	var pill_width := _pill_width_for_name(chosen_width)
	custom_minimum_size = Vector2(pill_width, frame_height)
	size = custom_minimum_size


static func place_on_dial(strip: Control, word_center: Vector2, table_center: Vector2 = TABLE_CENTER) -> void:
	if strip == null:
		return
	var strip_size := strip.size
	if strip_size.x <= 0.0 or strip_size.y <= 0.0:
		strip_size = strip.get_combined_minimum_size()

	var top_y := word_center.y + WORD_BELOW_OFFSET
	var center_y := top_y + strip_size.y * 0.5
	if center_y < table_center.y + 28.0:
		center_y = table_center.y + 28.0

	var dy := center_y - table_center.y
	var chord_half := 0.0
	if absf(dy) < DIAL_TABLE_RADIUS:
		chord_half = sqrt(DIAL_TABLE_RADIUS * DIAL_TABLE_RADIUS - dy * dy)

	var center_x := word_center.x
	var half_w := strip_size.x * 0.5
	if chord_half > 0.0:
		center_x = clampf(
			word_center.x,
			table_center.x - chord_half + half_w,
			table_center.x + chord_half - half_w
		)

	strip.position = Vector2(center_x - half_w, center_y - strip_size.y * 0.5)


func set_player(player: GamePlayer) -> void:
	_build_content()
	_slime.texture = load(SLIME_PATH % player.info.preset_id)
	_name_label.text = player.info.name.to_upper()
	_fit_name_layout()


func set_turn_caption(_text: String) -> void:
	pass


func pulse_choice_tick() -> void:
	pivot_offset = size * 0.5
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.05).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_slime, "modulate", Color(1.25, 1.15, 1.05, 1.0), 0.05)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_slime, "modulate", Color.WHITE, 0.12)
