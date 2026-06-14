extends Node2D

const MENU_BG_PATH := "res://assets/party_kitchen/background_menu.svg"

@export var game_events: GameEvents
@export var stone_layer: Sprite2D
@export var lava_layer: Sprite2D
@export var mask_layer: Sprite2D

var listener: EventListener = EventListener.new()
var _tween: Tween
var _menu_bg: Sprite2D


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	_setup_menu_background()
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)
	_apply_state(FSMGameStates.READY_TO_START)


func _exit_tree() -> void:
	listener.deinit()
	if _tween:
		_tween.kill()


func _setup_menu_background() -> void:
	var texture := load(MENU_BG_PATH) as Texture2D
	if texture == null:
		return
	_menu_bg = Sprite2D.new()
	_menu_bg.texture = texture
	_menu_bg.z_index = -2
	add_child(_menu_bg)
	move_child(_menu_bg, 0)
	if stone_layer:
		stone_layer.visible = false
	if mask_layer:
		mask_layer.visible = false


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	_apply_state(to_state)


func _on_alert() -> void:
	if lava_layer:
		lava_layer.visible = true
		_pulse_layer(lava_layer, 1.04, Color(1.25, 0.55, 0.35, 0.45))


func _apply_state(state: String) -> void:
	match state:
		FSMGameStates.PLAY:
			if _menu_bg:
				_menu_bg.modulate = Color.WHITE
			if lava_layer:
				lava_layer.visible = false
				lava_layer.modulate = Color(1, 1, 1, 0)
		FSMGameStates.EXPLOSION:
			_shake()
			if lava_layer:
				lava_layer.visible = true
				lava_layer.modulate = Color(1.35, 0.35, 0.2, 0.75)
			if _menu_bg:
				_menu_bg.modulate = Color(1.08, 0.82, 0.72, 1.0)
		FSMGameStates.READY_TO_START, FSMGameStates.PLAYER_CHOICE, FSMGameStates.COUNTDOWN:
			if _menu_bg:
				_menu_bg.modulate = Color.WHITE
				_menu_bg.scale = Vector2.ONE
			if lava_layer:
				lava_layer.visible = false
				lava_layer.modulate = Color(1, 1, 1, 0)
		FSMGameStates.RESULT:
			if _menu_bg:
				_menu_bg.modulate = Color(0.96, 0.94, 0.92, 1.0)


func _pulse_layer(layer: Sprite2D, target_scale: float, target_modulate: Color) -> void:
	if not layer:
		return
	var tween := create_tween().set_parallel(true)
	tween.tween_property(layer, "scale", Vector2.ONE * target_scale, 0.35).set_trans(Tween.TRANS_SINE)
	tween.tween_property(layer, "modulate", target_modulate, 0.35)


func _shake() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	var base_pos := position
	for i in 6:
		var offset := Vector2(randf_range(-12, 12), randf_range(-12, 12))
		_tween.tween_property(self, "position", base_pos + offset, 0.04)
	_tween.tween_property(self, "position", base_pos, 0.06)
