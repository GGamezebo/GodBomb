class_name UiSounds
extends RefCounted

const SFX_BUS := &"SFX"

const STREAMS: Dictionary = {
	&"click": preload("res://assets/audio/ui/ui_click.wav"),
	&"confirm": preload("res://assets/audio/ui/ui_confirm.wav"),
	&"toggle": preload("res://assets/audio/ui/ui_toggle.wav"),
	&"slider_tick": preload("res://assets/audio/ui/ui_slider_tick.wav"),
	&"modal_open": preload("res://assets/audio/ui/ui_modal_open.wav"),
	&"modal_close": preload("res://assets/audio/ui/ui_modal_close.wav"),
	&"lobby_add": preload("res://assets/audio/ui/lobby_player_add.wav"),
	&"lobby_remove": preload("res://assets/audio/ui/lobby_player_remove.wav"),
	&"lobby_swap": preload("res://assets/audio/ui/lobby_player_swap.wav"),
}


static func play(
	sound_id: StringName,
	pitch_scale: float = 1.0,
	volume_db: float = 0.0
) -> void:
	var stream: AudioStream = STREAMS.get(sound_id)
	if stream == null:
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var player := AudioStreamPlayer.new()
	player.bus = SFX_BUS
	player.pitch_scale = pitch_scale
	player.volume_db = volume_db
	player.stream = stream
	tree.root.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


static func play_click() -> void:
	play(&"click")


static func play_confirm() -> void:
	play(&"confirm")


static func play_toggle() -> void:
	play(&"toggle")


static func play_slider_tick() -> void:
	play(&"slider_tick", 1.0, -2.0)


static func play_modal_open() -> void:
	play(&"modal_open", 1.0, -1.0)


static func play_modal_close() -> void:
	play(&"modal_close", 1.0, -1.0)


static func play_lobby_add() -> void:
	play(&"lobby_add", 1.0, 1.0)


static func play_lobby_remove() -> void:
	play(&"lobby_remove", 1.0, 0.0)


static func play_lobby_swap() -> void:
	play(&"lobby_swap", 1.0, 0.0)


static func bind_button(button: BaseButton, sound_id: StringName = &"click") -> void:
	if button == null:
		return
	button.pressed.connect(func() -> void:
		play(sound_id)
	)


static func bind_slider(slider: Range, step_threshold: float = 0.5) -> void:
	if slider == null:
		return
	var state := {"last": slider.value}
	slider.value_changed.connect(func(value: float) -> void:
		if absf(value - float(state.last)) >= step_threshold:
			state.last = value
			play_slider_tick()
	)


static func bind_checkbox(check: CheckBox) -> void:
	if check == null:
		return
	check.toggled.connect(func(_enabled: bool) -> void:
		play_toggle()
	)
