class_name PlayState
extends StateBase

static func get_state() -> String:
	return FSMGameStates.PLAY


func _init() -> void:
	super()
	state_name = get_state()
