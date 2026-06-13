class_name ReadyToStartState
extends StateBase

static func get_state() -> String:
	return FSMGameStates.READY_TO_START


func _init() -> void:
	super()
	state_name = get_state()
