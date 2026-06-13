extends Node2D

@export var game_events: GameEvents
@export var bomb_sprite: Sprite2D
@export var pulse_speed: float = 6.0

var listener: EventListener = EventListener.new()
var _tween: Tween
var _alert_active: bool = false


func _ready() -> void:
	if not game_events:
		game_events = load("res://src/common/game_events.tres") as GameEvents
	if game_events:
		listener.add(game_events.ev_game_state_changed, _on_game_state_changed)
		listener.add(game_events.ev_alert, _on_alert)
	_play_ready()


func _exit_tree() -> void:
	listener.deinit()
	if _tween:
		_tween.kill()


func _process(delta: float) -> void:
	if _alert_active and bomb_sprite:
		var pulse := 0.08 * sin(Time.get_ticks_msec() * 0.01 * pulse_speed)
		bomb_sprite.scale = Vector2.ONE * (0.55 + pulse)
		bomb_sprite.modulate = Color(1.0, 0.55 + pulse, 0.45, 1.0)


func _on_game_state_changed(_from_state: String, to_state: String) -> void:
	match to_state:
		FSMGameStates.READY_TO_START:
			_alert_active = false
			_play_ready()
		FSMGameStates.PLAY:
			_alert_active = false
			_play_comes()
		FSMGameStates.EXPLOSION:
			_alert_active = false
			_play_boom()
		FSMGameStates.COUNTDOWN, FSMGameStates.PLAYER_CHOICE:
			_alert_active = false
			if bomb_sprite:
				bomb_sprite.modulate = Color.WHITE


func _on_alert() -> void:
	_alert_active = true


func _play_ready() -> void:
	if not bomb_sprite:
		return
	_kill_tween()
	bomb_sprite.visible = true
	bomb_sprite.modulate = Color.WHITE
	bomb_sprite.scale = Vector2.ONE * 0.5
	_tween = create_tween()
	_tween.tween_property(bomb_sprite, "scale", Vector2.ONE * 0.52, 0.35).set_trans(Tween.TRANS_SINE)


func _play_comes() -> void:
	if not bomb_sprite:
		return
	_kill_tween()
	bomb_sprite.visible = true
	bomb_sprite.scale = Vector2.ONE * 0.2
	bomb_sprite.modulate = Color(1, 1, 1, 0.2)
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(bomb_sprite, "scale", Vector2.ONE * 0.55, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(bomb_sprite, "modulate:a", 1.0, 0.35)


func _play_boom() -> void:
	if not bomb_sprite:
		return
	_kill_tween()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(bomb_sprite, "scale", Vector2.ONE * 0.9, 0.18).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_tween.tween_property(bomb_sprite, "modulate", Color(1.5, 0.35, 0.1, 1.0), 0.12)
	_tween.chain().tween_property(bomb_sprite, "modulate:a", 0.0, 0.25)
	_tween.parallel().tween_property(bomb_sprite, "scale", Vector2.ONE * 1.2, 0.25)


func _kill_tween() -> void:
	if _tween:
		_tween.kill()
		_tween = null
