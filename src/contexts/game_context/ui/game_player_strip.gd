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

var _frame: PanelContainer
var _avatar_ring: PanelContainer
var _slime: TextureRect
var _name_label: Label
var _built: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 3
	_build_content()


func _build_content() -> void:
	if _built:
		return
	_built = true

	_frame = PanelContainer.new()
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pill := StyleBoxFlat.new()
	pill.bg_color = Color(1.0, 0.99, 0.97, 0.44)
	pill.border_color = Color(1.0, 1.0, 1.0, 0.34)
	pill.set_border_width_all(2)
	pill.set_corner_radius_all(int(FRAME_HEIGHT * 0.5))
	pill.shadow_color = Color(0.05, 0.03, 0.02, 0.28)
	pill.shadow_size = 10
	pill.shadow_offset = Vector2(0.0, 4.0)
	_frame.add_theme_stylebox_override("panel", pill)
	add_child(_frame)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", int(MARGIN_LEFT))
	margin.add_theme_constant_override("margin_top", int(MARGIN_V))
	margin.add_theme_constant_override("margin_right", int(MARGIN_RIGHT))
	margin.add_theme_constant_override("margin_bottom", int(MARGIN_V))
	_frame.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", int(NAME_GAP))
	margin.add_child(row)

	_avatar_ring = PanelContainer.new()
	_avatar_ring.custom_minimum_size = Vector2(AVATAR_RING_SIZE, AVATAR_RING_SIZE)
	var ring := StyleBoxFlat.new()
	ring.bg_color = Color(1.0, 1.0, 1.0, 0.22)
	ring.border_color = Color(1.0, 1.0, 1.0, 0.72)
	ring.set_border_width_all(3)
	ring.set_corner_radius_all(int(AVATAR_RING_SIZE * 0.5))
	ring.shadow_color = Color(1.0, 0.98, 0.92, 0.35)
	ring.shadow_size = 6
	_avatar_ring.add_theme_stylebox_override("panel", ring)
	row.add_child(_avatar_ring)

	var avatar_pad := MarginContainer.new()
	avatar_pad.add_theme_constant_override("margin_left", 8)
	avatar_pad.add_theme_constant_override("margin_top", 8)
	avatar_pad.add_theme_constant_override("margin_right", 8)
	avatar_pad.add_theme_constant_override("margin_bottom", 8)
	_avatar_ring.add_child(avatar_pad)

	_slime = TextureRect.new()
	_slime.custom_minimum_size = Vector2(SLIME_SIZE, SLIME_SIZE)
	_slime.size = Vector2(SLIME_SIZE, SLIME_SIZE)
	_slime.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_slime.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	avatar_pad.add_child(_slime)

	_name_label = Label.new()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_name_label.clip_text = false
	_name_label.add_theme_font_size_override("font_size", NAME_FONT_MAX)
	_name_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	_name_label.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.5))
	_name_label.add_theme_constant_override("outline_size", 2)
	row.add_child(_name_label)


func _pill_width_for_name(name_width: float) -> float:
	return MARGIN_LEFT + AVATAR_RING_SIZE + NAME_GAP + name_width + MARGIN_RIGHT


func _measure_name_width(text: String, font_size: int) -> float:
	var font := _name_label.get_theme_font(&"font")
	if font == null:
		return float(text.length()) * float(font_size) * 0.58
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x


func _fit_name_layout() -> void:
	var display := _name_label.text
	var chosen_size := NAME_FONT_MIN
	var chosen_width := _measure_name_width(display, NAME_FONT_MIN)
	for font_size in range(NAME_FONT_MAX, NAME_FONT_MIN - 1, -2):
		var name_width := _measure_name_width(display, font_size)
		if _pill_width_for_name(name_width) <= MAX_PILL_WIDTH:
			chosen_size = font_size
			chosen_width = name_width
			break
	_name_label.add_theme_font_size_override("font_size", chosen_size)
	_name_label.custom_minimum_size = Vector2(chosen_width, AVATAR_RING_SIZE)
	var pill_width := _pill_width_for_name(chosen_width)
	custom_minimum_size = Vector2(pill_width, FRAME_HEIGHT)
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
