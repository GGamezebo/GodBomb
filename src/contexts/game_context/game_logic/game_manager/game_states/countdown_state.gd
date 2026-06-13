class_name CountdownState
extends StateBase

static func get_state() -> String:
	return FSMGameStates.COUNTDOWN


func _init() -> void:
	super()
	state_name = get_state()


func enter(_prev_state: FSMState, _event_data: Dictionary) -> void:
	game_manager.session.reset_round()
