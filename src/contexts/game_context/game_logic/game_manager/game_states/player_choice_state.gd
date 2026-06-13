class_name PlayerChoiceState
extends StateBase

static func get_state() -> String:
	return FSMGameStates.PLAYER_CHOICE


func _init() -> void:
	super()
	state_name = get_state()


func enter(_prev_state: FSMState, _event_data: Dictionary) -> void:
	game_manager.session.reset_round()
