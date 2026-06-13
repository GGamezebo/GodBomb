extends Node2D

@export var game_events: GameEvents
@export var stone_layer: Sprite2D
@export var lava_layer: Sprite2D
@export var mask_layer: Sprite2D

var listener: EventListener = EventListener.new()
var _tween: Tween


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)
	_apply_state(FSMGameStates.READY_TO_START)


func _exit_tree() -> void:
	listener.deinit()
	if _tween:
		_tween.kill()


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	_apply_state(to_state)


func _on_alert() -> void:
	if lava_layer:
		_pulse_layer(lava_layer, 1.03, Color(1.2, 0.7, 0.5, 1.0))


func _apply_state(state: String) -> void:
	match state:
		FSMGameStates.PLAY:
			_pulse_layer(stone_layer, 1.03, Color(0.95, 0.95, 1.0, 1.0))
			_pulse_layer(lava_layer, 1.05, Color(1.1, 0.85, 0.7, 1.0))
		FSMGameStates.EXPLOSION:
			_shake()
			if lava_layer:
				lava_layer.modulate = Color(1.4, 0.45, 0.25, 1.0)
		FSMGameStates.READY_TO_START, FSMGameStates.PLAYER_CHOICE:
			if stone_layer:
				stone_layer.modulate = Color.WHITE
				stone_layer.scale = Vector2.ONE
			if lava_layer:
				lava_layer.modulate = Color(1.0, 0.9, 0.8, 1.0)
				lava_layer.scale = Vector2.ONE


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
