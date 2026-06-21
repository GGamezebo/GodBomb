class_name EmergencyState
extends StateBase

static func get_state() -> String:
	return FSMGameStates.EMERGENCY


func _init() -> void:
	super()
	state_name = get_state()
