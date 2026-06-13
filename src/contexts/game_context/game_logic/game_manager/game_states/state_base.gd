class_name StateBase
extends FSMState

static func get_state() -> String:
	return ""

var game_manager: GameManager
var event_listener: EventListener = EventListener.new()


func _init() -> void:
	super(get_state())


func initialize(p_game_manager: GameManager) -> void:
	game_manager = p_game_manager


func deinit() -> void:
	event_listener.deinit()
	game_manager = null
