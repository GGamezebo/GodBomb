class_name GameBombBackground
extends Control

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const TINT_TWEEN := 0.35
const NEUTRAL_BG := Color(0.06, 0.05, 0.04, 1.0)

signal layout_applied

@export var game_events: GameEvents
@export var bomb_art: TextureRect
@export var dial_glass: CanvasItem
@export var player_color_bg: ColorRect
@export var fire_sparks: Control
@export var scaled_content: Control
@export var hint_marker: NodePath
@export var pulse_speed: float = 6.0

var listener: EventListener = EventListener.new()
var _tween: Tween
var _tint_tween: Tween
var _alert_active: bool = false
var _content_base_pos: Vector2 = Vector2.ZERO
var _base_tint: Color = NEUTRAL_BG
var _hint_marker_node: Node2D


func _ready() -> void:
	if bomb_art == null:
		bomb_art = get_node_or_null("BombArt") as TextureRect
	if dial_glass == null:
		dial_glass = get_node_or_null("DisplayBomb") as CanvasItem
	if player_color_bg == null:
		player_color_bg = get_node_or_null("PlayerColorBackground") as ColorRect
	if scaled_content == null:
		scaled_content = get_node_or_null("ScaledContent") as Control
	if not hint_marker.is_empty():
		_hint_marker_node = get_node_or_null(hint_marker) as Node2D
	elif scaled_content and scaled_content.has_node("PlayerName"):
		_hint_marker_node = scaled_content.get_node("PlayerName") as Node2D
	if scaled_content:
		_content_base_pos = scaled_content.position
	if player_color_bg:
		player_color_bg.color = NEUTRAL_BG
	resized.connect(_apply_layout)
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)
		listener.add(game_events.ev_current_player_changed, _on_current_player_changed)
	call_deferred("_apply_layout")


func _exit_tree() -> void:
	listener.deinit()
	_kill_tween()
	_kill_tint_tween()


func get_hint_marker_design_position() -> Vector2:
	if _hint_marker_node:
		return _hint_marker_node.position
	if scaled_content and scaled_content.has_node("PlayerName"):
		return (scaled_content.get_node("PlayerName") as Node2D).position
	return Vector2(DESIGN_SIZE.x * 0.5, 483.0)


func get_cover_scale() -> float:
	if size.x <= 0.0 or size.y <= 0.0:
		return 1.0
	return maxf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)


func _apply_layout() -> void:
	if not scaled_content:
		return
	var scale_factor := get_cover_scale()
	var scaled_size := DESIGN_SIZE * scale_factor
	var offset := (size - scaled_size) * 0.5
	scaled_content.scale = Vector2.ONE * scale_factor
	scaled_content.position = offset
	scaled_content.size = DESIGN_SIZE
	if bomb_art:
		bomb_art.scale = Vector2.ONE * scale_factor
		bomb_art.position = offset
		bomb_art.size = DESIGN_SIZE
	_content_base_pos = scaled_content.position
	layout_applied.emit()


func _process(_delta: float) -> void:
	if not _alert_active or player_color_bg == null:
		return
	var pulse := 0.06 * sin(Time.get_ticks_msec() * 0.01 * pulse_speed)
	player_color_bg.color = _base_tint.lightened(pulse)


func _on_current_player_changed(player: GamePlayer) -> void:
	_apply_player_tint(SlimeColors.get_color(player.info.preset_id))


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	_apply_state(to_state)


func _on_alert() -> void:
	_alert_active = true


func _slime_to_background(slime_color: Color) -> Color:
	return slime_color.darkened(0.32)


func _apply_player_tint(slime_color: Color, immediate: bool = false) -> void:
	if not player_color_bg:
		return
	_base_tint = _slime_to_background(slime_color)
	_kill_tint_tween()
	if immediate:
		player_color_bg.color = _base_tint
		return
	_tint_tween = create_tween()
	_tint_tween.tween_property(player_color_bg, "color", _base_tint, TINT_TWEEN).set_trans(Tween.TRANS_SINE)


func _clear_player_tint(immediate: bool = false) -> void:
	_base_tint = NEUTRAL_BG
	_kill_tint_tween()
	if not player_color_bg:
		return
	if immediate:
		player_color_bg.color = _base_tint
		return
	_tint_tween = create_tween()
	_tint_tween.tween_property(player_color_bg, "color", _base_tint, TINT_TWEEN).set_trans(Tween.TRANS_SINE)


func _apply_state(state: String) -> void:
	_set_fire_sparks(state == FSMGameStates.EXPLOSION)
	match state:
		FSMGameStates.READY_TO_START, FSMGameStates.PLAYER_CHOICE, FSMGameStates.COUNTDOWN, FSMGameStates.PLAY, FSMGameStates.EMERGENCY:
			_alert_active = false
			_set_bomb_visible(true)
			_set_bomb_modulate(Color.WHITE)
			if state == FSMGameStates.PLAY:
				_play_comes_flash()
			elif state in [FSMGameStates.READY_TO_START, FSMGameStates.PLAYER_CHOICE, FSMGameStates.COUNTDOWN]:
				_play_ready_pulse()
		FSMGameStates.EXPLOSION:
			_alert_active = false
			_play_explosion()
		FSMGameStates.RESULT:
			_alert_active = false
			_set_bomb_visible(false)
			_set_fire_sparks(false)


func _set_bomb_visible(visible: bool) -> void:
	for part in _bomb_visual_parts():
		part.visible = visible
		if visible:
			part.modulate = Color.WHITE


func _set_bomb_modulate(color: Color) -> void:
	for part in _bomb_visual_parts():
		part.modulate = color


func _bomb_visual_parts() -> Array[CanvasItem]:
	var parts: Array[CanvasItem] = []
	if bomb_art:
		parts.append(bomb_art)
	if dial_glass:
		parts.append(dial_glass)
	return parts


func _play_ready_pulse() -> void:
	var parts := _bomb_visual_parts()
	if parts.is_empty():
		return
	_kill_tween()
	_tween = create_tween()
	for part in parts:
		var track := _tween.parallel()
		track.tween_property(part, "modulate", Color(1.04, 1.02, 0.98, 1.0), 0.35).set_trans(Tween.TRANS_SINE)
		track.tween_property(part, "modulate", Color.WHITE, 0.35).set_trans(Tween.TRANS_SINE)


func _play_comes_flash() -> void:
	var parts := _bomb_visual_parts()
	if parts.is_empty():
		return
	_kill_tween()
	for part in parts:
		part.modulate = Color(1, 1, 1, 0.88)
	_tween = create_tween()
	for part in parts:
		_tween.parallel().tween_property(part, "modulate", Color.WHITE, 0.45).set_trans(Tween.TRANS_SINE)


func _play_explosion() -> void:
	_kill_tween()
	var parts := _visible_bomb_visual_parts()
	if not parts.is_empty():
		var flash_color := Color(1.45, 0.42, 0.12, 1.0)
		var fade := create_tween()
		for part in parts:
			part.modulate = flash_color
			fade.parallel().tween_property(part, "modulate:a", 0.0, 0.14).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		fade.tween_callback(func() -> void:
			for part in parts:
				part.visible = false
		)
	if scaled_content:
		_tween = create_tween()
		var base := _content_base_pos
		for i in 6:
			var shake_offset := Vector2(randf_range(-10, 10), randf_range(-10, 10))
			_tween.tween_property(scaled_content, "position", base + shake_offset, 0.04)
		_tween.tween_property(scaled_content, "position", base, 0.06)


func _visible_bomb_visual_parts() -> Array[CanvasItem]:
	var parts: Array[CanvasItem] = []
	for part in _bomb_visual_parts():
		if part.visible:
			parts.append(part)
	return parts


func _kill_tween() -> void:
	if _tween:
		_tween.kill()
		_tween = null


func _kill_tint_tween() -> void:
	if _tint_tween:
		_tint_tween.kill()
		_tint_tween = null


func _set_fire_sparks(enabled: bool) -> void:
	if not fire_sparks:
		return
	fire_sparks.visible = enabled
	for child in fire_sparks.get_children():
		if child is CPUParticles2D:
			(child as CPUParticles2D).emitting = enabled
