class_name GameManager
extends Node

@export var game_events: GameEvents
@export var states: Array[StateBase]

var fsm: FSM
var session: GameSession = GameSession.new()


func _ready() -> void:
	if states.is_empty():
		for child in get_children():
			if child is StateBase:
				states.append(child)

	for state in states:
		if state.state_name.is_empty():
			state.state_name = state.get_state()
		state.initialize(self)

	fsm = FSM.new({
		"initial": {"state": FSMGameStates.PLAYER_CHOICE},
		"transitions": [
			{
				"src": FSMGameStates.PLAYER_CHOICE,
				"dst": FSMGameStates.READY_TO_START,
				"event": FSMGameEvents.PLAYER_CHOICE_DONE,
			},
			{
				"src": FSMGameStates.READY_TO_START,
				"dst": FSMGameStates.COUNTDOWN,
				"event": FSMGameEvents.START_ROUND,
			},
			{
				"src": FSMGameStates.COUNTDOWN,
				"dst": FSMGameStates.PLAY,
				"event": FSMGameEvents.COUNTDOWN_DONE,
			},
			{
				"src": FSMGameStates.PLAY,
				"dst": FSMGameStates.EXPLOSION,
				"event": FSMGameEvents.EXPLODE,
			},
			{
				"src": FSMGameStates.EXPLOSION,
				"dst": FSMGameStates.READY_TO_START,
				"event": FSMGameEvents.EXPLOSION_DONE,
			},
			{
				"src": FSMGameStates.EXPLOSION,
				"dst": FSMGameStates.RESULT,
				"event": FSMGameEvents.MATCH_END,
			},
		],
		"states": states,
	})
	fsm.ev_state_changed.connect(_on_state_changed)


func _exit_tree() -> void:
	fsm.deinit()


func setup_session(game_config: GameConfig, account: PDataAccount) -> void:
	session.setup(game_config, game_events, account)
	session.next_card()
	session.reset_round()


func _process(delta: float) -> void:
	var state_name := fsm.get_current_state_name()
	match state_name:
		FSMGameStates.PLAYER_CHOICE:
			_process_player_choice(delta)
		FSMGameStates.COUNTDOWN:
			_process_countdown(delta)
		FSMGameStates.PLAY:
			_process_play(delta)
		FSMGameStates.EXPLOSION:
			_process_explosion(delta)


func start_round() -> void:
	session.reset_round()
	fsm.add_event(FSMGameEvents.START_ROUND)


func next_player() -> void:
	session.next_player()


func prev_player() -> bool:
	return session.prev_player()


func _process_player_choice(delta: float) -> void:
	session.advance_time(delta)
	session.set_current_player_index(session.get_player_choice_index())
	if session.state_time > session.game_config.player_choice_time:
		fsm.add_event(FSMGameEvents.PLAYER_CHOICE_DONE)


func _process_countdown(delta: float) -> void:
	session.advance_time(delta)
	session.tick_countdown()
	if session.state_time >= session.game_config.countdown_time:
		session.reset_bomb()
		session.reset_explosion()
		fsm.add_event(FSMGameEvents.COUNTDOWN_DONE)


func _process_play(delta: float) -> void:
	if session.update_bomb(delta):
		fsm.add_event(FSMGameEvents.EXPLODE)


func _process_explosion(delta: float) -> void:
	if session.update_explosion(delta):
		_on_explosion_finished()


func _on_explosion_finished() -> void:
	if session.next_card():
		session.next_player()
		session.reset_round()
		fsm.add_event(FSMGameEvents.EXPLOSION_DONE)
	else:
		fsm.add_event(FSMGameEvents.MATCH_END)


func _on_state_changed(from_state_name: String, to_state_name: String) -> void:
	game_events.ev_game_state_changed.emit(from_state_name, to_state_name)
