class_name OnboardingGestureHint
extends Control
## Animated gesture drawn over tutorial targets (tap / hold / drag), or a small
## static-ish icon of the same gesture for the coach card (`icon_mode`).

enum Gesture { NONE, TAP, HOLD, DRAG, WAIT, BOOM }

const SKIN := Color(0.98, 0.82, 0.68, 1.0)
const SKIN_SHADE := Color(0.62, 0.42, 0.32, 1.0)
const NAIL := Color(1.0, 0.93, 0.88, 1.0)
const ACCENT := Color(0.88, 0.62, 0.38, 1.0)
const SPARK := Color(1.0, 0.85, 0.35, 1.0)
const TAP_PERIOD := 1.3
const HOLD_PERIOD := 2.1
const HOLD_FILL := 1.4
const DRAG_PERIOD := 2.0

@export var icon_mode: bool = false

var gesture: Gesture = Gesture.NONE
var _from: Control
var _to: Control
var _point := Vector2.INF
var _time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not icon_mode:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## `from` / `to` are tracked every frame; `point` (global px) is used when `from` is null.
func show_gesture(kind: Gesture, from: Control = null, to: Control = null, point: Vector2 = Vector2.INF) -> void:
	gesture = kind
	_from = from
	_to = to
	_point = point
	_time = 0.0
	visible = kind != Gesture.NONE
	queue_redraw()


func clear() -> void:
	show_gesture(Gesture.NONE)


func _process(delta: float) -> void:
	if gesture == Gesture.NONE or not is_visible_in_tree():
		return
	_time += delta
	queue_redraw()


func _draw() -> void:
	if gesture == Gesture.NONE:
		return
	if icon_mode:
		_draw_icon()
		return
	var origin := get_global_rect().position
	var a := _anchor_point(_from, _point) - origin
	if not a.is_finite():
		return
	var scale_factor := StartActionButton.viewport_cover_scale(get_viewport_rect().size)
	match gesture:
		Gesture.TAP:
			_draw_tap(a, scale_factor)
		Gesture.HOLD:
			_draw_hold(a, _target_radius(_from, 60.0 * scale_factor), scale_factor)
		Gesture.DRAG:
			var b := _anchor_point(_to, Vector2.INF) - origin
			if b.is_finite():
				_draw_drag(a, b, scale_factor)


static func _anchor_point(control: Control, fallback: Vector2) -> Vector2:
	if control != null and is_instance_valid(control) and control.is_visible_in_tree():
		return control.get_global_rect().get_center()
	return fallback


static func _target_radius(control: Control, fallback: float) -> float:
	if control != null and is_instance_valid(control):
		return maxf(control.get_global_rect().size.length() * 0.42, fallback)
	return fallback


# --- Full-screen gestures ---------------------------------------------------

func _draw_tap(at: Vector2, s: float) -> void:
	var t := fmod(_time, TAP_PERIOD) / TAP_PERIOD
	var press := clampf(1.0 - absf(t - 0.35) * 6.0, 0.0, 1.0)
	if t > 0.35 and t < 0.85:
		var k := (t - 0.35) / 0.5
		draw_arc(at, (24.0 + k * 70.0) * s, 0.0, TAU, 48, Color(SPARK, 0.9 * (1.0 - k)), 5.0 * s)
	_finger(at + Vector2(10.0, 12.0 + (1.0 - press) * 46.0) * s, s, press)


func _draw_hold(at: Vector2, radius: float, s: float) -> void:
	var t := fmod(_time, HOLD_PERIOD)
	var fill := clampf((t - 0.3) / HOLD_FILL, 0.0, 1.0)
	var pressed := t > 0.25 and t < 0.3 + HOLD_FILL + 0.2
	draw_arc(at, radius, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.18), 8.0 * s)
	if fill > 0.0:
		draw_arc(at, radius, -PI * 0.5, -PI * 0.5 + TAU * fill, 64, SPARK, 8.0 * s)
	_finger(at + Vector2(10.0, 12.0 + (0.0 if pressed else 36.0)) * s, s, 1.0 if pressed else 0.0)


func _draw_drag(a: Vector2, b: Vector2, s: float) -> void:
	var t := fmod(_time, DRAG_PERIOD) / DRAG_PERIOD
	var mid := (a + b) * 0.5
	var normal := (b - a).orthogonal().normalized()
	if normal.y > 0.0:
		normal = -normal
	var ctrl := mid + normal * maxf(a.distance_to(b) * 0.35, 60.0 * s)
	# Dashed path with arrowhead at the destination.
	var steps := 18
	var phase := int(_time * 6.0) % 2
	for i in steps:
		if (i + phase) % 2 == 1:
			continue
		draw_line(_quad(a, ctrl, b, float(i) / steps), _quad(a, ctrl, b, float(i + 1) / steps), Color(ACCENT, 0.9), 6.0 * s)
	var tip := _quad(a, ctrl, b, 1.0)
	var dir := (tip - _quad(a, ctrl, b, 0.92)).normalized()
	var side := dir.orthogonal()
	draw_colored_polygon(PackedVector2Array([tip + dir * 16.0 * s, tip - dir * 12.0 * s + side * 16.0 * s, tip - dir * 12.0 * s - side * 16.0 * s]), ACCENT)
	draw_arc(a, 54.0 * s, 0.0, TAU, 48, Color(SPARK, 0.7), 4.0 * s)
	draw_arc(b, 54.0 * s, 0.0, TAU, 48, Color(ACCENT, 0.5 + 0.5 * sin(_time * 6.0)), 4.0 * s)
	# Finger: press at A, travel, release at B.
	var travel := clampf((t - 0.15) / 0.6, 0.0, 1.0)
	var eased := travel * travel * (3.0 - 2.0 * travel)
	var pos := _quad(a, ctrl, b, eased)
	var pressed := t > 0.1 and t < 0.82
	_finger(pos + Vector2(10.0, 12.0 + (0.0 if pressed else 30.0)) * s, s, 1.0 if pressed else 0.0)


# --- Coach icon -------------------------------------------------------------

func _draw_icon() -> void:
	var c := size * 0.5
	var s := minf(size.x, size.y) / 150.0
	draw_circle(c, 70.0 * s, Color(ACCENT, 0.18))
	draw_arc(c, 70.0 * s, 0.0, TAU, 48, Color(ACCENT, 0.85), 4.0 * s)
	match gesture:
		Gesture.TAP:
			var press := 0.5 + 0.5 * sin(_time * 5.0)
			draw_arc(c + Vector2(-8.0, -26.0) * s, (12.0 + press * 14.0) * s, 0.0, TAU, 32, Color(SPARK, 1.0 - press * 0.6), 4.0 * s)
			_finger(c + Vector2(0.0, -24.0 + (1.0 - press) * 8.0) * s, s * 0.8, press)
		Gesture.HOLD:
			var fill := fmod(_time, 1.8) / 1.4
			draw_arc(c, 50.0 * s, -PI * 0.5, -PI * 0.5 + TAU * clampf(fill, 0.0, 1.0), 40, SPARK, 6.0 * s)
			_finger(c + Vector2(0.0, -20.0) * s, s * 0.8, 1.0)
		Gesture.DRAG:
			var k := 0.5 - 0.5 * cos(_time * 2.6)
			var from := c + Vector2(-34.0, 6.0) * s
			var to := c + Vector2(34.0, 6.0) * s
			draw_line(from, to, Color(ACCENT, 0.9), 4.0 * s)
			draw_colored_polygon(PackedVector2Array([to + Vector2(12.0, 0.0) * s, to + Vector2(-4.0, -10.0) * s, to + Vector2(-4.0, 10.0) * s]), ACCENT)
			_finger(from.lerp(to, k) + Vector2(0.0, -34.0) * s, s * 0.7, 1.0)
		Gesture.WAIT:
			var a := _time * 2.4
			draw_arc(c, 42.0 * s, 0.0, TAU, 40, Color(1.0, 1.0, 1.0, 0.3), 5.0 * s)
			draw_line(c, c + Vector2(cos(a), sin(a)) * 36.0 * s, SPARK, 6.0 * s)
			draw_circle(c, 7.0 * s, SPARK)
		Gesture.BOOM:
			var pulse := 0.85 + 0.15 * sin(_time * 7.0)
			var points := PackedVector2Array()
			for i in 20:
				var ang := TAU * float(i) / 20.0
				var r := (52.0 if i % 2 == 0 else 26.0) * s * pulse
				points.append(c + Vector2(cos(ang), sin(ang)) * r)
			draw_colored_polygon(points, Color(1.0, 0.5, 0.15, 1.0))
			draw_circle(c, 18.0 * s * pulse, SPARK)


## Pointing finger: `tip` is the fingertip, body extends down-right. `press` 0..1 squashes it.
func _finger(tip: Vector2, s: float, press: float) -> void:
	var squash := 1.0 - press * 0.12
	var shadow := Color(0.0, 0.0, 0.0, 0.25)
	_capsule(tip + Vector2(6.0, 6.0) * s, Vector2(40.0, 112.0 * squash) * s, shadow)
	_capsule(tip + Vector2(28.0, 70.0 * squash) * s, Vector2(92.0, 80.0) * s, shadow)
	_capsule(tip + Vector2(28.0, 70.0 * squash) * s - Vector2(6.0, 6.0) * s, Vector2(92.0, 80.0) * s, SKIN, SKIN_SHADE)
	_capsule(tip, Vector2(40.0, 112.0 * squash) * s, SKIN, SKIN_SHADE)
	_capsule(tip + Vector2(0.0, 6.0) * s, Vector2(24.0, 26.0) * s, NAIL)


## Rounded rect whose top-center is `top`.
func _capsule(top: Vector2, box: Vector2, fill: Color, border: Color = Color(0, 0, 0, 0)) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(int(maxf(2.0, box.x * 0.06)) if border.a > 0.0 else 0)
	style.set_corner_radius_all(int(minf(box.x, box.y) * 0.5))
	style.anti_aliasing = true
	style.draw(get_canvas_item(), Rect2(top - Vector2(box.x * 0.5, 0.0), box))


static func _quad(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	return a.lerp(b, t).lerp(b.lerp(c, t), t)
