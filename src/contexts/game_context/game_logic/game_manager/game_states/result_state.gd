class_name ResultState
extends StateBase

static func get_state() -> String:
	return FSMGameStates.RESULT


func _init() -> void:
	super()
	state_name = get_state()
