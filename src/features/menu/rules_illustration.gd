class_name RulesIllustration
extends Control
## Animated, localized picture for one rules card. Drawn in a 900×340 virtual
## canvas and scaled to the control width (height follows the aspect).

enum Kind { CIRCLE, SYLLABLE, PASS, BOOM, WIN, LOBBY, OOPS, CENTER }

const CANVAS := Vector2(900.0, 340.0)
const SLIME_PATH := "res://assets/party_kitchen/slimes/%d.svg"
const EMERGENCY_ICON := "res://assets/party_kitchen/buttons/icon_emergency.svg"

const COPPER := Color(0.88, 0.62, 0.38, 1.0)
const COPPER_DARK := Color(0.45, 0.28, 0.16, 1.0)
const METAL := Color(0.16, 0.13, 0.11, 1.0)
const GLASS := Color(0.05, 0.04, 0.035, 1.0)
const DYNAMITE := Color(0.78, 0.12, 0.1, 1.0)
const TEXT := Color(0.99, 0.96, 0.9, 1.0)
const MUTED := Color(0.96, 0.9, 0.82, 0.75)
const GOOD := Color(0.42, 0.82, 0.42, 1.0)
const BAD := Color(0.95, 0.36, 0.3, 1.0)
const SPARK := Color(1.0, 0.85, 0.35, 1.0)

@export var kind: Kind = Kind.CIRCLE:
	set(value):
		kind = value
		queue_redraw()
@export var animate: bool = true

var _time := 0.0
var _base := Transform2D.IDENTITY
var _slimes: Dictionary = {}
var _font: Font


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(_fit_height)
	_fit_height()


func _fit_height() -> void:
	if size.x <= 0.0:
		return
	var wanted := floorf(size.x * CANVAS.y / CANVAS.x)
	if absf(custom_minimum_size.y - wanted) > 0.5:
		custom_minimum_size.y = wanted


func _process(delta: float) -> void:
	if not animate or not is_visible_in_tree():
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	_font = get_theme_font(&"font", &"Label")
	var s := minf(size.x / CANVAS.x, size.y / CANVAS.y)
	var offset := (size - CANVAS * s) * 0.5
	_base = Transform2D(0.0, Vector2(s, s), 0.0, offset)
	draw_set_transform_matrix(_base)
	match kind:
		Kind.CIRCLE:
			_draw_circle_scene()
		Kind.SYLLABLE:
			_draw_syllable_scene()
		Kind.PASS:
			_draw_pass_scene()
		Kind.BOOM:
			_draw_boom_scene()
		Kind.WIN:
			_draw_win_scene()
		Kind.LOBBY:
			_draw_lobby_scene()
		Kind.OOPS:
			_draw_oops_scene()
		Kind.CENTER:
			_draw_center_scene()
	draw_set_transform_matrix(Transform2D.IDENTITY)


# --- Scenes -----------------------------------------------------------------

func _draw_circle_scene() -> void:
	var center := Vector2(450.0, 172.0)
	var radii := Vector2(300.0, 132.0)
	var count := 6
	var holder := int(_time / 0.7) % count
	var points: Array[Vector2] = []
	for i in count:
		var a := TAU * float(i) / float(count)
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	for i in count:
		var from := points[i]
		var to := points[(i + 1) % count]
		_dashed_arc(from.lerp(to, 0.22), to.lerp(from, 0.22), center, Color(COPPER, 0.55), 4.0)
	for i in count:
		var bob := sin(_time * 3.0 + float(i)) * 3.0
		if i == holder:
			draw_circle(points[i], 50.0, Color(SPARK, 0.22))
			draw_arc(points[i], 50.0, 0.0, TAU, 40, Color(SPARK, 0.8), 3.0)
		_slime([0, 1, 2, 3, 4, 5][i], points[i] + Vector2(0.0, bob), 40.0)
	_phone_bomb(center + Vector2(0.0, 10.0), 0.92, sin(_time * 5.0) * 0.06, "")


func _draw_syllable_scene() -> void:
	var dial := Vector2(190.0, 148.0)
	_dial(dial, 108.0, _tr("RULES_ILL_SYLLABLE"), 72)
	_chip(Vector2(dial.x, dial.y + 156.0), _tr("RULES_ILL_CONDITION"), Color(COPPER, 0.95), 30, GLASS)
	var words := [_tr("RULES_ILL_WORD_OK1"), _tr("RULES_ILL_WORD_OK2"), _tr("RULES_ILL_WORD_BAD")]
	for i in words.size():
		var appear := clampf((fmod(_time, 6.0) - float(i) * 0.6) * 3.0, 0.0, 1.0)
		var y := 82.0 + float(i) * 92.0
		var ok := i < 2
		var pos := Vector2(620.0 + (1.0 - appear) * 40.0, y)
		_word_card(pos, words[i], ok, appear)


func _draw_pass_scene() -> void:
	var speaker := Vector2(120.0, 200.0)
	var receiver := Vector2(790.0, 200.0)
	_slime(1, speaker, 56.0)
	_slime(4, receiver + Vector2(0.0, sin(_time * 3.0) * 3.0), 56.0)
	_bubble(speaker + Vector2(40.0, -120.0), _tr("RULES_ILL_SAY"))

	var cycle := fmod(_time, 1.6)
	var press := clampf(1.0 - absf(cycle - 0.5) * 5.0, 0.0, 1.0)
	var phone := Vector2(450.0, 182.0)
	_phone_bomb(phone, 1.05, 0.0, "")
	if cycle > 0.5 and cycle < 1.2:
		var r := (cycle - 0.5) * 140.0
		draw_arc(phone + Vector2(0.0, -6.0), r, 0.0, TAU, 48, Color(SPARK, 1.0 - (cycle - 0.5) / 0.7), 4.0)
	_finger(phone + Vector2(18.0, -6.0 - (1.0 - press) * 46.0))
	var travel := clampf((cycle - 0.6) / 0.8, 0.0, 1.0)
	_arrow(Vector2(560.0, 150.0), Vector2(720.0, 150.0), Color(COPPER, 0.4 + 0.6 * travel), 6.0)
	_chip(Vector2(450.0, 318.0), _tr("RULES_ILL_TAP"), Color(COPPER, 0.95), 30, GLASS)


func _draw_boom_scene() -> void:
	var center := Vector2(450.0, 160.0)
	var pulse := 0.5 + 0.5 * sin(_time * 6.0)
	_burst(center, 120.0 + pulse * 14.0, 14, Color(1.0, 0.45, 0.12, 0.9))
	_burst(center, 78.0 + pulse * 8.0, 12, Color(SPARK, 0.95))
	var shake := Vector2(sin(_time * 40.0), cos(_time * 37.0)) * 3.0
	_slime(0, center + Vector2(0.0, 20.0) + shake, 48.0, 0.45)
	_text(center + Vector2(0.0, -88.0), _tr("EXPLOSION_BOOM"), 64, TEXT, 8)
	var others := [Vector2(110.0, 210.0), Vector2(250.0, 270.0), Vector2(650.0, 270.0), Vector2(790.0, 210.0)]
	for i in others.size():
		var p: Vector2 = others[i]
		_slime([2, 3, 5, 8][i], p, 40.0)
		var rise := fmod(_time * 0.8 + float(i) * 0.25, 1.0)
		_text(p + Vector2(0.0, -62.0 - rise * 34.0), "+1", 40, Color(GOOD, 1.0 - rise * 0.7), 5)


func _draw_win_scene() -> void:
	var steps := [
		{"x": 450.0, "h": 150.0, "id": 4, "pts": "9", "place": "1"},
		{"x": 236.0, "h": 104.0, "id": 1, "pts": "7", "place": "2"},
		{"x": 664.0, "h": 70.0, "id": 2, "pts": "5", "place": "3"},
	]
	var floor_y := 318.0
	for step: Dictionary in steps:
		var x: float = step["x"]
		var h: float = step["h"]
		var rect := Rect2(x - 104.0, floor_y - h, 208.0, h)
		_panel(rect, METAL, COPPER_DARK, 10)
		_text(rect.get_center() + Vector2(0.0, 4.0), str(step["place"]), 44, Color(COPPER, 0.9), 0)
		var bob := sin(_time * 3.0 + x) * 3.0 if step["place"] == "1" else 0.0
		var slime_pos := Vector2(x, floor_y - h - 50.0 + bob)
		_slime(int(step["id"]), slime_pos, 48.0)
		_chip(slime_pos + Vector2(74.0, -30.0), str(step["pts"]), Color(SPARK, 0.95), 32, GLASS)
		if step["place"] == "1":
			_crown(slime_pos + Vector2(0.0, -64.0), 1.0 + 0.06 * sin(_time * 4.0))
	_chip(Vector2(680.0, 40.0), _tr("RULES_ILL_MORE_POINTS"), Color(COPPER, 0.95), 30, GLASS)


func _draw_lobby_scene() -> void:
	var cols := [150.0, 450.0, 750.0]
	var y := 150.0
	# Add.
	var add_pulse := 1.0 + 0.06 * sin(_time * 4.0)
	draw_circle(Vector2(cols[0], y), 58.0 * add_pulse, COPPER_DARK)
	draw_circle(Vector2(cols[0], y), 50.0 * add_pulse, COPPER)
	var bar := 30.0 * add_pulse
	draw_rect(Rect2(cols[0] - bar, y - 7.0, bar * 2.0, 14.0), GLASS)
	draw_rect(Rect2(cols[0] - 7.0, y - bar, 14.0, bar * 2.0), GLASS)
	_text(Vector2(cols[0], 285.0), _tr("RULES_ILL_ADD"), 32, MUTED, 0)
	# Hold.
	var hold := fmod(_time, 2.2) / 1.5
	_slime(3, Vector2(cols[1], y), 50.0)
	draw_arc(Vector2(cols[1], y), 66.0, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, 0.15), 6.0)
	draw_arc(Vector2(cols[1], y), 66.0, -PI * 0.5, -PI * 0.5 + TAU * clampf(hold, 0.0, 1.0), 48, SPARK, 6.0)
	_text(Vector2(cols[1], y + 90.0), _tr("RULES_ILL_HOLD_TIME"), 30, Color(SPARK, 0.9), 0)
	_text(Vector2(cols[1], 285.0), _tr("RULES_ILL_HOLD"), 32, MUTED, 0)
	# Swap.
	var t := 0.5 - 0.5 * cos(fmod(_time, 3.0) / 3.0 * TAU)
	var left := Vector2(cols[2] - 62.0, y)
	var right := Vector2(cols[2] + 62.0, y)
	var lift := sin(t * PI) * 34.0
	_slime(5, right.lerp(left, t) + Vector2(0.0, lift), 42.0)
	_slime(8, left.lerp(right, t) - Vector2(0.0, lift), 42.0)
	_text(Vector2(cols[2], 285.0), _tr("RULES_ILL_SWAP"), 32, MUTED, 0)


func _draw_oops_scene() -> void:
	var icon := _texture(EMERGENCY_ICON)
	var pulse := 1.0 + 0.07 * sin(_time * 5.0)
	var c := Vector2(170.0, 160.0)
	draw_circle(c, 92.0 * pulse, Color(BAD, 0.18))
	if icon:
		var side := 150.0 * pulse
		draw_texture_rect(icon, Rect2(c - Vector2(side, side) * 0.5, Vector2(side, side)), false)
	_text(Vector2(c.x, 296.0), _tr("RULES_ILL_EMERGENCY"), 30, MUTED, 0)
	_arrow(Vector2(290.0, 160.0), Vector2(400.0, 160.0), Color(COPPER, 0.9), 6.0)
	var pick := int(_time / 0.9) % 4
	for i in 4:
		var p := Vector2(480.0 + float(i) * 118.0, 160.0)
		if i == pick:
			draw_circle(p, 50.0, Color(SPARK, 0.2))
			draw_arc(p, 50.0, 0.0, TAU, 40, SPARK, 3.0)
		_slime([0, 6, 7, 10][i], p, 40.0)
	_text(Vector2(657.0, 262.0), _tr("RULES_ILL_REPICK"), 30, MUTED, 0)


func _draw_center_scene() -> void:
	var center := Vector2(450.0, 172.0)
	_ellipse(center, Vector2(300.0, 128.0), Color(0.36, 0.22, 0.13, 1.0))
	_ellipse(center, Vector2(286.0, 116.0), Color(0.46, 0.29, 0.17, 1.0))
	var count := 8
	var seats: Array[Vector2] = []
	for i in count:
		var a := -PI * 0.5 + TAU * float(i) / float(count)
		seats.append(center + Vector2(cos(a) * 372.0, sin(a) * 150.0))
	var turn := int(_time / 1.1) % count
	var target := seats[turn]
	var facing := (target - center).angle() + PI * 0.5
	for i in count:
		if i == turn:
			draw_circle(seats[i], 40.0, Color(SPARK, 0.22))
		_slime(i, seats[i], 32.0)
	_phone_flat(center, facing)


# --- Building blocks -------------------------------------------------------

func _phone_bomb(center: Vector2, scale_factor: float, rotation: float, label: String) -> void:
	_push(center, rotation, scale_factor)
	# Dynamite sticks behind the phone.
	for i in 3:
		var y := -38.0 + float(i) * 38.0
		_panel(Rect2(-96.0, y - 16.0, 192.0, 32.0), DYNAMITE, Color(0.35, 0.04, 0.03), 14)
	draw_rect(Rect2(-100.0, -6.0, 200.0, 12.0), Color(0.08, 0.06, 0.05))
	# Phone.
	_panel(Rect2(-54.0, -92.0, 108.0, 176.0), METAL, COPPER, 18)
	_panel(Rect2(-44.0, -78.0, 88.0, 146.0), GLASS, Color(COPPER, 0.35), 10)
	draw_circle(Vector2(0.0, -6.0), 30.0, Color(0.2, 0.06, 0.04))
	draw_arc(Vector2(0.0, -6.0), 30.0, 0.0, TAU, 40, Color(BAD, 0.8), 3.0)
	if not label.is_empty():
		_text(Vector2(0.0, -4.0), label, 28, TEXT, 3)
	# Fuse + spark.
	var fuse := PackedVector2Array([Vector2(30.0, -92.0), Vector2(46.0, -118.0), Vector2(70.0, -124.0)])
	draw_polyline(fuse, Color(0.85, 0.7, 0.45), 5.0)
	var spark_r := 14.0 + 5.0 * sin(_time * 18.0)
	_burst(Vector2(72.0, -126.0), spark_r, 8, SPARK)
	_pop()


func _phone_flat(center: Vector2, rotation: float) -> void:
	_push(center, rotation, 1.0)
	_panel(Rect2(-46.0, -78.0, 92.0, 156.0), METAL, COPPER, 16)
	_panel(Rect2(-38.0, -66.0, 76.0, 130.0), GLASS, Color(COPPER, 0.35), 8)
	_text(Vector2(0.0, -14.0), _tr("RULES_ILL_SYLLABLE"), 34, TEXT, 3)
	draw_colored_polygon(PackedVector2Array([Vector2(0.0, -64.0), Vector2(-14.0, -46.0), Vector2(14.0, -46.0)]), SPARK)
	_pop()


func _dial(center: Vector2, radius: float, label: String, font_size: int) -> void:
	draw_circle(center, radius + 12.0, COPPER_DARK)
	draw_circle(center, radius + 6.0, COPPER)
	draw_circle(center, radius, GLASS)
	for i in 12:
		var a := TAU * float(i) / 12.0
		var dir := Vector2(cos(a), sin(a))
		draw_line(center + dir * (radius - 16.0), center + dir * (radius - 4.0), Color(COPPER, 0.6), 3.0)
	draw_arc(center, radius - 26.0, -PI * 0.5, -PI * 0.5 + TAU * fmod(_time * 0.25, 1.0), 64, Color(BAD, 0.7), 4.0)
	_text(center + Vector2(0.0, 6.0), label, font_size, TEXT, 6)


func _word_card(pos: Vector2, word: String, ok: bool, alpha: float) -> void:
	var rect := Rect2(pos - Vector2(210.0, 36.0), Vector2(420.0, 72.0))
	_panel(rect, Color(1.0, 0.99, 0.97, 0.14 * alpha), Color(GOOD if ok else BAD, 0.8 * alpha), 22)
	_rich_word(Vector2(rect.position.x + 28.0, pos.y), word, 38, alpha)
	var mark := Vector2(rect.end.x - 40.0, pos.y)
	var color := Color(GOOD if ok else BAD, alpha)
	if ok:
		draw_polyline(PackedVector2Array([mark + Vector2(-14.0, 0.0), mark + Vector2(-4.0, 11.0), mark + Vector2(16.0, -12.0)]), color, 6.0)
	else:
		draw_line(mark + Vector2(-12.0, -12.0), mark + Vector2(12.0, 12.0), color, 6.0)
		draw_line(mark + Vector2(12.0, -12.0), mark + Vector2(-12.0, 12.0), color, 6.0)


## Draws `word`, painting the part inside [brackets] in the accent color.
func _rich_word(left_mid: Vector2, word: String, font_size: int, alpha: float) -> void:
	if _font == null:
		return
	var x := left_mid.x
	var baseline := left_mid.y + _font.get_ascent(font_size) * 0.5 - _font.get_descent(font_size) * 0.3
	var accent := false
	for part in word.replace("]", "[").split("["):
		if not part.is_empty():
			var color := Color(SPARK, alpha) if accent else Color(TEXT, alpha)
			draw_string(_font, Vector2(x, baseline), part, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)
			x += _font.get_string_size(part, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		accent = not accent


func _bubble(pos: Vector2, text: String) -> void:
	if _font == null:
		return
	var width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 34).x + 44.0
	var rect := Rect2(pos - Vector2(width * 0.5, 34.0), Vector2(width, 68.0))
	_panel(rect, Color(0.99, 0.96, 0.9, 0.95), COPPER, 30)
	draw_colored_polygon(PackedVector2Array([
		Vector2(rect.position.x + 34.0, rect.end.y - 2.0),
		Vector2(rect.position.x + 60.0, rect.end.y - 2.0),
		Vector2(rect.position.x + 26.0, rect.end.y + 26.0),
	]), Color(0.99, 0.96, 0.9, 0.95))
	_text(rect.get_center() + Vector2(0.0, 2.0), text, 34, GLASS, 0)


func _finger(tip: Vector2) -> void:
	var skin := Color(0.98, 0.8, 0.65)
	var shade := Color(0.78, 0.55, 0.42)
	_panel(Rect2(tip.x - 17.0, tip.y - 6.0, 34.0, 96.0), skin, shade, 17)
	_panel(Rect2(tip.x - 9.0, tip.y + 2.0, 18.0, 20.0), Color(1.0, 0.92, 0.86), shade, 8)
	_panel(Rect2(tip.x - 30.0, tip.y + 66.0, 76.0, 70.0), skin, shade, 26)


func _crown(center: Vector2, scale_factor: float) -> void:
	_push(center, 0.0, scale_factor)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-34.0, 14.0), Vector2(-34.0, -10.0), Vector2(-18.0, 2.0), Vector2(0.0, -22.0),
		Vector2(18.0, 2.0), Vector2(34.0, -10.0), Vector2(34.0, 14.0),
	]), SPARK)
	draw_rect(Rect2(-34.0, 10.0, 68.0, 8.0), Color(0.85, 0.6, 0.15))
	_pop()


func _burst(center: Vector2, radius: float, spikes: int, color: Color) -> void:
	var points := PackedVector2Array()
	for i in spikes * 2:
		var a := TAU * float(i) / float(spikes * 2) + _time * 0.6
		var r := radius if i % 2 == 0 else radius * 0.55
		points.append(center + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(points, color)


func _arrow(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	draw_line(from, to, color, width)
	var dir := (to - from).normalized()
	var side := Vector2(-dir.y, dir.x)
	draw_colored_polygon(PackedVector2Array([to + dir * 14.0, to - dir * 10.0 + side * 14.0, to - dir * 10.0 - side * 14.0]), color)


func _dashed_arc(from: Vector2, to: Vector2, around: Vector2, color: Color, width: float) -> void:
	# Slight outward bow, animated dash offset (clockwise flow).
	var mid := (from + to) * 0.5
	var bow := mid + (mid - around).normalized() * 18.0
	var steps := 14
	var phase := fmod(_time * 2.0, 1.0)
	for i in steps:
		if (i + int(phase * 2.0)) % 2 == 1:
			continue
		var t0 := float(i) / float(steps)
		var t1 := float(i + 1) / float(steps)
		draw_line(_quad(from, bow, to, t0), _quad(from, bow, to, t1), color, width)
	var tip := _quad(from, bow, to, 1.0)
	var dir := (tip - _quad(from, bow, to, 0.9)).normalized()
	var side := Vector2(-dir.y, dir.x)
	draw_colored_polygon(PackedVector2Array([tip + dir * 8.0, tip - dir * 8.0 + side * 8.0, tip - dir * 8.0 - side * 8.0]), color)


static func _quad(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	return a.lerp(b, t).lerp(b.lerp(c, t), t)


func _ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 48:
		var a := TAU * float(i) / 48.0
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(points, color)


func _chip(center: Vector2, text: String, bg: Color, font_size: int, text_color: Color) -> void:
	if _font == null or text.is_empty():
		return
	var width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x + 36.0
	var height := float(font_size) + 18.0
	_panel(Rect2(center - Vector2(width, height) * 0.5, Vector2(width, height)), bg, Color(0, 0, 0, 0), int(height * 0.5))
	_text(center + Vector2(0.0, 1.0), text, font_size, text_color, 0)


func _panel(rect: Rect2, bg: Color, border: Color, radius: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(3 if border.a > 0.0 else 0)
	style.set_corner_radius_all(radius)
	style.anti_aliasing = true
	style.draw(get_canvas_item(), rect)


func _text(center: Vector2, text: String, font_size: int, color: Color, outline: int) -> void:
	if _font == null or text.is_empty():
		return
	var width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var pos := Vector2(center.x - width * 0.5, center.y + (_font.get_ascent(font_size) - _font.get_descent(font_size)) * 0.5)
	if outline > 0:
		draw_string_outline(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, outline, Color(0.04, 0.03, 0.02, color.a * 0.85))
	draw_string(_font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)


func _slime(preset_id: int, center: Vector2, radius: float, squash: float = 0.0) -> void:
	var tex := _texture(SLIME_PATH % preset_id)
	if tex == null:
		draw_circle(center, radius, SlimeColors.get_color(preset_id))
		return
	var stretch := Vector2(1.0 + squash * 0.3, 1.0 - squash * 0.3)
	var half := Vector2(radius, radius) * 1.2 * stretch
	draw_texture_rect(tex, Rect2(center - half, half * 2.0), false)


func _texture(path: String) -> Texture2D:
	if not _slimes.has(path):
		_slimes[path] = load(path) as Texture2D
	return _slimes[path]


func _push(pos: Vector2, rotation: float, scale_factor: float) -> void:
	draw_set_transform_matrix(_base * Transform2D(rotation, Vector2(scale_factor, scale_factor), 0.0, pos))


func _pop() -> void:
	draw_set_transform_matrix(_base)


func _tr(key: String) -> String:
	return LocaleService.text(key)
